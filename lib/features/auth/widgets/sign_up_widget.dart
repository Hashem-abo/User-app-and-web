import 'dart:convert';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/models/response_model.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/custom_text_field.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/auth/domain/enum/centralize_login_enum.dart';
import 'package:sixam_mart/features/auth/domain/models/signup_body_model.dart';
import 'package:sixam_mart/features/auth/widgets/condition_check_box_widget.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/verification/screens/verification_screen.dart';
import 'package:sixam_mart/helper/custom_validator.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/helper/validate_check.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/features/auth/widgets/social_login_widget.dart';

class SignUpWidget extends StatefulWidget {
  const SignUpWidget({super.key});

  @override
  SignUpWidgetState createState() => SignUpWidgetState();
}

class SignUpWidgetState extends State<SignUpWidget> {
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  final FocusNode _referCodeFocus = FocusNode();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _referCodeController = TextEditingController();
  String? _countryDialCode;
  GlobalKey<FormState>? _formKeySignUp;

  @override
  void initState() {
    super.initState();
    _formKeySignUp = GlobalKey<FormState>();
    _countryDialCode = CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).dialCode;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKeySignUp,
      child: Container(
        width: context.width > 700 ? 500 : context.width,
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: GetBuilder<AuthController>(builder: (authController) {
          return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [

            // Name Label
            Text(
              'user_name'.tr,
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).secondaryHeaderColor),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            CustomTextField(
              hintText: 'ex_jhon'.tr,
              controller: _nameController,
              focusNode: _nameFocus,
              nextFocus: _phoneFocus,
              inputType: TextInputType.name,
              capitalization: TextCapitalization.words,
              prefixIcon: CupertinoIcons.person,
              validator: (value) => ValidateCheck.validateEmptyText(value, "please_enter_your_name".tr),
              borderRadius: 15,
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            // Phone Label
            Text(
              'phone'.tr,
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).secondaryHeaderColor),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
           Directionality(
                textDirection: TextDirection.ltr,
                child: CustomTextField(
                  hintText: 'xxx-xxx-xxxxx'.tr,
                  controller: _phoneController,
                  focusNode: _phoneFocus,
                  nextFocus: _emailFocus,
                  inputType: TextInputType.number, // Forces numeric keyboard layout
                  isPhone: true,
                  maxLength: 9,
                  onCountryChanged: (CountryCode countryCode) {
                    _countryDialCode = countryCode.dialCode;
                  },
                  countryDialCode: _countryDialCode != null 
                      ? CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).code
                      : Get.find<LocalizationController>().locale.countryCode,
                  validator: (value) => ValidateCheck.validateEmptyText(value, "please_enter_phone_number".tr),
                  borderRadius: 15,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
            // Email Label
            Text(
              'email'.tr,
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).secondaryHeaderColor),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            CustomTextField(
              hintText: 'enter_email'.tr,
              controller: _emailController,
              focusNode: _emailFocus,
              nextFocus: _passwordFocus,
              inputType: TextInputType.emailAddress,
              prefixIcon: CupertinoIcons.mail,
              validator: (value) => ValidateCheck.validateEmail(value),
              borderRadius: 15,
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            // Password Label
            Text(
              'password'.tr,
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).secondaryHeaderColor),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            CustomTextField(
              hintText: '8+characters'.tr,
              controller: _passwordController,
              focusNode: _passwordFocus,
              nextFocus: _confirmPasswordFocus,
              inputType: TextInputType.visiblePassword,
              prefixIcon: Icons.lock_outline,
              isPassword: true,
              validator: (value) => ValidateCheck.validateEmptyText(value, "please_enter_password".tr),
              borderRadius: 15,
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            // Confirm Password Label
            Text(
              'confirm_password'.tr,
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).secondaryHeaderColor),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            CustomTextField(
              hintText: 're_enter_your_password'.tr,
              controller: _confirmPasswordController,
              focusNode: _confirmPasswordFocus,
              nextFocus: Get.find<SplashController>().configModel!.refEarningStatus == 1 ? _referCodeFocus : null,
              inputAction: Get.find<SplashController>().configModel!.refEarningStatus == 1 ? TextInputAction.next : TextInputAction.done,
              inputType: TextInputType.visiblePassword,
              prefixIcon: Icons.lock_outline,
              isPassword: true,
              onSubmit: (text) => (GetPlatform.isWeb) ? _register(authController, _countryDialCode!) : null,
              validator: (value) => ValidateCheck.validateConfirmPassword(value, _passwordController.text),
              borderRadius: 15,
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            // Refer Code Label
            if (Get.find<SplashController>().configModel!.refEarningStatus == 1) ...[
              Text(
                '${'refer_code'.tr} (${'optional'.tr})',
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).secondaryHeaderColor),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              CustomTextField(
                hintText: 'refer_code'.tr,
                controller: _referCodeController,
                focusNode: _referCodeFocus,
                inputAction: TextInputAction.done,
                inputType: TextInputType.text,
                capitalization: TextCapitalization.words,
                prefixIcon: CupertinoIcons.group,
                borderRadius: 15,
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
            ],

            const ConditionCheckBoxWidget(forDeliveryMan: true),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            CustomButton(
              buttonText: 'continue'.tr,
              radius: 15,
              isBold: true,
              isLoading: authController.isLoading,
              onPressed: authController.acceptTerms ? () => _register(authController, _countryDialCode!) : null,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),


            // Google Login
            SocialLoginWidget(onlySocialLogin: false, backFromThis: false),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
              child: Row(children: [
                Expanded(child: Container(height: 1, color: Theme.of(context).disabledColor)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                  child: Text('already_have_account'.tr, style: robotoMedium.copyWith(color: Theme.of(context).disabledColor)),
          ),
          Expanded(child: Container(height: 1, color: Theme.of(context).disabledColor)),
        ]),
      ),
      const SizedBox(height: Dimensions.paddingSizeSmall),
            // Sign In link
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              InkWell(
                onTap: authController.isLoading ? null : () {
                  if (Get.currentRoute == RouteHelper.signUp) {
                    Get.back();
                  } else {
                    Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.signUp));
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                  child: Text('sign_in'.tr, style: robotoBold.copyWith(color: Theme.of(context).primaryColor)),
                ),
              ),
            ]),

          ]);
        }),
      ),
    );
  }

  void _register(AuthController authController, String countryCode) async {

    SignUpBodyModel? signUpModel = await _prepareSignUpBody(countryCode);

    if(signUpModel == null) {
      return;
    } else {
      authController.registration(signUpModel).then((status) async {
        _handleResponse(status, countryCode);
      });
    }
  }

  void _handleResponse(ResponseModel status, String countryCode) {
    String password = _passwordController.text.trim();
    String numberWithCountryCode = countryCode + _phoneController.text.trim();
    String email = _emailController.text.trim();

    if (status.isSuccess) {
      if(ResponsiveHelper.isDesktop(context)) {
        Get.find<CartController>().getCartDataOnline();
      }
      if(status.authResponseModel != null && !status.authResponseModel!.isPhoneVerified!) {
        List<int> encoded = utf8.encode(password);
        String data = base64Encode(encoded);
        if(Get.find<SplashController>().configModel!.firebaseOtpVerification!) {
          Get.find<AuthController>().firebaseVerifyPhoneNumber(numberWithCountryCode, status.message, CentralizeLoginType.manual.name, fromSignUp: true);
        } else {
          if(ResponsiveHelper.isDesktop(context)) {
            Get.back();
            Get.dialog(VerificationScreen(
              number: numberWithCountryCode, email: null, token: status.message, fromSignUp: true,
              fromForgetPassword: false, loginType: CentralizeLoginType.manual.name, password: password,
            ));
          } else {
            Get.toNamed(RouteHelper.getVerificationRoute(
              numberWithCountryCode, null, status.message, RouteHelper.signUp, data, CentralizeLoginType.manual.name,
            ));
          }
        }
      } else if(status.authResponseModel != null && !status.authResponseModel!.isEmailVerified!) {
        List<int> encoded = utf8.encode(password);
        String data = base64Encode(encoded);
        if(ResponsiveHelper.isDesktop(context)) {
          Get.back();
          Get.dialog(VerificationScreen(
            number: null, email: email, token: status.message, fromSignUp: true,
            fromForgetPassword: false, loginType: CentralizeLoginType.manual.name, password: password,
          ));
        } else {
          Get.toNamed(RouteHelper.getVerificationRoute(
            null, email, status.message, RouteHelper.signUp, data, CentralizeLoginType.manual.name,
          ));
        }
      } else {
        Get.find<ProfileController>().getUserInfo();
        Get.find<LocationController>().navigateToLocationScreen(RouteHelper.signUp);
        if(ResponsiveHelper.isDesktop(context)) {
          Get.back();
        }
      }
    } else {
      showCustomSnackBar(status.message);
    }
  }

  Future<SignUpBodyModel?> _prepareSignUpBody(String countryCode) async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String number = _phoneController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();
    String referCode = _referCodeController.text.trim();

    String numberWithCountryCode = countryCode + number;
    PhoneValid phoneValid = await CustomValidator.isPhoneValid(numberWithCountryCode);
    numberWithCountryCode = phoneValid.phone;

    if (_formKeySignUp!.currentState!.validate()) {
      if (name.isEmpty) {
        showCustomSnackBar('please_enter_your_name'.tr);
      } else if (email.isEmpty) {
        showCustomSnackBar('enter_email_address'.tr);
      } else if (!GetUtils.isEmail(email)) {
        showCustomSnackBar('enter_a_valid_email_address'.tr);
      } else if (number.isEmpty) {
        showCustomSnackBar('enter_phone_number'.tr);
      } else if (!phoneValid.isValid) {
        showCustomSnackBar('invalid_phone_number'.tr);
      } else if (password.isEmpty) {
        showCustomSnackBar('enter_password'.tr);
      } else if (password.length < 8) {
        showCustomSnackBar('password_should_be_8_characters'.tr);
      } else if (password != confirmPassword) {
        showCustomSnackBar('confirm_password_does_not_matched'.tr);
      } else if (referCode.isNotEmpty && referCode.length != 10) {
        showCustomSnackBar('invalid_refer_code'.tr);
      } else {
        SignUpBodyModel signUpBody = SignUpBodyModel(
          name: name,
          email: email,
          phone: numberWithCountryCode,
          password: password,
          refCode: referCode,
        );
        return signUpBody;
      }
    }
    return null;
  }
}