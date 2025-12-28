import 'package:flutter/foundation.dart';
import 'package:surf_mobile/models/class_pack_model.dart';
import 'package:surf_mobile/models/class_pack_purchase_model.dart';
import 'package:surf_mobile/services/user_provider.dart';
import '../services/api_service.dart';

class ClassPackProvider extends ChangeNotifier {
  final ApiService api;
  final UserProvider userProvider;

  ClassPackProvider(this.api, this.userProvider);

  bool isLoading = false;

  List<ClassPack> packs = [];
  List<ClassPackPurchase> purchases = [];

  String get headline {
    final skill = userProvider.studentSkillSlug;
    switch (skill) {
      case 'kids':
        return 'Packs for Kids';
      case 'iniciante':
        return 'Packs for Beginners';
      case 'intermediario':
        return 'Packs for Intermediate';
      case 'avancado':
        return 'Advanced Packs';
      default:
        return 'Choose your Pack';
    }
  }

  /// ✅ SALDO REAL (vem da API)
  int get availableLessons =>
      purchases.fold(0, (sum, p) => sum + p.availableLessons);

  bool get hasCredits => availableLessons > 0;

  Future<void> load(int schoolId) async {
    isLoading = true;
    notifyListeners();

    packs = await api.getClassPacks(
      schoolId: schoolId,
      featured: true,
    );

    final studentId = userProvider.studentId;
    if (studentId != null) {
      purchases = await api.getStudentPacks(studentId);
    }

    isLoading = false;
    notifyListeners();
  }

  List<ClassPack> get visiblePacks {
    final skill = userProvider.studentSkillSlug;
    return packs.where((p) {
      if (skill == null || p.skillLevel == null) return true;
      return p.skillLevel!.slug == skill ||
          (skill == 'avancado' &&
              ['iniciante', 'intermediario', 'avancado']
                  .contains(p.skillLevel!.slug));
    }).toList();
  }

  Future<void> buyPack(ClassPack pack) async {
    final studentId = userProvider.studentId;
    if (studentId == null) return;

    await api.purchasePack(
      packId: pack.id,
      studentId: studentId,
    );

    purchases = await api.getStudentPacks(studentId);
    notifyListeners();
  }
}
