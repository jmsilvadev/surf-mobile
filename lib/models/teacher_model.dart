class TeacherModel {
  final String name;
  final String? nif;
  final String? nis;
  final String? email;
  final String? phone;

  TeacherModel({
    required this.name,
    this.nif,
    this.nis,
    this.email,
    this.phone,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      name: json['name'],
      nif: json['nif'] ?? '',
      nis: json['nis'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}
