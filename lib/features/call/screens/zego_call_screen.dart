import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:sixam_mart/util/app_constants.dart';

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
    return ZegoUIKitPrebuiltCall(
      appID: AppConstants.zegoAppId,
      appSign: AppConstants.zegoAppSign,
      userID: userId,
      userName: userName,
      callID: orderId,
      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall()
        ..turnOnMicrophoneWhenJoining = true
        ..useSpeakerWhenJoining = true,
    );
  }
}
