class PriceClassModel {
  final String type;
  final String? description;
  final double amount;

  PriceClassModel({
    required this.type,
    required this.amount,
    this.description,
  });

  factory PriceClassModel.fromJson(Map<String, dynamic> json) {
    return PriceClassModel(
      type: json['type'],
      amount: (json['amount'] as num).toDouble(),
      description: json['description'],
    );
  }
}
