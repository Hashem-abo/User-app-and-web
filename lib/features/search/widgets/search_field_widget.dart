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
  bool _isExpandedManually = false;
  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextOrFocusChange);
    _focusNode.addListener(_onTextOrFocusChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextOrFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  String _previousText = '';

  void _onTextOrFocusChange() {
    String currentText = widget.controller.text;
    if (currentText != _previousText) {
      _previousText = currentText;
      if (_isExpandedManually && currentText.isNotEmpty) {
        _isExpandedManually = false;
      }
    }
    if (currentText.isEmpty && _isExpandedManually) {
      _isExpandedManually = false;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    bool hasText = widget.controller.text.isNotEmpty;
    bool shouldCollapse = hasText && !_isExpandedManually;

    Color iconColor = widget.iconColor ?? Theme.of(context).textTheme.bodyLarge!.color!;

    return TextField(
      controller: widget.controller,
      focusNode: _focusNode,
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
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Smoothly collapse / expand action icons (Camera, AI Voice, Barcode) with horizontal pull towards X
            ClipRect(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 320),
                curve: Curves.fastOutSlowIn,
                alignment: Alignment.centerRight,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeInOut,
                  opacity: shouldCollapse ? 0.0 : 1.0,
                  child: AnimatedSlide(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.fastOutSlowIn,
                    offset: shouldCollapse ? const Offset(0.4, 0.0) : Offset.zero,
                    child: shouldCollapse
                        ? const SizedBox.shrink()
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.showCamera) IconButton(
                                onPressed: widget.onCameraTap as void Function()?,
                                icon: Icon(Icons.camera_alt, color: iconColor),
                              ),
                              if (widget.showAiMic) IconButton(
                                onPressed: widget.onAiMicTap as void Function()?,
                                icon: Icon(Icons.auto_awesome, color: iconColor),
                              ),
                              if (widget.showBarcode) IconButton(
                                onPressed: widget.onBarcodeTap as void Function()?,
                                icon: Icon(Icons.qr_code_scanner, color: iconColor),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),

            // Small expand arrow button when collapsed
            ClipRect(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 320),
                curve: Curves.fastOutSlowIn,
                alignment: Alignment.centerRight,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeInOut,
                  opacity: shouldCollapse ? 1.0 : 0.0,
                  child: AnimatedSlide(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.fastOutSlowIn,
                    offset: shouldCollapse ? Offset.zero : const Offset(0.4, 0.0),
                    child: shouldCollapse
                        ? InkWell(
                            onTap: () {
                              setState(() {
                                _isExpandedManually = true;
                              });
                            },
                            borderRadius: BorderRadius.circular(15),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 14,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
            ),

            // Clear (X) or Suffix Icon
            if (widget.suffixIcon != null) IconButton(
              onPressed: () {
                if (widget.controller.text.isNotEmpty) {
                  setState(() {
                    _isExpandedManually = false;
                  });
                }
                widget.iconPressed();
              },
              icon: Icon(widget.suffixIcon, color: iconColor),
            ),
          ],
        ),
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
      onChanged: (text) {
        if (_isExpandedManually && text.isNotEmpty) {
          setState(() {
            _isExpandedManually = false;
          });
        }
        if (widget.onChanged != null) {
          widget.onChanged!(text);
        }
      },
    );
  }
}
