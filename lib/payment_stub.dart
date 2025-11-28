class Stripe {
  static String publishableKey = '';
  static Stripe get instance => Stripe();
  Future<void> applySettings() async {}
  Future<void> initPaymentSheet({dynamic paymentSheetParameters}) async {}
  Future<void> presentPaymentSheet() async {}
}

class SetupPaymentSheetParameters {
  SetupPaymentSheetParameters({
    required String paymentIntentClientSecret,
    required String merchantDisplayName,
    required dynamic style,
    required PaymentSheetAppearance appearance,
  });
}

class PaymentSheetAppearance {
  PaymentSheetAppearance({required PaymentSheetAppearanceColors colors});
}

class PaymentSheetAppearanceColors {
  PaymentSheetAppearanceColors({required dynamic primary});
}

class StripeException implements Exception {
  final StripeError error;
  StripeException(this.error);
}

class StripeError {
  final String localizedMessage;
  StripeError(this.localizedMessage);
}
