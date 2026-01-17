import 'package:surf_mobile/models/skill_level_model.dart';

class ClassPack {
  final int id;
  final int schoolId;

  final SkillLevel? skillLevel;

  final String name;
  final String? description;

  final int lessonsQty;
  final int? validityDays;

  final double? price;
  final bool includesEquipment;
  final bool includesInsurance;

  final bool featured;
  final int featuredOrder;

  final String? heroImageUrl;
  final List<String> benefits;

  ClassPack({
    required this.id,
    required this.schoolId,
    required this.name,
    required this.lessonsQty,
    required this.price,
    required this.includesEquipment,
    required this.includesInsurance,
    required this.featured,
    required this.featuredOrder,
    this.skillLevel,
    this.description,
    this.validityDays,
    this.heroImageUrl,
    this.benefits = const [],
  });

  factory ClassPack.fromJson(Map<String, dynamic> json) {
    return ClassPack(
      id: json['id'],
      schoolId: json['school_id'],
      name: json['name'],
      description: json['description'],
      lessonsQty: json['lessons_qty'],
      validityDays: json['validity_days'],
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      includesEquipment: json['includes_equipment'] ?? false,
      includesInsurance: json['includes_insurance'] ?? false,
      featured: json['featured'] ?? false,
      featuredOrder: json['featured_order'] ?? 0,
      // heroImageUrl: json['hero_image_url'] != null
      //     ? '${AppConfig.apiBaseUrl}${json['hero_image_url']}'
      //     : null,
      heroImageUrl: json['hero_image_url'] ?? '',
      benefits: (json['benefits'] as List?)?.cast<String>() ?? [],
      skillLevel: json['skill_level'] != null
          ? SkillLevel.fromJson(json['skill_level'])
          : null,
    );
  }
}
