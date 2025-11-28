import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mob_edu/config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentService {
  static const String baseUrlpay = '$baseUrl/api';

  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");

    final _publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'];
    if (_publishableKey == null) {
      throw Exception('Stripe publishable key is missing in .env');
    }

    Stripe.publishableKey = _publishableKey;
    await Stripe.instance.applySettings();

    print('Stripe initialized for ${kIsWeb ? 'Web' : 'Mobile'}');
  }

  static Future<bool> upgradeToPremium({
    required BuildContext context,
    required int? userId,
  }) async {
    try {
      if (kIsWeb) {
        return await _handleWebPayment(context, userId);
      } else {
        return await _handleMobilePayment(context, userId);
      }
    } on StripeException catch (e) {
      debugPrint('Stripe error: ${e.error.localizedMessage}');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${e.error.localizedMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    } catch (e) {
      debugPrint('Payment error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }

  // WEB: Open Stripe Checkout in new window
  static Future<bool> _handleWebPayment(
    BuildContext context,
    int? userId,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrlpay/create-checkout-session'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId, 'amount': 500, 'currency': 'usd'}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create checkout session');
    }

    final data = jsonDecode(response.body);
    final checkoutUrl = data['url'];

    if (checkoutUrl != null) {
      final uri = Uri.parse(checkoutUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Redirecting to payment page...'),
              backgroundColor: Colors.blue,
            ),
          );
        }
        return true;
      }
    }
    throw Exception('Failed to open payment page');
  }

  // MOBILE: Use Stripe Payment Sheet
  static Future<bool> _handleMobilePayment(
    BuildContext context,
    int? userId,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrlpay/create-payment-intent'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId, 'amount': 500, 'currency': 'usd'}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create payment intent');
    }

    final data = jsonDecode(response.body);
    final clientSecret = data['clientSecret'];

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'Your App Name',
        style: ThemeMode.system,
      ),
    );

    await Stripe.instance.presentPaymentSheet();

    // Wait for webhook to process (give it 3 seconds)
    await Future.delayed(const Duration(seconds: 3));

    // Check if premium was activated
    final isPremium = await checkIfPremium(userId: userId);

    if (context.mounted) {
      if (isPremium) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully upgraded to Premium!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Payment processing. Please check your status in a moment.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }

    return isPremium;
  }

  // Check premium status from database
  static Future<bool> checkIfPremium({required int? userId}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrlpay/premium-status/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['is_premium'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('Status check error: $e');
      return false;
    }
  }

  // For web: verify checkout session after redirect
  static Future<bool> verifyCheckoutSession({required String sessionId}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrlpay/verify-checkout-session/$sessionId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['is_premium'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('Checkout verification error: $e');
      return false;
    }
  }
}
