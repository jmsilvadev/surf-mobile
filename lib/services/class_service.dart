class EnrollmentValidationResult {
  final bool allowed;
  final String? message;

  EnrollmentValidationResult({
    required this.allowed,
    this.message,
  });

  factory EnrollmentValidationResult.fromJson(Map<String, dynamic> json) {
    return EnrollmentValidationResult(
      allowed: json['allowed'] as bool,
      message: json['message'] as String?,
    );
  }
}
