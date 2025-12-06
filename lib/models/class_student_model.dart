class ClassStudentModel {
  final int id;
  final int classId;
  final int studentId;
  final DateTime createdAt;

  ClassStudentModel({
    required this.id,
    required this.classId,
    required this.studentId,
    required this.createdAt,
  });

  factory ClassStudentModel.fromJson(Map<String, dynamic> json) {
    return ClassStudentModel(
      id: json['id'] as int,
      classId: json['class_id'] as int,
      studentId: json['student_id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'class_id': classId,
      'student_id': studentId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

