import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import 'package:provider/provider.dart';
import 'package:surf_mobile/helpers/currency_formatter.dart';
import 'package:surf_mobile/models/class_pack_model.dart';
import 'package:surf_mobile/providers/class_pack_provider.dart';
import 'package:surf_mobile/providers/navigation_provider.dart';
import 'package:surf_mobile/services/stripe_service.dart';
import 'package:surf_mobile/services/api_service.dart';
import 'package:surf_mobile/services/user_provider.dart';
// Importe onde sua ClassCalendar está localizada:

class PackDetailScreen extends StatefulWidget {
  // Mudamos para StatefulWidget para gerenciar o estado do botão
  final ClassPack pack;

  const PackDetailScreen({super.key, required this.pack});

  @override
  State<PackDetailScreen> createState() => _PackDetailScreenState();
}

class _PackDetailScreenState extends State<PackDetailScreen> {
  bool _isPurchasing = false;
  @override
  Widget build(BuildContext context) {
    final stripe = context.read<StripeService>();
    final api = context.read<ApiService>();
    final user = context.read<UserProvider>();
    return Scaffold(
      appBar: AppBar(title: Text(widget.pack.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Substitua o Image.network original por este:
          widget.pack.heroImageUrl != null &&
                  widget.pack.heroImageUrl!.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.pack.heroImageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    // Exibe algo enquanto a imagem carrega
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                    // Caso a URL seja inválida ou falhe a conexão
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image,
                            size: 50, color: Colors.grey),
                      );
                    },
                  ),
                )
              : Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported,
                      size: 50, color: Colors.grey),
                ),
          const SizedBox(height: 16),
          Text(widget.pack.description ?? ''),
          const SizedBox(height: 16),
          if (widget.pack.benefits.isNotEmpty)
            ...widget.pack.benefits.map(
              (b) => ListTile(
                leading: const Icon(Icons.check, color: Colors.green),
                title: Text(b),
              ),
            ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isPurchasing
                  ? null
                  : () async {
                      setState(() => _isPurchasing = true);

                      try {
                        final studentId = user.studentId;
                        if (studentId == null) {
                          throw Exception('Usuário não identificado.');
                        }

                        final checkout = await api.createPackPaymentIntent(
                          packId: widget.pack.id,
                          studentId: studentId,
                        );
                        final clientSecret =
                            stripe.parseClientSecret(checkout);
                        final paymentIntentId =
                            checkout['payment_intent_id'];
                        if (paymentIntentId is! String ||
                            paymentIntentId.isEmpty) {
                          throw Exception(
                            'Resposta inválida: payment_intent_id ausente.',
                          );
                        }
                        await stripe.presentPaymentSheet(clientSecret);

                        final status = await _waitForStripePaymentStatus(
                          api,
                          paymentIntentId,
                        );
                        if (status != 'succeeded') {
                          throw Exception(
                            'Pagamento não confirmado (status: $status).',
                          );
                        }

                        if (!mounted) return;

                        final schoolId = user.schoolId;
                        if (schoolId != null) {
                          await context
                              .read<ClassPackProvider>()
                              .load(schoolId);
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pagamento concluído.'),
                            backgroundColor: Colors.green,
                          ),
                        );

                        setState(() => _isPurchasing = false);

                        context.read<NavigationProvider>().setIndex(0);
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      } on StripeException catch (e) {
                        setState(() => _isPurchasing = false);
                        if (e.error.code == FailureCode.Canceled) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Pagamento cancelado.')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Erro no pagamento: ${e.error.message}',
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        setState(() => _isPurchasing = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error purchasing: $e')),
                        );
                      }
                    },
              child: _isPurchasing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Buy for ${CurrencyFormatter.euro(widget.pack.price)}'),
            ),
          ),
        ],
      ),
    );
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
