import 'package:get/get.dart';
import 'package:sixam_mart/features/onboard/domain/repository/onboard_repository_interface.dart';
import 'package:sixam_mart/features/onboard/domain/models/onboarding_model.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/common/models/config_model.dart';

class OnboardRepository implements OnboardRepositoryInterface {

  @override
  Future<Response> getList({int? offset}) async {
    try {
      List<OnBoardingModel> onBoardingList = [];
      List<OnboardingScreen>? screens = Get.find<SplashController>().configModel!.onboardingScreens;
      bool isLtr = Get.isRegistered<LocalizationController>() ? Get.find<LocalizationController>().isLtr : false;

      if(screens != null && screens.isNotEmpty) {
        for (var screen in screens) {
          String title = (isLtr && screen.titleEn != null && screen.titleEn!.isNotEmpty) ? screen.titleEn! : (screen.title ?? '');
          String description = (isLtr && screen.descriptionEn != null && screen.descriptionEn!.isNotEmpty) ? screen.descriptionEn! : (screen.description ?? '');
          onBoardingList.add(OnBoardingModel(screen.imageFullUrl ?? '', title, description));
        }
      } else {
        // Fallback or empty list
      }

      Response response = Response(body: onBoardingList, statusCode: 200);
      return response;
    } catch (e) {
      return const Response(statusCode: 404, statusText: 'Onboarding data not found');
    }
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }

}