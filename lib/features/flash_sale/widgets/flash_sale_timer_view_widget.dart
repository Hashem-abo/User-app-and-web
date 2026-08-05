import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/flash_sale/widgets/timer_widget.dart';

class FlashSaleTimerView extends StatelessWidget {
  final Duration? eventDuration;
  const FlashSaleTimerView({super.key, this.eventDuration});

  @override
  Widget build(BuildContext context) {
    int? days, hours, minutes, seconds;
    if (eventDuration != null) {
      days = eventDuration!.inDays;
      hours = eventDuration!.inHours - days * 24;
      minutes = eventDuration!.inMinutes - (24 * days * 60) - (hours * 60);
      seconds = eventDuration!.inSeconds - (24 * days * 60 * 60) - (hours * 60 * 60) - (minutes * 60);
    }
    return eventDuration != null ? Row(children: [

      TimerWidget(
        timeCount: days ?? 0,
        timeUnit: 'days'.tr,
        textColor: Colors.white,
      ),
      _buildSeparator(),

      TimerWidget(
        timeCount: hours ?? 0,
        timeUnit: 'hours'.tr,
        textColor: Colors.white,
      ),
      _buildSeparator(),

      TimerWidget(
        timeCount: minutes ?? 0,
        timeUnit: 'mins'.tr,
        textColor: Colors.white,
      ),


    ]) : const SizedBox();
  }

  Widget _buildSeparator() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(':', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 25), // Spacer to align with number boxes
      ],
    );
  }
}


class FlashSaleTimerWebHomeView extends StatelessWidget {
  final Duration? eventDuration;
  const FlashSaleTimerWebHomeView({super.key, this.eventDuration});

  @override
  Widget build(BuildContext context) {
    int? days, hours, minutes, seconds;
    if (eventDuration != null) {
      days = eventDuration!.inDays;
      hours = eventDuration!.inHours - days * 24;
      minutes = eventDuration!.inMinutes - (24 * days * 60) - (hours * 60);
      seconds = eventDuration!.inSeconds - (24 * days * 60 * 60) - (hours * 60 * 60) - (minutes * 60);
    }
    return eventDuration != null ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

      TimerWidget(
        timeCount: days ?? 0,
        timeUnit: 'days'.tr,
        textColor: Colors.white,
      ),

      TimerWidget(
        timeCount: hours ?? 0,
        timeUnit: 'hours'.tr,
        textColor: Colors.white,
      ),

      TimerWidget(
        timeCount: minutes ?? 0,
        timeUnit: 'mins'.tr,
        textColor: Colors.white,
      ),

      TimerWidget(
        timeCount: seconds ?? 0,
        timeUnit: 'sec'.tr,
        textColor: Colors.white,
      ),

    ]) : const SizedBox();
  }
}
