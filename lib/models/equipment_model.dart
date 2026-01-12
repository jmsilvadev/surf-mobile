class EquipmentModel {
  final int id;
  final int schoolId;
  final String name;
  final String type;
  final String? photoURL;
  final String? description;
  final int totalQuantity;
  final int availableQuantity;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;

  EquipmentModel({
    required this.id,
    required this.schoolId,
    required this.name,
    required this.type,
    this.photoURL,
    this.description,
    required this.totalQuantity,
    required this.availableQuantity,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EquipmentModel.fromJson(Map<String, dynamic> json) {
    return EquipmentModel(
      id: json['id'] as int,
      schoolId: json['school_id'] as int,
      name: json['name'] as String,
      type: json['type'] as String,
      photoURL: json['photo_url'],
      description: json['description'] as String?,
      totalQuantity: json['total_quantity'] as int,
      availableQuantity: json['available_quantity'] as int,
      active: json['active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'school_id': schoolId,
      'name': name,
      'type': type,
      'photo_url': photoURL,
      'description': description,
      'total_quantity': totalQuantity,
      'available_quantity': availableQuantity,
      'active': active,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
