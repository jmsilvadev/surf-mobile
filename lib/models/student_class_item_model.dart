import 'package:surf_mobile/models/skill_level_model.dart';

class StudentClassItem {
  final int id;
  final String name;
  final String? phone;
  final String? email;
  final String? birthDate;
  final SkillLevel? skillLevel;

  StudentClassItem({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.birthDate,
    this.skillLevel,
  });

  factory StudentClassItem.fromJson(Map<String, dynamic> json) {
    return StudentClassItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] ?? '',
      phone: json['phone']?.toString(),
      email: json['email'],
      birthDate: json['birth_date'],
      skillLevel: json['skill_level'] != null
          ? SkillLevel.fromJson(json['skill_level'])
          : null,
    );
  }
}
