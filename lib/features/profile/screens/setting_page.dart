import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/language/widgets/language_bottom_sheet_widget.dart';
import 'package:sixam_mart/features/profile/widgets/notification_status_change_bottom_sheet.dart';
import 'package:sixam_mart/features/profile/widgets/profile_button_widget.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/common/widgets/confirmation_dialog.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String _cacheSize = '0.00 MB';

  @override
  void initState() {
    super.initState();
    _calculateCacheSize();
  }

  Future<void> _calculateCacheSize() async {
    try {
      final tempDir = await getTemporaryDirectory();
      double totalSize = await _getDirSize(tempDir);
      double sizeInMB = totalSize / (1024 * 1024);
      if (mounted) {
        setState(() {
          _cacheSize = '${sizeInMB.toStringAsFixed(2)} MB';
        });
      }
    } catch (e) {
      debugPrint("Error calculating cache size: $e");
    }
  }

  Future<double> _getDirSize(Directory dir) async {
    double totalSize = 0;
    try {
      if (await dir.exists()) {
        await for (final FileSystemEntity entity in dir.list(recursive: true, followLinks: false)) {
          try {
            if (entity is File && await entity.exists()) {
              totalSize += await entity.length();
            }
          } catch (e) {
            debugPrint('Error getting file size: ${entity.path}, error: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Error listing cache directory: $e');
    }
    return totalSize;
  }

  Future<void> _clearCache() async {
    try {
      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        await for (final FileSystemEntity entity in tempDir.list(recursive: false, followLinks: false)) {
          try {
            if (entity is File) {
              await entity.delete();
            } else if (entity is Directory) {
              await entity.delete(recursive: true);
            }
          } catch (e) {
            debugPrint("Failed to delete entity: ${entity.path}, error: $e");
          }
        }
      }
      await _calculateCacheSize();
      showCustomSnackBar('cache_cleared_successfully'.tr, isError: false);
    } catch (e) {
      debugPrint("Error clearing cache: $e");
      showCustomSnackBar('failed_to_clear_cache'.tr, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = AuthHelper.isLoggedIn();
    return Scaffold(
      appBar: CustomAppBar(title: 'settings'.tr),
      endDrawer: const MenuDrawer(), endDrawerEnableOpenDragGesture: false,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(children: [

          ProfileButtonWidget(icon: Icons.language, title: 'language'.tr, languageName: AppConstants.languages[Get.find<LocalizationController>().selectedLanguageIndex].languageName, onTap: () {
            _manageLanguageFunctionality();
          }),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          
          // GetBuilder<ThemeController>(builder: (themeController) {
          //   return Column(children: [
          //     Container(
          //       padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          //       decoration: BoxDecoration(
          //         color: Theme.of(context).cardColor,
          //         borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          //         boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 1, blurRadius: 5)],
          //       ),
          //       child: Column(children: [
          //          Padding(
          //           padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          //           child: Row(children: [
          //             const Icon(Icons.color_lens_outlined, size: 25),
          //             const SizedBox(width: Dimensions.paddingSizeSmall),
          //             Expanded(child: Text('primary_color'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge))),
          //           ]),
          //         ),
          //         const SizedBox(height: Dimensions.paddingSizeSmall),
          //
          //         ColorPicker(
          //           pickerColor: _primaryColor ?? themeController.primaryColor,
          //           onColorChanged: (Color color){
          //             setState(() {
          //               _primaryColor = color;
          //             });
          //           },
          //           colorPickerWidth: 300,
          //           pickerAreaHeightPercent: 0.7,
          //           enableAlpha: false,
          //           displayThumbColor: true,
          //           paletteType: PaletteType.hsvWithHue,
          //           labelTypes: const [],
          //           pickerAreaBorderRadius: const BorderRadius.only(
          //             topLeft: Radius.circular(Dimensions.radiusDefault),
          //             topRight: Radius.circular(Dimensions.radiusDefault),
          //           ),
          //         ),
          //       ]),
          //     ),
          //     const SizedBox(height: Dimensions.paddingSizeSmall),
          //
          //     Container(
          //       padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          //       decoration: BoxDecoration(
          //         color: Theme.of(context).cardColor,
          //         borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          //         boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 1, blurRadius: 5)],
          //       ),
          //       child: Column(children: [
          //          Padding(
          //           padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          //           child: Row(children: [
          //             const Icon(Icons.color_lens_outlined, size: 25),
          //             const SizedBox(width: Dimensions.paddingSizeSmall),
          //             Expanded(child: Text('disabled_color'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge))),
          //           ]),
          //         ),
          //         const SizedBox(height: Dimensions.paddingSizeSmall),
          //
          //         ColorPicker(
          //           pickerColor: _disabledColor ?? themeController.disabledColor,
          //           onColorChanged: (Color color) {
          //             setState(() {
          //                _disabledColor = color;
          //             });
          //           },
          //           colorPickerWidth: 300,
          //           pickerAreaHeightPercent: 0.7,
          //           enableAlpha: false,
          //           displayThumbColor: true,
          //           paletteType: PaletteType.hsvWithHue,
          //           labelTypes: const [],
          //           pickerAreaBorderRadius: const BorderRadius.only(
          //             topLeft: Radius.circular(Dimensions.radiusDefault),
          //             topRight: Radius.circular(Dimensions.radiusDefault),
          //           ),
          //         ),
          //       ]),
          //     ),
          //     const SizedBox(height: Dimensions.paddingSizeSmall),
          //
          //     Container(
          //       padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          //       decoration: BoxDecoration(
          //         color: Theme.of(context).cardColor,
          //         borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          //         boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 1, blurRadius: 5)],
          //       ),
          //       child: Column(children: [
          //          Padding(
          //           padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          //           child: Row(children: [
          //             const Icon(Icons.color_lens_outlined, size: 25),
          //             const SizedBox(width: Dimensions.paddingSizeSmall),
          //             Expanded(child: Text('card_color'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge))),
          //           ]),
          //         ),
          //         const SizedBox(height: Dimensions.paddingSizeSmall),
          //
          //         ColorPicker(
          //           pickerColor: _cardColor ?? themeController.cardColor,
          //           onColorChanged: (Color color) {
          //             setState(() {
          //                _cardColor = color;
          //             });
          //           },
          //           colorPickerWidth: 300,
          //           pickerAreaHeightPercent: 0.7,
          //           enableAlpha: false,
          //           displayThumbColor: true,
          //           paletteType: PaletteType.hsvWithHue,
          //           labelTypes: const [],
          //           pickerAreaBorderRadius: const BorderRadius.only(
          //             topLeft: Radius.circular(Dimensions.radiusDefault),
          //             topRight: Radius.circular(Dimensions.radiusDefault),
          //           ),
          //         ),
          //       ]),
          //     ),
          //     const SizedBox(height: Dimensions.paddingSizeSmall),
          //
          //     Container(
          //       padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          //       decoration: BoxDecoration(
          //         color: Theme.of(context).cardColor,
          //         borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          //         boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 1, blurRadius: 5)],
          //       ),
          //       child: Column(children: [
          //          Padding(
          //           padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          //           child: Row(children: [
          //             const Icon(Icons.color_lens_outlined, size: 25),
          //             const SizedBox(width: Dimensions.paddingSizeSmall),
          //             Expanded(child: Text('text_color'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge))),
          //           ]),
          //         ),
          //         const SizedBox(height: Dimensions.paddingSizeDefault),
          //
          //         ColorPicker(
          //           pickerColor: _textColor ?? themeController.textColor,
          //           onColorChanged: (Color color) {
          //             setState(() {
          //                _textColor = color;
          //             });
          //           },
          //           colorPickerWidth: 300,
          //           pickerAreaHeightPercent: 0.7,
          //           enableAlpha: false,
          //           displayThumbColor: true,
          //           paletteType: PaletteType.hsvWithHue,
          //           labelTypes: const [],
          //           pickerAreaBorderRadius: const BorderRadius.only(
          //             topLeft: Radius.circular(Dimensions.radiusDefault),
          //             topRight: Radius.circular(Dimensions.radiusDefault),
          //           ),
          //         ),
          //       ]),
          //     ),
          //     const SizedBox(height: Dimensions.paddingSizeDefault),
          //     Container(
          //       padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
          //       decoration: BoxDecoration(
          //         color: Theme.of(context).cardColor,
          //         borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          //         boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 1, blurRadius: 5)],
          //       ),
          //       child: Column(children: [
          //         Padding(
          //           padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          //           child: Row(children: [
          //             const Icon(Icons.color_lens_outlined, size: 25),
          //             const SizedBox(width: Dimensions.paddingSizeSmall),
          //             Expanded(child: Text('hint_color'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge))),
          //           ]),
          //         ),
          //         const SizedBox(height: Dimensions.paddingSizeSmall),
          //
          //         ColorPicker(
          //           pickerColor: _hintColor ?? themeController.hintColor,
          //           onColorChanged: (Color color) {
          //             setState(() {
          //               _hintColor = color;
          //             });
          //           },
          //           colorPickerWidth: 300,
          //           pickerAreaHeightPercent: 0.7,
          //           enableAlpha: false,
          //           displayThumbColor: true,
          //           paletteType: PaletteType.hsvWithHue,
          //           labelTypes: const [],
          //           pickerAreaBorderRadius: const BorderRadius.only(
          //             topLeft: Radius.circular(Dimensions.radiusDefault),
          //             topRight: Radius.circular(Dimensions.radiusDefault),
          //           ),
          //         ),
          //       ]),
          //     ),
          //     const SizedBox(height: Dimensions.paddingSizeSmall),
          //     CustomButton(
          //       buttonText: 'update'.tr,
          //       onPressed: () {
          //         if(_primaryColor != null) themeController.changePrimaryColor(_primaryColor!);
          //         if(_disabledColor != null) themeController.changeDisabledColor(_disabledColor!);
          //         if(_hintColor != null) themeController.changeHintColor(_hintColor!);
          //         if(_cardColor != null) themeController.changeCardColor(_cardColor!);
          //         if(_textColor != null) themeController.changeTextColor(_textColor!);
          //       },
          //     ),
          //     const SizedBox(height: Dimensions.paddingSizeSmall),
          //
          //     Container(
          //       padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          //       decoration: BoxDecoration(
          //         color: Theme.of(context).cardColor,
          //         borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          //         boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 1, blurRadius: 5)],
          //       ),
          //       child: Column(children: [
          //         Padding(
          //           padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          //           child: Row(children: [
          //             const Icon(Icons.text_fields, size: 25),
          //             const SizedBox(width: Dimensions.paddingSizeSmall),
          //             Expanded(child: Text('font_size'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge))),
          //             Text('${themeController.fontSize.toInt()}', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
          //           ]),
          //         ),
          //
          //         Slider(
          //           value: themeController.fontSize,
          //           min: 10,
          //           max: 40,
          //           divisions: 15,
          //           label: themeController.fontSize.round().toString(),
          //           onChanged: (double value) => themeController.changeFontSize(value),
          //         ),
          //       ]),
          //     ),
          //     const SizedBox(height: Dimensions.paddingSizeSmall),
          //
          //     Container(
          //       padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          //       decoration: BoxDecoration(
          //         color: Theme.of(context).cardColor,
          //         borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          //         boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 1, blurRadius: 5)],
          //       ),
          //       child: Column(children: [
          //         Padding(
          //           padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          //           child: Row(children: [
          //             const Icon(Icons.font_download_outlined, size: 25),
          //             const SizedBox(width: Dimensions.paddingSizeSmall),
          //             Expanded(child: Text('font_style'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge))),
          //           ]),
          //         ),
          //         const SizedBox(height: Dimensions.paddingSizeSmall),
          //
          //         const SizedBox(height: Dimensions.paddingSizeSmall),
          //
          //         ...AppConstants.fontFamilies.map((font) => RadioListTile<String>(
          //           title: Text(font),
          //           value: font,
          //           groupValue: themeController.fontFamily,
          //           onChanged: (String? value) {
          //             if(value != null) themeController.changeFont(value);
          //           },
          //           activeColor: Theme.of(context).primaryColor,
          //         )),
          //
          //       ]),
          //     ),
          //   ]);
          // }),

          GetBuilder<ThemeController>(
            builder: (themeController) {
              return ProfileButtonWidget(icon: Icons.tonality_outlined, title: 'dark_mode'.tr, isButtonActive: themeController.darkTheme, onTap: () {
                themeController.toggleTheme();
              });
            }
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          isLoggedIn ? GetBuilder<AuthController>(builder: (authController) {
            return ProfileButtonWidget(
              icon: Icons.notifications, title: 'notification'.tr,
              isButtonActive: authController.notification,
              onTap: () {
                Get.bottomSheet(const NotificationStatusChangeBottomSheet());
              },
            );
          }) : const SizedBox(),
          SizedBox(height: isLoggedIn ? Dimensions.paddingSizeSmall : 0),

          isLoggedIn ? GetBuilder<ProfileController>(builder: (profileController) {
            return ProfileButtonWidget(
              icon: Icons.contacts_outlined,
              title: 'discoverable_by_contacts'.tr,
              isButtonActive: profileController.userInfoModel?.isDiscoverable ?? true,
              onTap: () {
                bool currentStatus = profileController.userInfoModel?.isDiscoverable ?? true;
                profileController.toggleDiscoverability(!currentStatus);
              },
            );
          }) : const SizedBox(),
          SizedBox(height: isLoggedIn ? Dimensions.paddingSizeSmall : 0),

          ProfileButtonWidget(
            icon: Icons.delete_outline,
            title: 'clear_cache'.tr,
            trailingText: _cacheSize,
            onTap: () {
              Get.dialog(ConfirmationDialog(
                icon: Images.warning,
                description: 'delete_cached_images_alert'.tr,
                isLogOut: false,
                onYesPressed: () {
                  Get.back();
                  _clearCache();
                },
              ), useSafeArea: false);
            },
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          SizedBox(height: isLoggedIn ? Dimensions.paddingSizeLarge : 0),

          // Danger Section
          if(isLoggedIn) ...[
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              InkWell(
                onTap: () {
                  Get.dialog(ConfirmationDialog(icon: Images.support,
                    title: 'are_you_sure_to_delete_account'.tr,
                    description: 'it_will_remove_your_all_information'.tr, isLogOut: true,
                    onYesPressed: () => Get.find<ProfileController>().deleteUser(),
                  ), useSafeArea: false);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Directionality.of(context) == TextDirection.rtl ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.white,
                    ),
                    title: Text(
                      'delete_account'.tr,
                      style: robotoMedium.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeDefault),
                    ),
                    trailing: const Icon(Icons.delete_outline, color: Colors.white),
                  ),
                ),
              ),
            ]),
            SizedBox(height: isLoggedIn ? Dimensions.paddingSizeLarge : 0),
          ],

          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('${'version'.tr}:', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall)),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            Text(AppConstants.appVersion.toStringAsFixed(1), style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall)),
          ]),

        ]),
      ),
    );
  }

  void _manageLanguageFunctionality() {
    Get.find<LocalizationController>().saveCacheLanguage(null);
    Get.find<LocalizationController>().searchSelectedLanguage();

    showModalBottomSheet(
      isScrollControlled: true, useRootNavigator: true, context: Get.context!,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusExtraLarge), topRight: Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      builder: (context) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: const LanguageBottomSheetWidget(),
        );
      },
    ).then((value) => Get.find<LocalizationController>().setLanguage(Get.find<LocalizationController>().getCacheLocaleFromSharedPref()));
  }
}
