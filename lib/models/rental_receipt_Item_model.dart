class RentalReceiptItem {
  final String equipmentName;
  final int quantity;
  final double unitPrice;
  final double total;

  RentalReceiptItem({
    required this.equipmentName,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  factory RentalReceiptItem.fromJson(Map<String, dynamic> json) {
    return RentalReceiptItem(
      equipmentName: json['equipment_name'],
      quantity: json['quantity'],
      unitPrice: (json['unit_price'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
    );
  }
}
