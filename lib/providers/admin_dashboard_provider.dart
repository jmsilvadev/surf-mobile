import 'package:flutter/material.dart';
import 'package:surf_mobile/models/admin_dashboard_model.dart';
import 'package:surf_mobile/services/api_service.dart';

class AdminDashboardProvider extends ChangeNotifier {
  final ApiService service;

  AdminDashboardProvider(this.service);

  AdminDashboardResponse? _data;
  bool _isLoading = false;
  String? _error;

  AdminDashboardResponse? get data => _data;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AdminDashboardStats? get stats => _data?.stats;
  List<ClassesPerMonth> get classesPerMonth =>
      _data?.charts.classesPerMonth ?? [];

  List<RevenueByType> get revenueByType => _data?.charts.revenueByType ?? [];

  List<TopEquipment> get topEquipments => _data?.charts.topEquipment ?? [];

  Future<void> load() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _data = await service.getDashboard();
    } catch (e, stack) {
      // _error = 'Failed to load admin dashboard';
      debugPrint('❌ ADMIN DASHBOARD ERROR: $e');
      debugPrintStack(stackTrace: stack);
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void refresh() {
    load();
  }
}
