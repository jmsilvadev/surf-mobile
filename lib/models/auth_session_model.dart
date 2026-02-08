import 'package:surf_mobile/models/user_profile.dart';

import 'school_model.dart';
import 'skill_level_model.dart';

class AuthSession {
  final UserAccount user;
  final School? school;
  final StudentProfile? profile;

  AuthSession({
    required this.user,
    this.school,
    this.profile,
  });

  AuthSession copyWith({
    UserAccount? user,
    School? school,
    StudentProfile? profile,
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
      profile: json['profile'] != null
          ? StudentProfile.fromJson(json['profile'])
          : null,
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
