class RentalModel {
  final int id;
  final int schoolId;
  final int studentId;
  final int equipmentId;
  final int priceId;
  final DateTime startDate;
  final DateTime endDate;
  final int quantity;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  RentalModel({
    required this.id,
    required this.schoolId,
    required this.studentId,
    required this.equipmentId,
    required this.priceId,
    required this.startDate,
    required this.endDate,
    required this.quantity,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RentalModel.fromJson(Map<String, dynamic> json) {
    return RentalModel(
      id: json['id'] as int,
      schoolId: json['school_id'] as int,
      studentId: json['student_id'] as int,
      equipmentId: json['equipment_id'] as int,
      priceId: json['price_id'] as int,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      quantity: json['quantity'] as int,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'school_id': schoolId,
      'student_id': studentId,
      'equipment_id': equipmentId,
      'price_id': priceId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'quantity': quantity,
      'status': status,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

