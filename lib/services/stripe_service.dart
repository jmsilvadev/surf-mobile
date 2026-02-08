import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:surf_mobile/config/app_config.dart';

class StripeService {
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    final publishableKey = AppConfig.stripePublishableKey;
    if (publishableKey.isEmpty) {
      throw Exception('STRIPE_PUBLISHABLE_KEY não configurado no .env');
    }

    debugPrint(
      'Stripe init: publishableKey length=${publishableKey.length}',
    );
    Stripe.publishableKey = publishableKey;

    final merchantIdentifier = AppConfig.stripeMerchantIdentifier;
    if (merchantIdentifier.isNotEmpty) {
      Stripe.merchantIdentifier = merchantIdentifier;
    }

    try {
      await Stripe.instance.applySettings();
    } catch (e) {
      debugPrint('Stripe init failed: $e');
      rethrow;
    }
    _initialized = true;
  }

  String parseClientSecret(Map<String, dynamic> data) {
    final clientSecret = data['client_secret'] ??
        data['payment_intent_client_secret'] ??
        data['payment_intent'] ??
        data['paymentIntent'];

    if (clientSecret is! String || clientSecret.isEmpty) {
      throw Exception('Resposta inválida: client_secret ausente.');
    }
    return clientSecret;
  }

  Future<void> presentPaymentSheet(String clientSecret) async {
    await _ensureInitialized();

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'OceanDojo',
        style: ThemeMode.system,
      ),
    );

    await Stripe.instance.presentPaymentSheet();
  }
}
