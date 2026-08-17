import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/features/profile/domain/models/size_info_model.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/favourite/controllers/favourite_controller.dart';
import 'package:sixam_mart/features/chat/domain/models/conversation_model.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/common/models/response_model.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/profile/domain/models/update_user_model.dart';
import 'package:sixam_mart/features/profile/domain/models/userinfo_model.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/verification/screens/verification_screen.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/profile/domain/services/profile_service_interface.dart';
import 'package:sixam_mart/api/api_client.dart';

class ProfileController extends GetxController implements GetxService {
  final ProfileServiceInterface profileServiceInterface;
  ProfileController({required this.profileServiceInterface});

  UserInfoModel? _userInfoModel;
  UserInfoModel? get userInfoModel => _userInfoModel;

  XFile? _pickedFile;
  XFile? get pickedFile => _pickedFile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool get proStatus => _userInfoModel?.proStatus ?? false;

  List<SizeInfo> _sizeList = [];
  List<SizeInfo> get sizeList => _sizeList;

  ShoppingPreference _shoppingPreference = ShoppingPreference.empty();
  ShoppingPreference get shoppingPreference => _shoppingPreference;

  void loadSizeAndPreferences() {
    try {
      final sharedPref = Get.find<SharedPreferences>();
      final String? sizesJson = sharedPref.getString('user_size_info_list');
      if (sizesJson != null) {
        final List decoded = jsonDecode(sizesJson);
        _sizeList = decoded.map((e) => SizeInfo.fromJson(e)).toList();
      } else {
        _sizeList = [];
      }

      final String? prefJson = sharedPref.getString('user_shopping_preferences');
      if (prefJson != null) {
        _shoppingPreference = ShoppingPreference.fromJson(jsonDecode(prefJson));
      } else {
        _shoppingPreference = ShoppingPreference.empty();
      }
    } catch (e) {
      // ignore
    }
    Future.microtask(() => update());
  }

  Future<void> saveSizeInfo(SizeInfo size) async {
    final sharedPref = Get.find<SharedPreferences>();
    int index = _sizeList.indexWhere((element) => element.id == size.id);
    if (index != -1) {
      _sizeList[index] = size;
    } else {
      _sizeList.add(size);
    }
    await sharedPref.setString('user_size_info_list', jsonEncode(_sizeList.map((e) => e.toJson()).toList()));
    update();
  }

  Future<void> deleteSizeInfo(String id) async {
    final sharedPref = Get.find<SharedPreferences>();
    _sizeList.removeWhere((element) => element.id == id);
    await sharedPref.setString('user_size_info_list', jsonEncode(_sizeList.map((e) => e.toJson()).toList()));
    update();
  }

  Future<void> savePreferences(ShoppingPreference preference) async {
    final sharedPref = Get.find<SharedPreferences>();
    _shoppingPreference = preference;
    await sharedPref.setString('user_shopping_preferences', jsonEncode(_shoppingPreference.toJson()));
    update();
  }

  Future<void> getUserInfo() async {
    _pickedFile = null;
    loadSizeAndPreferences();
    UserInfoModel? userInfoModel = await profileServiceInterface.getUserInfo();
    if (userInfoModel != null) {
      _userInfoModel = userInfoModel;
      
      ZegoUIKitPrebuiltCallInvitationService().init(
        appID: AppConstants.zegoAppId,
        appSign: AppConstants.zegoAppSign,
        userID: 'user_${userInfoModel.id}',
        userName: '${userInfoModel.fName} ${userInfoModel.lName}',
        plugins: [ZegoUIKitSignalingPlugin()],
        config: ZegoCallInvitationConfig(
          permissions: [],
        ),
        notificationConfig: ZegoCallInvitationNotificationConfig(
          androidNotificationConfig: ZegoAndroidNotificationConfig(
            channelID: "zego_video_call",
            channelName: "VoIP Call",
            sound: "zego_incoming",
          ),
        ),
        uiConfig: ZegoCallInvitationUIConfig(
          inviter: ZegoCallInvitationInviterUIConfig(
            defaultCameraOn: false,
            defaultMicrophoneOn: true,
          ),
          invitee: ZegoCallInvitationInviteeUIConfig(
            defaultCameraOn: false,
            defaultMicrophoneOn: true,
          ),
        ),
        invitationEvents: ZegoUIKitPrebuiltCallInvitationEvents(
          onError: (error) {
            if (error.code == 6000281 || error.message.contains('107026')) {
              showCustomSnackBar('delivery_man_offline_message'.tr);
            }
          },
        ),
        requireConfig: (ZegoCallInvitationData data) {
          var config = ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();
          config.turnOnMicrophoneWhenJoining = true;
          config.useSpeakerWhenJoining = true;
          return config;
        },
      );
    }
    update();
  }

  void setForceFullyUserEmpty() {
    _userInfoModel = null;
    ZegoUIKitPrebuiltCallInvitationService().uninit();
  }

  Future<ResponseModel> updateUserInfo(UpdateUserModel updateUserModel, String token, {bool fromVerification = false, bool fromButton = false}) async {
    if(fromButton) {
      _isLoading = true;
      update();
    }
    ResponseModel responseModel = await profileServiceInterface.updateProfile(updateUserModel, _pickedFile, token);
    if(!fromVerification) {
      _updateProfileResponseHandle(responseModel, updateUserModel, token);
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<void> toggleAnonymity() async {
    if (_userInfoModel != null) {
      bool currentStatus = _userInfoModel!.isAnonymous ?? false;
      bool newStatus = !currentStatus;
      
      // Optimistic update
      _userInfoModel!.isAnonymous = newStatus;
      update();
      
      UpdateUserModel updateUserModel = UpdateUserModel(
        name: '${_userInfoModel!.fName} ${_userInfoModel!.lName}',
        email: _userInfoModel!.email,
        phone: _userInfoModel!.phone,
        isAnonymous: newStatus,
        buttonType: 'profile',
      );
      
      String token = Get.find<AuthController>().getUserToken();
      
      ResponseModel responseModel = await profileServiceInterface.updateProfile(updateUserModel, null, token);
      if (!responseModel.isSuccess) {
        // Rollback
        _userInfoModel!.isAnonymous = currentStatus;
        update();
        showCustomSnackBar(responseModel.message);
      } else {
        showCustomSnackBar('Profile updated successfully'.tr, isError: false);
      }
    }
  }

  Future<bool> toggleDiscoverability(bool isDiscoverable) async {
    _isLoading = true;
    update();
    Response response = await Get.find<ApiClient>().putData(
      '/api/v1/customer/privacy-settings',
      {'is_discoverable': isDiscoverable},
    );
    _isLoading = false;
    if (response.statusCode == 200) {
      if (_userInfoModel != null) {
        _userInfoModel!.isDiscoverable = isDiscoverable;
      }
      update();
      showCustomSnackBar(response.body['message'] ?? 'Privacy settings updated successfully'.tr, isError: false);
      return true;
    } else {
      showCustomSnackBar(response.statusText ?? 'Failed to update privacy settings'.tr, isError: true);
      return false;
    }
  }

  Future<void> _updateProfileResponseHandle(ResponseModel responseModel, UpdateUserModel updateUserModel, String token) async {
    updateUserModel.verificationOn = responseModel.updateProfileResponseModel?.verificationOn;
    updateUserModel.verificationMedium = responseModel.updateProfileResponseModel?.verificationMedium;

    if(responseModel.isSuccess && responseModel.updateProfileResponseModel != null && responseModel.updateProfileResponseModel!.verificationOn != null && responseModel.updateProfileResponseModel!.verificationOn! == 'phone'){
      if(responseModel.updateProfileResponseModel!.verificationMedium! == 'firebase') {
        Get.find<AuthController>().firebaseVerifyPhoneNumber(updateUserModel.phone!, token, '', fromSignUp: false, updateUserModel: updateUserModel);
      } else {
        if(Get.isDialogOpen!) {
          Get.back();
        }
        if(ResponsiveHelper.isDesktop(Get.context)) {
          Get.dialog(VerificationScreen(
            number: updateUserModel.phone!, email: null, token: '', fromSignUp: false,
            fromForgetPassword: false, loginType: '', password: '', userModel: updateUserModel,
          ));
        } else {
          Get.toNamed(RouteHelper.getVerificationRoute(updateUserModel.phone!, null, '', '', null, '', updateUserModel: updateUserModel));
        }
      }
    } else if(responseModel.isSuccess && responseModel.updateProfileResponseModel != null && responseModel.updateProfileResponseModel!.verificationOn != null && responseModel.updateProfileResponseModel!.verificationOn! == 'email'){
      if(Get.isDialogOpen!) {
        Get.back();
      }
      if(ResponsiveHelper.isDesktop(Get.context)) {
        Get.dialog(VerificationScreen(
          number: null, email: updateUserModel.email!, token: '', fromSignUp: false,
          fromForgetPassword: false, loginType: '', password: '', userModel: updateUserModel,
        ));
      } else {
        Get.toNamed(RouteHelper.getVerificationRoute(null, updateUserModel.email!, '', '', null, '', updateUserModel: updateUserModel));
      }
    } else if(responseModel.isSuccess && responseModel.updateProfileResponseModel == null){
      if(Get.isDialogOpen!) {
        Get.back();
      }
      await getUserInfo();
      if(!ResponsiveHelper.isDesktop(Get.context)){
        Get.back();
        Get.back();
      }
      _pickedFile = null;
      showCustomSnackBar(responseModel.message, isError: false);
    }  else if(!responseModel.isSuccess && responseModel.updateProfileResponseModel != null){
      if(Get.isDialogOpen!) {
        Get.back();
      }
      showCustomSnackBar(responseModel.updateProfileResponseModel!.message);
    } else {
      if(Get.isDialogOpen!) {
        Get.back();
      }
      showCustomSnackBar(responseModel.message);
    }
  }

  Future<ResponseModel> changePassword(UserInfoModel updatedUserModel) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await profileServiceInterface.changePassword(updatedUserModel);
    _isLoading = false;
    update();
    return responseModel;
  }

  void updateUserWithNewData(User? user) {
    _userInfoModel!.userInfo = user;
  }

  void pickImage() async {
    _pickedFile = await profileServiceInterface.pickImageFromGallery();
    update();
  }

  void initData({bool isUpdate = false}) {
    _pickedFile = null;
    if(isUpdate){
      update();
    }
  }

  Future<void> deleteUser() async {
    _isLoading = true;
    update();
    Response response = await profileServiceInterface.deleteUser();
    _isLoading = false;
    if (response.statusCode == 200) {
      await Get.find<AuthController>().clearSharedData(removeToken: false);
      await Get.find<AuthController>().clearUserNumberAndPassword();
      await Get.find<CartController>().clearCartList();
      if(Get.find<AuthController>().isActiveRememberMe) {
        Get.find<AuthController>().toggleRememberMe();
      }
      Get.find<FavouriteController>().removeFavourite();
      setForceFullyUserEmpty();
      showCustomSnackBar('your_account_remove_successfully'.tr, isError: false);
      _isLoading = false;
      Get.find<LocationController>().navigateToLocationScreen('splash', offNamed: true);
    } else {
      _isLoading = false;
      Get.back();
    }
    update();
  }

  void clearUserInfo() {
    _userInfoModel = null;
    ZegoUIKitPrebuiltCallInvitationService().uninit();
    update();
  }

}