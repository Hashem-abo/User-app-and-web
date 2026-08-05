import 'dart:async';
import 'package:get/get.dart';
import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'package:sixam_mart/features/home/domain/models/cashback_model.dart';
import 'package:sixam_mart/features/home/domain/models/homepage_model.dart';
import 'package:sixam_mart/features/home/domain/services/home_service_interface.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/banner/controllers/banner_controller.dart';
import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/features/shelf/controllers/shelf_controller.dart';
import 'package:sixam_mart/features/home/controllers/store_corner_controller.dart';
import 'package:sixam_mart/features/item/controllers/campaign_controller.dart';
import 'package:sixam_mart/features/home/controllers/super_banner_controller.dart';

class HomeController extends GetxController implements GetxService {
  final HomeServiceInterface homeServiceInterface;
  HomeController({required this.homeServiceInterface});

  List<CashBackModel>? _cashBackOfferList;
  List<CashBackModel>? get cashBackOfferList => _cashBackOfferList;

  CashBackModel? _cashBackData;
  CashBackModel? get cashBackData => _cashBackData;

  bool _showFavButton = true;
  bool get showFavButton => _showFavButton;

  final Map<int, double> _moduleScrollOffsets = {};
  
  void saveScrollOffset(int moduleId, double offset) {
    _moduleScrollOffsets[moduleId] = offset;
  }
  
  double getScrollOffset(int moduleId) {
    return _moduleScrollOffsets[moduleId] ?? 0.0;
  }

  Future<void> getCashBackOfferList() async {
    _cashBackOfferList = null;
    _cashBackOfferList = await homeServiceInterface.getCashBackOfferList();
    update();
  }

  void forcefullyNullCashBackOffers() {
    _cashBackOfferList = null;
    update();
  }

  Future<void> getCashBackData(double amount) async {
    CashBackModel? cashBackModel = await homeServiceInterface.getCashBackData(amount);
    if(cashBackModel != null) {
      _cashBackData = cashBackModel;
    }
    update();
  }

  void changeFavVisibility(){
    _showFavButton = !_showFavButton;
    update();
  }

  Future<bool> saveRegistrationSuccessfulSharedPref(bool status) async {
    return await homeServiceInterface.saveRegistrationSuccessful(status);
  }

  Future<bool> saveIsStoreRegistrationSharedPref(bool status) async {
    return await homeServiceInterface.saveIsRestaurantRegistration(status);
  }

  bool getRegistrationSuccessfulSharedPref() {
    return homeServiceInterface.getRegistrationSuccessful();
  }

  bool getIsStoreRegistrationSharedPref() {
    return homeServiceInterface.getIsRestaurantRegistration();
  }

  Future<void> getHomepageData() async {
    HomepageModel? cachedHomepageModel = await homeServiceInterface.getHomepageData(source: DataSourceEnum.local);
    if(cachedHomepageModel != null) {
      _populateHomepageData(cachedHomepageModel);
    }

    HomepageModel? freshHomepageModel = await homeServiceInterface.getHomepageData(source: DataSourceEnum.client);
    if(freshHomepageModel != null) {
      _populateHomepageData(freshHomepageModel);
    }
  }

  void _populateHomepageData(HomepageModel homepageModel) {
    if (homepageModel.modules != null) {
      Get.find<SplashController>().setModuleList(homepageModel.modules);
    }
    if (homepageModel.banners != null) {
      Get.find<BannerController>().setBannerData(homepageModel.banners);
    }
    if (homepageModel.otherBanners != null) {
      Get.find<BannerController>().setPromotionalBanner(homepageModel.otherBanners);
    }
    if (homepageModel.categories != null) {
      Get.find<CategoryController>().setCategoryList(homepageModel.categories);
    }
    if (homepageModel.shelves != null) {
      Get.find<ShelfController>().setShelfList(homepageModel.shelves);
    }
    if (homepageModel.storeCorner != null) {
      Get.find<StoreCornerController>().setStoreCornerList(homepageModel.storeCorner);
    }
    if (homepageModel.campaignsBasic != null || homepageModel.campaignsItem != null) {
      Get.find<CampaignController>().setCampaignData(
        basicCampaigns: homepageModel.campaignsBasic,
        itemCampaigns: homepageModel.campaignsItem,
      );
    }
    if (homepageModel.superBanners != null && homepageModel.superBanners!.isNotEmpty) {
      for (final banner in homepageModel.superBanners!) {
        if (banner.id != null) {
          Get.find<SuperBannerController>().preloadSuperBanner(banner);
        }
      }
    }
  }

}