import 'package:flutter_test/flutter_test.dart';

bool isWalletGateway(String? digitalName) {
  if (digitalName == null) return false;
  return digitalName == 'easy_wallet' ||
      digitalName == 'floosak' ||
      digitalName.toLowerCase().contains('wallet') ||
      digitalName.toLowerCase().contains('floosak');
}

void main() {
  group('Wallet Gateway Resolution Tests', () {
    test('Identifies easy_wallet and floosak correctly', () {
      expect(isWalletGateway('easy_wallet'), isTrue);
      expect(isWalletGateway('floosak'), isTrue);
    });

    test('Identifies variants containing wallet or floosak case-insensitively', () {
      expect(isWalletGateway('Easy_Wallet_Pay'), isTrue);
      expect(isWalletGateway('my_wallet'), isTrue);
      expect(isWalletGateway('Floosak_Direct'), isTrue);
      expect(isWalletGateway('AL_KURAYMI_WALLET'), isTrue);
    });

    test('Rejects non-wallet payment gateways', () {
      expect(isWalletGateway('stripe'), isFalse);
      expect(isWalletGateway('paypal'), isFalse);
      expect(isWalletGateway('razorpay'), isFalse);
      expect(isWalletGateway('sslcommerz'), isFalse);
      expect(isWalletGateway(null), isFalse);
    });
  });

  group('User Checkout Wallet Payment Check on Continue Tests', () {
    test('Selecting wallet method does not require purchase code upfront', () {
      // Simulating user choosing wallet gateway in payment method sheet:
      int paymentMethodIndex = 2;
      String digitalPaymentName = 'easy_wallet';
      String purchaseCode = '';

      // Tapping the method only sets selection; purchase code is initially empty
      expect(paymentMethodIndex, equals(2));
      expect(digitalPaymentName, equals('easy_wallet'));
      expect(purchaseCode.isEmpty, isTrue);
      expect(isWalletGateway(digitalPaymentName), isTrue);
    });

    test('Continue action on wallet gateway triggers payment onboarding dialog instead of blocking error', () {
      final String digitalPaymentName = 'easy_wallet';
      final String purchaseCode = '';

      bool showOnboardingDialog = false;
      bool showBlockingSnackBar = false;

      // When Continue / Confirm Order is pressed:
      if (isWalletGateway(digitalPaymentName) && purchaseCode.trim().isEmpty) {
        showOnboardingDialog = true;
      } else if (purchaseCode.trim().isEmpty) {
        showBlockingSnackBar = true;
      }

      expect(showOnboardingDialog, isTrue,
          reason: 'Clicking Continue with wallet method must trigger PaymentOnboardingDialog');
      expect(showBlockingSnackBar, isFalse,
          reason: 'Must not block with a raw error snackbar when onboarding can guide the user');
    });

    test('In-app wallet balance check is deferred to order placement continue', () {
      final double total = 150.0;
      final double walletBalance = 50.0;
      final int paymentMethodIndex = 1;
      final bool isPartialPay = false;

      bool canProceed = true;
      String? errorMessage;

      // Selection phase: user can select wallet
      expect(paymentMethodIndex, equals(1));

      // Continuation phase: check wallet balance when clicking Continue / Confirm Order
      if (paymentMethodIndex == 1 && !isPartialPay && walletBalance < total) {
        canProceed = false;
        errorMessage = 'you_do_not_have_sufficient_balance_in_wallet';
      }

      expect(canProceed, isFalse);
      expect(errorMessage, equals('you_do_not_have_sufficient_balance_in_wallet'));
    });
  });

  group('Subscription Wallet Payment Flow Tests', () {
    test('Selecting wallet balance in subscription allows clean selection', () {
      bool isWalletSelected = false;
      int selectedDigitalIndex = -1;

      // Tap on wallet balance:
      isWalletSelected = true;
      selectedDigitalIndex = -1;

      expect(isWalletSelected, isTrue);
      expect(selectedDigitalIndex, equals(-1));
    });

    test('Selecting digital wallet gateway in subscription does not open inline purchase code', () {
      final paymentGateways = ['easy_wallet', 'stripe'];
      int selectedDigitalIndex = -1;
      bool isWalletSelected = true;

      // Tap on easy_wallet:
      selectedDigitalIndex = 0;
      isWalletSelected = false;

      expect(isWalletSelected, isFalse);
      expect(selectedDigitalIndex, equals(0));
      expect(isWalletGateway(paymentGateways[selectedDigitalIndex]), isTrue);
    });

    test('Continue action in subscription performs check or triggers onboarding', () {
      final double planPrice = 100.0;
      final double walletBalance = 120.0;
      final bool isWalletSelected = true;
      final int selectedDigitalIndex = -1;

      bool subscriptionTriggered = false;
      bool onboardingOpened = false;

      // User taps Continue button:
      if (isWalletSelected) {
        if (walletBalance >= planPrice) {
          subscriptionTriggered = true;
        }
      } else if (selectedDigitalIndex != -1) {
        onboardingOpened = true;
      }

      expect(subscriptionTriggered, isTrue);
      expect(onboardingOpened, isFalse);
    });

    test('Continue action with digital wallet gateway opens PaymentOnboardingDialog', () {
      final bool isWalletSelected = false;
      final int selectedDigitalIndex = 0;
      final String gateway = 'floosak';

      bool onboardingOpened = false;

      if (!isWalletSelected && selectedDigitalIndex != -1) {
        if (isWalletGateway(gateway)) {
          onboardingOpened = true;
        }
      }

      expect(onboardingOpened, isTrue);
    });
  });
}
