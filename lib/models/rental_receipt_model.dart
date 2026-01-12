import 'package:surf_mobile/models/rental_receipt_Item_model.dart';
import 'package:surf_mobile/models/skill_level_model.dart';

class SchoolReceipt {
  final String name;
  final String? nis;
  final String phone;
  final String? logoUrl;

  SchoolReceipt({
    required this.name,
    this.nis,
    required this.phone,
    this.logoUrl,
  });

  factory SchoolReceipt.fromJson(Map<String, dynamic> json) {
    return SchoolReceipt(
      name: json['name'] as String,
      nis: json['nis'] as String,
      phone: json['phone'] as String,
      logoUrl: json['logo_url'] as String,
    );
  }
}

class StudentReceipt {
  final String name;
  final SkillLevel skillLevel;

  StudentReceipt({required this.name, required this.skillLevel});

  factory StudentReceipt.fromJson(Map<String, dynamic> json) {
    return StudentReceipt(
        name: json['name'] as String,
        skillLevel: SkillLevel.fromJson(json['skill_level']));
  }
}

class RentalReceipt {
  final SchoolReceipt school;
  final StudentReceipt? student;
  final List<RentalReceiptItem> rentals;
  final double total;
  final DateTime createdAt;

  RentalReceipt({
    required this.school,
    this.student,
    required this.rentals,
    required this.total,
    required this.createdAt,
  });

  factory RentalReceipt.fromJson(Map<String, dynamic> json) {
    return RentalReceipt(
      school: SchoolReceipt.fromJson(json['school']),
      student: null,
      rentals: (json['rentals'] as List)
          .map((e) => RentalReceiptItem.fromJson(e))
          .toList(),
      total: (json['total'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
