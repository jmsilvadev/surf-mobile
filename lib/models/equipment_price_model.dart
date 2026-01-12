class EquipmentPrice {
  final int id;
  final int schoolId;
  final int equipmentId;
  final double amount;
  final String priceModel;
  final bool? active;

  EquipmentPrice({
    required this.id,
    required this.schoolId,
    required this.equipmentId,
    required this.amount,
    required this.priceModel,
    required this.active,
  });
  factory EquipmentPrice.fromJson(Map<String, dynamic> json) {
    return EquipmentPrice(
      id: json['id'] as int,
      schoolId: json['school_id'] as int,
      equipmentId: json['equipment_id'] as int,
      amount: (json['amount'] as num).toDouble(),
      priceModel: json['price_model'] as String,
      active: json['active'] as bool,
    );
  }
}
