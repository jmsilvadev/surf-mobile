import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:surf_mobile/config/app_config.dart';
import 'package:surf_mobile/models/EquipmentWithPrice.dart';
//import 'package:surf_mobile/models/auth_session_model.dart';
import 'package:surf_mobile/models/class_model.dart';
import 'package:surf_mobile/models/class_pack_model.dart';
import 'package:surf_mobile/models/class_pack_purchase_model.dart';
import 'package:surf_mobile/models/class_rule_model.dart';
import 'package:surf_mobile/models/enrollment_validation_model.dart';
import 'package:surf_mobile/models/equipment_price_model.dart';
import 'package:surf_mobile/models/rental_model.dart';
import 'package:surf_mobile/models/class_student_model.dart';
import 'package:surf_mobile/models/equipment_model.dart';
import 'package:surf_mobile/models/price_model.dart';
import 'package:surf_mobile/models/rental_receipt_model.dart';
import 'package:surf_mobile/models/school_model.dart';
import 'package:surf_mobile/models/user_profile.dart';

class ApiService extends ChangeNotifier {
  late Dio _dio;
  String? _authToken;
  // Future<String?> Function()? _tokenRefreshCallback;

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
    print('🌐 BASE URL = ${_dio.options.baseUrl}');
    _dio.interceptors.add(InterceptorsWrapper(
      // onRequest: (options, handler) async {
      //   // allow unauthenticated access to auth endpoints
      //   final path = options.path;
      //   if (path == '/api/auth/google') {
      //     handler.next(options);
      //     return;
      //   }

      //   // If we have token attach it
      //   if (_authToken != null &&
      //       !options.headers.containsKey('Authorization')) {
      //     options.headers['Authorization'] = 'Bearer $_authToken';
      //     handler.next(options);
      //     return;
      //   }

      //   print('➡️ REQUEST ${options.path}');
      //   print('➡️ AUTH HEADER ${options.headers['Authorization']}');
      //   // No token: try to refresh via callback if provided
      //   if (_tokenRefreshCallback != null) {
      //     try {
      //       final newToken = await _tokenRefreshCallback!.call();
      //       if (newToken != null) {
      //         setAuthToken(newToken);
      //         options.headers['Authorization'] = 'Bearer $newToken';
      //         handler.next(options);
      //         return;
      //       }
      //     } catch (e) {
      //       if (kDebugMode) print('Token refresh failed before request: $e');
      //     }
      //   }

      //   // If still no token, reject request with clear error
      //   handler.reject(DioException(
      //     requestOptions: options,
      //     error: 'No authentication token available',
      //     response: Response(
      //         requestOptions: options,
      //         statusCode: 401,
      //         data: {'error': 'missing_token'}),
      //   ));
      // },
      onRequest: (options, handler) async {
        final path = options.path;

        // endpoints públicos
        if (path.startsWith('/api/auth/google')) {
          handler.next(options);
          return;
        }

        if (_authToken != null) {
          options.headers['Authorization'] = 'Bearer $_authToken';
        }
        print('➡️ REQUEST ${options.path}');

        print('➡️ AUTH HEADER ${options.headers['Authorization']}');

        handler.next(options);
      },

      onError: (err, handler) async {
        // final statusCode = err.response?.statusCode;
        // if (statusCode == 401 && _tokenRefreshCallback != null) {
        //   try {
        //     final newToken = await _tokenRefreshCallback!.call();
        //     if (newToken != null) {
        //       setAuthToken(newToken);
        //       final opts = err.requestOptions;
        //       opts.headers['Authorization'] = 'Bearer $newToken';
        //       try {
        //         final response = await _dio.fetch(opts);
        //         return handler.resolve(response);
        //       } catch (e) {
        //         return handler.next(err);
        //       }
        //     }
        //   } catch (_) {
        //     // ignore and forward original error
        //   }
        // }
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

  Dio get dio => _dio;

  // void setTokenRefreshCallback(Future<String?> Function()? cb) {
  //   _tokenRefreshCallback = cb;
  // }

  Future<List<ClassModel>> getClasses() async {
    try {
      final response = await _dio.get('/api/classes');

      if (kDebugMode) {
        print('RAW /api/classes RESPONSE:');
        print(response.data);
      }

      final data = response.data;

      // 🔹 Caso 1: backend retorna lista direta
      if (data is List) {
        return data.map((json) => ClassModel.fromJson(json)).toList();
      }

      // 🔹 Caso 2: backend retorna objeto paginado { items, itemCount }
      if (data is Map && data['items'] is List) {
        return (data['items'] as List)
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

  Future<List<ClassPack>> getClassPacks({
    required int schoolId,
    bool? featured,
  }) async {
    final response = await _dio.get(
      '/api/class-packs',
      queryParameters: {
        'school_id': schoolId,
        if (featured != null) 'featured': featured,
      },
    );
    debugPrint('RAW /api/class-packs RESPONSE: ${response.data}');
    final data = response.data;
    if (data is List) {
      return data.map((e) => ClassPack.fromJson(e)).toList();
    }
    if (data is Map && data['list'] is List) {
      return (data['list'] as List).map((e) => ClassPack.fromJson(e)).toList();
    }
    return [];
  }

  Future<EnrollmentValidation> getEnrollmentValidation({
    required int classId,
    required int studentId,
  }) async {
    try {
      final response = await _dio.get(
        '/api/classes/$classId/can-enroll',
        queryParameters: {
          'student_id': studentId,
        },
      );
      debugPrint('✅ RAW can-enroll RESPONSE: ${response.data}');

      if (response.data is Map<String, dynamic>) {
        return EnrollmentValidation.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      if (response.data is Map) {
        final map = Map<String, dynamic>.from(response.data as Map);
        return EnrollmentValidation.fromJson(map);
      }

      throw Exception('Unexpected can-enroll response format');
    } catch (e) {
      if (kDebugMode) {
        print('Error validating enrollment: $e');
      }
      rethrow;
    }
  }

  Future<void> purchasePack({
    required int packId,
    required int studentId,
    int quantity = 1,
  }) async {
    await _dio.post(
      '/api/class-packs/$packId/purchase',
      data: {
        'student_id': studentId,
        'quantity': quantity,
      },
    );
  }

  Future<Map<String, dynamic>> createPackPaymentIntent({
    required int packId,
    required int studentId,
  }) async {
    final response = await _dio.post(
      '/api/class-packs/$packId/payment-intent',
      data: {
        'student_id': studentId,
      },
    );
    return Map<String, dynamic>.from(response.data);
  }

  Future<ClassModel> getClassById(int classId) async {
    final res = await _dio.get('/api/classes/$classId');
    return ClassModel.fromJson(res.data);
  }

  Future<School> getSchoolById(int schoolId) async {
    final res = await _dio.get('/api/schools/$schoolId');
    return School.fromJson(res.data);
  }

  Future<List<ClassRule>> getClassRules(int classId) async {
    final response = await _dio.get('/api/classes/$classId/rules');

    if (response.data is List) {
      return (response.data as List).map((e) => ClassRule.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<ClassPackPurchase>> getStudentPacks(int studentId) async {
    final response = await _dio.get('/api/students/$studentId/packs');

    if (response.data is List) {
      return (response.data as List)
          .map((e) => ClassPackPurchase.fromJson(e))
          .toList();
    }
    return [];
  }

  Future<List<EquipmentWithPrice>> getAvailableEquipments() async {
    print('🌐 FULL URL = ${_dio.options.baseUrl}/api/equipment');
    debugPrint('🔑 TOKEN: ${_dio.options.headers['Authorization']}');
    final equipments = await getEquipment(); // List<EquipmentModel>
    final prices = await getEquipmentPrices(); // List<EquipmentWithPrice>

    final result = <EquipmentWithPrice>[];

    for (final eq in equipments) {
      if (!eq.active) continue;

      final price =
          prices.firstWhereOrNull((p) => p.equipmentId == eq.id && p.active!);

      if (price == null) continue;

      result.add(
        EquipmentWithPrice.fromEquipment(
          equipment: eq,
          amount: price.amount,
          priceModel: price.priceModel,
        ),
      );
    }

    return result;
  }

  Future<List<EquipmentPrice>> getEquipmentPrices() async {
    print('🌐 FULL URL = ${_dio.options.baseUrl}/api/equipment-prices');
    debugPrint('🔑 TOKEN: ${_dio.options.headers['Authorization']}');

    final response = await _dio.get('/api/equipment-prices');
    final data = response.data;

    // ✅ Caso ideal: já é uma lista
    if (data is List) {
      return data.map((e) => EquipmentPrice.fromJson(e)).toList();
    }

    // 🔥 Caso atual: backend manda JSON como String
    if (data is String) {
      final decoded = jsonDecode(data);

      if (decoded is List) {
        return decoded.map((e) => EquipmentPrice.fromJson(e)).toList();
      }
    }

    debugPrint('Unexpected equipment-prices response: $data');
    return [];

    // Fallback
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

  Future<void> enrollStudentInClass({
    required int classId,
    required int studentId,
  }) async {
    try {
      await _dio.post(
        '/api/classes/$classId/enroll',
        data: {
          'student_id': studentId,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error enrolling student in class: $e');
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
        return allRentals
            .where((rental) => rental.studentId == studentId)
            .toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching student rentals: $e');
      }
      rethrow;
    }
  }

  Future<RentalReceipt> getRentalReceipt(List<int> rentalIds) async {
    final response = await _dio.post(
      '/api/rentals/receipt',
      data: {'rental_ids': rentalIds},
    );

    return RentalReceipt.fromJson(response.data);
  }

  Future<RentalModel> createRental({
    required int schoolId,
    required int studentId,
    required int equipmentId,
    int quantity = 1,
    required DateTime startDate,
    required DateTime endDate,
    String? notes,
  }) async {
    try {
      final payload = <String, dynamic>{
        'school_id': schoolId,
        'student_id': studentId,
        'equipment_id': equipmentId,
        'quantity': quantity,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      };

      print('CREATE RENTAL na api: ${payload.values}');
      final response = await _dio.post('/api/rentals', data: payload);
      return RentalModel.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ STATUS: ${e.response?.statusCode}');
      print('❌ DATA: ${e.response?.data}');
      // print('❌ PAYLOAD ENVIADO: ${payload.values}');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createRentalPaymentIntent({
    required int studentId,
    required List<Map<String, dynamic>> items,
    required String startDate,
    required String endDate,
    String? customerEmail,
  }) async {
    final response = await _dio.post(
      '/api/rentals/payment-intent',
      data: {
        'student_id': studentId,
        'items': items,
        'start_date': startDate,
        'end_date': endDate,
        if (customerEmail != null && customerEmail.isNotEmpty)
          'customer_email': customerEmail,
      },
    );
    return Map<String, dynamic>.from(response.data);
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

  Future<Map<String, dynamic>> getStripePayment(
      {required String paymentIntentId}) async {
    final response = await _dio.get(
      '/api/stripe-payments/$paymentIntentId',
    );
    return Map<String, dynamic>.from(response.data);
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

  Future<ClassStudentModel> addStudentToClass(
      int classId, int studentId) async {
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

  Future<StudentProfile> getCurrentUserProfile() async {
    try {
      final response = await _dio.get('/api/auth/me');

      // debugPrint('🧪 RAW /api/auth/me RESPONSE: ${response.data}');

      if (response.data is Map &&
          response.data['profile'] is Map<String, dynamic>) {
        final profileJson = Map<String, dynamic>.from(response.data['profile']);

        final student = StudentProfile.fromJson(profileJson);

        // debugPrint('✅ Parsed StudentProfile: ${student.toJson()}');

        return student;
      }

      // if (response.data is Map && response.data.containsKey('profile')) {
      //   final map = Map<String, dynamic>.from(response.data as Map);
      //   debugPrint('✅ Parsed Map for StudentProfile: $map');
      //   return StudentProfile.fromJson(map);
      // }
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
      final response =
          await _dio.put('/api/students/${student.id}', data: payload);
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
