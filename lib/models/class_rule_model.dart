class ClassRule {
  final int id;
  final int classId;
  final String title;
  final String? description;
  final bool mandatory;
  final int displayOrder;

  ClassRule({
    required this.id,
    required this.classId,
    required this.title,
    this.description,
    required this.mandatory,
    required this.displayOrder,
  });

  factory ClassRule.fromJson(Map<String, dynamic> json) {
    return ClassRule(
      id: json['id'],
      classId: json['class_id'],
      title: json['title'],
      description: json['description'],
      mandatory: json['mandatory'] ?? false,
      displayOrder: json['display_order'] ?? 0,
    );
  }
}
