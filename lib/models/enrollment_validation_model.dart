class EnrollmentValidation {
  final bool allowed;
  final String? message;

  EnrollmentValidation({
    required this.allowed,
    this.message,
  });

  factory EnrollmentValidation.fromJson(Map<String, dynamic> json) {
    return EnrollmentValidation(
      allowed: json['allowed'] as bool,
      message: json['message'] as String?,
    );
  }
}
