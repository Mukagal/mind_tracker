import 'package:flutter/material.dart';
import 'package:mob_edu/services/payment_service.dart';

class PaymentSuccessPage extends StatefulWidget {
  final String? sessionId;

  const PaymentSuccessPage({Key? key, this.sessionId}) : super(key: key);

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  bool _isVerifying = true;
  bool _isSuccess = false;
  String _message = 'Verifying your payment...';
  String? _sessionId;

  @override
  void initState() {
    super.initState();
    _verifyPayment();
  }

  Future<void> _verifyPayment() async {
    if (_sessionId == null) {
      setState(() {
        _isVerifying = false;
        _message = 'Invalid payment session';
      });
      return;
    }

    // Wait a bit for webhook to process
    await Future.delayed(const Duration(seconds: 2));

    try {
      final verified = await PaymentService.verifyCheckoutSession(
        sessionId: _sessionId!,
      );

      setState(() {
        _isVerifying = false;
        _isSuccess = verified;
        _message = verified
            ? 'Payment successful! You are now a Premium member.'
            : 'Payment is being processed. Your premium status will be activated shortly.';
      });
    } catch (e) {
      setState(() {
        _isVerifying = false;
        _message = 'Error verifying payment. Please check your account status.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Status')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isVerifying)
                const CircularProgressIndicator()
              else
                Icon(
                  _isSuccess ? Icons.check_circle : Icons.error,
                  color: _isSuccess ? Colors.green : Colors.red,
                  size: 80,
                ),
              const SizedBox(height: 24),
              Text(
                _message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 32),
              if (!_isVerifying)
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/', (route) => false);
                  },
                  child: const Text('Go to Home'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
