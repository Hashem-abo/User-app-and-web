import 'dart:ui';
import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class UpdateScreen extends StatefulWidget {
  final bool isUpdate;
  final bool isOptional;
  const UpdateScreen({super.key, required this.isUpdate, this.isOptional = false});

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              Images.onboard_2, // Using an onboarding image as background
              fit: BoxFit.cover,
            ),
          ),

          // Blur Effect
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),
          ),

          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, spreadRadius: 5),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.isOptional)
                    Align(
                      alignment: Alignment.topLeft,
                      child: InkWell(
                        onTap: () => Get.offAllNamed(RouteHelper.getInitialRoute()),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'skip'.tr,
                            style: robotoMedium.copyWith(color: Theme.of(context).primaryColor),
                          ),
                        ),
                      ),
                    ),

                  Image.asset(
                    widget.isUpdate ? Images.update : Images.maintenance,
                    width: MediaQuery.of(context).size.height * 0.25,
                    height: MediaQuery.of(context).size.height * 0.25,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  Text(
                    widget.isUpdate 
                        ? (widget.isOptional ? 'new_update_available'.tr : 'update_required'.tr) 
                        : 'system_under_maintenance'.tr,
                    style: robotoBold.copyWith(fontSize: 22, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Text(
                    widget.isUpdate 
                        ? 'your_app_is_deprecated'.tr 
                        : 'maintenance_message'.tr,
                    style: robotoRegular.copyWith(fontSize: 16, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  if (widget.isUpdate)
                    CustomButton(
                      buttonText: 'update_now'.tr,
                      radius: 15,
                      height: 50,
                      onPressed: () async {
                        String? appUrl = 'https://google.com';
                        if (GetPlatform.isAndroid) {
                          appUrl = Get.find<SplashController>().configModel!.appUrlAndroid;
                        } else if (GetPlatform.isIOS) {
                          appUrl = Get.find<SplashController>().configModel!.appUrlIos;
                        }
                        if (await canLaunchUrlString(appUrl!)) {
                          launchUrlString(appUrl, mode: LaunchMode.externalApplication);
                        } else {
                          showCustomSnackBar('${'can_not_launch'.tr} $appUrl');
                        }
                      },
                    ),
                  
                  if (!widget.isUpdate) ...[
                    CustomButton(
                      buttonText: 'retry'.tr,
                      radius: 15,
                      height: 50,
                      isLoading: _isLoading,
                      onPressed: () async {
                        setState(() {
                          _isLoading = true;
                        });
                        await Get.find<SplashController>().getConfigData(source: DataSourceEnum.client);
                        setState(() {
                          _isLoading = false;
                        });
                      },
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    CustomButton(
                      buttonText: 'contact_us'.tr,
                      transparent: true,
                      isBorder: true,
                      textColor: Theme.of(context).primaryColor,
                      radius: 15,
                      height: 50,
                      onPressed: () => Get.toNamed(RouteHelper.getSupportRoute()),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
