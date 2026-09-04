import 'dart:async';
import 'package:sixam_mart/features/order/controllers/order_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class ConfirmationDialog extends StatefulWidget {
  final String icon;
  final String? title;
  final String description;
  final Function onYesPressed;
  final bool isLogOut;
  final Function? onNoPressed;
  final String? confirmButtonText;
  final String? cancelButtonText;

  const ConfirmationDialog({
    super.key,
    required this.icon,
    this.title,
    required this.description,
    required this.onYesPressed,
    this.isLogOut = false,
    this.onNoPressed,
    this.confirmButtonText,
    this.cancelButtonText,
  });

  @override
  State<ConfirmationDialog> createState() => _ConfirmationDialogState();
}

class _ConfirmationDialogState extends State<ConfirmationDialog> {
  bool _canInteract = false;
  bool _isLoading = false;
  Timer? _canInteractTimer;

  @override
  void initState() {
    super.initState();
    // Protect against touch bleeding / tap-through from preceding tap event
    _canInteractTimer = Timer(const Duration(milliseconds: 250), () {
      if (mounted) {
        setState(() {
          _canInteract = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _canInteractTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    if (_isLoading || !_canInteract) return;
    setState(() {
      _isLoading = true;
    });

    try {
      dynamic result = widget.onYesPressed();
      if (result is Future) {
        await result;
      }
    } catch (e) {
      debugPrint('ConfirmationDialog onYesPressed error: $e');
    } finally {
      if (widget.isLogOut && mounted) {
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isActualLogout = widget.isLogOut &&
        (widget.title == null || widget.title == 'logout'.tr || widget.description == 'are_you_sure_to_logout'.tr);

    String effectiveIcon = widget.icon;
    if (isActualLogout && (effectiveIcon == Images.support || effectiveIcon.isEmpty)) {
      effectiveIcon = Images.logOut;
    }

    String? effectiveTitle = widget.title;
    if (effectiveTitle == null && isActualLogout) {
      effectiveTitle = 'logout'.tr;
    }

    return PopScope(
      canPop: !_isLoading,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
        insetPadding: const EdgeInsets.all(30),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: PointerInterceptor(
          child: SizedBox(
            width: 460,
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                // Top Icon Badge
                Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    color: widget.isLogOut
                        ? Theme.of(context).colorScheme.error.withValues(alpha: 0.1)
                        : Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Image.asset(
                      effectiveIcon,
                      width: 32,
                      height: 32,
                      color: widget.isLogOut ? Theme.of(context).colorScheme.error : Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                // Title
                if (effectiveTitle != null && effectiveTitle.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                    child: Text(
                      effectiveTitle,
                      textAlign: TextAlign.center,
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeExtraLarge,
                        color: widget.isLogOut ? Theme.of(context).colorScheme.error : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                if (effectiveTitle != null && effectiveTitle.isNotEmpty)
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                // Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                  child: Text(
                    _isLoading
                        ? (isActualLogout ? 'logging_out'.tr : 'loading'.tr)
                        : widget.description,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).disabledColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                // Actions
                if (!widget.isLogOut && Get.isRegistered<OrderController>())
                  GetBuilder<OrderController>(builder: (orderController) {
                    return !orderController.isLoading
                        ? _buildActionButtons(context, isActualLogout)
                        : const Center(child: CircularProgressIndicator());
                  })
                else
                  _buildActionButtons(context, isActualLogout),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isActualLogout) {
    return Row(children: [
      // CANCEL / NO BUTTON (Neutral secondary style)
      Expanded(
        child: TextButton(
          onPressed: (_isLoading || !_canInteract)
              ? null
              : () {
                  if (widget.onNoPressed != null) {
                    widget.onNoPressed!();
                  } else {
                    Get.back();
                  }
                },
          style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).disabledColor.withValues(alpha: 0.15),
            minimumSize: const Size(Dimensions.webMaxWidth, 48),
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
          ),
          child: Text(
            widget.cancelButtonText ?? 'cancel'.tr,
            textAlign: TextAlign.center,
            style: robotoMedium.copyWith(
              color: (_isLoading || !_canInteract)
                  ? Theme.of(context).disabledColor
                  : Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: Dimensions.fontSizeDefault,
            ),
          ),
        ),
      ),
      const SizedBox(width: Dimensions.paddingSizeSmall),

      // CONFIRM / YES BUTTON (Primary or Destructive Error style)
      Expanded(
        child: CustomButton(
          buttonText: _isLoading
              ? (isActualLogout ? 'logging_out'.tr : 'loading'.tr)
              : (widget.confirmButtonText ?? (isActualLogout ? 'logout'.tr : 'yes'.tr)),
          isLoading: _isLoading,
          color: widget.isLogOut ? Theme.of(context).colorScheme.error : Theme.of(context).primaryColor,
          textColor: Colors.white,
          onPressed: (_isLoading || !_canInteract) ? null : _handleConfirm,
          radius: Dimensions.radiusSmall,
          height: 48,
        ),
      ),
    ]);
  }
}
