import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'package:sixam_mart/features/banner/domain/models/banner_model.dart';
import 'package:sixam_mart/features/banner/domain/models/others_banner_model.dart';
import 'package:sixam_mart/features/banner/domain/models/promotional_banner_model.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/banner/domain/services/banner_service_interface.dart';

class BannerController extends GetxController implements GetxService {
  final BannerServiceInterface bannerServiceInterface;
  BannerController({required this.bannerServiceInterface});

  List<String?>? _bannerImageList;
  List<String?>? get bannerImageList => _bannerImageList;
  
  List<String?>? _taxiBannerImageList;
  List<String?>? get taxiBannerImageList => _taxiBannerImageList;
  
  List<String?>? _featuredBannerList;
  List<String?>? get featuredBannerList => _featuredBannerList;
  
  List<dynamic>? _bannerDataList;
  List<dynamic>? get bannerDataList => _bannerDataList;
  
  List<dynamic>? _taxiBannerDataList;
  List<dynamic>? get taxiBannerDataList => _taxiBannerDataList;
  
  List<dynamic>? _featuredBannerDataList;
  List<dynamic>? get featuredBannerDataList => _featuredBannerDataList;
  
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;
  
  ParcelOtherBannerModel? _parcelOtherBannerModel;
  ParcelOtherBannerModel? get parcelOtherBannerModel => _parcelOtherBannerModel;
  
  PromotionalBanner? _promotionalBanner;
  PromotionalBanner? get promotionalBanner => _promotionalBanner;

  void clearBannerData() {
    _bannerImageList = null;
    _featuredBannerList = null;
    _bannerDataList = null;
    _featuredBannerDataList = null;
    _promotionalBanner = null;
    update();
  }

  bool _isBannerLoaded = false;
  bool _isFeaturedBannerLoaded = false;
  final Map<int, List<String?>> _moduleBannerImageList = {};
  final Map<int, List<dynamic>> _moduleBannerDataList = {};
  bool _isPromotionalBannerLoaded = false;
  final bool _isTaxiBannerLoaded = false;
  final bool _isParcelOtherBannerLoaded = false;

  Future<void> getFeaturedBanner({bool reload = false}) async {
    if(!reload && _isFeaturedBannerLoaded && _featuredBannerList != null && _featuredBannerList!.isNotEmpty) {
      return;
    }
    BannerModel? bannerModel = await bannerServiceInterface.getFeaturedBannerList();
    if (bannerModel != null) {
      _featuredBannerList = [];
      _featuredBannerDataList = [];

      List<int?> moduleIdList = bannerServiceInterface.moduleIdList();

      for (var campaign in bannerModel.campaigns!) {
        if(_featuredBannerList!.contains(campaign.imageFullUrl)) {
          _featuredBannerList!.add('${campaign.imageFullUrl}${bannerModel.campaigns!.indexOf(campaign)}');
        } else {
          _featuredBannerList!.add(campaign.imageFullUrl);
        }
        _featuredBannerDataList!.add(campaign);
      }
      for (var banner in bannerModel.banners!) {
        if(_featuredBannerList!.contains(banner.imageFullUrl)) {
          _featuredBannerList!.add('${banner.imageFullUrl}${bannerModel.banners!.indexOf(banner)}');
        } else {
          _featuredBannerList!.add(banner.imageFullUrl);
        }
        if(banner.item != null && moduleIdList.contains(banner.item!.moduleId)) {
          _featuredBannerDataList!.add(banner.item);
        }else if(banner.store != null && moduleIdList.contains(banner.store!.moduleId)) {
          _featuredBannerDataList!.add(banner.store);
        }else if(banner.type == 'default') {
          _featuredBannerDataList!.add(banner.link);
        }else{
          _featuredBannerDataList!.add(null);
        }
      }
      _isFeaturedBannerLoaded = true;
    }
    update();
  }

  void clearBanner() {
    _bannerImageList = null;
    _isBannerLoaded = false;
    _isFeaturedBannerLoaded = false;
    _isPromotionalBannerLoaded = false;
  }

  Future<void> getBannerList(bool reload, {DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false}) async {
    int? currentModuleId = Get.find<SplashController>().module?.id;
    
    if(!reload && currentModuleId != null && _moduleBannerImageList.containsKey(currentModuleId)) {
      _bannerImageList = _moduleBannerImageList[currentModuleId];
      _bannerDataList = _moduleBannerDataList[currentModuleId];
      _isBannerLoaded = true;
      update();
      return;
    } else if (!reload) {
      // If not in cache and not reloading, clear the list to avoid showing old module's data
      _bannerImageList = null;
      _bannerDataList = null;
      _isBannerLoaded = false;
    }

    if(_bannerImageList == null || reload || fromRecall) {
      if(reload) {
        _bannerImageList = null;
      }
      BannerModel? bannerModel;
      if(dataSource == DataSourceEnum.local) {
        bannerModel = await bannerServiceInterface.getBannerList(source: DataSourceEnum.local);
        await _prepareBanner(bannerModel);

        getBannerList(false, dataSource: DataSourceEnum.client, fromRecall: true);
      } else {
        bannerModel = await bannerServiceInterface.getBannerList(source: DataSourceEnum.client);
        _prepareBanner(bannerModel);
        _isBannerLoaded = true;
      }

    }
  }

  Future<void> _prepareBanner(BannerModel? bannerModel) async{
    if (bannerModel != null) {
      _bannerImageList = [];
      _bannerDataList = [];
      for (var campaign in bannerModel.campaigns!) {
        if(_bannerImageList!.contains(campaign.imageFullUrl)) {
          _bannerImageList!.add('${campaign.imageFullUrl}${bannerModel.campaigns!.indexOf(campaign)}');
        } else {
          _bannerImageList!.add(campaign.imageFullUrl);
        }
        _bannerDataList!.add(campaign);
      }
      for (var banner in bannerModel.banners!) {

        if(_bannerImageList!.contains(banner.imageFullUrl)) {
          _bannerImageList!.add('${banner.imageFullUrl}${bannerModel.banners!.indexOf(banner)}');
        } else {
          _bannerImageList!.add(banner.imageFullUrl);
        }

        if(banner.item != null) {
          _bannerDataList!.add(banner.item);
        }else if(banner.store != null){
          _bannerDataList!.add(banner.store);
        }else if(banner.type == 'default'){
          _bannerDataList!.add(banner.link);
        }else{
          _bannerDataList!.add(null);
        }
      }
      
      int? currentModuleId = Get.find<SplashController>().module?.id;
      if (currentModuleId != null) {
        _moduleBannerImageList[currentModuleId] = _bannerImageList!;
        _moduleBannerDataList[currentModuleId] = _bannerDataList!;
      }
    }
    update();
  }

  Future<void> getTaxiBannerList(bool reload) async {
    if(_taxiBannerImageList == null || reload) {
      _taxiBannerImageList = null;
      BannerModel? bannerModel = await bannerServiceInterface.getTaxiBannerList();
      if (bannerModel != null) {
        _taxiBannerImageList = [];
        _taxiBannerDataList = [];
        for (var campaign in bannerModel.campaigns!) {
          _taxiBannerImageList!.add(campaign.imageFullUrl);
          _taxiBannerDataList!.add(campaign);
        }
        for (var banner in bannerModel.banners!) {
          _taxiBannerImageList!.add(banner.imageFullUrl);
          if(banner.item != null) {
            _taxiBannerDataList!.add(banner.item);
          }else if(banner.store != null){
            _taxiBannerDataList!.add(banner.store);
          }else if(banner.type == 'default'){
            _taxiBannerDataList!.add(banner.link);
          }else{
            _taxiBannerDataList!.add(null);
          }
        }
        if(ResponsiveHelper.isDesktop(Get.context) && _taxiBannerImageList!.length % 2 != 0){
          _taxiBannerImageList!.add(_taxiBannerImageList![0]);
          _taxiBannerDataList!.add(_taxiBannerDataList![0]);
        }
      }
      update();
    }
  }

  Future<void> getParcelOtherBannerList(bool reload, {DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false}) async {
    if(_parcelOtherBannerModel == null || reload || fromRecall) {
      ParcelOtherBannerModel? parcelOtherBannerModel;
      if(dataSource == DataSourceEnum.local) {
        parcelOtherBannerModel = await bannerServiceInterface.getParcelOtherBannerList(source: dataSource);
        _prepareParcelBanner(parcelOtherBannerModel);
        getParcelOtherBannerList(false, dataSource: DataSourceEnum.client, fromRecall: true);
      } else {
        parcelOtherBannerModel = await bannerServiceInterface.getParcelOtherBannerList(source: dataSource);
        _prepareParcelBanner(parcelOtherBannerModel);
      }
    }
  }

  void _prepareParcelBanner(ParcelOtherBannerModel? parcelOtherBannerModel) {
    if (parcelOtherBannerModel != null) {
      _parcelOtherBannerModel = parcelOtherBannerModel;
    }
    update();
  }

  Future<void> getPromotionalBannerList(bool reload) async {
    if(!reload && _isPromotionalBannerLoaded && _promotionalBanner != null) {
      return;
    }
    if(_promotionalBanner == null || reload) {
      PromotionalBanner? promotionalBanner = await bannerServiceInterface.getPromotionalBannerList();
      if (promotionalBanner != null) {
        _promotionalBanner = promotionalBanner;
        _isPromotionalBannerLoaded = true;
      }
      update();
    }
  }

  void setCurrentIndex(int index, bool notify) {
    _currentIndex = index;
    if(notify) {
      update();
    }
  }

  Future<void> setBannerData(BannerModel? bannerModel) async {
    await _prepareBanner(bannerModel);
    _isBannerLoaded = true;
    update();
  }

  void setPromotionalBanner(PromotionalBanner? promotionalBanner) {
    if (promotionalBanner != null) {
      _promotionalBanner = promotionalBanner;
      _isPromotionalBannerLoaded = true;
      update();
    }
  }
}