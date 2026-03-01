class School {
  final int id;

  final String name;
  final String taxNumber;

  final String address;
  final String phone;
  final String email;
  final String nis;
  final String? logoUrl;

  School({
    required this.id,
    required this.name,
    required this.taxNumber,
    required this.address,
    required this.phone,
    required this.email,
    required this.nis,
    this.logoUrl,
  });

  factory School.fromJson(Map<String, dynamic> json) {
    String _readString(String key, {String defaultValue = ''}) {
      final value = json[key];
      if (value == null) return defaultValue;
      if (value is String) return value;
      return value.toString();
    }

    return School(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: _readString('name'),
      taxNumber: _readString('tax_number'),
      address: _readString('address'),
      phone: _readString('phone'),
      email: _readString('email'),
      nis: _readString('nis'),
      logoUrl: json['logo_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
