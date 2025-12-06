import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:surf_mobile/config/app_config.dart';
import 'package:surf_mobile/models/class_model.dart';
import 'package:surf_mobile/models/rental_model.dart';
import 'package:surf_mobile/models/class_student_model.dart';
import 'package:surf_mobile/models/equipment_model.dart';
import 'package:surf_mobile/models/price_model.dart';

class ApiService extends ChangeNotifier {
  late Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
  }

  void setAuthToken(String? token) {
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  Future<List<ClassModel>> getClasses() async {
    try {
      final response = await _dio.get('/api/classes');
      if (response.data is List) {
        return (response.data as List)
            .map((json) => ClassModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching classes: $e');
      }
      rethrow;
    }
  }

  Future<List<ClassStudentModel>> getStudentClasses(int studentId) async {
    try {
      final response = await _dio.get('/api/students/$studentId/classes');
      if (response.data is List) {
        return (response.data as List)
            .map((json) => ClassStudentModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching student classes: $e');
      }
      rethrow;
    }
  }

  Future<List<RentalModel>> getRentals() async {
    try {
      final response = await _dio.get('/api/rentals');
      if (response.data is List) {
        return (response.data as List)
            .map((json) => RentalModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching rentals: $e');
      }
      rethrow;
    }
  }

  Future<List<RentalModel>> getStudentRentals(int studentId) async {
    try {
      final response = await _dio.get('/api/rentals');
      if (response.data is List) {
        final allRentals = (response.data as List)
            .map((json) => RentalModel.fromJson(json))
            .toList();
        return allRentals.where((rental) => rental.studentId == studentId).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching student rentals: $e');
      }
      rethrow;
    }
  }

  Future<RentalModel> createRental({
    required int schoolId,
    required int studentId,
    required int equipmentId,
    required int priceId,
    required DateTime startDate,
    required DateTime endDate,
    int quantity = 1,
    String? notes,
  }) async {
    try {
      final response = await _dio.post(
        '/api/rentals',
        data: {
          'school_id': schoolId,
          'student_id': studentId,
          'equipment_id': equipmentId,
          'price_id': priceId,
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
          'quantity': quantity,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        },
      );
      return RentalModel.fromJson(response.data);
    } catch (e) {
      if (kDebugMode) {
        print('Error creating rental: $e');
      }
      rethrow;
    }
  }

  Future<List<EquipmentModel>> getEquipment() async {
    try {
      final response = await _dio.get('/api/equipment');
      if (response.data is List) {
        return (response.data as List)
            .map((json) => EquipmentModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching equipment: $e');
      }
      rethrow;
    }
  }

  Future<List<PriceModel>> getPrices({String? type}) async {
    try {
      final response = await _dio.get(
        '/api/prices',
        queryParameters: type != null ? {'type': type} : null,
      );
      if (response.data is List) {
        return (response.data as List)
            .map((json) => PriceModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching prices: $e');
      }
      rethrow;
    }
  }

  Future<ClassStudentModel> addStudentToClass(int classId, int studentId) async {
    try {
      final response = await _dio.post(
        '/api/classes/$classId/students',
        data: {'student_id': studentId},
      );
      return ClassStudentModel.fromJson(response.data);
    } catch (e) {
      if (kDebugMode) {
        print('Error adding student to class: $e');
      }
      rethrow;
    }
  }

  Future<void> removeStudentFromClass(int classId, int studentId) async {
    try {
      await _dio.delete('/api/classes/$classId/students/$studentId');
    } catch (e) {
      if (kDebugMode) {
        print('Error removing student from class: $e');
      }
      rethrow;
    }
  }
}

