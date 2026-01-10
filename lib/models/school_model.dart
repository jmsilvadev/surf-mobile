class School {
  final String name;
  final String taxNumber;

  final String address;
  final String phone;
  final String email;
  final String nis;
  final String? logoUrl;

  School({
    required this.name,
    required this.taxNumber,
    required this.address,
    required this.phone,
    required this.email,
    required this.nis,
    this.logoUrl,
  });

  factory School.fromJson(Map<String, dynamic> json) {
    return School(
      name: json['name'] as String,
      taxNumber: json['tax_number'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      nis: json['nis'] as String,
      logoUrl: json['logo_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'tax_number': taxNumber,
      'address': address,
      'phone': phone,
      'email': email,
      'nis': nis,
      'logo_url': logoUrl,
    };
  }
}
