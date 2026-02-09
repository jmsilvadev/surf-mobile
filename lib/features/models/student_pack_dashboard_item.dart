class StudentPackDashboardItem {
  final int purchaseId;
  final int packId;

  final String packName;
  final int lessonsBalance;

  final String status;
  final String paymentStatus;

  final double? pricePaid;
  final int? validityDays;
  final DateTime? createdAt;
  DateTime? get expiresAt {
    if (validityDays == null) return null;
    final purchaseDate = createdAt ?? DateTime.now();
    return purchaseDate.add(Duration(days: validityDays!));
  }

  StudentPackDashboardItem(
      {required this.purchaseId,
      required this.packId,
      required this.packName,
      required this.lessonsBalance,
      required this.status,
      required this.paymentStatus,
      this.pricePaid,
      this.validityDays,
      this.createdAt});
}
