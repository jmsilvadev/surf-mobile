class PriceModel {
  final int id;
  final int schoolId;
  final String type;
  final String? description;
  final double amount;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;

  PriceModel({
    required this.id,
    required this.schoolId,
    required this.type,
    this.description,
    required this.amount,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PriceModel.fromJson(Map<String, dynamic> json) {
    return PriceModel(
      id: json['id'] as int,
      schoolId: json['school_id'] as int,
      type: json['type'] as String,
      description: json['description'] as String?,
      amount: (json['amount'] as num).toDouble(),
      active: json['active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'school_id': schoolId,
      'type': type,
      'description': description,
      'amount': amount,
      'active': active,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

