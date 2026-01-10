class SkillLevel {
  final String slug;
  final String name;
  final String? description;
  final int? minAge;
  final int? maxAge;
  final bool defaultForNew;

  SkillLevel(
      {required this.slug,
      required this.name,
      this.description,
      this.minAge,
      this.maxAge,
      this.defaultForNew = false});

  factory SkillLevel.fromJson(Map<String, dynamic> json) {
    return SkillLevel(
      slug: json['slug'],
      name: json['name'],
      description: json['description'],
      minAge: json['min_age'],
      maxAge: json['max_age'],
      defaultForNew: json['default_for_new'] ?? false,
    );
  }
}
