import 'package:surf_mobile/models/user_profile.dart';

import 'school_model.dart';
import 'skill_level_model.dart';

class AuthSession {
  final UserAccount user;
  final School? school;
  final dynamic profile;

  AuthSession({
    required this.user,
    this.school,
    this.profile,
  });

  AuthSession copyWith({
    UserAccount? user,
    School? school,
    dynamic profile,
  }) {
    return AuthSession(
      user: user ?? this.user,
      school: school ?? this.school,
      profile: profile ?? this.profile,
    );
  }

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      user: UserAccount.fromJson(json['user']),
      school: json['school'] != null ? School.fromJson(json['school']) : null,
      // profile: json['profile'] != null
      //     ? UserProfile.fromJson(json['profile'])
      //     : null,
      profile: _parseProfile(
        json['profile'],
        json['user']['role'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'school': school?.toJson(),
      'profile': profile?.toJson(),
    };
  }
}

class Profile {
  final int? id;
  final String name;
  final String? photoUrl;
  final SkillLevel? skillLevel;

  Profile({
    this.id,
    required this.name,
    this.photoUrl,
    this.skillLevel,
  });

  Profile copyWith({
    int? id,
    String? name,
    String? photoUrl,
    SkillLevel? skillLevel,
  }) {
    return Profile(
      id: id ?? this.id,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      skillLevel: skillLevel ?? this.skillLevel,
    );
  }

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] ?? 0,
      name: json['name'],
      photoUrl: json['photo_url'],
      skillLevel: json['skill_level'] != null
          ? SkillLevel.fromJson(json['skill_level'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'photo_url': photoUrl,
      'skill_level': skillLevel?.toJson(),
    };
  }
}

dynamic _parseProfile(
  Map<String, dynamic>? json,
  String role,
) {
  if (json == null) return null;

  switch (role) {
    case 'student':
      return StudentProfile.fromJson(json);

    case 'teacher':
      return TeacherProfile.fromJson(json);

    case 'admin':
    case 'super_admin':
      return null;

    default:
      return null;
  }
}
