class StudentDeposit {
  final int id;
  final String paymentIntentId;
  final String sourceType; // class_pack | rental | other
  final int sourceId;
  final int schoolId;
  final int studentId;
  final String stripeCustomerId;
  final double amount;
  final String currency;
  final String status; // pending | succeeded | failed | refunded
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? invoiceUrl;
  final String? invoiceCode;

  StudentDeposit({
    required this.id,
    required this.paymentIntentId,
    required this.sourceType,
    required this.sourceId,
    required this.schoolId,
    required this.studentId,
    required this.stripeCustomerId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.invoiceUrl,
    this.invoiceCode,
  });

  factory StudentDeposit.fromJson(Map<String, dynamic> json) {
    return StudentDeposit(
      id: json['id'],
      paymentIntentId: json['payment_intent_id'],
      sourceType: json['source_type'],
      sourceId: json['source_id'],
      schoolId: json['school_id'],
      studentId: json['student_id'],
      stripeCustomerId: json['stripe_customer_id'],
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      invoiceUrl: json['invoice_url'],
      invoiceCode: json['invoice_code'],
    );
  }
}
