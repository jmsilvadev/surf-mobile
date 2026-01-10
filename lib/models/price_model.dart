class PriceModel {
  final int id;
  final int schoolId;
  final String type;
  final String? description;
  final double amount;
  final bool active;
  final String createdAt;
  final String updatedAt;

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
      id: json['id'],
      schoolId: json['school_id'],
      type: json['type'],
      description: json['description'],
      amount: (json['amount'] as num).toDouble(),
      active: json['active'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
