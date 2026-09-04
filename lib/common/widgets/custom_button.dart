import 'package:get/get.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomButton extends StatefulWidget {
  final Function? onPressed;
  final String buttonText;
  final bool transparent;
  final EdgeInsets? margin;
  final double? height;
  final double? width;
  final double? fontSize;
  final double radius;
  final IconData? icon;
  final Color? color;
  final Color? textColor;
  final bool isLoading;
  final bool isBold;
  final bool isBorder;
  final Color? iconColor;
  const CustomButton({super.key, this.onPressed, required this.buttonText, this.transparent = false, this.margin, this.width, this.height,
    this.fontSize, this.radius = 12, this.icon, this.color, this.textColor, this.isLoading = false, this.isBold = true, this.isBorder = false, this.iconColor});

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      backgroundColor: widget.onPressed == null ? const Color(0xff93A2AE) : widget.transparent
          ? Colors.transparent : widget.color ?? Theme.of(context).primaryColor,
      minimumSize: Size(widget.width != null ? widget.width! : Dimensions.webMaxWidth, widget.height != null ? widget.height! : 50),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(widget.radius),
        side: widget.isBorder ? BorderSide(color: Theme.of(context).disabledColor.withValues(alpha: 0.5)) : BorderSide.none,
      ),
    );

    final Color effectiveTextColor = widget.textColor ?? (widget.transparent ? Theme.of(context).primaryColor : Colors.white);

    return Center(child: SizedBox(width: widget.width ?? Dimensions.webMaxWidth, child: Padding(
      padding: widget.margin ?? EdgeInsets.zero,
      child: Listener(
        onPointerDown: (_) {
          if (widget.onPressed != null && !widget.isLoading) {
            setState(() => _isPressed = true);
          }
        },
        onPointerUp: (_) {
          if (_isPressed) {
            setState(() => _isPressed = false);
          }
        },
        onPointerCancel: (_) {
          if (_isPressed) {
            setState(() => _isPressed = false);
          }
        },
        child: AnimatedScale(
          scale: _isPressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
          child: TextButton(
            onPressed: widget.isLoading ? null : widget.onPressed == null ? null : () {
              HapticFeedback.lightImpact();
              (widget.onPressed as void Function())();
            },
            style: flatButtonStyle,
            child: widget.isLoading ?
            Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(
                height: 18, width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(effectiveTextColor),
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Text('loading'.tr, style: robotoMedium.copyWith(color: effectiveTextColor)),
            ]),
            ) : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              widget.icon != null ? Padding(
                padding: const EdgeInsets.only(right: Dimensions.paddingSizeExtraSmall),
                child: Icon(widget.icon, color: widget.iconColor ?? (widget.transparent ? Theme.of(context).primaryColor : Theme.of(context).cardColor)),
              ) : const SizedBox(),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(widget.buttonText, textAlign: TextAlign.center, style: widget.isBold ? robotoBold.copyWith(
                    color: effectiveTextColor,
                    fontSize: widget.fontSize ?? Dimensions.fontSizeLarge,
                  ) : robotoRegular.copyWith(
                    color: effectiveTextColor,
                    fontSize: widget.fontSize ?? Dimensions.fontSizeLarge,
                  )),
                ),
              ),
            ]),
          ),
        ),
      ),
    )));
  }
}
