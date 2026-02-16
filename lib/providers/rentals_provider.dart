import 'package:flutter/foundation.dart';
import 'package:surf_mobile/models/rental_model.dart';
import 'package:surf_mobile/services/api_service.dart';

class RentalsProvider extends ChangeNotifier {
  final ApiService api;

  RentalsProvider(this.api);

  bool isLoading = false;
  List<RentalModel> rentals = [];

  Future<void> loadStudentRentals(int studentId) async {
    isLoading = true;
    notifyListeners();
    try {
      // 1️⃣ Buscar rentals
      final rawRentals = await api.getStudentRentals(studentId);

      // 2️⃣ Buscar equipamentos (1 chamada só)
      final equipments = await api.getEquipment();

      // 3️⃣ Criar mapa equipmentId -> name
      final equipmentMap = {
        for (final e in equipments) e.id: e.name,
      };

      // 4️⃣ Enriquecer rentals
      rentals = rawRentals.map((rental) {
        return rental.copyWith(
          equipmentName: equipmentMap[rental.equipmentId],
        );
      }).toList();
    } catch (e) {
      debugPrint('Error loading rentals: $e');
      rentals = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }

    // 1️⃣ Buscar rentals
    // final rawRentals = await api.getStudentRentals(studentId);

    // // 2️⃣ Buscar equipamentos (1 chamada só)
    // final equipments = await api.getEquipment();

    // // 3️⃣ Criar mapa equipmentId -> name
    // final equipmentMap = {
    //   for (final e in equipments) e.id: e.name,
    // };

    // // 4️⃣ Enriquecer rentals
    // rentals = rawRentals.map((rental) {
    //   return rental.copyWith(
    //     equipmentName: equipmentMap[rental.equipmentId],
    //   );
    // }).toList();

    // isLoading = false;
    // notifyListeners();
  }
}
