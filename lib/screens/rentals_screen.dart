import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import 'package:provider/provider.dart';

import 'package:surf_mobile/models/EquipmentWithPrice.dart';
import 'package:surf_mobile/providers/navigation_provider.dart';
import 'package:surf_mobile/services/api_service.dart';
import 'package:surf_mobile/services/stripe_service.dart';
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
  bool submitting = false;
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
          onPressed: (selected.isEmpty || submitting)
              ? null
              : () => submitRental(),
          child: submitting
              ? const CircularProgressIndicator(color: Colors.white)
              : Text('Confirm Rental (€${total.toStringAsFixed(2)})'),
        ),
      ),
    );
  }

  Future<void> submitRental() async {
    final api = context.read<ApiService>();
    final user = context.read<UserProvider>();
    final stripe = context.read<StripeService>();

    if (user.studentId == null || user.studentId == 0) {
      throw Exception('StudentID inválido');
    }

    if (user.studentId == null) {
      throw Exception('User not properly initialized');
    }

    setState(() => submitting = true);

    try {
      final amount = total;
      if (amount <= 0) {
        throw Exception('Equipamento sem preço ativo');
      }
      if (amount > 0) {
        final items = selected.entries
            .map((entry) => {
                  'equipment_id': entry.key,
                  'quantity': entry.value,
                })
            .toList();

        final startDate = DateTime.now().toUtc();
        final endDate = startDate.add(const Duration(days: 1));

        final checkoutResponse = await api.createRentalPaymentIntent(
          studentId: user.studentId!,
          items: items,
          startDate: _formatDate(startDate),
          endDate: _formatDate(endDate),
          customerEmail: user.userEmail,
        );
        final response = Map<String, dynamic>.from(checkoutResponse);
        final clientSecret = stripe.parseClientSecret(response);
        final paymentIntentId = response['payment_intent_id'];
        if (paymentIntentId is! String || paymentIntentId.isEmpty) {
          throw Exception('Resposta inválida: payment_intent_id ausente.');
        }
        await stripe.presentPaymentSheet(clientSecret);

        final status = await _waitForStripePaymentStatus(
          api,
          paymentIntentId,
        );
        if (status != 'succeeded') {
          throw Exception('Pagamento não confirmado (status: $status).');
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pagamento concluído.'),
        ),
      );

      selected.clear();
      loadEquipments();

      context.read<NavigationProvider>().setIndex(0);
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pagamento cancelado.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro no pagamento: ${e.error.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error renting equipment: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => submitting = false);
      }
    }
  }
}

Future<String> _waitForStripePaymentStatus(
  ApiService api,
  String paymentIntentId,
) async {
  const attempts = 12;
  const delay = Duration(seconds: 2);

  for (var i = 0; i < attempts; i++) {
    final payment = await api.getStripePayment(
      paymentIntentId: paymentIntentId,
    );
    final status = payment['status'];
    if (status is String && status.isNotEmpty && status != 'pending') {
      return status;
    }
    await Future.delayed(delay);
  }
  return 'pending';
}

String _formatDate(DateTime date) {
  final local = date.toLocal();
  final year = local.year.toString().padLeft(4, '0');
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
