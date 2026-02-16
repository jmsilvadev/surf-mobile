import 'package:flutter/foundation.dart';
//import 'package:surf_mobile/models/school_model.dart';
import 'package:surf_mobile/models/skill_level_model.dart';

class UserAccount {
  final String id;
  final String email;
  final String role;
  final bool active;

  const UserAccount({
    required this.id,
    required this.email,
    required this.role,
    required this.active,
  });

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    return UserAccount(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      active: json['active'] is bool
          ? json['active'] as bool
          : json['active'].toString().toLowerCase() == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'active': active,
    };
  }
}

class StudentProfile {
  final int id;
  final int schoolId;
//  final School? school;
  final String name;
  //final String taxNumber;
  // final String? phone;
  final DateTime? birthDate;
  final String? photoUrl;
  // final String userId;
  // final bool active;
  final SkillLevel? skillLevel;

  const StudentProfile({
    required this.id,
    required this.schoolId,
    // required this.school,
    required this.name,
    // required this.taxNumber,
    // required this.userId,
    // required this.active,
    // this.phone,
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
      // school: json['school'] is Map<String, dynamic>
      //     ? School.fromJson(json['school'] as Map<String, dynamic>)
      //     : School(
      //         id: 0,
      //         name: '',
      //         taxNumber: '',
      //         address: '',
      //         phone: '',
      //         email: '',
      //         nis: ''),
      name: json['name']?.toString() ?? '',
      //   taxNumber: json['tax_number']?.toString() ?? '',
      //   phone: json['phone']?.toString(),
      birthDate: parsedDate,
      photoUrl: json['photo_url']?.toString(),
      //    userId: json['user_id']?.toString() ?? '',
      // active: json['active'] is bool
      //     ? json['active'] as bool
      //     : json['active'].toString().toLowerCase() == 'true',
      skillLevel: json['skill_level'] != null
          ? SkillLevel.fromJson(json['skill_level'])
          : null,
    );
  }

  StudentProfile copyWith({
    int? schoolId,
    //School? school,
    String? name,
    //String? taxNumber,
    // String? phone,
    DateTime? birthDate,
    String? photoUrl,
    // bool? active,
    SkillLevel? skillLevel,
  }) {
    return StudentProfile(
      id: id,
      schoolId: schoolId ?? this.schoolId,
      //school: school ?? this.school,
      name: name ?? this.name,
      //  taxNumber: taxNumber ?? this.taxNumber,
      //   phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
      photoUrl: photoUrl ?? this.photoUrl,
      //   userId: userId,
      // active: active ?? this.active,
      skillLevel: skillLevel ?? this.skillLevel,
    );
  }

  Map<String, dynamic> toUpdatePayload({int? overrideSchoolId}) {
    return {
      'school_id': overrideSchoolId ?? schoolId,
      'name': name,
      //  'tax_number': taxNumber,
      //   'phone': phone,
      'birth_date': birthDate?.toIso8601String(),
      'photo_url': photoUrl,
      //  'active': active,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'school_id': schoolId,
      'name': name,
      'birth_date': birthDate?.toIso8601String(),
      'photo_url': photoUrl,
      'skill_level': skillLevel?.toJson(),
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'school_id': schoolId,
      'name': name,
      'tax_number': taxNumber,
      'nif': nif,
      'nis': nis,
      'phone': phone,
      'specialty': specialty,
      'user_id': userId,
      'active': active,
    };
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
    final userJson = json['user'];

    return UserProfile(
      user: userJson is Map<String, dynamic>
          ? UserAccount.fromJson(userJson)
          : const UserAccount(
              id: '',
              email: '',
              role: '',
              active: true,
            ), // fallback seguro
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

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'student': student != null
          ? {
              'id': student!.id,
              'school_id': student!.schoolId,
              'name': student!.name,
              //  'tax_number': student!.taxNumber,
              //'phone': student!.phone,
              'birth_date': student!.birthDate?.toIso8601String(),
              'photo_url': student!.photoUrl,
              //   'user_id': student!.userId,
              // 'active': student!.active,
            }
          : null,
      'teacher': teacher != null
          ? {
              'id': teacher!.id,
              'school_id': teacher!.schoolId,
              'name': teacher!.name,
              'tax_number': teacher!.taxNumber,
              'nif': teacher!.nif,
              'nis': teacher!.nis,
              'phone': teacher!.phone,
              'specialty': teacher!.specialty,
              'user_id': teacher!.userId,
              'active': teacher!.active,
            }
          : null,
    };
  }
}
