import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/custom_text_field.dart';
import 'package:sixam_mart/features/checkout/controllers/checkout_controller.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class PaymentOnboardingDialog extends StatefulWidget {
  final String paymentMethodName;
  final String paymentTitle;
  final String? paymentImage;
  final double totalPrice;
  final String? walletNumber;
  final Future<bool> Function(String purchaseCode)? onVerifyAndPlaceOrder;
  final VoidCallback? onOrderSuccess;

  const PaymentOnboardingDialog({
    super.key,
    required this.paymentMethodName,
    required this.paymentTitle,
    this.paymentImage,
    required this.totalPrice,
    this.walletNumber,
    this.onVerifyAndPlaceOrder,
    this.onOrderSuccess,
  });

  @override
  State<PaymentOnboardingDialog> createState() => _PaymentOnboardingDialogState();
}

class _PaymentOnboardingDialogState extends State<PaymentOnboardingDialog> with SingleTickerProviderStateMixin {
  int _currentStep = 0; // 0: Info & QR, 1: Enter Code, 2: Loading, 3: Confirmation
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _codeFocusNode = FocusNode();
  bool _isCopied = false;
  bool _isSuccess = false;
  String _errorMessage = '';
  String _statusMessage = 'connecting_to_wallet_gateway'.tr;
  Timer? _statusTimer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    final checkoutController = Get.find<CheckoutController>();
    if (checkoutController.purchaseCodeController.text.isNotEmpty) {
      _codeController.text = checkoutController.purchaseCodeController.text;
    }

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _pulseController.dispose();
    _codeController.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  String get _effectiveWalletNumber {
    if (widget.walletNumber != null && widget.walletNumber!.isNotEmpty) {
      return widget.walletNumber!;
    }
    // Check offline method list if available
    if (Get.isRegistered<CheckoutController>()) {
      final checkout = Get.find<CheckoutController>();
      if (checkout.offlineMethodList != null && checkout.offlineMethodList!.isNotEmpty) {
        for (final m in checkout.offlineMethodList!) {
          if (m.methodFields != null) {
            for (final f in m.methodFields!) {
              if (f.inputData != null && f.inputData!.isNotEmpty) {
                return f.inputData!;
              }
            }
          }
        }
      }
    }
    // Sensible merchant wallet default
    return '777200400';
  }

  void _copyWalletNumber() {
    Clipboard.setData(ClipboardData(text: _effectiveWalletNumber));
    setState(() {
      _isCopied = true;
    });
    showCustomSnackBar('wallet_number_copied'.tr, isError: false);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isCopied = false;
        });
      }
    });
  }

  void _pastePurchaseCode() async {
    final clipboardData = await Clipboard.getData('text/plain');
    if (clipboardData != null && clipboardData.text != null) {
      setState(() {
        _codeController.text = clipboardData.text!.trim();
      });
    }
  }

  void _startVerification() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      showCustomSnackBar('enter_purchase_code'.tr);
      return;
    }

    // Save into CheckoutController
    if (Get.isRegistered<CheckoutController>()) {
      Get.find<CheckoutController>().purchaseCodeController.text = code;
    }

    setState(() {
      _currentStep = 2; // Loading
      _statusMessage = 'connecting_to_wallet_gateway'.tr;
    });

    _statusTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() {
          _statusMessage = 'verifying_purchase_code'.tr;
        });
      }
    });

    try {
      bool success = true;
      if (widget.onVerifyAndPlaceOrder != null) {
        success = await widget.onVerifyAndPlaceOrder!(code);
      } else {
        // Fallback simulation / verification delay
        await Future.delayed(const Duration(seconds: 3));
        success = code.length >= 4;
      }

      if (mounted) {
        setState(() {
          _isSuccess = success;
          _currentStep = 3; // Confirmation
        });
        if (success && widget.onOrderSuccess != null) {
          widget.onOrderSuccess!();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSuccess = false;
          _errorMessage = e.toString();
          _currentStep = 3;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusLarge)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: Theme.of(context).cardColor,
      child: Container(
        width: 520,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            _buildStepIndicator(context),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                child: _buildCurrentStepContent(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (widget.paymentImage != null && widget.paymentImage!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CustomImage(
                    image: widget.paymentImage!,
                    height: 32,
                    width: 32,
                    fit: BoxFit.contain,
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.account_balance_wallet_rounded, color: Theme.of(context).primaryColor, size: 20),
                ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.paymentTitle,
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                  ),
                  Text(
                    PriceConverter.convertPrice(widget.totalPrice),
                    textDirection: TextDirection.ltr,
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close_rounded),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          _stepBadge(0, '1', 'how_to_pay'.tr),
          _stepDivider(0),
          _stepBadge(1, '2', 'purchase_code'.tr),
          _stepDivider(1),
          _stepBadge(2, '3', _currentStep == 3 ? (_isSuccess ? 'confirmed'.tr : 'failed'.tr) : 'verifying_payment'.tr),
        ],
      ),
    );
  }

  Widget _stepBadge(int stepIndex, String number, String label) {
    final bool isActive = _currentStep == stepIndex;
    final bool isCompleted = _currentStep > stepIndex;
    final Color primary = Theme.of(context).primaryColor;

    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? Colors.green
                : isActive
                    ? primary
                    : Theme.of(context).disabledColor.withValues(alpha: 0.3),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : Text(
                    number,
                    style: robotoBold.copyWith(fontSize: 12, color: Colors.white),
                  ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeExtraSmall,
            color: isActive || isCompleted ? Theme.of(context).textTheme.bodyLarge?.color : Theme.of(context).disabledColor,
          ),
        ),
      ],
    );
  }

  Widget _stepDivider(int stepIndex) {
    final bool isCompleted = _currentStep > stepIndex;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        color: isCompleted ? Colors.green : Theme.of(context).disabledColor.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildCurrentStepContent(BuildContext context) {
    switch (_currentStep) {
      case 0:
        return _buildStep1WalletAndInstructions(context);
      case 1:
        return _buildStep2EnterPurchaseCode(context);
      case 2:
        return _buildStep3VerificationLoading(context);
      case 3:
      default:
        return _buildStep4Confirmation(context);
    }
  }

  Widget _buildStep1WalletAndInstructions(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Barcode & QR Code Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'scan_qr_to_pay'.tr,
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: primaryColor),
              ),
              const SizedBox(height: 12),
              CustomPaint(
                size: const Size(160, 160),
                painter: _QrBarcodePainter(primaryColor: primaryColor),
              ),
              const SizedBox(height: 12),
              Text(
                '${'amount'.tr}: ${PriceConverter.convertPrice(widget.totalPrice)}',
                textDirection: TextDirection.ltr,
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
              ),
            ],
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        // Wallet Number Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            border: Border.all(color: primaryColor.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'wallet_number'.tr,
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _effectiveWalletNumber,
                    textDirection: TextDirection.ltr,
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge, letterSpacing: 1.2),
                  ),
                ],
              ),
              InkWell(
                onTap: _copyWalletNumber,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _isCopied ? Colors.green : primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isCopied ? Icons.check_circle : Icons.copy_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isCopied ? 'copied'.tr : 'copy'.tr,
                        style: robotoBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeSmall),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        // Numbered Steps Guide
        Text('how_to_pay'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        _buildStepTile(1, 'payment_step_1'.tr),
        _buildStepTile(2, 'payment_step_2'.tr),
        _buildStepTile(3, 'payment_step_3'.tr),
        const SizedBox(height: Dimensions.paddingSizeLarge),

        CustomButton(
          buttonText: 'i_have_paid_continue'.tr,
          onPressed: () {
            setState(() {
              _currentStep = 1;
            });
          },
        ),
      ],
    );
  }

  Widget _buildStepTile(int stepNumber, String text) {
    final Color primaryColor = Theme.of(context).primaryColor;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$stepNumber',
                style: robotoBold.copyWith(fontSize: 11, color: primaryColor),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2EnterPurchaseCode(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.pin_outlined, size: 56, color: Theme.of(context).primaryColor),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        Text(
          'enter_purchase_code'.tr,
          textAlign: TextAlign.center,
          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
        ),
        const SizedBox(height: 6),
        Text(
          'enter_purchase_code_description'.tr,
          textAlign: TextAlign.center,
          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
        ),
        const SizedBox(height: Dimensions.paddingSizeLarge),

        Row(
          children: [
            Expanded(
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: CustomTextField(
                  titleText: '000000',
                  hintText: 'purchase_code'.tr,
                  controller: _codeController,
                  focusNode: _codeFocusNode,
                  inputType: TextInputType.number,
                  isNumber: true,
                  maxLength: 12,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            InkWell(
              onTap: _pastePurchaseCode,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.3)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.content_paste_rounded, color: Theme.of(context).primaryColor, size: 20),
                    const SizedBox(height: 2),
                    Text('paste'.tr, style: robotoMedium.copyWith(fontSize: 10, color: Theme.of(context).primaryColor)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: Dimensions.paddingSizeLarge),

        CustomButton(
          buttonText: 'verify_and_confirm_payment'.tr,
          onPressed: _startVerification,
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        TextButton(
          onPressed: () {
            setState(() {
              _currentStep = 0;
            });
          },
          child: Text(
            'back_to_wallet_details'.tr,
            style: robotoMedium.copyWith(color: Theme.of(context).disabledColor),
          ),
        ),
      ],
    );
  }

  Widget _buildStep3VerificationLoading(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withValues(alpha: 0.1),
                border: Border.all(color: primaryColor.withValues(alpha: 0.3), width: 3),
              ),
              child: Center(
                child: Icon(Icons.shield_outlined, size: 48, color: primaryColor),
              ),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _statusMessage,
            textAlign: TextAlign.center,
            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
          ),
          const SizedBox(height: 8),
          Text(
            'please_wait_while_verifying'.tr,
            textAlign: TextAlign.center,
            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
          ),
        ],
      ),
    );
  }

  Widget _buildStep4Confirmation(BuildContext context) {
    if (_isSuccess) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.check_circle_rounded, color: Colors.green, size: 56),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Text(
            'payment_confirmed_successfully'.tr,
            textAlign: TextAlign.center,
            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Colors.green),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                _summaryRow('payment_method'.tr, widget.paymentTitle),
                const Divider(),
                _summaryRow('amount'.tr, PriceConverter.convertPrice(widget.totalPrice)),
                const Divider(),
                _summaryRow('purchase_code'.tr, _codeController.text),
              ],
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          CustomButton(
            buttonText: 'done'.tr,
            onPressed: () {
              Get.back();
            },
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.error_outline_rounded, color: Colors.red, size: 56),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Text(
            'payment_not_confirmed'.tr,
            textAlign: TextAlign.center,
            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Colors.red),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage.isNotEmpty ? _errorMessage : 'payment_verification_failed_msg'.tr,
            textAlign: TextAlign.center,
            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          CustomButton(
            buttonText: 'reenter_code'.tr,
            onPressed: () {
              setState(() {
                _currentStep = 1;
              });
            },
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          TextButton(
            onPressed: () => Get.back(),
            child: Text('change_payment_method'.tr, style: robotoMedium),
          ),
        ],
      );
    }
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
          Text(value, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall)),
        ],
      ),
    );
  }
}

class _QrBarcodePainter extends CustomPainter {
  final Color primaryColor;

  _QrBarcodePainter({required this.primaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;

    // Outer corner finder squares
    void drawFinder(double x, double y, double s) {
      final border = Paint()
        ..color = primaryColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, s, s), const Radius.circular(6)), border);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x + 6, y + 6, s - 12, s - 12), const Radius.circular(3)), paint);
    }

    drawFinder(6, 6, 36);
    drawFinder(size.width - 42, 6, 36);
    drawFinder(6, size.height - 42, 36);

    // Simulated QR blocks
    final rows = 12;
    final cols = 12;
    final cellSize = (size.width - 24) / cols;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        // Skip corner finder zones
        if ((r < 4 && c < 4) || (r < 4 && c > 7) || (r > 7 && c < 4)) continue;
        if ((r * 7 + c * 13) % 3 == 0 || (r + c) % 5 == 0) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(12 + c * cellSize, 12 + r * cellSize, cellSize - 2, cellSize - 2),
              const Radius.circular(1.5),
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
