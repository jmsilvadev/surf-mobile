import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:surf_mobile/config/app_config.dart';
import 'package:surf_mobile/models/class_model.dart';
import 'package:surf_mobile/models/rental_model.dart';
import 'package:surf_mobile/models/class_student_model.dart';
import 'package:surf_mobile/models/equipment_model.dart';
import 'package:surf_mobile/models/price_model.dart';
import 'package:surf_mobile/models/user_profile.dart';

class ApiService extends ChangeNotifier {
  late Dio _dio;
  String? _authToken;
  Future<String?> Function()? _tokenRefreshCallback;

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
    // Interceptor: attach token; if missing, try to refresh via callback before request.
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // allow unauthenticated access to auth endpoints
        final path = options.path;
        if (path.startsWith('/api/auth')) {
          handler.next(options);
          return;
        }

        // If we have token attach it
        if (_authToken != null && !options.headers.containsKey('Authorization')) {
          options.headers['Authorization'] = 'Bearer $_authToken';
          handler.next(options);
          return;
        }

        // No token: try to refresh via callback if provided
        if (_tokenRefreshCallback != null) {
          try {
            final newToken = await _tokenRefreshCallback!.call();
            if (newToken != null) {
              setAuthToken(newToken);
              options.headers['Authorization'] = 'Bearer $newToken';
              handler.next(options);
              return;
            }
          } catch (e) {
            if (kDebugMode) print('Token refresh failed before request: $e');
          }
        }

        // If still no token, reject request with clear error
        handler.reject(DioException(
          requestOptions: options,
          error: 'No authentication token available',
          response: Response(requestOptions: options, statusCode: 401, data: {'error': 'missing_token'}),
        ));
      },
      onError: (err, handler) async {
        final statusCode = err.response?.statusCode;
        if (statusCode == 401 && _tokenRefreshCallback != null) {
          try {
            final newToken = await _tokenRefreshCallback!.call();
            if (newToken != null) {
              setAuthToken(newToken);
              final opts = err.requestOptions;
              opts.headers['Authorization'] = 'Bearer $newToken';
              try {
                final response = await _dio.fetch(opts);
                return handler.resolve(response);
              } catch (e) {
                return handler.next(err);
              }
            }
          } catch (_) {
            // ignore and forward original error
          }
        }
        handler.next(err);
      },
    ));
  }

  void setAuthToken(String? token) {
    _authToken = token;
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  void setTokenRefreshCallback(Future<String?> Function()? cb) {
    _tokenRefreshCallback = cb;
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

  Future<List<Map<String, dynamic>>> getSchools() async {
    try {
      final response = await _dio.get('/api/schools');
      if (response.data is List) {
        final raw = response.data as List;
        return raw.map((e) => e as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching schools: $e');
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

  Future<UserProfile> getCurrentUserProfile() async {
    try {
      final response = await _dio.get('/api/auth/me');
      if (response.data is Map<String, dynamic>) {
        return UserProfile.fromJson(response.data as Map<String, dynamic>);
      }
      if (response.data is Map) {
        final map = Map<String, dynamic>.from(response.data as Map);
        return UserProfile.fromJson(map);
      }
      throw Exception('Unexpected profile response format');
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching current user profile: $e');
      }
      rethrow;
    }
  }

  Future<StudentProfile> updateStudentSchool({
    required StudentProfile student,
    required int schoolId,
  }) async {
    try {
      final payload = student.toUpdatePayload(overrideSchoolId: schoolId);
      final response = await _dio.put('/api/students/${student.id}', data: payload);
      if (response.data is Map<String, dynamic>) {
        return StudentProfile.fromJson(response.data as Map<String, dynamic>);
      }
      if (response.data is Map) {
        final map = Map<String, dynamic>.from(response.data as Map);
        return StudentProfile.fromJson(map);
      }
      throw Exception('Unexpected response updating student');
    } catch (e) {
      if (kDebugMode) {
        print('Error updating student school: $e');
      }
      rethrow;
    }
  }

  Future<StudentProfile> createStudentProfile({
    required int schoolId,
    required String name,
    required String userId,
    String? taxNumber,
    String? phone,
    DateTime? birthDate,
    bool active = true,
  }) async {
    try {
      final payload = <String, dynamic>{
        'school_id': schoolId,
        'name': name,
        'user_id': userId,
        'active': active,
        if (taxNumber != null && taxNumber.isNotEmpty) 'tax_number': taxNumber,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (birthDate != null) 'birth_date': birthDate.toIso8601String(),
      };
      final response = await _dio.post('/api/students', data: payload);
      if (response.data is Map<String, dynamic>) {
        return StudentProfile.fromJson(response.data as Map<String, dynamic>);
      }
      if (response.data is Map) {
        final map = Map<String, dynamic>.from(response.data as Map);
        return StudentProfile.fromJson(map);
      }
      throw Exception('Unexpected response creating student');
    } catch (e) {
      if (kDebugMode) {
        print('Error creating student profile: $e');
      }
      rethrow;
    }
  }
}
