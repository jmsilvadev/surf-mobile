import 'package:surf_mobile/models/equipment_info_model.dart';
import 'package:surf_mobile/models/price_class_model.dart';
import 'package:surf_mobile/models/skill_level_model.dart';
import 'package:surf_mobile/models/student_class_item_model.dart';
import 'package:surf_mobile/models/teacher_model.dart';

class ClassModel {
  final int id;
  final DateTime startDatetime;
  final DateTime endDatetime;
  final String status;
  final int maxStudents;

  final int teacherId;
  final TeacherModel teacher;

  final int priceId;
  final PriceClassModel price;

  final int? skillLevelId;
  final SkillLevel? skillLevel;

  final List<int>? studentIds;
  final List<StudentClassItem>? students;
  final List<EquipmentInfo>? equipments;

  ClassModel({
    required this.id,
    required this.startDatetime,
    required this.endDatetime,
    required this.status,
    required this.maxStudents,
    required this.teacherId,
    required this.teacher,
    required this.priceId,
    required this.price,
    this.skillLevelId,
    this.skillLevel,
    this.studentIds,
    this.students,
    this.equipments,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      startDatetime: DateTime.parse(json['start_datetime']),
      endDatetime: DateTime.parse(json['end_datetime']),
      status: json['status'] ?? 'unknown',
      maxStudents: (json['max_students'] as num?)?.toInt() ?? 0,
      teacherId: (json['teacher_id'] as num?)?.toInt() ?? 0,
      teacher: json['teacher'] != null
          ? TeacherModel.fromJson(json['teacher'])
          : TeacherModel(name: 'Unknown'),
      priceId: (json['price_id'] as num?)?.toInt() ?? 0,
      price: json['price'] != null
          ? PriceClassModel.fromJson(json['price'])
          : PriceClassModel(type: 'unknown', amount: 0),
      skillLevelId: (json['skill_level_id'] as num?)?.toInt(),
      skillLevel: json['skill_level'] != null
          ? SkillLevel.fromJson(json['skill_level'])
          : null,
      // ✅ AQUI ESTAVA O BUG
      studentIds: (json['student_ids'] as List<dynamic>?)
              ?.whereType<num>()
              .map((e) => e.toInt())
              .toList() ??
          [],
      students: (json['students'] as List<dynamic>?)
              ?.map((e) => StudentClassItem.fromJson(e))
              .toList() ??
          [],
      equipments: (json['equipment'] as List<dynamic>?)
              ?.map((e) => EquipmentInfo.fromJson(e))
              .toList() ??
          [],
    );
  }
}
