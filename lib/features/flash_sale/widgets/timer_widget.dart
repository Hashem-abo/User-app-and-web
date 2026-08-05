import 'package:flutter/material.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class TimerWidget extends StatelessWidget {
  final int timeCount;
  final String timeUnit;
  final Color? textColor;
  const TimerWidget({super.key, required this.timeUnit, required this.timeCount, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black87, // Dark background for professional look
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          ),
          child: Text(timeCount > 9 ? timeCount.toString() : '0${timeCount.toString()}' , style: robotoBold.copyWith(color: Colors.white, fontSize: 16)),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        Text(timeUnit, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: textColor ?? Theme.of(context).primaryColor, fontWeight: FontWeight.w500)),
      ],
    );
  }
}