import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:sixam_mart/features/auth/widgets/sign_up_widget.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class SignUpScreen extends StatefulWidget {
  final bool exitFromApp;
  const SignUpScreen({super.key, this.exitFromApp = false});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  bool _canExit = GetPlatform.isWeb ? true : false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (widget.exitFromApp) {
          if (_canExit) {
            if (GetPlatform.isAndroid) {
              SystemNavigator.pop();
            } else if (GetPlatform.isIOS) {
              exit(0);
            } else {
              Get.offAllNamed(RouteHelper.getInitialRoute());
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('back_press_again_to_exit'.tr,
                  style: const TextStyle(color: Colors.white)),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            ));
            _canExit = true;
            Timer(const Duration(seconds: 2), () {
              _canExit = false;
            });
          }
        } else {
          Get.back();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).cardColor,
        endDrawer: const MenuDrawer(), endDrawerEnableOpenDragGesture: false,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: Image.asset(
                  Images.onboard_1,
                  fit: BoxFit.cover,
                ),
              ),

              // Blur Effect
              Positioned.fill(
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.2), 
                  ),
                ),
              ),

              // Main Content
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge , vertical: 60),
                    child: Center(
                      child: Container(
                        width: context.width > 700 ? 500 : context.width,
                        padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeExtraLarge,
                            vertical: Dimensions.paddingSizeLarge),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(220), 
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(25),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            )
                          ],
                        ),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: Dimensions.paddingSizeLarge),
                              Image.asset(Images.logo, width: 140),
                              const SizedBox(height: Dimensions.paddingSizeDefault),

                              Text(
                                'create_your_account'.tr,
                                style: robotoBold.copyWith(fontSize: 24, color: Colors.black),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                              Text(
                                'start_now_and_enjoy_shopping'.tr,
                                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.grey[600]),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                              const SignUpWidget(),
                            ]),
                      ),
                    ),
                  ),
                ),
              ),

              // Back Button (Directional & Safe Area aware)
              PositionedDirectional(
                top: MediaQuery.of(context).padding.top + 10,
                start: 20,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => Get.back(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 5)],
                    ),
                    child: Icon(
                      Directionality.of(context) == TextDirection.rtl
                          ? Icons.arrow_forward_ios_rounded
                          : Icons.arrow_back_ios_rounded,
                      size: 20,
                      color: Colors.grey[700],
                    ), 
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
