class RentalModel {
  final int id;
  final int schoolId;
  final int studentId;
  final int equipmentId;
  final int equipmentPriceId;
  final double amountSnapshot;
  final DateTime startDate;
  final DateTime endDate;
  final int quantity;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? equipmentName;

  RentalModel({
    required this.id,
    required this.schoolId,
    required this.studentId,
    required this.equipmentId,
    required this.equipmentPriceId,
    required this.amountSnapshot,
    required this.startDate,
    required this.endDate,
    required this.quantity,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.equipmentName,
  });

  factory RentalModel.fromJson(Map<String, dynamic> json) {
    return RentalModel(
      id: json['id'] as int,
      schoolId: json['school_id'] as int,
      studentId: json['student_id'] as int,
      equipmentId: json['equipment_id'] as int,
      equipmentPriceId: json['equipment_price_id'] as int,
      amountSnapshot: (json['amount_snapshot'] as num).toDouble(),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      quantity: json['quantity'] as int,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  RentalModel copyWith({
    String? equipmentName,
  }) {
    return RentalModel(
      id: id,
      schoolId: schoolId,
      studentId: studentId,
      equipmentId: equipmentId,
      equipmentPriceId: equipmentPriceId,
      amountSnapshot: amountSnapshot,
      startDate: startDate,
      endDate: endDate,
      quantity: quantity,
      status: status,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
      equipmentName: equipmentName ?? this.equipmentName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'school_id': schoolId,
      'student_id': studentId,
      'equipment_id': equipmentId,
      'equipment_price_id': equipmentPriceId,
      'amount_snapshot': amountSnapshot,
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
