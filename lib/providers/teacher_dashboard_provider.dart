import 'package:flutter/material.dart';
import 'package:surf_mobile/models/class_model.dart';
import 'package:surf_mobile/services/api_service.dart';
import 'package:surf_mobile/services/user_provider.dart';

class TeacherDashboardProvider extends ChangeNotifier {
  final ApiService _api;
  final UserProvider _user;

  TeacherDashboardProvider(this._api, this._user);

  bool isLoading = false;
  String? error;

  List<ClassModel> _classes = [];

  List<ClassModel> get classes => _classes;

  List<ClassModel> get upcoming => _classes
      .where((c) => c.status == 'scheduled' || c.status == 'in_progress')
      .toList();

  List<ClassModel> get completed =>
      _classes.where((c) => c.status == 'completed').toList();

  int get totalClassesGiven => completed.length;

  int get totalClassesToGive => upcoming.length;

  int get totalUniqueStudents {
    final ids = <int>{};
    for (var c in completed) {
      for (var s in c.students ?? []) {
        ids.add(s.id);
      }
    }
    return ids.length;
  }

  Future<void> load() async {
    final teacher = _user.teacherProfile;
    if (teacher == null) return;

    try {
      isLoading = true;
      notifyListeners();

      final all = await _api.getClasses();
      _classes = all.where((c) => c.teacherId == teacher.id).toList();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
