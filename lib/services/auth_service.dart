import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' show min;
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:surf_mobile/config/app_config.dart';
import 'package:surf_mobile/screens/registration_screen.dart';
import 'package:surf_mobile/services/navigation_service.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: AppConfig.googleServerClientId,
  );

  User? _currentUser;
  bool _isLoading = true;
  String? _token;
  String? _googleIdToken;
  bool _pendingRegistration = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  AuthService() {
    _initAuth();
  }

  Future<void> _initAuth() async {
    // Listen to auth state changes and token changes to keep stored token in sync.
    _auth.authStateChanges().listen((User? user) async {
      _currentUser = user;
      _isLoading = false;
      if (user != null) {
        // Load server JWT from preferences if present. Do NOT treat Firebase id_token
        // as the server JWT here to avoid sending Google id_tokens to protected endpoints.
        final prefs = await SharedPreferences.getInstance();
        final stored = prefs.getString('auth_token');
        _token = stored;
      } else {
        _token = null;
        await _clearToken();
      }
      notifyListeners();
    });

    // Also listen to id token refreshes. Do not overwrite server JWT with Firebase id tokens.
    _auth.idTokenChanges().listen((User? user) async {
      // Keep current server token in place; notify listeners so UI can react to auth state.
      notifyListeners();
    });
  }

  String? get cachedToken => _token;
  bool get pendingRegistration => _pendingRegistration;

  Future<String?> getIdToken({bool force = false}) async {
    // Return cached server JWT if available and not forced
    if (!force && _token != null) {
      if (kDebugMode) print('[AuthService] Returning cached server JWT');
      return _token;
    }

    // Try to load from prefs
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('auth_token');
    if (!force && stored != null) {
      if (kDebugMode) print('[AuthService] Loaded server JWT from SharedPreferences');
      _token = stored;
      return stored;
    }

    // If user is not signed in, return stored or null
    if (_currentUser == null) {
      if (kDebugMode) print('[AuthService] No current Firebase user; cannot refresh JWT');
      _token = stored;
      return _token;
    }

    // We need to exchange Google id_token with backend to obtain server JWT.
    // Try to use cached google id token, otherwise try silent sign-in to refresh it.
    String? gid = _googleIdToken;
    if (gid == null) {
      try {
        if (kDebugMode) print('[AuthService] No cached Google id_token; attempting silent sign-in');
        final googleUser = await _googleSignIn.signInSilently();
        if (googleUser != null) {
          final googleAuth = await googleUser.authentication;
          gid = googleAuth.idToken;
          _googleIdToken = gid;
          if (kDebugMode && gid != null) _logJwtDebug('Silent sign-in id_token', gid);
        }
      } catch (_) {
        // ignore
      }
    }

    if (gid == null) {
      // fallback: try Firebase id token (might be acceptable for some backends)
      try {
        if (kDebugMode) print('[AuthService] Falling back to Firebase id_token for exchange');
        final firebaseToken = await _currentUser!.getIdToken(force);
        gid = firebaseToken;
        if (kDebugMode && gid != null) _logJwtDebug('Firebase fallback id_token', gid);
      } catch (_) {
        gid = null;
      }
    }

    if (gid == null) return null;

    try {
      final dio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));
      if (kDebugMode) _logJwtDebug('Exchanging id_token', gid);
      final resp = await dio.post('/api/auth/google', data: {'id_token': gid});
      String? jwt;
      if (resp.data is String) jwt = resp.data as String;
      else if (resp.data is Map) {
        final map = resp.data as Map;
        jwt = map['token'] ?? map['access_token'] ?? map['jwt'] ?? map['token']?.toString();
      }
      if (jwt == null) throw Exception('Invalid auth response: ${resp.data}');
      _token = jwt;
      await _saveToken(jwt);
      return jwt;
    } on DioException catch (e) {
      if (kDebugMode) print('Error exchanging Google id_token: ${e.response?.statusCode} ${e.response?.data}');
      return null;
    } catch (e) {
      if (kDebugMode) print('Error exchanging Google id_token: $e');
      return null;
    }
  }

  Future<String?> _fetchFreshGoogleIdToken() async {
    try {
      if (kDebugMode) print('[AuthService] Attempting to fetch fresh Google id_token');
      // Prefer GoogleSignIn id_token (OAuth2 id token) which backends commonly verify.
      try {
        final account = await _googleSignIn.signInSilently();
        if (kDebugMode) {
          if (account != null) {
            print('[AuthService] Silent Google sign-in succeeded for ${account.email}');
          } else {
            print('[AuthService] Silent Google sign-in returned null account');
          }
        }
        final auth = await account?.authentication;
        final id = auth?.idToken;
        if (id != null && id.isNotEmpty) {
          if (kDebugMode) _logJwtDebug('Fresh id_token from GoogleSignIn', id);
          return id;
        }
      } catch (_) {}

      // Fallback to Firebase id token if GoogleSignIn token unavailable.
      final user = _auth.currentUser;
      if (user != null) {
        try {
          final token = await user.getIdToken(true);
          if (token != null && token.isNotEmpty) {
            if (kDebugMode) _logJwtDebug('Fresh id_token from Firebase', token);
            return token;
          }
        } catch (_) {}
      } else {
        if (kDebugMode) print('[AuthService] No Firebase user when fetching fresh id_token');
      }

      return null;
    } catch (e) {
      if (kDebugMode) print('Error fetching fresh Google id_token: $e');
      return null;
    }
  }

  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _currentUser = credential.user;
      notifyListeners();
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserCredential?> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _currentUser = credential.user;
      notifyListeners();
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kDebugMode) print('[AuthService] Starting Google sign-in flow');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        if (kDebugMode) print('[AuthService] Google sign-in aborted by user');
        return null;
      }

      if (kDebugMode) {
        print('[AuthService] Google account obtained: ${googleUser.email}');
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      if (kDebugMode) {
        print('[AuthService] Received Google auth tokens');
        _logJwtDebug('Google id_token after signIn()', googleAuth.idToken ?? '');
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      // store google id token for later exchanges
      _googleIdToken = googleAuth.idToken;

      // Sign in to Firebase first
      final userCredential = await _auth.signInWithCredential(credential);
      if (kDebugMode) {
        print(
            '[AuthService] Firebase sign-in complete for uid=${userCredential.user?.uid}');
      }

      // Exchange using the freshest id_token we can obtain
      final freshId = await _fetchFreshGoogleIdToken() ?? _googleIdToken;
      if (freshId == null) {
        if (kDebugMode) print('No Google id_token available for backend exchange');
        _currentUser = userCredential.user;
        notifyListeners();
        return userCredential;
      }

      try {
        final dio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));
        if (kDebugMode) _logJwtDebug('Exchanging Google id_token with backend (prefix)', freshId);
        final resp = await dio.post('/api/auth/google', data: {'id_token': freshId});
        if (kDebugMode) print('Auth exchange response: ${resp.statusCode} ${resp.data}');
        String? jwt;
        if (resp.data is String) jwt = resp.data as String;
        else if (resp.data is Map) {
          final map = resp.data as Map;
          jwt = map['token'] ?? map['access_token'] ?? map['jwt'] ?? map['token']?.toString();
        }
        if (jwt != null) {
          _token = jwt;
          _pendingRegistration = false;
          _googleIdToken = null;
          await _saveToken(jwt);
          _currentUser = userCredential.user;
          notifyListeners();
          return userCredential;
        } else {
          if (kDebugMode) print('No JWT found in auth exchange response');
        }
      } on DioException catch (e) {
        final status = e.response?.statusCode;
        final data = e.response?.data;
        if (kDebugMode) print('Error exchanging Google id_token: $status $data');
        if (status == 400 && data is Map && (data['message'] == 'school_id is required for new user registration' || data['error'] == 'school_id_required')) {
          // backend requires registration
          _pendingRegistration = true;
          _googleIdToken = freshId;
          // keep the firebase/google session out of main area until registration completes
          _currentUser = null;
          notifyListeners();
          try {
            navigateToRegistration();
          } catch (_) {}
          return null;
        }
      } catch (e) {
        if (kDebugMode) print('Error exchanging Google id_token: $e');
      }

      // If we reach here exchange didn't succeed but wasn't an explicit registration requirement
      _currentUser = userCredential.user;
      notifyListeners();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) print('[AuthService] FirebaseAuthException during Google sign-in: ${e.code} ${e.message}');
      throw _handleAuthException(e);
    } catch (e, s) {
      if (kDebugMode) {
        print('[AuthService] Unexpected error during Google sign-in: $e');
        print(s);
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    _currentUser = null;
    _token = null;
    await _clearToken();
    notifyListeners();
  }

  Future<void> _saveToken(String? token) async {
    final prefs = await SharedPreferences.getInstance();
    if (token == null) {
      await prefs.remove('auth_token');
    } else {
      await prefs.setString('auth_token', token);
    }
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  /// Complete registration when backend requires additional fields (eg. school_id).
  /// Sends stored `googleIdToken` plus `school_id` to `/api/auth/google` and
  /// saves returned JWT on success.
  Future<bool> completeRegistration({required int schoolId, required String taxNumber}) async {
    if (_googleIdToken == null) return false;
    try {
      final dio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));
      if (kDebugMode) _logJwtDebug('Completing registration with id_token', _googleIdToken!);
      final resp = await dio.post('/api/auth/google', data: {
        'id_token': _googleIdToken,
        'school_id': schoolId,
        'tax_number': taxNumber,
      });
      if (kDebugMode) print('Complete registration response: ${resp.statusCode} ${resp.data}');
      String? jwt;
      if (resp.data is String) jwt = resp.data as String;
      else if (resp.data is Map) {
        final map = resp.data as Map;
        jwt = map['token'] ?? map['access_token'] ?? map['jwt'] ?? map['token']?.toString();
      }
      if (jwt == null) return false;
      _token = jwt;
      _pendingRegistration = false;
      await _saveToken(jwt);
      notifyListeners();
      return true;
    } on DioException catch (e) {
      if (kDebugMode) print('Complete registration failed: ${e.response?.statusCode} ${e.response?.data}');
      return false;
    } catch (e) {
      if (kDebugMode) print('Complete registration failed: $e');
      return false;
    }
  }

  String _safePrefix(String? s, [int len = 20]) {
    if (s == null) return '';
    return s.substring(0, min(len, s.length));
  }

  void _logJwtDebug(String label, String token) {
    try {
      final parts = token.split('.');
      String header = '';
      String payload = '';
      if (parts.length >= 2) {
        header = utf8.decode(base64Url.decode(base64Url.normalize(parts[0])));
        payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      }
      if (kDebugMode) {
        print('$label prefix: ${_safePrefix(token)}');
        print('$label header: $header');
        print('$label payload: $payload');
      }
    } catch (e) {
      if (kDebugMode) print('Failed to decode JWT for debug: $e');
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }
}
