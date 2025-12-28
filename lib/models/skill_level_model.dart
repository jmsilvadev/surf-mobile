class SkillLevel {
  final int id;
  final String name;
  final String slug;

  SkillLevel({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory SkillLevel.fromJson(Map<String, dynamic> json) {
    return SkillLevel(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
    );
  }
}
