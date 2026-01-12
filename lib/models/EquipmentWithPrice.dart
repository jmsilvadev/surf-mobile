import 'package:surf_mobile/models/equipment_model.dart';

class EquipmentWithPrice {
  final int id;
  final int schoolId;
  final int equipmentId;
  final double amount;
  final String priceModel;
  final bool? active;

  final String name;
  final String? photoUrl;
  final String? description;
  final int availableQuantity;

  EquipmentWithPrice(
      {required this.id,
      required this.schoolId,
      required this.equipmentId,
      required this.amount,
      required this.priceModel,
      required this.active,
      required this.name,
      this.photoUrl,
      this.description,
      required this.availableQuantity});

  factory EquipmentWithPrice.fromEquipment({
    required EquipmentModel equipment,
    required double amount,
    required String priceModel,
  }) {
    return EquipmentWithPrice(
      id: equipment.id,
      schoolId: equipment.schoolId,
      equipmentId: equipment.id,
      name: equipment.name,
      photoUrl: equipment.photoURL,
      description: equipment.description,
      active: equipment.active,
      availableQuantity: equipment.availableQuantity,
      amount: amount,
      priceModel: priceModel,
    );
  }

  factory EquipmentWithPrice.fromJson(Map<String, dynamic> json) {
    return EquipmentWithPrice(
      id: json['id'] as int,
      schoolId: json['school_id'] as int,
      equipmentId: json['equipment_id'] as int,
      amount: (json['amount'] as num).toDouble(),
      priceModel: json['price_model'] as String,
      active: json['active'] as bool,
      name: json['name'] as String,
      photoUrl: json['photo_url'] as String,
      description: json['description'] as String,
      availableQuantity: json['available_quantity'] as int,
    );
  }
}
