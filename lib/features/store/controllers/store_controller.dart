import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/store/domain/models/cart_suggested_item_model.dart';
import 'package:sixam_mart/features/category/domain/models/category_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/store/domain/models/recommended_product_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_banner_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_category_items_model.dart';
import 'package:sixam_mart/features/review/domain/models/review_model.dart';
import 'package:sixam_mart/features/location/domain/models/zone_response_model.dart';
import 'package:sixam_mart/features/checkout/controllers/checkout_controller.dart';
import 'package:sixam_mart/features/favourite/controllers/favourite_controller.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/home/screens/home_screen.dart';
import 'package:sixam_mart/features/store/domain/services/store_service_interface.dart';
import 'package:sixam_mart/helper/module_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/contact_share/screens/contact_share_sheet.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';

import 'package:sixam_mart/features/address/domain/models/address_model.dart';

class StoreController extends GetxController implements GetxService {
  final StoreServiceInterface storeServiceInterface;
  StoreController({required this.storeServiceInterface});

  List<Store>? _filterStoresByZone(List<Store>? list) {
    if (list == null) return null;
    AddressModel? address = AddressHelper.getUserAddressFromSharedPref();
    int? activeZoneId = address?.zoneId;
    if (activeZoneId == null || activeZoneId == 0) return list;
    return list.where((store) {
      if (store.zoneId == null || store.zoneId == 0) return true;
      return store.zoneId == activeZoneId || (address != null && address.zoneIds != null && address.zoneIds!.contains(store.zoneId));
    }).toList();
  }

  StoreModel? _storeModel;
  StoreModel? get storeModel {
    if (_storeModel == null || _storeModel!.stores == null) return _storeModel;
    List<Store> filteredStores = _filterStoresByZone(_storeModel!.stores!) ?? [];
    return StoreModel(
      totalSize: filteredStores.length,
      limit: _storeModel!.limit,
      offset: _storeModel!.offset,
      stores: filteredStores,
    );
  }

  List<Store>? _popularStoreList;
  List<Store>? get popularStoreList => _filterStoresByZone(_popularStoreList);

  List<Store>? _latestStoreList;
  List<Store>? get latestStoreList => _filterStoresByZone(_latestStoreList);

  List<Store>? _topOfferStoreList;
  List<Store>? get topOfferStoreList => _filterStoresByZone(_topOfferStoreList);

  List<Store>? _featuredStoreList;
  List<Store>? get featuredStoreList => _filterStoresByZone(_featuredStoreList);

  List<Store>? _visitAgainStoreList;
  List<Store>? get visitAgainStoreList => _filterStoresByZone(_visitAgainStoreList);

  Store? _store;
  Store? get store => _store;

  final Map<int, List<Store>> _modulePopularStoreList = {};
  final Map<int, List<Store>> _moduleLatestStoreList = {};
  final Map<int, List<Store>> _moduleFeaturedStoreList = {};
  final Map<int, List<Store>> _moduleTopOfferStoreList = {};
  final Map<int, StoreModel> _moduleStoreModel = {};

  void switchModule(int? moduleId) {
    if (moduleId != null && _modulePopularStoreList.containsKey(moduleId)) {
      _popularStoreList = _modulePopularStoreList[moduleId];
      _latestStoreList = _moduleLatestStoreList[moduleId];
      _featuredStoreList = _moduleFeaturedStoreList[moduleId];
      _topOfferStoreList = _moduleTopOfferStoreList[moduleId];
      _storeModel = _moduleStoreModel[moduleId];
      _isPopularStoreListLoaded = _popularStoreList != null;
      _isLatestStoreListLoaded = _latestStoreList != null;
      _isTopOfferStoreListLoaded = _topOfferStoreList != null;
    } else {
      _popularStoreList = null;
      _latestStoreList = null;
      _featuredStoreList = null;
      _topOfferStoreList = null;
      _visitAgainStoreList = null;
      _recommendedStoreList = null;
      _storeModel = null;
      _isPopularStoreListLoaded = false;
      _isLatestStoreListLoaded = false;
      _isTopOfferStoreListLoaded = false;
      _isRecommendedStoreListLoaded = false;
    }
    update();
  }

  void clearStoreLists({bool clearAllModuleCache = false}) {
    _popularStoreList = null;
    _latestStoreList = null;
    _topOfferStoreList = null;
    _featuredStoreList = null;
    _visitAgainStoreList = null;
    _recommendedStoreList = null;
    _storeModel = null;
    _isPopularStoreListLoaded = false;
    _isLatestStoreListLoaded = false;
    _isTopOfferStoreListLoaded = false;
    _isRecommendedStoreListLoaded = false;
    if (clearAllModuleCache) {
      _modulePopularStoreList.clear();
      _moduleLatestStoreList.clear();
      _moduleFeaturedStoreList.clear();
      _moduleTopOfferStoreList.clear();
      _moduleStoreModel.clear();
    }
    update();
  }

  ItemModel? _storeItemModel;
  ItemModel? get storeItemModel => _storeItemModel;

  ItemModel? _storeSearchItemModel;
  ItemModel? get storeSearchItemModel => _storeSearchItemModel;

  int _categoryIndex = 0;
  int get categoryIndex => _categoryIndex;

  List<CategoryModel>? _categoryList;
  List<CategoryModel>? get categoryList => _categoryList;

  Map<int, List<Item>> _categoryItems = {};
  Map<int, List<Item>> get categoryItems => _categoryItems;

  Map<int, int> _categoryOffsets = {};
  Map<int, int> get categoryOffsets => _categoryOffsets;

  Map<int, int> _categoryTotalSizes = {};
  Map<int, int> get categoryTotalSizes => _categoryTotalSizes;

  Map<int, bool> _categoryLoading = {};
  Map<int, bool> get categoryLoading => _categoryLoading;

  List<int> _loadedCategoryIndexes = [];
  List<int> get loadedCategoryIndexes => _loadedCategoryIndexes;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _filterType = 'all';
  String get filterType => _filterType;

  String _storeType = 'all';
  String get storeType => _storeType;

  List<ReviewModel>? _storeReviewList;
  List<ReviewModel>? get storeReviewList => _storeReviewList;

  String _type = 'all';
  String get type => _type;

  String _searchType = 'all';
  String get searchType => _searchType;

  String _searchText = '';
  String get searchText => _searchText;

  bool _currentState = true;
  bool get currentState => _currentState;

  bool _showFavButton = true;
  bool get showFavButton => _showFavButton;

  List<XFile> _pickedPrescriptions = [];
  List<XFile> get pickedPrescriptions => _pickedPrescriptions;

  RecommendedItemModel? _recommendedItemModel;
  RecommendedItemModel? get recommendedItemModel => _recommendedItemModel;

  CartSuggestItemModel? _cartSuggestItemModel;
  CartSuggestItemModel? get cartSuggestItemModel => _cartSuggestItemModel;

  StoreCategoryItemsModel? _storeCategoryItemsModel;
  StoreCategoryItemsModel? get storeCategoryItemsModel => _storeCategoryItemsModel;

  int? _cartSuggestStoreId;
  int? get cartSuggestStoreId => _cartSuggestStoreId;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  List<StoreBannerModel>? _storeBanners;
  List<StoreBannerModel>? get storeBanners => _storeBanners;

  List<Store>? _recommendedStoreList;
  List<Store>? get recommendedStoreList => _recommendedStoreList;

  String _topOfferFilter = '';
  String get topOfferFilter => _topOfferFilter;

  String _topOfferSort = '';
  String get topOfferSort => _topOfferSort;

  bool _isPopularStoreListLoaded = false;
  bool get isPopularStoreListLoaded => _isPopularStoreListLoaded;
  bool _isLatestStoreListLoaded = false;
  bool get isLatestStoreListLoaded => _isLatestStoreListLoaded;
  bool _isTopOfferStoreListLoaded = false;
  bool get isTopOfferStoreListLoaded => _isTopOfferStoreListLoaded;
  bool _isRecommendedStoreListLoaded = false;
  bool get isRecommendedStoreListLoaded => _isRecommendedStoreListLoaded;
  bool _isFeaturedStoreListLoaded = false;
  bool get isFeaturedStoreListLoaded => _isFeaturedStoreListLoaded;

  bool _isAvailableItems = false;
  bool get isAvailableItems => _isAvailableItems;

  bool _isDiscountedItems = false;
  bool get isDiscountedItems => _isDiscountedItems;

  List<String>? _filter = [];
  List<String>? get filter => _filter;

  int _rating = -1;
  int get rating => _rating;

  double _lowerValue = 0;
  double get lowerValue => _lowerValue;

  double _upperValue = 0;
  double get upperValue => _upperValue;

  double getRestaurantDistance(LatLng storeLatLng){
    double distance = 0;
    distance = Geolocator.distanceBetween(storeLatLng.latitude, storeLatLng.longitude,
        double.parse(AddressHelper.getUserAddressFromSharedPref()!.latitude!), double.parse(AddressHelper.getUserAddressFromSharedPref()!.longitude!)) / 1000;
    return distance;
  }

  String filteringUrl(String slug){
    return storeServiceInterface.filterRestaurantLinkUrl(slug, _store!);
  }

  void pickPrescriptionImage({required bool isRemove, required bool isCamera}) async {
    if(isRemove) {
      _pickedPrescriptions = [];
    }else {
      XFile? xFile = await ImagePicker().pickImage(source: isCamera ? ImageSource.camera : ImageSource.gallery, imageQuality: 50);
      if(xFile != null) {
        _pickedPrescriptions.add(xFile);
      }
      update();
    }
  }

  void removePrescriptionImage(int index) {
    _pickedPrescriptions.removeAt(index);
    update();
  }

  void changeFavVisibility(){
    _showFavButton = !_showFavButton;
    update();
  }

  void hideAnimation(){
    _currentState = false;
  }

  void showButtonAnimation(){
    Future.delayed(const Duration(seconds: 3), () {
      _currentState = true;
      update();
    });
  }

  Future<void> getRestaurantRecommendedItemList(int? storeId, bool reload) async {
    if(reload) {
      _storeModel = null;
      update();
    }
    RecommendedItemModel? recommendedItemModel = await storeServiceInterface.getStoreRecommendedItemList(storeId);
    if (recommendedItemModel != null) {
      _recommendedItemModel = recommendedItemModel;
      if (_recommendedItemModel!.items!.isNotEmpty && _categoryIndex == 0) {
        setCategoryList();
        getStoreItemList(storeId, 1, type, false);
      }
    }
    update();
  }

  Future<void> getCartStoreSuggestedItemList(int? storeId) async {
    _cartSuggestStoreId = storeId;
    CartSuggestItemModel? cartSuggestItemModel = await storeServiceInterface.getCartStoreSuggestedItemList(storeId, Get.find<LocalizationController>().locale.languageCode,
        ModuleHelper.getModule(), ModuleHelper.getCacheModule()?.id, ModuleHelper.getModule()?.id);
    if (cartSuggestItemModel != null) {
      _cartSuggestItemModel = cartSuggestItemModel;
    }
    update();
  }

  Future<void> getStoreBannerList(int? storeId) async {
    List<StoreBannerModel>? storeBanners = await storeServiceInterface.getStoreBannerList(storeId);
    if (storeBanners != null) {
      _storeBanners = [];
      _storeBanners!.addAll(storeBanners);
    }
    update();
  }

  Future<void> getStoreCategoryItems(int storeId, {bool notify = true}) async {
    _storeCategoryItemsModel = null;
    if (notify) update();
    _storeCategoryItemsModel = await storeServiceInterface.getStoreCategoryItems(storeId);
    update();
  }

  Future<void> getStoreList(int offset, bool reload, {DataSourceEnum source = DataSourceEnum.local}) async {
    if(reload) {
      _storeModel = null;
      update();
    }
    StoreModel? storeModel;
    if(source == DataSourceEnum.local && offset == 1) {
      storeModel = await storeServiceInterface.getStoreList(offset, _filterType, _storeType, source: DataSourceEnum.local);
      _prepareStoreModel(storeModel, offset);
      getStoreList(offset, false, source: DataSourceEnum.client);
    } else {
      storeModel = await storeServiceInterface.getStoreList(offset, _filterType, _storeType, source: DataSourceEnum.client);
      _prepareStoreModel(storeModel, offset);
    }
  }

  void _prepareStoreModel(StoreModel? storeModel, int offset) {
    if (storeModel != null) {
      if (offset == 1) {
        _storeModel = storeModel;
        int? currentModuleId = Get.find<SplashController>().module?.id;
        if (currentModuleId != null) {
          _moduleStoreModel[currentModuleId] = storeModel;
        }
      }else {
        _storeModel!.totalSize = storeModel.totalSize;
        _storeModel!.offset = storeModel.offset;
        _storeModel!.stores!.addAll(storeModel.stores!);
      }
      update();
    }
  }

  void setFilterType(String type) {
    _filterType = type;
    getStoreList(1, true);
  }

  void setStoreType(String type) {
    _storeType = type;
    getStoreList(1, true);
  }

  void resetStoreData() {
    _filterType = 'all';
    _storeType = 'all';
  }

  Future<void> getPopularStoreList(bool reload, String type, bool notify, {DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false}) async {
    int? currentModuleId = Get.find<SplashController>().module?.id;
    if(!reload && !fromRecall && currentModuleId != null && _modulePopularStoreList.containsKey(currentModuleId) && _modulePopularStoreList[currentModuleId]!.isNotEmpty) {
      _popularStoreList = _modulePopularStoreList[currentModuleId];
      _isPopularStoreListLoaded = true;
      if(notify) update();
      return;
    }
    _type = type;
    if(reload) {
      _popularStoreList = null;
    }
    if(notify) {
      update();
    }
    if(_popularStoreList == null || reload || fromRecall) {
      List<Store>? popularStoreList;
      if(dataSource == DataSourceEnum.local) {
        popularStoreList = await storeServiceInterface.getPopularStoreList(type, source: DataSourceEnum.local);
        if (popularStoreList != null) {
          _popularStoreList = [];
          _popularStoreList!.addAll(popularStoreList);
          if (currentModuleId != null) {
            _modulePopularStoreList[currentModuleId] = _popularStoreList!;
          }
        }
        update();
        getPopularStoreList(false, type, notify, dataSource: DataSourceEnum.client, fromRecall: true);
      } else {
        popularStoreList = await storeServiceInterface.getPopularStoreList(type, source: DataSourceEnum.client);
        if (popularStoreList != null) {
          _popularStoreList = [];
          _popularStoreList!.addAll(popularStoreList);
          _isPopularStoreListLoaded = true;
          if (currentModuleId != null) {
            _modulePopularStoreList[currentModuleId] = _popularStoreList!;
          }
        }
        update();
      }

    }
  }

  Future<void> getLatestStoreList(bool reload, String type, bool notify, {DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false}) async {
    int? currentModuleId = Get.find<SplashController>().module?.id;
    if(!reload && !fromRecall && currentModuleId != null && _moduleLatestStoreList.containsKey(currentModuleId) && _moduleLatestStoreList[currentModuleId]!.isNotEmpty) {
      _latestStoreList = _moduleLatestStoreList[currentModuleId];
      _isLatestStoreListLoaded = true;
      if(notify) update();
      return;
    }
    _type = type;
    if(reload){
      _latestStoreList = null;
    }
    if(notify) {
      update();
    }
    if(_latestStoreList == null || reload || fromRecall) {
      List<Store>? latestStoreList;
      if(dataSource == DataSourceEnum.local) {
        latestStoreList = await storeServiceInterface.getLatestStoreList(type, source: DataSourceEnum.local);
        if (latestStoreList != null) {
          _latestStoreList = [];
          _latestStoreList!.addAll(latestStoreList);
          if (currentModuleId != null) {
            _moduleLatestStoreList[currentModuleId] = _latestStoreList!;
          }
        }
        update();
        getLatestStoreList(false, type, notify, fromRecall: true, dataSource: DataSourceEnum.client);
      } else {
        latestStoreList = await storeServiceInterface.getLatestStoreList(type, source: DataSourceEnum.client);
        if (latestStoreList != null) {
          _latestStoreList = [];
          _latestStoreList!.addAll(latestStoreList);
          _isLatestStoreListLoaded = true;
          if (currentModuleId != null) {
            _moduleLatestStoreList[currentModuleId] = _latestStoreList!;
          }
        }
        update();
      }
    }
  }

  Future<void> getTopOfferStoreList(bool reload, bool notify, {DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false}) async {
    int? currentModuleId = Get.find<SplashController>().module?.id;
    if(!reload && !fromRecall && currentModuleId != null && _moduleTopOfferStoreList.containsKey(currentModuleId) && _moduleTopOfferStoreList[currentModuleId]!.isNotEmpty) {
      _topOfferStoreList = _moduleTopOfferStoreList[currentModuleId];
      _isTopOfferStoreListLoaded = true;
      if(notify) update();
      return;
    }
    if(reload){
      _topOfferStoreList = null;
    }
    if(notify) {
      update();
    }
    if(_topOfferStoreList == null || reload || fromRecall) {
      List<Store>? latestStoreList;
      if(dataSource == DataSourceEnum.local) {
        latestStoreList = await storeServiceInterface.getTopOfferStoreList(source: DataSourceEnum.local, filterBy: _topOfferFilter, sortBy: _topOfferSort);
        if (latestStoreList != null) {
          _topOfferStoreList = [];
          _topOfferStoreList!.addAll(latestStoreList);
          if (currentModuleId != null) {
            _moduleTopOfferStoreList[currentModuleId] = _topOfferStoreList!;
          }
        }
        update();
        getTopOfferStoreList(false, notify, dataSource: DataSourceEnum.client, fromRecall: true);
      } else {
        latestStoreList = await storeServiceInterface.getTopOfferStoreList(source: DataSourceEnum.client, filterBy: _topOfferFilter, sortBy: _topOfferSort);
        if (latestStoreList != null) {
          _topOfferStoreList = [];
          _topOfferStoreList!.addAll(latestStoreList);
          _isTopOfferStoreListLoaded = true;
          if (currentModuleId != null) {
            _moduleTopOfferStoreList[currentModuleId] = _topOfferStoreList!;
          }
        }
        update();
      }
    }
  }

  void setTopOfferFilter(String type) {
    _topOfferFilter = type;
   getTopOfferStoreList(true, false);
  }

  void setTopOfferSort(String sort) {
    _topOfferSort = sort;
    getTopOfferStoreList(true, false);
  }

  Future<void> getFeaturedStoreList({DataSourceEnum dataSource = DataSourceEnum.local}) async {
    int? currentModuleId = Get.find<SplashController>().module?.id;
    if (dataSource == DataSourceEnum.local && currentModuleId != null && _moduleFeaturedStoreList.containsKey(currentModuleId) && _moduleFeaturedStoreList[currentModuleId]!.isNotEmpty) {
      _featuredStoreList = _moduleFeaturedStoreList[currentModuleId];
      update();
      getFeaturedStoreList(dataSource: DataSourceEnum.client);
      return;
    }
    List<Store>? stores;
    if(dataSource == DataSourceEnum.local) {
      stores = await storeServiceInterface.getFeaturedStoreList(source: dataSource);
      _prepareFeaturedStore(stores);
      getFeaturedStoreList(dataSource: DataSourceEnum.client);
    } else {
      stores = await storeServiceInterface.getFeaturedStoreList(source: dataSource);
      _prepareFeaturedStore(stores);
    }

  }

  void _prepareFeaturedStore(List<Store>? stores) {
    if (stores != null) {
      _featuredStoreList = [];
      List<Modules> moduleList = [];
      moduleList.addAll(storeServiceInterface.moduleList());
      for (Store store in stores) {
        for (var module in moduleList) {
          if(module.id == store.moduleId){
            if(module.pivot!.zoneId == store.zoneId){
              _featuredStoreList!.add(store);
            }
          }
        }
      }
      int? currentModuleId = Get.find<SplashController>().module?.id;
      if (currentModuleId != null) {
        _moduleFeaturedStoreList[currentModuleId] = _featuredStoreList!;
      }
    }
    update();
  }

  Future<void> getVisitAgainStoreList({bool fromModule = false, DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false}) async {
    if(fromModule && !fromRecall) {
      _visitAgainStoreList = [];
    }
    List<Store>? stores;
    try {
      if(dataSource == DataSourceEnum.local) {
        stores = await storeServiceInterface.getVisitAgainStoreList(source: DataSourceEnum.local);
        _prepareVisitAgainStore(stores);
        getVisitAgainStoreList(dataSource: DataSourceEnum.client, fromRecall: true);
      } else {
        stores = await storeServiceInterface.getVisitAgainStoreList(source: DataSourceEnum.client);
        _prepareVisitAgainStore(stores);
      }
    } catch(e) {
      _prepareVisitAgainStore([]);
    }
  }
  void _prepareVisitAgainStore(List<Store>? stores) {
    _visitAgainStoreList = [];
    if (stores != null) {
      List<Modules> moduleList = [];
      moduleList.addAll(storeServiceInterface.moduleList());
      for (var store in stores) {
        for (var module in moduleList) {
          if(module.id == store.moduleId){
            if(module.pivot!.zoneId == store.zoneId){
              _visitAgainStoreList!.add(store);
            }
          }
        }
      }
    }
    update();
  }

  void setCategoryList() {
    if(Get.find<CategoryController>().categoryList != null && _store != null) {
      _categoryList = [];
      final favouriteController = Get.find<FavouriteController>();
      bool hasFavorites = false;
      if (favouriteController.wishItemList != null) {
        for (var item in favouriteController.wishItemList!) {
          if (item != null && item.storeId == _store!.id) {
            hasFavorites = true;
            break;
          }
        }
      }
      bool hasMostOrdered = _recommendedItemModel != null && _recommendedItemModel!.items!.isNotEmpty;
      
      bool isFood = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == 'food';
      
      if (isFood) {
        if (hasFavorites) {
          _categoryList!.add(CategoryModel(id: -1, name: 'favorites'.tr));
        }
        if (hasMostOrdered) {
          _categoryList!.add(CategoryModel(id: -2, name: 'most_requested'.tr));
        }
      } else {
        if (hasMostOrdered && hasFavorites) {
          _categoryList!.add(CategoryModel(id: -1, name: 'favorites'.tr));
        } else {
          _categoryList!.add(CategoryModel(id: 0, name: 'all'.tr));
        }
      }
      
      for (var category in Get.find<CategoryController>().categoryList!) {
        if(_store!.categoryIds!.contains(category.id)) {
          _categoryList!.add(category);
        }
      }
      debugPrint("DEBUG: [Store Category Info] Store: ${_store!.name} (ID: ${_store!.id})");
      debugPrint("DEBUG: category_ids returned by server: ${_store!.categoryIds}");
      debugPrint("DEBUG: parsed categories displayed in App: ${_categoryList!.map((e) => '${e.name} (ID: ${e.id})').toList()}");
    }
  }

  Future<Store?> getStoreDetails(Store store, bool fromModule, {bool fromCart = false, String slug = ''}) async {
    _categoryIndex = 0;
    _recommendedItemModel = null;
    initCategoryScrollState();
    if(store.name != null) {
      _store = store;
    }else {
      _isLoading = true;
      _store = null;
      Store? storeDetails = await storeServiceInterface.getStoreDetails(store.id.toString(), fromCart, slug, Get.find<LocalizationController>().locale.languageCode,
          ModuleHelper.getModule(), ModuleHelper.getCacheModule()?.id, ModuleHelper.getModule()?.id);
      if (storeDetails != null) {
        _store = storeDetails;
        Get.find<CheckoutController>().initializeTimeSlot(_store!);
        if(!fromCart && slug.isEmpty){
          Get.find<CheckoutController>().getDistanceInKM(
            LatLng(
              double.parse(AddressHelper.getUserAddressFromSharedPref()!.latitude!),
              double.parse(AddressHelper.getUserAddressFromSharedPref()!.longitude!),
            ),
            LatLng(double.parse(_store!.latitude!), double.parse(_store!.longitude!)),
          );
        }
        if(slug.isNotEmpty){
          await Get.find<LocationController>().setStoreAddressToUserAddress(LatLng(double.parse(_store!.latitude!), double.parse(_store!.longitude!)));
        }
        if(fromModule) {
          HomeScreen.loadData(true);
        }/*else {
          Get.find<CheckoutController>().clearPrevData();
        }*/
      }
      Get.find<CheckoutController>().setOrderType(
        _store != null ? _store!.delivery! ? 'delivery' : 'take_away' : 'delivery', notify: false,
      );
      _isLoading = false;
      update();
    }
    return _store;
  }

  Future<void> getRecommendedStoreList({DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false, bool reload = false}) async {
    if(!reload && !fromRecall && _isRecommendedStoreListLoaded && _recommendedStoreList != null && _recommendedStoreList!.isNotEmpty) {
      return;
    }
    if(!fromRecall) {
      _recommendedStoreList = null;
    }
    List<Store>? recommendedStoreList;
    if(dataSource == DataSourceEnum.local) {
      recommendedStoreList = await storeServiceInterface.getRecommendedStoreList(source: DataSourceEnum.local);
      _prepareRecommendedStores(recommendedStoreList);
      getRecommendedStoreList(dataSource: DataSourceEnum.client, fromRecall: true);
    } else {
      recommendedStoreList = await storeServiceInterface.getRecommendedStoreList(source: DataSourceEnum.client);
      _prepareRecommendedStores(recommendedStoreList);
      _isRecommendedStoreListLoaded = true;
    }
  }

  void _prepareRecommendedStores(List<Store>? recommendedStoreList) {
    if (recommendedStoreList != null) {
      _recommendedStoreList = [];
      _recommendedStoreList!.addAll(recommendedStoreList);
    }
    update();
  }

  void initCategoryScrollState() {
    _categoryItems = {};
    _categoryOffsets = {};
    _categoryTotalSizes = {};
    _categoryLoading = {};
    _loadedCategoryIndexes = [];
    _categoryIndex = 0;
  }

  Future<void> initializeCategoryData(int? storeId) async {
    initCategoryScrollState();
    if (Get.find<CategoryController>().categoryList == null) {
      await Get.find<CategoryController>().getCategoryList(true);
    }
    setCategoryList();
    if (_categoryList != null && _categoryList!.isNotEmpty) {
      await loadCategoryItems(0);
    }
  }

  Future<void> loadCategoryItems(int index, {bool isPaginate = false}) async {
    if (_categoryList == null || index >= _categoryList!.length) return;
    
    CategoryModel category = _categoryList![index];
    int categoryId = category.id ?? 0;

    if (_categoryLoading[categoryId] == true) return;
    _categoryLoading[categoryId] = true;
    update();

    int offset = isPaginate ? (_categoryOffsets[categoryId] ?? 1) + 1 : 1;

    if (categoryId == -1) {
      final favouriteController = Get.find<FavouriteController>();
      List<Item> storeFavorites = [];
      if (favouriteController.wishItemList != null) {
        for (var item in favouriteController.wishItemList!) {
          if (item != null && item.storeId == _store!.id) {
            storeFavorites.add(item);
          }
        }
      }
      _categoryItems[categoryId] = storeFavorites;
      _categoryOffsets[categoryId] = 1;
      _categoryTotalSizes[categoryId] = storeFavorites.length;
      _categoryLoading[categoryId] = false;
      if (!_loadedCategoryIndexes.contains(index)) {
        _loadedCategoryIndexes.add(index);
        _loadedCategoryIndexes.sort();
      }
      update();
    } else if (categoryId == -2) {
      List<Item> recommended = _recommendedItemModel?.items ?? [];
      _categoryItems[categoryId] = recommended;
      _categoryOffsets[categoryId] = 1;
      _categoryTotalSizes[categoryId] = recommended.length;
      _categoryLoading[categoryId] = false;
      if (!_loadedCategoryIndexes.contains(index)) {
        _loadedCategoryIndexes.add(index);
        _loadedCategoryIndexes.sort();
      }
      update();
    } else {
      ItemModel? storeItemModel = await storeServiceInterface.getStoreItemList(
        storeID: _store!.id,
        offset: offset,
        categoryID: categoryId,
        type: _type,
        filter: _filter,
        rating: _rating == -1 ? null : _rating,
        lowerValue: _lowerValue == 0 ? null : _lowerValue,
        upperValue: _upperValue == 0 ? null : _upperValue,
      );

      if (storeItemModel != null) {
        if (isPaginate) {
          _categoryItems[categoryId]!.addAll(storeItemModel.items ?? []);
          _categoryOffsets[categoryId] = storeItemModel.offset ?? offset;
          _categoryTotalSizes[categoryId] = storeItemModel.totalSize ?? 0;
        } else {
          _categoryItems[categoryId] = storeItemModel.items ?? [];
          _categoryOffsets[categoryId] = 1;
          _categoryTotalSizes[categoryId] = storeItemModel.totalSize ?? 0;
        }
        if (!_loadedCategoryIndexes.contains(index)) {
          _loadedCategoryIndexes.add(index);
          _loadedCategoryIndexes.sort();
        }
      }
      _categoryLoading[categoryId] = false;
      update();
    }
  }

  Future<void> loadUntilCategory(int targetIndex) async {
    if (_categoryList == null) return;
    for (int i = 0; i <= targetIndex; i++) {
      CategoryModel category = _categoryList![i];
      int categoryId = category.id ?? 0;
      if (_categoryItems[categoryId] == null) {
        await loadCategoryItems(i);
      }
    }
  }

  void setCategoryIndexOnly(int index) {
    _categoryIndex = index;
    update();
  }

  Future<void> reloadCategoryData() async {
    initCategoryScrollState();
    setCategoryList();
    if (_categoryList != null && _categoryList!.isNotEmpty) {
      await loadCategoryItems(0);
    }
  }

  Future<void> getStoreItemList(int? storeID, int offset, String type, bool notify) async {
    if (offset == 1 && _loadedCategoryIndexes.isNotEmpty) {
      _type = type;
      await reloadCategoryData();
      return;
    }
    if(offset == 1 || _storeItemModel == null) {
      _type = type;
      _storeItemModel = null;
      if(notify) {
        update();
      }
    }
    int selectedCategoryId = 0;
    if (_store != null && _categoryList != null && _categoryList!.isNotEmpty && _categoryIndex < _categoryList!.length) {
      selectedCategoryId = _categoryList![_categoryIndex].id ?? 0;
    }

    if (selectedCategoryId == -1) {
      final favouriteController = Get.find<FavouriteController>();
      List<Item> storeFavorites = [];
      if (favouriteController.wishItemList != null) {
        for (var item in favouriteController.wishItemList!) {
          if (item != null && item.storeId == storeID) {
            storeFavorites.add(item);
          }
        }
      }
      _storeItemModel = ItemModel(
        items: storeFavorites,
        totalSize: storeFavorites.length,
        offset: 1,
      );
      update();
      return;
    }

    ItemModel? storeItemModel = await storeServiceInterface.getStoreItemList(
      storeID: storeID, offset: offset,
      categoryID: selectedCategoryId,
      type: type,
      filter: _filter,
      rating: _rating == -1 ? null : _rating,
      lowerValue: _lowerValue == 0 ? null : _lowerValue,
      upperValue: _upperValue == 0 ? null : _upperValue,
    );
    if (storeItemModel != null) {
      if (offset == 1) {
        _storeItemModel = storeItemModel;
      } else if (_storeItemModel != null) {
        _storeItemModel!.items!.addAll(storeItemModel.items!);
        _storeItemModel!.totalSize = storeItemModel.totalSize;
        _storeItemModel!.offset = storeItemModel.offset;
      }
    }
    update();
  }

  Future<void> getStoreSearchItemList(String searchText, String? storeID, int offset, String type) async {
    if(searchText.isEmpty) {
      showCustomSnackBar('write_item_name'.tr);
    }else {
      _isSearching = true;
      _searchText = searchText;
      _type = type;
      if(offset == 1 || _storeSearchItemModel == null) {
        _searchType = type;
        _storeSearchItemModel = null;
        update();
      }
      ItemModel? storeSearchItemModel = await storeServiceInterface.getStoreSearchItemList(searchText, storeID, offset, 'all', 0);
      if (storeSearchItemModel != null) {
        if (offset == 1) {
          _storeSearchItemModel = storeSearchItemModel;
        } else if (_storeSearchItemModel != null) {
          _storeSearchItemModel!.items!.addAll(storeSearchItemModel.items!);
          _storeSearchItemModel!.totalSize = storeSearchItemModel.totalSize;
          _storeSearchItemModel!.offset = storeSearchItemModel.offset;
        }
      }
      update();
    }
  }

  void changeSearchStatus({bool isUpdate = true}) {
    _isSearching = !_isSearching;
    if(isUpdate) {
      update();
    }
  }

  void initSearchData() {
    _storeSearchItemModel = ItemModel(items: []);
    _searchText = '';
  }

  void setCategoryIndex(int index, {bool itemSearching = false}) {
    _categoryIndex = index;
    if(itemSearching){
      _storeSearchItemModel = null;
      getStoreSearchItemList(_searchText, _store!.id.toString(), 1, type);
    } else {
      _storeItemModel = null;
      getStoreItemList(_store!.id, 1, Get.find<StoreController>().type, false);
    }
    update();
  }

  bool isStoreClosed(bool today, bool active, List<Schedules>? schedules) {
    if(!active) {
      return true;
    }
    DateTime date = DateTime.now();
    if(!today) {
      date = date.add(const Duration(days: 1));
    }
    int weekday = date.weekday;
    if(weekday == 7) {
      weekday = 0;
    }
    for(int index=0; index<schedules!.length; index++) {
      if(weekday == schedules[index].day) {
        return false;
      }
    }
    return true;
  }

  bool isStoreOpenNow(bool active, List<Schedules>? schedules) {
    if(isStoreClosed(true, active, schedules)) {
      return false;
    }
    int weekday = DateTime.now().weekday;
    if(weekday == 7) {
      weekday = 0;
    }
    for(int index=0; index<schedules!.length; index++) {
      if(weekday == schedules[index].day
          && DateConverter.isAvailable(schedules[index].openingTime, schedules[index].closingTime)) {
        return true;
      }
    }
    return false;
  }

  bool isOpenNow(Store store) => store.open == 1 && store.active!;

  double? getDiscount(Store store) => store.discount != null ? store.discount!.discount : 0;

  String? getDiscountType(Store store) => store.discount != null ? store.discount!.discountType : 'percent';

  void shareStore() {
    String shareUrl = '${AppConstants.webHostedUrl}${filteringUrl(store!.slug ?? '')}';
    if (AuthHelper.isLoggedIn()) {
      Get.bottomSheet(
        ContactShareSheet(
          shareableType: 'store',
          shareableId: store!.id!,
          shareableName: store!.name!,
          shareUrl: shareUrl,
        ),
        isScrollControlled: true,
        backgroundColor: const Color(0x00000000),
      );
    } else {
      if(ResponsiveHelper.isDesktop(Get.context)){
        Clipboard.setData(ClipboardData(text: shareUrl));
        showCustomSnackBar('store_url_copied'.tr, isError: false);
      } else {
        SharePlus.instance.share(ShareParams(text: shareUrl));
      }
    }
  }

  void setRating(int rate) {
    _rating = rate;
    update();
  }

  void setLowerValue(double value) {
    _lowerValue = value;
    update();
  }

  void setUpperValue(double value) {
    _upperValue = value;
    update();
  }

  void toggleAvailableItems() {
    _isAvailableItems = !_isAvailableItems;
    if(_isAvailableItems) {
      _filter!.add("available_now");
    } else {
      _filter!.remove("available_now");
    }
    update();
  }

  void toggleDiscountedItems() {
    _isDiscountedItems = !_isDiscountedItems;
    if(_isDiscountedItems) {
      _filter!.add("discounted");
    } else {
      _filter!.remove("discounted");
    }
    update();
  }

  void setLowerAndUpperValue(double lower, double upper) {
    _lowerValue = lower;
    _upperValue = upper;
    update();
  }

  void resetFilter({bool isUpdate = true}) {
    _isAvailableItems = false;
    _isDiscountedItems = false;
    _rating = -1;
    _lowerValue = 0;
    _upperValue = 0;
    _filter = [];
    if(isUpdate) {
      update();
    }
  }

  List<int> _followedStoreIds = [];
  List<int> get followedStoreIds => _followedStoreIds;
  List<Store>? _followedStoreList;
  List<Store>? get followedStoreList => _followedStoreList;

  Future<void> getFollowedStores() async {
    Response response = await Get.find<ApiClient>().getData(AppConstants.followedStoresUri);
    if (response.statusCode == 200) {
      _followedStoreIds = [];
      _followedStoreList = [];
      response.body.forEach((store) {
        _followedStoreIds.add(store['id']);
        _followedStoreList!.add(Store.fromJson(store));
      });
      update();
    }
  }

  Future<void> followStore(int? storeId) async {
    _isLoading = true;
    update();
    Response response = await Get.find<ApiClient>().postData(AppConstants.followStoreUri, {'store_id': storeId});
    if (response.statusCode == 200) {
      showCustomSnackBar('followed_successfully'.tr, isError: false);
      if(storeId != null) _followedStoreIds.add(storeId);
    }
    _isLoading = false;
    update();
  }

  Future<void> unfollowStore(int? storeId) async {
    _isLoading = true;
    update();
    Response response = await Get.find<ApiClient>().postData(AppConstants.unfollowStoreUri, {'store_id': storeId});
    if (response.statusCode == 200) {
      showCustomSnackBar('unfollowed_successfully'.tr, isError: false);
      if(storeId != null) _followedStoreIds.remove(storeId);
    }
    _isLoading = false;
    update();
  }
}