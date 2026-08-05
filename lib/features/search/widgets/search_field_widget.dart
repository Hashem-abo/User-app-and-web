import 'package:flutter/services.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SearchFieldWidget extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData? suffixIcon;
  final IconData? prefixIcon;
  final Function iconPressed;
  final Color? filledColor;
  final Color? iconColor;
  final Function? onSubmit;
  final Function? onChanged;
  final double? radius;
  final bool isFocused;
  final bool showCamera;
  final Function? onCameraTap;
  final bool showAiMic;
  final Function? onAiMicTap;
  final bool showBarcode;
  final Function? onBarcodeTap;
  const SearchFieldWidget({
    super.key, required this.controller, required this.hint, this.suffixIcon,
    required this.iconPressed, this.filledColor, this.onSubmit, this.onChanged, this.iconColor,
    this.radius, this.prefixIcon, this.isFocused = false, this.showCamera = false, this.onCameraTap,
    this.showAiMic = false, this.onAiMicTap, this.showBarcode = false, this.onBarcodeTap,
    this.searchImage,
  });
  final XFile? searchImage;

  @override
  State<SearchFieldWidget> createState() => _SearchFieldWidgetState();
}

class _SearchFieldWidgetState extends State<SearchFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      textInputAction: TextInputAction.search,
      autofocus: widget.isFocused,
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(r'[!@#$%^&*(),.?":{}|<>_+-/~`•√π÷×§∆£¢€¥°=©®™✓;]')),
      ],
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(widget.radius ?? Dimensions.radiusSmall), borderSide: BorderSide.none),
        filled: true, fillColor: widget.filledColor ?? Theme.of(context).cardColor,
        isDense: true,
        suffixIcon: Row(mainAxisSize: MainAxisSize.min, children: [
          if (widget.showCamera) IconButton(
            onPressed: widget.onCameraTap as void Function()?,
            icon: Icon(Icons.camera_alt, color: widget.iconColor ?? Theme.of(context).textTheme.bodyLarge!.color),
          ),
          if (widget.showAiMic) IconButton(
            onPressed: widget.onAiMicTap as void Function()?,
            icon: Icon(Icons.auto_awesome, color: widget.iconColor ?? Theme.of(context).textTheme.bodyLarge!.color),
          ),
          if (widget.showBarcode) IconButton(
            onPressed: widget.onBarcodeTap as void Function()?,
            icon: Icon(Icons.qr_code_scanner, color: widget.iconColor ?? Theme.of(context).textTheme.bodyLarge!.color),
          ),
          if (widget.suffixIcon != null) IconButton(
            onPressed: widget.iconPressed as void Function()?,
            icon: Icon(widget.suffixIcon, color: widget.iconColor ?? Theme.of(context).textTheme.bodyLarge!.color),
          ),
        ]),
        prefixIcon: widget.searchImage != null
            ? Container(
                margin: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).primaryColor, width: 1.5),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.file(
                  File(widget.searchImage!.path),
                  fit: BoxFit.cover,
                  width: 32, height: 32,
                ),
              )
            : (widget.prefixIcon != null ? Icon(widget.prefixIcon, size: 24, color: Theme.of(context).disabledColor) : null),
      ),
      onSubmitted: widget.onSubmit as void Function(String)?,
      onChanged: widget.onChanged as void Function(String)?,
    );
  }
}
