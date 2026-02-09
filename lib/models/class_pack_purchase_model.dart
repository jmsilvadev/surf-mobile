class ClassPackPurchase {
  final int id;
  final int classPackId;
  final int studentId;
  final int lessonsTotal;
  final int lessonsUsed;
  final String status;
  final String paymentStatus;

  ClassPackPurchase({
    required this.id,
    required this.classPackId,
    required this.studentId,
    required this.lessonsTotal,
    required this.lessonsUsed,
    required this.status,
    required this.paymentStatus,
  });

  int get availableLessons => lessonsTotal - lessonsUsed;

  factory ClassPackPurchase.fromJson(Map<String, dynamic> json) {
    return ClassPackPurchase(
        id: json['id'],
        classPackId: json['class_pack_id'],
        studentId: json['student_id'],
        lessonsTotal: json['lessons_total'],
        lessonsUsed: json['lessons_used'],
        status: json['status'],
        paymentStatus: json['payment_status']);
  }
}
