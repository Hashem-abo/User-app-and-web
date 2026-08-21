import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class AnimatedCalculatingWidget extends StatefulWidget {
  final TextStyle? textStyle;
  const AnimatedCalculatingWidget({super.key, this.textStyle});

  @override
  State<AnimatedCalculatingWidget> createState() => _AnimatedCalculatingWidgetState();
}

class _AnimatedCalculatingWidgetState extends State<AnimatedCalculatingWidget> {
  int _dotCount = 1;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 450), (timer) {
      if (mounted) {
        setState(() {
          _dotCount = (_dotCount % 3) + 1;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String dots = '.' * _dotCount;
    String baseText = 'calculating_base'.tr != 'calculating_base'
        ? 'calculating_base'.tr
        : ('calculating'.tr.replaceAll('.', '').trim().isNotEmpty
            ? 'calculating'.tr.replaceAll('.', '').trim()
            : 'Calculating');
    return Text(
      '$baseText$dots',
      style: widget.textStyle ?? robotoMedium.copyWith(
        fontSize: Dimensions.fontSizeDefault,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}
