import 'package:flutter/foundation.dart';
import 'package:surf_mobile/models/school_model.dart';
import 'package:surf_mobile/models/skill_level_model.dart';

class UserAccount {
  final String id;
  final String email;
  final String userType;
  final bool active;

  const UserAccount({
    required this.id,
    required this.email,
    required this.userType,
    required this.active,
  });

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    return UserAccount(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      userType: json['user_type']?.toString() ?? '',
      active: json['active'] is bool
          ? json['active'] as bool
          : json['active'].toString().toLowerCase() == 'true',
    );
  }
}

class StudentProfile {
  final int id;
  final int schoolId;
  final School school;
  final String name;
  final String taxNumber;
  final String? phone;
  final DateTime? birthDate;
  final String? photoUrl;
  final String userId;
  final bool active;
  final SkillLevel? skillLevel;

  const StudentProfile({
    required this.id,
    required this.schoolId,
    required this.school,
    required this.name,
    required this.taxNumber,
    required this.userId,
    required this.active,
    this.phone,
    this.birthDate,
    this.photoUrl,
    this.skillLevel,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    final birth = json['birth_date'];
    if (birth is String && birth.isNotEmpty) {
      try {
        parsedDate = DateTime.parse(birth);
      } catch (_) {
        if (kDebugMode) {
          print('Failed to parse birth_date: $birth');
        }
      }
    }

    return StudentProfile(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      schoolId: json['school_id'] is int
          ? json['school_id'] as int
          : int.tryParse(json['school_id']?.toString() ?? '0') ?? 0,
      school: json['school'] is Map<String, dynamic>
          ? School.fromJson(json['school'] as Map<String, dynamic>)
          : School(
              name: '',
              taxNumber: '',
              address: '',
              phone: '',
              email: '',
              nis: ''),
      name: json['name']?.toString() ?? '',
      taxNumber: json['tax_number']?.toString() ?? '',
      phone: json['phone']?.toString(),
      birthDate: parsedDate,
      photoUrl: json['photo_url']?.toString(),
      userId: json['user_id']?.toString() ?? '',
      active: json['active'] is bool
          ? json['active'] as bool
          : json['active'].toString().toLowerCase() == 'true',
      skillLevel: json['skill_level'] != null
          ? SkillLevel.fromJson(json['skill_level'])
          : null,
    );
  }

  StudentProfile copyWith({
    int? schoolId,
    School? school,
    String? name,
    String? taxNumber,
    String? phone,
    DateTime? birthDate,
    String? photoUrl,
    bool? active,
    SkillLevel? skillLevel,
  }) {
    return StudentProfile(
      id: id,
      schoolId: schoolId ?? this.schoolId,
      school: school ?? this.school,
      name: name ?? this.name,
      taxNumber: taxNumber ?? this.taxNumber,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
      photoUrl: photoUrl ?? this.photoUrl,
      userId: userId,
      active: active ?? this.active,
      skillLevel: skillLevel ?? this.skillLevel,
    );
  }

  Map<String, dynamic> toUpdatePayload({int? overrideSchoolId}) {
    return {
      'school_id': overrideSchoolId ?? schoolId,
      'name': name,
      'tax_number': taxNumber,
      'phone': phone,
      'birth_date': birthDate?.toIso8601String(),
      'photo_url': photoUrl,
      'active': active,
    };
  }
}

class TeacherProfile {
  final int id;
  final int schoolId;
  final String name;
  final String taxNumber;
  final String? nif;
  final String? nis;
  final String? phone;
  final String? specialty;
  final String userId;
  final bool active;

  const TeacherProfile({
    required this.id,
    required this.schoolId,
    required this.name,
    required this.taxNumber,
    required this.userId,
    required this.active,
    this.nif,
    this.nis,
    this.phone,
    this.specialty,
  });

  factory TeacherProfile.fromJson(Map<String, dynamic> json) {
    return TeacherProfile(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      schoolId: json['school_id'] is int
          ? json['school_id'] as int
          : int.tryParse(json['school_id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      taxNumber: json['tax_number']?.toString() ?? '',
      nif: json['nif']?.toString(),
      nis: json['nis']?.toString(),
      phone: json['phone']?.toString(),
      specialty: json['specialty']?.toString(),
      userId: json['user_id']?.toString() ?? '',
      active: json['active'] is bool
          ? json['active'] as bool
          : json['active'].toString().toLowerCase() == 'true',
    );
  }
}

class UserProfile {
  final UserAccount user;
  final StudentProfile? student;
  final TeacherProfile? teacher;

  const UserProfile({
    required this.user,
    this.student,
    this.teacher,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      user: UserAccount.fromJson(json['user'] as Map<String, dynamic>),
      student: json['student'] is Map<String, dynamic>
          ? StudentProfile.fromJson(json['student'] as Map<String, dynamic>)
          : null,
      teacher: json['teacher'] is Map<String, dynamic>
          ? TeacherProfile.fromJson(json['teacher'] as Map<String, dynamic>)
          : null,
    );
  }

  UserProfile copyWith({
    StudentProfile? student,
    TeacherProfile? teacher,
  }) {
    return UserProfile(
      user: user,
      student: student ?? this.student,
      teacher: teacher ?? this.teacher,
    );
  }
}
