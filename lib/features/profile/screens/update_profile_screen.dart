import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:sixam_mart/features/profile/screens/edit_size_screen.dart';
import 'package:sixam_mart/features/profile/screens/size_information_screen.dart';
import 'package:sixam_mart/features/profile/screens/preference_screen.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';
import 'package:sixam_mart/common/widgets/custom_text_field.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/common/widgets/web_menu_bar.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/profile/domain/models/update_user_model.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/profile/widgets/profile_bg_widget.dart';
import 'package:sixam_mart/features/profile/widgets/profile_button_widget.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/custom_validator.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/helper/validate_check.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/not_logged_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  JustTheController toolController = JustTheController();
  final ScrollController scrollController = ScrollController();
  bool isPhoneVerified = false;
  bool isEmailVerified = false;
  String? _countryDialCode;
  bool _isPhoneLoading = true;
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    if(AuthHelper.isLoggedIn()) {
      _initCall();
    }
  }

  void _initCall(){
    AuthController authController  = Get.find<AuthController>();
    _countryDialCode = authController.getUserCountryCode().isNotEmpty ? authController.getUserCountryCode()
        : CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).dialCode;

    if(Get.find<AuthController>().isLoggedIn() && Get.find<ProfileController>().userInfoModel == null) {
      Get.find<ProfileController>().getUserInfo();
    }
    Get.find<ProfileController>().getUserInfo();
    Get.find<ProfileController>().initData();
  }

  @override
  void dispose() {
    toolController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _splitPhoneNumber(String number) async {
    _isPhoneLoading = true;
    try{
      PhoneValid phoneNumber = await CustomValidator.isPhoneValid(number);
      _phoneController.text = phoneNumber.phone.replaceFirst('+${phoneNumber.countryCode}', '');
      _countryDialCode = '+${phoneNumber.countryCode}';
    }catch(_) {}
    setState(() {
      _isPhoneLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
      endDrawer: const MenuDrawer(), endDrawerEnableOpenDragGesture: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: GetBuilder<ProfileController>(builder: (profileController) {

        if(profileController.userInfoModel != null && _phoneController.text.isEmpty && _isPhoneLoading) {
          if(profileController.userInfoModel?.phone != null && profileController.userInfoModel!.phone!.isNotEmpty){
            _splitPhoneNumber(profileController.userInfoModel!.phone!);
          }
        }

        if(profileController.userInfoModel != null && _selectedGender == null) {
          _selectedGender = profileController.userInfoModel!.gender;
        }

        if(profileController.userInfoModel != null && _nameController.text.isEmpty ) {
          _nameController.text = '${profileController.userInfoModel?.fName ?? ''} ${profileController.userInfoModel?.lName ?? ''}';
        }

        if(profileController.userInfoModel != null && _emailController.text.isEmpty) {
          _emailController.text = profileController.userInfoModel?.email ?? '';
        }

        return isLoggedIn ? profileController.userInfoModel != null ? ResponsiveHelper.isDesktop(context) ? webView(profileController, isLoggedIn) : ProfileBgWidget(
          backButton: true,
          circularImage: Center(child: Stack(children: [

            ClipOval(child: profileController.pickedFile != null ? GetPlatform.isWeb ? Image.network(
              profileController.pickedFile!.path, width: 100, height: 100, fit: BoxFit.cover) : Image.file(
              File(profileController.pickedFile!.path), width: 100, height: 100, fit: BoxFit.cover) : FadeInImage.assetNetwork(
                placeholder: Images.defultImage,
                image: '${profileController.userInfoModel!.imageFullUrl}',
                height: 100, width: 100, fit: BoxFit.cover,
                imageErrorBuilder: (c, o, s) => Image.asset(Images.defultImage, height: 100, width: 100, fit: BoxFit.cover),
            )),

            Positioned(
              bottom: 0, right: 0, top: 0, left: 0,
              child: InkWell(
                onTap: () => profileController.pickImage(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3), shape: BoxShape.circle,
                    border: Border.all(width: 1, color: Theme.of(context).primaryColor),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      border: Border.all(width: 2, color: Colors.white),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white),
                  ),
                ),
              ),
            ),

          ])),
          mainWidget: Column(children: [

            Expanded(child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Center(child: SizedBox(width: 1170, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                SizedBox(height: 20, width: context.width),

                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeDefault),
                  // margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    Text('basic_information'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    CustomTextField(
                      titleText: 'enter_name'.tr,
                      controller: _nameController,
                      capitalization: TextCapitalization.words,
                      inputType: TextInputType.name,
                      focusNode: _nameFocus,
                      nextFocus: _emailFocus,
                      prefixIcon: CupertinoIcons.person_alt_circle_fill,
                      labelText: 'name'.tr,
                      required: true,
                      validator: (value) => ValidateCheck.validateEmptyText(value, "please_enter_first_name".tr),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraOverLarge),

                    CustomTextField(
                      titleText: 'enter_email'.tr,
                      controller: _emailController,
                      focusNode: _emailFocus,
                      inputType: TextInputType.emailAddress,
                      prefixIcon: CupertinoIcons.mail_solid,
                      labelText: 'email'.tr,
                      required: true,
                      validator: (value) => ValidateCheck.validateEmail(value),
                      suffixImage: profileController.userInfoModel!.isEmailVerified! && profileController.userInfoModel!.email == _emailController.text
                          ? Images.verifiedIcon : Get.find<SplashController>().configModel!.centralizeLoginSetup!.emailVerificationStatus! ? Images.unverifiedIcon : null,
                      suffixOnPressed: () async {
                        if(!profileController.userInfoModel!.isEmailVerified! || profileController.userInfoModel!.email != _emailController.text) {
                          Get.dialog(const CustomLoaderWidget());
                          await _updateProfile(profileController: profileController, fromButton: false, fromPhone: false);
                        }
                      },
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraOverLarge),

                    Stack(children: [

                      CustomTextField(
                        titleText: 'write_phone_number'.tr,
                        controller: _phoneController,
                        focusNode: _phoneFocus,
                        inputType: TextInputType.phone,
                        prefixIcon: CupertinoIcons.lock_fill,
                        isEnabled: !profileController.userInfoModel!.isPhoneVerified! || profileController.userInfoModel!.phone == null,
                        fromUpdateProfile: true,
                        labelText: 'phone'.tr,
                        required: true,
                        isPhone: true,
                        onCountryChanged: (CountryCode countryCode) => _countryDialCode = countryCode.dialCode,
                        countryDialCode: _countryDialCode ?? Get.find<LocalizationController>().locale.countryCode,
                        suffixImage: profileController.userInfoModel!.isPhoneVerified! ? Images.verifiedIcon : null,
                      ),

                      Positioned(
                        right: 15, top: 15,
                        child: !profileController.userInfoModel!.isPhoneVerified! && Get.find<SplashController>().configModel!.centralizeLoginSetup!.phoneVerificationStatus! ? InkWell(
                          onTap: () async {
                            if(!profileController.userInfoModel!.isPhoneVerified! && Get.find<SplashController>().configModel!.centralizeLoginSetup!.phoneVerificationStatus!) {
                              Get.dialog(const CustomLoaderWidget());
                              await _updateProfile(profileController: profileController, fromButton: false, fromPhone: true);
                            }
                          },
                          child: Image.asset(Images.unverifiedIcon, height: 20, width: 20, fit: BoxFit.cover),
                        ) : const SizedBox(),
                      ),

                    ]),

                    if (profileController.userInfoModel != null &&
                        (profileController.userInfoModel!.gender == null || profileController.userInfoModel!.gender!.isEmpty)) ...[
                      const SizedBox(height: Dimensions.paddingSizeExtraOverLarge),
                      Text(
                        'gender'.tr,
                        style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Theme.of(context).secondaryHeaderColor),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      Row(children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedGender = 'male';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                              decoration: BoxDecoration(
                                color: _selectedGender == 'male' ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: _selectedGender == 'male' ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withValues(alpha: 0.2)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.male, color: _selectedGender == 'male' ? Theme.of(context).primaryColor : Theme.of(context).disabledColor),
                                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                  Text('male'.tr, style: robotoMedium.copyWith(color: _selectedGender == 'male' ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge!.color)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeDefault),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedGender = 'female';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                              decoration: BoxDecoration(
                                color: _selectedGender == 'female' ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: _selectedGender == 'female' ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withValues(alpha: 0.2)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.female, color: _selectedGender == 'female' ? Theme.of(context).primaryColor : Theme.of(context).disabledColor),
                                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                  Text('female'.tr, style: robotoMedium.copyWith(color: _selectedGender == 'female' ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge!.color)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ],

                  ]),
                ),

                // Shein-style Size Information & Preference Widget
                if(isLoggedIn)
                  Container(
                    margin: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, spreadRadius: 1)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                Get.to(() => const EditSizeScreen());
                              },
                              child: Row(
                                children: [
                                  const Icon(Icons.add, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text('add_more'.tr, style: robotoRegular.copyWith(color: Colors.grey[600], fontSize: 12)),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Get.to(() => const SizeInformationScreen());
                              },
                              child: Row(
                                children: [
                                  Text('size_information'.tr, style: robotoBold.copyWith(fontSize: 14)),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.straighten, size: 18, color: Colors.black),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),

                        // Sizes List
                        profileController.sizeList.isEmpty
                          ? Text(
                              'no_size_profiles_menu'.tr,
                              style: robotoRegular.copyWith(color: Colors.grey, fontSize: 12),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: profileController.sizeList.length,
                              separatorBuilder: (context, idx) => const Divider(height: 12, color: Color(0xFFF5F5F5)),
                              itemBuilder: (context, idx) {
                                final size = profileController.sizeList[idx];
                                return Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Get.to(() => EditSizeScreen(sizeInfo: size));
                                      },
                                      child: const Icon(Icons.edit_outlined, color: Colors.grey, size: 18),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(size.label, style: robotoMedium.copyWith(fontSize: 14)),
                                    const Spacer(),
                                    Text(
                                      '${size.weight.toStringAsFixed(0)}kg / ${size.bust.toStringAsFixed(0)}cm / ${size.waist.toStringAsFixed(0)}cm',
                                      style: robotoRegular.copyWith(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                );
                              },
                            ),

                        const Divider(height: 24),

                        // Preference Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(Icons.arrow_back_ios, size: 12, color: Colors.grey),
                            InkWell(
                              onTap: () {
                                Get.to(() => const PreferenceScreen());
                              },
                              child: Row(
                                children: [
                                  Text('my_preference'.tr, style: robotoBold.copyWith(fontSize: 14)),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.favorite_border, size: 18, color: Colors.black),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Selected Preferences Wrap
                        profileController.shoppingPreference.isCompleted
                          ? Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              alignment: WrapAlignment.end,
                              children: [
                                ...profileController.shoppingPreference.favoriteCategories,
                                ...profileController.shoppingPreference.targetAudience,
                                ...profileController.shoppingPreference.favoriteStyles,
                              ].map((pref) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    pref.tr,
                                    style: robotoRegular.copyWith(fontSize: 11, color: Colors.black87),
                                  ),
                                );
                              }).toList(),
                            )
                          : Text(
                              'configure_preferences_hint'.tr,
                              style: robotoRegular.copyWith(color: Colors.grey, fontSize: 12),
                            ),
                      ],
                    ),
                  ),

                isLoggedIn && Get.find<SplashController>().configModel!.centralizeLoginSetup!.manualLoginStatus! ? Padding(
                  padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
                  child: ProfileButtonWidget(icon: Icons.lock, title: 'change_password'.tr, onTap: () {
                    Get.toNamed(RouteHelper.getResetPasswordRoute(phone: '', email: '', token: '', page: 'password-change'));
                  }),
                ) : const SizedBox(),

              ]))),
            )),

            SafeArea(
              top: false,
              child: CustomButton(
                isLoading: profileController.isLoading,
                onPressed: () => _updateProfile(profileController: profileController, fromButton: true, fromPhone: false),
                margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                buttonText: 'update'.tr,
              ),
            ),

          ]),
        ) : const CustomLoaderWidget() : Center(
          child: NotLoggedInScreen(callBack: (value){
            _initCall();
            setState(() {});
          }),
        );
      }),
    );
  }

  Widget webView(ProfileController profileController, bool isLoggedIn) {
    return SingleChildScrollView(
      controller: scrollController,
      child: FooterView(
        child: Stack(children: [

          SizedBox(height: 520, width: context.width),

          Center(
            child: Container(
              height: 300, width: Dimensions.webMaxWidth,
              decoration: BoxDecoration(
               color: Theme.of(context).primaryColor,
                image: const DecorationImage(image: AssetImage(Images.profileBg), fit: BoxFit.fill),
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
                  child: Text('profile'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).cardColor)),
                ),
              ),
            ),
          ),

          Positioned(
            top: 120, left: 0, right: 0,
            child: Center(
              child: Stack(clipBehavior : Clip.none, children: [

                Container(
                  alignment: Alignment.topCenter,
                  height: 400, width: Dimensions.webMaxWidth,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge), bottom: Radius.circular(Dimensions.radiusDefault)),
                    boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
                  ),
                ),

                Positioned(
                  top: -50, left: 0, right: 0,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Stack(children: [

                      ClipOval(child: profileController.pickedFile != null ? GetPlatform.isWeb ? Image.network(
                          profileController.pickedFile!.path, width: 100, height: 100, fit: BoxFit.cover) : Image.file(
                          File(profileController.pickedFile!.path), width: 100, height: 100, fit: BoxFit.cover) : CustomImage(
                        image: '${profileController.userInfoModel!.imageFullUrl}',
                        height: 100, width: 100, fit: BoxFit.cover,
                      )),

                      Positioned(
                        bottom: 0, right: 0, top: 0, left: 0,
                        child: InkWell(
                          onTap: () => profileController.pickImage(),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.3), shape: BoxShape.circle,
                            ),
                            child: Container(
                              margin: const EdgeInsets.all(25),
                              decoration: BoxDecoration(
                                border: Border.all(width: 2, color: Colors.white),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white),
                            ),
                          ),
                        ),
                      ),

                    ]),
                  ),
                ),

                Positioned(
                  top: 80, left: 0, right: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 90),
                    child: Center(
                      child: SizedBox(
                        width: 500,
                        child: Column(children: [

                          CustomTextField(
                            titleText: 'enter_name'.tr,
                            controller: _nameController,
                            capitalization: TextCapitalization.words,
                            inputType: TextInputType.name,
                            focusNode: _nameFocus,
                            nextFocus: _emailFocus,
                            prefixIcon: CupertinoIcons.person_alt_circle_fill,
                            labelText: 'name'.tr,
                            required: true,
                            validator: (value) => ValidateCheck.validateEmptyText(value, "first_name_field_is_required".tr),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeExtraOverLarge),

                          CustomTextField(
                            titleText: 'enter_email'.tr,
                            controller: _emailController,
                            focusNode: _emailFocus,
                            inputType: TextInputType.emailAddress,
                            prefixIcon: CupertinoIcons.mail_solid,
                            labelText: 'email'.tr,
                            required: true,
                            validator: (value) => ValidateCheck.validateEmail(value),
                            onChanged: (value) {
                              profileController.update();
                            },
                            suffixImage: profileController.userInfoModel!.isEmailVerified! && profileController.userInfoModel!.email == _emailController.text
                              ? Images.verifiedIcon : Get.find<SplashController>().configModel!.centralizeLoginSetup!.emailVerificationStatus! ? Images.unverifiedIcon : null,
                            suffixOnPressed: () {
                              if(!profileController.userInfoModel!.isEmailVerified! || profileController.userInfoModel!.email != _emailController.text) {
                                _updateProfile(profileController: profileController, fromButton: false, fromPhone: false);
                              }
                            },
                          ),
                          const SizedBox(height: Dimensions.paddingSizeExtraOverLarge),

                          Stack(children: [
                            CustomTextField(
                              titleText: 'phone'.tr,
                              controller: _phoneController,
                              focusNode: _phoneFocus,
                              inputType: TextInputType.phone,
                              isEnabled: !profileController.userInfoModel!.isPhoneVerified! || profileController.userInfoModel!.phone == null,
                              fromUpdateProfile: true,
                              labelText: 'phone'.tr,
                              required: true,
                              isPhone: true,
                              onCountryChanged: (CountryCode countryCode) => _countryDialCode = countryCode.dialCode,
                              countryDialCode: _countryDialCode ?? Get.find<LocalizationController>().locale.countryCode,
                              suffixImage: profileController.userInfoModel!.isPhoneVerified! ? Images.verifiedIcon : null,
                            ),

                            Positioned(
                              right: 10, top: 10,
                              child: !profileController.userInfoModel!.isPhoneVerified! && Get.find<SplashController>().configModel!.centralizeLoginSetup!.phoneVerificationStatus! ? InkWell(
                                onTap: () {
                                  if(!profileController.userInfoModel!.isPhoneVerified! && Get.find<SplashController>().configModel!.centralizeLoginSetup!.phoneVerificationStatus!) {
                                    _updateProfile(profileController: profileController, fromButton: false, fromPhone: true);
                                  }
                                },
                                child: Image.asset(Images.unverifiedIcon, height: 25, width: 25, fit: BoxFit.cover),
                              ) : const SizedBox(),
                            ),
                          ]),
                          const SizedBox(height: Dimensions.paddingSizeExtraOverLarge),

                          CustomButton(
                            width: 500,
                            buttonText: 'update_profile'.tr,
                            fontSize: Dimensions.fontSizeDefault,
                            isBold: false,
                            radius: Dimensions.radiusSmall,
                            isLoading: profileController.isLoading,
                            onPressed: () => _updateProfile(profileController: profileController, fromButton: true, fromPhone: false),
                          ),

                        ]),
                      ),
                    ),
                  ),
                ),

              ]),
            ),
          ),

        ]),
      ),
    );
  }

  Future<void> _updateProfile({required ProfileController profileController, required bool fromButton, required bool fromPhone}) async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String phoneNumber = _phoneController.text.trim();
    String numberWithCountryCode = _countryDialCode! + phoneNumber;
    PhoneValid phoneValid = await CustomValidator.isPhoneValid(numberWithCountryCode);
    numberWithCountryCode = phoneValid.phone;

    if (name.isEmpty) {
      showCustomSnackBar('enter_your_name'.tr);
    }else if(!phoneValid.isValid) {
      showCustomSnackBar('invalid_phone_number'.tr);
    }else if (email.isEmpty) {
      showCustomSnackBar('enter_email_address'.tr);
    }else if (!GetUtils.isEmail(email)) {
      showCustomSnackBar('enter_a_valid_email_address'.tr);
    }else if (phoneNumber.isEmpty) {
      showCustomSnackBar('enter_phone_number'.tr);
    }else if (phoneNumber.length < 6) {
      showCustomSnackBar('enter_a_valid_phone_number'.tr);
    } else {
      bool showGenderField = profileController.userInfoModel == null ||
          profileController.userInfoModel!.gender == null ||
          profileController.userInfoModel!.gender!.isEmpty;

      if (showGenderField && _selectedGender == null) {
        showCustomSnackBar('please_select_gender'.tr);
      } else {
        UpdateUserModel updatedUser = UpdateUserModel(
          name: name,
          email: email,
          phone: numberWithCountryCode,
          buttonType: fromPhone ? 'phone' : 'profile',
          gender: showGenderField ? _selectedGender : null,
        );
        await profileController.updateUserInfo(updatedUser, Get.find<AuthController>().getUserToken(), fromButton: fromButton);
      }
    }
  }
}
