import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mob_edu/services/payment_service.dart';

class PremiumUpgradeScreen extends StatefulWidget {
  final int? userId;
  final String? sessionId; // For when returning from Stripe

  const PremiumUpgradeScreen({Key? key, required this.userId, this.sessionId})
    : super(key: key);

  @override
  State<PremiumUpgradeScreen> createState() => _PremiumUpgradeScreenState();
}

class _PremiumUpgradeScreenState extends State<PremiumUpgradeScreen> {
  bool _isLoading = false;
  bool _isPremium = false;
  bool _isVerifying = false;
  String? _verificationMessage;

  @override
  void initState() {
    super.initState();

    // If sessionId is present, user returned from payment
    if (widget.sessionId != null) {
      _verifyPaymentAndCheckStatus();
    } else {
      _checkPremiumStatus();
    }
  }

  Future<void> _verifyPaymentAndCheckStatus() async {
    setState(() {
      _isVerifying = true;
      _verificationMessage = 'Verifying your payment...';
    });

    // Wait for webhook to process
    await Future.delayed(const Duration(seconds: 2));

    try {
      // For web, verify the checkout session
      if (kIsWeb && widget.sessionId != null) {
        final verified = await PaymentService.verifyCheckoutSession(
          sessionId: widget.sessionId!,
        );

        setState(() {
          _isPremium = verified;
          _isVerifying = false;
          _verificationMessage = verified
              ? 'Payment successful! You are now Premium!'
              : 'Payment verification in progress...';
        });

        if (verified && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successfully upgraded to Premium!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isVerifying = false;
        _verificationMessage = 'Error verifying payment';
      });
    }
  }

  Future<void> _checkPremiumStatus() async {
    final isPremium = await PaymentService.checkIfPremium(
      userId: widget.userId,
    );
    if (mounted) {
      setState(() => _isPremium = isPremium);
    }
  }

  Future<void> _handleUpgrade() async {
    setState(() => _isLoading = true);

    try {
      final success = await PaymentService.upgradeToPremium(
        context: context,
        userId: widget.userId,
      );

      // For mobile, check status immediately after payment
      if (!kIsWeb && success) {
        await Future.delayed(const Duration(seconds: 2));
        await _checkPremiumStatus();
      }

      // For web, don't do anything - user will be redirected
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isVerifying ? 'Payment Verification' : 'Premium Upgrade'),
      ),
      body: _isVerifying
          ? _buildVerifying()
          : (_isPremium ? _buildPremiumActive() : _buildUpgradeOffer()),
    );
  }

  Widget _buildVerifying() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            _verificationMessage ?? 'Verifying...',
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumActive() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: 100, color: Colors.green),
          const SizedBox(height: 24),
          const Text(
            'You are Premium!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Enjoy all premium features',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              backgroundColor: Colors.blue,
            ),
            child: const Text(
              'Continue',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeOffer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.workspace_premium_outlined,
            size: 80,
            color: Colors.amber[700],
          ),
          const SizedBox(height: 24),
          const Text(
            'Upgrade to Premium',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildFeature('Remove all ads'),
          _buildFeature('Unlimited access'),
          _buildFeature('Priority support'),
          _buildFeature('Exclusive features'),
          const SizedBox(height: 48),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue),
            ),
            child: const Column(
              children: [
                Text(
                  '\$5.00',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Text('one-time payment', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleUpgrade,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Upgrade Now',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
