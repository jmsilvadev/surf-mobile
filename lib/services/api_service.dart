import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:surf_mobile/config/app_config.dart';
import 'package:surf_mobile/models/class_model.dart';
import 'package:surf_mobile/models/rental_model.dart';
import 'package:surf_mobile/models/class_student_model.dart';

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
}

