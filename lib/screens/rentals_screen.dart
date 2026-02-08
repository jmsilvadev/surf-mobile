import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:surf_mobile/models/EquipmentWithPrice.dart';
import 'package:surf_mobile/models/rental_model.dart';
import 'package:surf_mobile/models/rental_receipt_model.dart';
import 'package:surf_mobile/screens/rental_receipt_screen.dart';
import 'package:surf_mobile/services/api_service.dart';

import 'package:surf_mobile/services/user_provider.dart';

class RentalsScreen extends StatefulWidget {
  const RentalsScreen({super.key});

  @override
  State<RentalsScreen> createState() => _RentalsScreenState();
}

class _RentalsScreenState extends State<RentalsScreen> {
  List<EquipmentWithPrice> equipments = [];
  final Map<int, int> selected = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadEquipments();
  }

  Future<void> loadEquipments() async {
    final api = context.read<ApiService>();

    final data = await api.getAvailableEquipments();

    setState(() {
      equipments = data;
      loading = false;
    });
  }

  double get total {
    double sum = 0;
    for (final eq in equipments) {
      final qty = selected[eq.id] ?? 0;
      sum += qty * eq.amount;
    }
    return sum;
  }

  String? resolveImageUrl(String? url) {
    if (url == null) return null;

    if (url.contains('localhost')) {
      return url.replaceFirst('localhost', '10.0.2.2');
    }

    return url;
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Rent Equipment')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: equipments.length,
        itemBuilder: (context, index) {
          final eq = equipments[index];
          final qty = selected[eq.id] ?? 0;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  /// TOPO: imagem + descrição
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// IMAGEM
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: eq.photoUrl != null && eq.photoUrl!.isNotEmpty
                            ? Image.network(
                                resolveImageUrl(eq.photoUrl!)!,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.image_not_supported),
                              )
                            : const Icon(Icons.image, size: 40),
                      ),

                      const SizedBox(width: 12),

                      /// NOME + DESCRIÇÃO
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              eq.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              eq.description?.isNotEmpty == true
                                  ? eq.description!
                                  : 'Sem descrição',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  const Divider(),

                  /// DISPONIBILIDADE + PREÇO
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Disponível: ${eq.availableQuantity}'),
                      Text(
                        '€ ${eq.amount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  /// CONTROLE DE QUANTIDADE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: qty > 0
                            ? () => setState(() => selected[eq.id] = qty - 1)
                            : null,
                      ),
                      Text(
                        qty.toString(),
                        style: const TextStyle(fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: qty < eq.availableQuantity
                            ? () => setState(() => selected[eq.id] = qty + 1)
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: selected.isEmpty ? null : () => submitRental(),
          child: Text('Confirm Rental (€${total.toStringAsFixed(2)})'),
        ),
      ),
    );
  }

  Future<void> submitRental() async {
    final api = context.read<ApiService>();
    final user = context.read<UserProvider>();

    if (user.schoolId == null || user.schoolId == 0) {
      throw Exception('SchoolID inválido');
    }
    if (user.studentId == null || user.studentId == 0) {
      throw Exception('StudentID inválido');
    }

    if (user.schoolId == null || user.studentId == null) {
      throw Exception('User not properly initialized');
    }

    print('START CREATE RENTALS:');

    final createdRentals = <RentalModel>[];

    for (final entry in selected.entries) {
      final eq = equipments.firstWhere((e) => e.id == entry.key);

      if (eq.amount <= 0) {
        print('Equipamento sem preço ativo');
        throw Exception('Equipamento sem preço ativo');
      }

      print('CREATE RENTAL PAYLOAD:');

      final startDate = DateTime.now().toUtc();
      final endDate = startDate.add(const Duration(days: 1));

      final rental = await api.createRental(
        schoolId: user.schoolId!,
        studentId: user.studentId!,
        equipmentId: entry.key,
        quantity: entry.value,
        startDate: startDate,
        endDate: endDate,
        notes: 'Rental via mobile',
      );

      createdRentals.add(rental);
    }

    final ids = createdRentals.map((r) => r.id).toList();

    final apiReceipt = await api.getRentalReceipt(ids);

    //final user = context.read<UserProvider>();
    final student = user.profile!;
    //final school = student.school;

// 🧾 Receipt FINAL (igual ao frontend)
    final receipt = RentalReceipt(
      school: apiReceipt.school,
      rentals: apiReceipt.rentals,
      total: apiReceipt.total,
      createdAt: apiReceipt.createdAt,
      student: StudentReceipt(
        name: student.name,
        skillLevel: student.skillLevel!,
      ),
    );

// agora sim
    await RentalReceiptPdf.generate(receipt);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rental completed')),
    );

    selected.clear();
    loadEquipments();
  }
}
