import 'package:flutter/foundation.dart';
import 'package:surf_mobile/models/user_profile.dart';
import 'package:surf_mobile/services/api_service.dart';
import 'package:surf_mobile/services/auth_service.dart';

class UserProvider extends ChangeNotifier {
  ApiService? _apiService;
  AuthService? _authService;

  UserProfile? _profile;
  bool _isLoading = false;
  bool _hasAttemptedLoad = false;
  String? _loadError;
  String? _updateError;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get loadError => _loadError;
  String? get updateError => _updateError;
  bool get isStudent => _profile?.user.userType == 'student';
  int? get studentId => _profile?.student?.id;
  int? get schoolId => _profile?.student?.schoolId;
  String? get studentSkillSlug => _profile?.student?.skillLevel?.slug;

  void updateDependencies(AuthService auth, ApiService api) {
    _authService = auth;
    _apiService = api;

    final bool isLoggedOut =
        auth.cachedToken == null && auth.currentUser == null;
    if (isLoggedOut) {
      _profile = null;
      _loadError = null;
      _updateError = null;
      _isLoading = false;
      _hasAttemptedLoad = false;
      notifyListeners();
      return;
    }

    // If we have not loaded the profile yet and have an auth token, trigger load.
    if (!_hasAttemptedLoad && !_isLoading && auth.cachedToken != null) {
      ensureProfileLoaded();
    }
  }

  Future<void> ensureProfileLoaded() async {
    if (_apiService == null || _isLoading) return;
    _isLoading = true;
    _loadError = null;
    notifyListeners();

    try {
      final profile = await _apiService!.getCurrentUserProfile();
      _profile = profile;
    } catch (e) {
      _loadError = 'Não foi possível carregar seu perfil. $e';
    } finally {
      _isLoading = false;
      _hasAttemptedLoad = true;
      notifyListeners();
    }
  }

  bool get requiresSchoolSelection {
    if (_profile == null) return false;
    if (_profile!.user.userType != 'student') return false;
    final student = _profile!.student;
    if (student == null) return true;
    return student.schoolId <= 0;
  }

  Future<bool> assignSchool(int schoolId) async {
    if (schoolId <= 0) {
      _updateError = 'Escolha uma escola válida.';
      notifyListeners();
      return false;
    }
    final api = _apiService;
    final profile = _profile;
    if (api == null || profile == null) {
      _updateError = 'Não foi possível atualizar seu perfil agora.';
      notifyListeners();
      return false;
    }

    _updateError = null;
    notifyListeners();

    try {
      StudentProfile? student = profile.student;
      if (student == null) {
        final authUser = _authService?.currentUser;
        final displayName = authUser?.displayName?.trim();
        final resolvedName = (displayName != null && displayName.isNotEmpty)
            ? displayName
            : _deriveNameFromEmail(authUser?.email ?? profile.user.email);
        final phone = authUser?.phoneNumber?.trim();
        student = await api.createStudentProfile(
          schoolId: schoolId,
          name: resolvedName,
          userId: profile.user.id,
          phone: phone,
        );
      } else if (student.schoolId != schoolId) {
        student = await api.updateStudentSchool(
          student: student,
          schoolId: schoolId,
        );
      }

      _profile = profile.copyWith(student: student);
      notifyListeners();
      return true;
    } catch (e) {
      _updateError = 'Erro ao atualizar escola: $e';
      notifyListeners();
      return false;
    }
  }

  String _deriveNameFromEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Aluno';
    }
    final localPart = email.split('@').first;
    if (localPart.isEmpty) return 'Aluno';
    return localPart[0].toUpperCase() + localPart.substring(1);
  }

  void markNeedsReload() {
    _hasAttemptedLoad = false;
  }
}
