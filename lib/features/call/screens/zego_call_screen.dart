import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';

class ZegoCallScreen extends StatelessWidget {
  final String orderId;
  final String userId;
  final String userName;

  const ZegoCallScreen({
    super.key,
    required this.orderId,
    required this.userId,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final config = Get.isRegistered<SplashController>() ? Get.find<SplashController>().configModel : null;
    final int zegoAppId = config?.zegoAppId ?? AppConstants.zegoAppId;
    final String zegoAppSign = config?.zegoAppSign ?? AppConstants.zegoAppSign;

    return ZegoUIKitPrebuiltCall(
      appID: zegoAppId,
      appSign: zegoAppSign,
      userID: userId,
      userName: userName,
      callID: orderId,
      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall()
        ..turnOnMicrophoneWhenJoining = true
        ..useSpeakerWhenJoining = true,
    );
  }
}
