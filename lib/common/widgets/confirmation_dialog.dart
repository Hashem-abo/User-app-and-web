import 'package:sixam_mart/features/order/controllers/order_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
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

  const ConfirmationDialog({
    super.key,
    required this.icon,
    this.title,
    required this.description,
    required this.onYesPressed,
    this.isLogOut = false,
    this.onNoPressed,
  });

  @override
  State<ConfirmationDialog> createState() => _ConfirmationDialogState();
}

class _ConfirmationDialogState extends State<ConfirmationDialog> {
  bool _canInteract = false;

  @override
  void initState() {
    super.initState();
    // Protect against touch bleeding / tap-through from preceding tap event
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        setState(() {
          _canInteract = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
      insetPadding: const EdgeInsets.all(30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: PointerInterceptor(
        child: SizedBox(
          width: 500,
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                child: Image.asset(
                  widget.icon,
                  width: 50,
                  height: 50,
                  color: widget.isLogOut ? Theme.of(context).colorScheme.error : Theme.of(context).primaryColor,
                ),
              ),

              if (widget.title != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                  child: Text(
                    widget.title!,
                    textAlign: TextAlign.center,
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Colors.red),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                child: Text(
                  widget.description,
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              if (!widget.isLogOut && Get.isRegistered<OrderController>())
                GetBuilder<OrderController>(builder: (orderController) {
                  return !orderController.isLoading
                      ? _buildActionButtons(context)
                      : const Center(child: CircularProgressIndicator());
                })
              else
                _buildActionButtons(context),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(children: [
      // CANCEL / NO BUTTON (Neutral secondary style)
      Expanded(
        child: TextButton(
          onPressed: !_canInteract
              ? null
              : () {
                  if (widget.onNoPressed != null) {
                    widget.onNoPressed!();
                  } else {
                    Get.back();
                  }
                },
          style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).disabledColor.withValues(alpha: 0.2),
            minimumSize: const Size(Dimensions.webMaxWidth, 50),
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
          ),
          child: Text(
            'cancel'.tr,
            textAlign: TextAlign.center,
            style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),
          ),
        ),
      ),
      const SizedBox(width: Dimensions.paddingSizeLarge),

      // CONFIRM / YES BUTTON (Primary or Destructive Error style)
      Expanded(
        child: CustomButton(
          buttonText: widget.isLogOut ? 'logout'.tr : 'yes'.tr,
          color: widget.isLogOut ? Theme.of(context).colorScheme.error : Theme.of(context).primaryColor,
          textColor: Colors.white,
          onPressed: !_canInteract
              ? null
              : () {
                  widget.onYesPressed();
                },
          radius: Dimensions.radiusSmall,
          height: 50,
        ),
      ),
    ]);
  }
}
