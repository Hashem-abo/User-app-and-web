import 'package:sixam_mart/util/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:sixam_mart/util/images.dart';

class QuantityButton extends StatefulWidget {
  final bool isIncrement;
  final Function? onTap;
  final bool fromSheet;
  final bool showRemoveIcon;
  final Color? color;
  const QuantityButton({super.key, required this.isIncrement, required this.onTap, this.fromSheet = false, this.showRemoveIcon = false, this.color});

  @override
  State<QuantityButton> createState() => _QuantityButtonState();
}

class _QuantityButtonState extends State<QuantityButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final double buttonSize = widget.fromSheet ? 32 : 28;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        if (widget.onTap != null) {
          setState(() => _isPressed = true);
        }
      },
      onTapUp: (_) {
        if (_isPressed) {
          setState(() => _isPressed = false);
        }
      },
      onTapCancel: () {
        if (_isPressed) {
          setState(() => _isPressed = false);
        }
      },
      onTap: () {
        if (widget.onTap != null) {
          (widget.onTap as void Function())();
        }
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutBack,
        child: Container(
          height: buttonSize, width: buttonSize,
          margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.showRemoveIcon
                ? Theme.of(context).colorScheme.error.withValues(alpha: 0.1)
                : widget.isIncrement
                    ? widget.color ?? Theme.of(context).primaryColor
                    : Theme.of(context).disabledColor.withValues(alpha: 0.2),
            boxShadow: widget.isIncrement
                ? [
                    BoxShadow(
                      color: (widget.color ?? Theme.of(context).primaryColor).withValues(alpha: 0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: widget.showRemoveIcon
              ? Image.asset(Images.delete, height: 15, color: Theme.of(context).colorScheme.error)
              : Icon(
                  widget.isIncrement ? Icons.add : Icons.remove,
                  size: 16,
                  color: widget.showRemoveIcon
                      ? Theme.of(context).colorScheme.error
                      : widget.isIncrement
                          ? Theme.of(context).cardColor
                          : Theme.of(context).disabledColor,
                ),
        ),
      ),
    );
  }
}