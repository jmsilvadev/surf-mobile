class EquipmentInfo {
  final int equipmentId;
  final int qty;
  final String? equipmentName;

  EquipmentInfo({
    required this.equipmentId,
    required this.qty,
    this.equipmentName,
  });

  factory EquipmentInfo.fromJson(Map<String, dynamic> json) {
    return EquipmentInfo(
      equipmentId: (json['equipment_id'] as num?)?.toInt() ?? 0,
      qty: (json['qty'] as num?)?.toInt() ?? 0,
      equipmentName: json['equipment_name'] as String?,
    );
  }
}
