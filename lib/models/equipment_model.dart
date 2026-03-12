class TypeEquipmentModel {
  final int id;
  final String name;

  TypeEquipmentModel({required this.id, required this.name});

  factory TypeEquipmentModel.fromJson(Map<String, dynamic> json) {
    return TypeEquipmentModel(id: json['id'], name: json['name']);
  }
}

class EquipmentModel {
  final int id;
  final int schoolId;
  final String name;
  final int typeEquipmentId;
  final TypeEquipmentModel typeEquipment;
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
    required this.typeEquipmentId,
    required this.typeEquipment,
    this.photoURL,
    this.description,
    required this.totalQuantity,
    required this.availableQuantity,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EquipmentModel.fromJson(Map<String, dynamic> json) {
    String _readString(String key, {String defaultValue = ''}) {
      final value = json[key];
      if (value == null) return defaultValue;
      if (value is String) return value;
      return value.toString();
    }

    int _readInt(String key, {int defaultValue = 0}) {
      final value = json[key];
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString()) ?? defaultValue;
    }

    bool _readBool(String key, {bool defaultValue = false}) {
      final value = json[key];
      if (value == null) return defaultValue;
      if (value is bool) return value;
      if (value is num) return value != 0;
      final text = value.toString().toLowerCase();
      if (text == 'true' || text == '1') return true;
      if (text == 'false' || text == '0') return false;
      return defaultValue;
    }

    DateTime _readDate(String key) {
      final value = json[key];
      if (value == null) {
        return DateTime.fromMillisecondsSinceEpoch(0);
      }
      if (value is DateTime) return value;
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
      return DateTime.tryParse(value.toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0);
    }

    return EquipmentModel(
      id: _readInt('id'),
      schoolId: _readInt('school_id'),
      name: _readString('name'),
      typeEquipmentId: _readInt('type_equipment_id'),
      typeEquipment: json['type_equipment'],
      photoURL: json['photo_url'],
      description: json['description'] as String?,
      totalQuantity: _readInt('total_quantity'),
      availableQuantity: _readInt('available_quantity'),
      active: _readBool('active'),
      createdAt: _readDate('created_at'),
      updatedAt: _readDate('updated_at'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'school_id': schoolId,
      'name': name,
      'type_equipment_id': typeEquipmentId,
      'type_equipment': typeEquipment,
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
