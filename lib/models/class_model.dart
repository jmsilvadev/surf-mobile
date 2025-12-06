class ClassModel {
  final int id;
  final int schoolId;
  final int teacherId;
  final int priceId;
  final DateTime startDatetime;
  final DateTime endDatetime;
  final String status;
  final String? notes;
  final List<int> studentIds;
  final List<EquipmentInfo> equipment;
  final DateTime createdAt;
  final DateTime updatedAt;

  ClassModel({
    required this.id,
    required this.schoolId,
    required this.teacherId,
    required this.priceId,
    required this.startDatetime,
    required this.endDatetime,
    required this.status,
    this.notes,
    required this.studentIds,
    required this.equipment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'] as int,
      schoolId: json['school_id'] as int,
      teacherId: json['teacher_id'] as int,
      priceId: json['price_id'] as int,
      startDatetime: DateTime.parse(json['start_datetime'] as String),
      endDatetime: DateTime.parse(json['end_datetime'] as String),
      status: json['status'] as String,
      notes: json['notes'] as String?,
      studentIds: (json['student_ids'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      equipment: (json['equipment'] as List<dynamic>?)
              ?.map((e) => EquipmentInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'school_id': schoolId,
      'teacher_id': teacherId,
      'price_id': priceId,
      'start_datetime': startDatetime.toIso8601String(),
      'end_datetime': endDatetime.toIso8601String(),
      'status': status,
      'notes': notes,
      'student_ids': studentIds,
      'equipment': equipment.map((e) => e.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class EquipmentInfo {
  final int equipmentId;
  final int quantity;

  EquipmentInfo({
    required this.equipmentId,
    required this.quantity,
  });

  factory EquipmentInfo.fromJson(Map<String, dynamic> json) {
    return EquipmentInfo(
      equipmentId: json['equipmentId'] as int,
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'equipmentId': equipmentId,
      'quantity': quantity,
    };
  }
}

