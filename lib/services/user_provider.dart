import 'package:flutter/foundation.dart';
import 'package:surf_mobile/models/auth_session_model.dart';
import 'package:surf_mobile/models/school_model.dart';
import 'package:surf_mobile/models/user_profile.dart';
//import 'package:surf_mobile/models/user_profile.dart';
import 'package:surf_mobile/services/api_service.dart';
import 'package:surf_mobile/services/auth_service.dart';

class UserProvider extends ChangeNotifier {
  ApiService? _apiService;
  AuthService? _authService;

  AuthSession? _session;
  bool _isLoading = false;
  // bool _hasAttemptedLoad = false;
  String? _loadError;
  String? _updateError;

  dynamic get user => _session?.user;
  dynamic get profile => _session?.profile;
  bool get isLoading => _isLoading;
  String? get loadError => _loadError;
  String? get updateError => _updateError;
  bool get isAdmin => _session?.user.role == 'admin';
  bool get isStudent =>
      _session?.user.role == 'student' && _session?.profile is StudentProfile;
  bool get isTeacher =>
      _session?.user.role == 'teacher' && _session?.profile is TeacherProfile;
  int? get studentId => _session?.user.role == 'student' ? profile?.id : null;
  StudentProfile? get studentProfile => isStudent ? _session?.profile : null;
  TeacherProfile? get teacherProfile =>
      isTeacher ? _session?.profile as TeacherProfile? : null;

  School? get school => _session?.school;
  int? get schoolId {
    if (studentProfile != null) return studentProfile!.schoolId;
    if (teacherProfile != null) return teacherProfile!.schoolId;
    if (isAdmin) return _session?.school?.id;
    return null;
  }

  String? get userEmail => _session?.user.email;

  String? get studentSkillSlug => _session?.profile?.skillLevel?.slug;

  void updateDependencies(AuthService auth, ApiService api) {
    // final hadNoSession = _authService?.session == null;
    // final hasSessionNow = auth.session != null;

    final previousSession = _authService?.session;
    _authService = auth;

    //  _authService = auth;
    _apiService = api;

    if (previousSession == null && auth.session != null) {
      debugPrint('🔥 Sessão apareceu → carregando profile');
      // _hasAttemptedLoad = false;
      ensureProfileLoaded();
    }

    final bool isLoggedOut =
        auth.cachedToken == null && auth.currentUser == null;

    if (isLoggedOut) {
      api.setAuthToken(null); // ✅ só limpa no logout
      _session = null;
      _loadError = null;
      _updateError = null;
      _isLoading = false;
      //  _hasAttemptedLoad = false;
      notifyListeners();
      return;
    }

    // ✅ injeta token corretamente
    if (auth.cachedToken != null) {
      api.setAuthToken(auth.cachedToken);
    }

    // if (!_hasAttemptedLoad && !_isLoading) {
    //   ensureProfileLoaded();
    // }
  }

  Future<void> ensureProfileLoaded() async {
    // if (_apiService == null || _isLoading) return;

    // // if (_isLoading) {
    // //   debugPrint('⏭️ ensureProfileLoaded ignorado (já carregando)');
    // //   return;
    // // }

    // if (_isLoading || _hasAttemptedLoad) {
    //   debugPrint('⏭️ profile já tentado, ignorando');
    //   return;
    // }

    // if (_authService?.cachedToken == null) {
    //   _loadError = 'Sessão inválida. Faça login novamente.';
    //   notifyListeners();
    //   return;
    // }

    // if (_session != null) {
    //   debugPrint('⏭️ session já carregado');
    //   return;
    // }

    // final session = _authService?.session;
    // if (session == null) {
    //   //debugPrint('❌ session é null em ensureProfileLoaded');
    //   debugPrint('⏳ aguardando sessão...');
    //   return;
    // }

    // debugPrint('🚀 Buscando profile via API...');

    // print('👤 ensureProfileLoaded called | '
    //     'token=${_authService?.cachedToken != null} | '
    //     'session=${_authService?.session != null}');

    // try {
    //   _isLoading = true;
    //   _loadError = null;
    //   notifyListeners();
    //   final profile =
    //       await _apiService?.getCurrentUserProfile(session.user.role);
    //   debugPrint('✅ Profile carregado: ${profile?.toJson()}');

    //   // 🚨 REGRA: mobile só aceita STUDENT
    //   // final isStudent = session.user.role == 'student' && student != null;

    //   // if (!isStudent) {
    //   //   debugPrint('🚫 Usuário não é student → forçando logout');

    //   //   await _authService?.forceLogout();

    //   //   _session = null;
    //   //   _hasAttemptedLoad = false;
    //   //   _isLoading = false;

    //   //   notifyListeners();
    //   //   return;
    //   // }

    //   // debugPrint('🚀 profile via API:  ${student.toJson()}');
    //   // _session = session.copyWith(
    //   //   profile: student,
    //   // );
    //   _session = session.copyWith(
    //     profile: profile,
    //   );
    // } catch (e) {
    //   _loadError = 'Não foi possível carregar seu perfil. $e';
    // } finally {
    //   _isLoading = false;
    //   _hasAttemptedLoad = true;
    //   notifyListeners();
    // }
    if (_session != null) return;

    final session = _authService?.session;
    if (session == null) return;

    _session = session;
    notifyListeners();
  }

  bool get requiresSchoolSelection {
    if (_session == null) return false;
    if (_session!.user.role != 'student') return false;

    final profile = _session!.profile;
    if (profile == null) return true;

    return schoolId == null || schoolId! <= 0;
  }

  // Future<bool> assignSchool(int schoolId) async {
  //   if (schoolId <= 0) {
  //     _updateError = 'Escolha uma escola válida.';
  //     notifyListeners();
  //     return false;
  //   }
  //   final api = _apiService;
  //   final profile = _session?.profile;
  //   if (api == null || profile == null) {
  //     _updateError = 'Não foi possível atualizar seu perfil agora.';
  //     notifyListeners();
  //     return false;
  //   }

  //   _updateError = null;
  //   notifyListeners();

  //   try {
  //     Profile? student = _session?.profile;
  //     if (student == null) {
  //       final authUser = _authService?.currentUser;
  //       final displayName = authUser?.displayName?.trim();
  //       final resolvedName = (displayName != null && displayName.isNotEmpty)
  //           ? displayName
  //           : _deriveNameFromEmail(authUser?.email ?? _session?.user.email);
  //       final phone = authUser?.phoneNumber?.trim();
  //       student = await api.createStudentProfile(
  //         schoolId: schoolId,
  //         name: resolvedName,
  //         userId: profile.user.id,
  //         phone: phone,
  //       );
  //     } else if (student.schoolId != schoolId) {
  //       student = await api.updateStudentSchool(
  //         student: student,
  //         schoolId: schoolId,
  //       );
  //     }

  //     _profile = profile.copyWith(student: student);
  //     notifyListeners();
  //     return true;
  //   } catch (e) {
  //     _updateError = 'Erro ao atualizar escola: $e';
  //     notifyListeners();
  //     return false;
  //   }
  // }

  Future<bool> assignSchool(int schoolId) async {
    if (schoolId <= 0) {
      _updateError = 'Escolha uma escola válida.';
      notifyListeners();
      return false;
    }

    final api = _apiService;
    final session = _session;

    if (api == null || session == null) {
      _updateError = 'Sessão inválida.';
      notifyListeners();
      return false;
    }

    _updateError = null;
    notifyListeners();

    try {
      // 🔥 Backend cuida de criar/atualizar student internamente
      await api.createStudentProfile(
        schoolId: schoolId,
        name: session.profile?.name ?? 'Aluno',
        userId: session.user.id,
      );

      // 🔄 Buscar escola atualizada
      final school = await api.getSchoolById(schoolId);

      // ✅ Atualiza SOMENTE a session
      _session = session.copyWith(
        school: school,
      );

      notifyListeners();
      return true;
    } catch (e) {
      _updateError = 'Erro ao vincular escola: $e';
      notifyListeners();
      return false;
    }
  }

  // String _deriveNameFromEmail(String? email) {
  //   if (email == null || email.isEmpty) {
  //     return 'Aluno';
  //   }
  //   final localPart = email.split('@').first;
  //   if (localPart.isEmpty) return 'Aluno';
  //   return localPart[0].toUpperCase() + localPart.substring(1);
  // }

  void markNeedsReload() {
    // _hasAttemptedLoad = false;
  }
}
