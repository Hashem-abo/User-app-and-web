import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/checkout/domain/models/place_order_body_model.dart';
import 'package:sixam_mart/features/item/domain/models/basic_medicine_model.dart';
import 'package:sixam_mart/features/cart/domain/models/cart_model.dart';
import 'package:sixam_mart/features/item/domain/models/common_condition_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/module_helper.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:collection/collection.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/common/widgets/cart_snackbar.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/common/widgets/confirmation_dialog.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/item_bottom_sheet.dart';
import 'package:sixam_mart/features/item/screens/item_details_screen.dart';
import 'package:sixam_mart/features/item/domain/services/item_service_interface.dart';
import 'package:sixam_mart/features/review/domain/models/review_model.dart';
import 'package:sixam_mart/common/models/response_model.dart';

class ItemController extends GetxController implements GetxService {
  final ItemServiceInterface itemServiceInterface;
  ItemController({required this.itemServiceInterface});
  
  List<Item>? _popularItemList;
  List<Item>? get popularItemList => _popularItemList;

  // New list for National Products View (Aggregated)
  List<Item>? _nationalAggregatedItemList;
  List<Item>? get nationalAggregatedItemList => _nationalAggregatedItemList;
  
  List<Item>? _reviewedItemList;
  List<Item>? get reviewedItemList => _reviewedItemList;
  
  List<Item>? _recommendedItemList;
  List<Item>? get recommendedItemList => _recommendedItemList;
  
  List<Item>? _discountedItemList;
  List<Item>? get discountedItemList => _discountedItemList;
  List<Item>? _buyAgainItemList;
  List<Item>? get buyAgainItemList => _buyAgainItemList;
  List<Categories>? _reviewedCategoriesList;
  List<Categories>? get reviewedCategoriesList => _reviewedCategoriesList;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int? _pageSize = 0;
  int? get pageSize => _pageSize;

  List<String> _offsetList = [];

  int _offset = 1;
  int get offset => _offset;
  
  List<int>? _variationIndex;
  List<int>? get variationIndex => _variationIndex;
  
  List<List<bool?>> _selectedVariations = [];
  List<List<bool?>> get selectedVariations => _selectedVariations;
  
  int? _quantity = 1;
  int? get quantity => _quantity;
  
  List<bool> _addOnActiveList = [];
  List<bool> get addOnActiveList => _addOnActiveList;
  
  List<int?> _addOnQtyList = [];
  List<int?> get addOnQtyList => _addOnQtyList;
  
  final String _popularType = 'all';
  String get popularType => _popularType;
  
  final String _reviewedType = 'all';
  String get reviewType => _reviewedType;

  final String _discountedType = 'all';
  String get discountedType => _discountedType;
  
  static final List<String> _itemTypeList = ['all', 'veg', 'non_veg'];
  List<String> get itemTypeList => _itemTypeList;
  
  int _imageIndex = 0;
  int get imageIndex => _imageIndex;
  
  int _cartIndex = -1;
  int get cartIndex => _cartIndex;
  
  Item? _item;
  Item? get item => _item;
  
  int _productSelect = 0;
  int get productSelect => _productSelect;
  
  int _imageSliderIndex = 0;
  int get imageSliderIndex => _imageSliderIndex;
  
  List<bool> _collapseVariation = [];
  List<bool> get collapseVariation => _collapseVariation;
  
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;
  
  bool _isReadMore = false;
  bool get isReadMore => _isReadMore;
  
  BasicMedicineModel? _basicMedicineModel;
  BasicMedicineModel? get basicMedicineModel => _basicMedicineModel;
  
  List<CommonConditionModel>? _commonConditions;
  List<CommonConditionModel>? get commonConditions => _commonConditions;
  
  int _selectedCommonCondition = 0;
  int get selectedCommonCondition => _selectedCommonCondition;
  
  List<Item>? _conditionWiseProduct;
  List<Item>? get conditionWiseProduct => _conditionWiseProduct;
  
  ItemModel? _featuredCategoriesItem;
  ItemModel? get featuredCategoriesItem => _featuredCategoriesItem;

  int _selectedCategory = 0;
  int get selectedCategory => _selectedCategory;

  static final List<String> _sortOptions = ['default', 'a_to_z', 'z_to_a', 'high', 'low'];
  List<String> get sortOptions => _sortOptions;

  String _selectedSortOption = 'default';
  String get selectedSortOption => _selectedSortOption;

  final List<String> _filter = [];
  List<String>? get filter => _filter;

  int? _rating;
  int? get rating => _rating;

  final List<int> _selectedCategoryIds = [];
  List<int> get selectedCategoryIds => _selectedCategoryIds;

  double _selectedMinPrice = 0;
  double get selectedMinPrice => _selectedMinPrice;

  double _selectedMaxPrice = 9999999999;
  double get selectedMaxPrice => _selectedMaxPrice;

  List<Categories>? _categoryList = [];
  List<Categories>? get categoryList => _categoryList;

  bool _isAvailableItems = false;
  bool get isAvailableItems => _isAvailableItems;

  bool _isUnAvailableItems = false;
  bool get isUnAvailableItems => _isUnAvailableItems;

  bool _isTopRated = false;
  bool get isTopRated => _isTopRated;

  bool _isMostLoved = false;
  bool get isMostLoved => _isMostLoved;

  bool _isPopular = false;
  bool get isPopular => _isPopular;

  bool _isLatest = false;
  bool get isLatest => _isLatest;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  final TextEditingController _searchController = TextEditingController(text: '');
  TextEditingController get searchController => _searchController;

  void clearSearch({bool withUpdate = true}) {
    _searchController.text = '';
    _isSearching = false;
    if(withUpdate) {
      update();
    }
  }

  // + ahmed (national filters)
  String _nationalFilterType = 'latest';
  String get nationalFilterType => _nationalFilterType;

  // Cache for national filters
  final Map<String, List<Item>?> _nationalAggregatedItemListCache = {};
  final Map<String, List<String>> _nationalOffsetListCache = {};
  final Map<String, int> _nationalOffsetCache = {};
  final Map<String, int> _nationalCurrentModuleIndexCache = {};

  void setNationalFilterType(String type) {
    if (_nationalFilterType != type) {
      // Save current state
      _nationalAggregatedItemListCache[_nationalFilterType] = _nationalAggregatedItemList;
      _nationalOffsetListCache[_nationalFilterType] = List.from(_offsetList);
      _nationalOffsetCache[_nationalFilterType] = _offset;
      _nationalCurrentModuleIndexCache[_nationalFilterType] = _currentAggregatedModuleIndex;

      _nationalFilterType = type;

      // Restore from cache or fetch new
      if (_nationalAggregatedItemListCache.containsKey(type)) {
        _nationalAggregatedItemList = _nationalAggregatedItemListCache[type];
        _offsetList = _nationalOffsetListCache[type] ?? [];
        _offset = _nationalOffsetCache[type] ?? 1;
        _currentAggregatedModuleIndex = _nationalCurrentModuleIndexCache[type] ?? 0;
        update();
      } else {
        _offsetList = [];
        _offset = 1;
        _nationalAggregatedItemList = null;
        _currentAggregatedModuleIndex = 0;
        getNationalAggregatedItemList(offset: '1', notify: true, dataSource: DataSourceEnum.local);
      }
    }
  }

  // + ahmed
  List<int> _aggregatedModuleIds = [];
  int _currentAggregatedModuleIndex = 0;
  bool _isAggregating = false;

  void initNationalProductsAggregation() {
    _aggregatedModuleIds.clear();
    _isAggregating = true;
    _currentAggregatedModuleIndex = 0;
    _offsetList.clear();
    _offset = 1;
    _nationalAggregatedItemList = null;
    
    // Clear cache on fresh initialization
    _nationalAggregatedItemListCache.clear();
    _nationalOffsetListCache.clear();
    _nationalOffsetCache.clear();
    _nationalCurrentModuleIndexCache.clear();


    var splashController = Get.find<SplashController>();

    List<int> targetModuleIds = [];
    if (splashController.moduleList != null) {
      targetModuleIds = splashController.moduleList!
          .where((m) => m.showNationalProducts == true)
          .map((m) => m.id!)
          .toList();
          
      // Add current module if it's one of the target modules
      if (splashController.module != null && targetModuleIds.contains(splashController.module!.id)) {
        _aggregatedModuleIds.add(splashController.module!.id!);
      }

      // Add other target modules
      for (var id in targetModuleIds) {
        if (!_aggregatedModuleIds.contains(id)) {
          _aggregatedModuleIds.add(id);
        }
      }
    } else {
      // Fallback if moduleList is not yet loaded
      if (splashController.module != null && splashController.module!.showNationalProducts == true) {
        _aggregatedModuleIds.add(splashController.module!.id!);
      }
    }
  } // + ahmed

  void toggleCategory(int? categoryId) {
    if (_selectedCategoryIds.contains(categoryId)) {
      _selectedCategoryIds.remove(categoryId);
    } else {
      _selectedCategoryIds.add(categoryId!);
    }
    update();
  }

  void setMinAndMaxPrice(double min, double max, {bool withUpdate = true}) {
    _selectedMinPrice = min;
    _selectedMaxPrice = max;
    if(withUpdate) {
      update();
    }
  }

  void toggleAvailableItems() {
    _isAvailableItems = !_isAvailableItems;
    if(_isAvailableItems) {
      _filter.add("available_now");
    } else {
      _filter.remove("available_now");
    }
    update();
  }

  void toggleUnavailableItems() {
    _isUnAvailableItems = !_isUnAvailableItems;
    if(_isUnAvailableItems) {
      _filter.add("un_available_now");
    } else {
      _filter.remove("un_available_now");
    }
    update();
  }

  void toggleTopRated() {
    _isTopRated = !_isTopRated;
    if(_isTopRated) {
      _filter.add("top_rated");
    } else {
      _filter.remove("top_rated");
    }
    update();
  }

  void toggleMostLoved() {
    _isMostLoved = !_isMostLoved;
    if(_isMostLoved) {
      _filter.add("most_loved");
    } else {
      _filter.remove("most_loved");
    }
    update();
  }

  void togglePopular() {
    _isPopular = !_isPopular;
    if(_isPopular) {
      _filter.add("popular");
    } else {
      _filter.remove("popular");
    }
    update();
  }

  void toggleLatest() {
    _isLatest = !_isLatest;
    if(_isLatest) {
      _filter.add("latest");
    } else {
      _filter.remove("latest");
    }
    update();
  }

  void setSelectedRating(int rating) {
    _rating = rating;
    update();
  }

  void setSelectedSortOption(String option) {
    _selectedSortOption = option;

    for (var element in _sortOptions) {
      if(_filter.contains(element)) {
        _filter.remove(element);
      }else if(element == _selectedSortOption) {
        _filter.add(element);
      }
    }
    update();
  }

  void selectCategory(int index) {
    _selectedCategory = index;
    update();
  }

  void applyFilters({bool isPopular = false, bool isSpecial = false}) {
    if(isPopular){
      getPopularItemList(notify: true, offset: '1', dataSource: DataSourceEnum.client);
    }else if(isSpecial){
      getDiscountedItemList(notify: true, offset: '1', dataSource: DataSourceEnum.client);
    }else{
      getReviewedItemList(notify: true, offset: '1', dataSource: DataSourceEnum.client);
    }
  }

  void resetFilters({bool isPopular = false, bool isSpecial = false}) {
    _selectedCategoryIds.clear();
    _filter.clear();
    _rating = null;
    _selectedMinPrice = 0;
    _selectedMaxPrice = 9999999999;
    _isAvailableItems = false;
    _isUnAvailableItems = false;
    _isTopRated = false;
    _isMostLoved = false;
    _isPopular = false;
    _isLatest = false;
    _selectedSortOption = 'default';
    _searchController.text = '';

    if (isPopular) {
      getPopularItemList(offset: '1', dataSource: DataSourceEnum.client);
    } else if(isSpecial) {
      getDiscountedItemList(offset: '1', dataSource: DataSourceEnum.client);
    } else {
      getReviewedItemList(offset: '1', dataSource: DataSourceEnum.client);
    }

    update();
  }

  void clearFilters({bool isPopular = false, bool isSpecial = false}) {
    _selectedCategoryIds.clear();
    _filter.clear();
    _rating = null;
    _selectedMinPrice = 0;
    _selectedMaxPrice = 9999999999;
    _isAvailableItems = false;
    _isUnAvailableItems = false;
    _isTopRated = false;
    _isMostLoved = false;
    _isPopular = false;
    _isLatest = false;
    _selectedSortOption = 'default';
    _searchController.text = '';

    if (isPopular) {
      getPopularItemList(offset: '1', dataSource: DataSourceEnum.client, firstTimeCategoryLoad: true);
    } else if (isSpecial) {
      getDiscountedItemList(offset: '1', dataSource: DataSourceEnum.client, firstTimeCategoryLoad: true);
    } else {
      getReviewedItemList(offset: '1', dataSource: DataSourceEnum.client, firstTimeCategoryLoad: true);
    }
  }

  void selectCommonCondition(int index) {
    _selectedCommonCondition = index;
    getConditionsWiseItem(_commonConditions![index].id!, true);
    update();
  }

  void changeReadMore() {
    _isReadMore = !_isReadMore;
    update();
  }

  void setCurrentIndex(int index, bool notify) {
    _currentIndex = index;
    if(notify) {
      update();
    }
  }

  void clearItemLists() {
    _popularItemList = null;
    _nationalAggregatedItemList = null;
    _reviewedItemList = null;
    _discountedItemList = null;
    _featuredCategoriesItem = null;
    _recommendedItemList = null;
    _similarLocalProductList = null;
    _similarProductList = null;
    _sameTypeProductList = null;
    _storeProductList = null;
    _isPopularItemListLoaded = false;
    _isReviewedItemListLoaded = false;
    _isDiscountedItemListLoaded = false;
    _currentAggregatedModuleIndex = 0;
    _aggregatedModuleIds = [];
   // _isAggregating = false;
    //_popularInFlightOffsets.clear();
   // _reviewedInFlightOffsets.clear();
   // _discountedInFlightOffsets.clear();
   // _nationalInFlightOffsets.clear();
    //update();
  }

  List<Item>? _similarProductList;
  List<Item>? get similarProductList => _similarProductList;

  List<Item>? _similarLocalProductList;
  List<Item>? get similarLocalProductList => _similarLocalProductList;

  List<Item>? _storeProductList;
  List<Item>? get storeProductList => _storeProductList;

  List<Item>? _sameTypeProductList;
  List<Item>? get sameTypeProductList => _sameTypeProductList;

  int? _similarItemsLoadingId;
  final List<int> _exploreMoreInFlight = [];

  Future<void> getSimilarItems(String name, int moduleId, int categoryId, int currentItemId, int? storeId, {required int parentCategoryId}) async {
    if (_similarItemsLoadingId == currentItemId) {
      return;
    }
    _similarItemsLoadingId = currentItemId;

    _similarProductList = null;
    _similarLocalProductList = null;
    _storeProductList = null;
    _sameTypeProductList = null;
    update(['explore_more', 'similar_local', 'more_from_store', 'similar_same_type']);

    List<Future> futures = [];

    // 1. Similar Products (Sub-category)
    futures.add(itemServiceInterface.getPopularItemList(
        type: 'all', source: DataSourceEnum.client, offset: 1, categoryIds: [categoryId], moduleId: moduleId
    ).then((res) {
       if (res != null) {
         _sameTypeProductList = res.items!.where((item) => item.id != currentItemId).toList();
         update(['similar_same_type']);
       }
    }));

    // 2. Explore More (Parent Category)
    if (parentCategoryId != 0 && parentCategoryId != categoryId) {
      futures.add(itemServiceInterface.getPopularItemList(
          type: 'all', source: DataSourceEnum.client, offset: 1, categoryIds: [parentCategoryId], moduleId: moduleId
      ).then((res) {
         if (res != null) {
           _similarProductList = res.items!.where((item) => item.id != currentItemId).toList();
           update(['explore_more']);
         }
      }));
    } else {
       _similarProductList = [];
    }

    // 3. Store Products (More from Store)
    if (Get.isRegistered<StoreController>() && storeId != null) {
      futures.add(Get.find<StoreController>().storeServiceInterface.getStoreItemList(
          storeID: storeId, offset: 1, type: 'all', categoryID: 0
      ).then((res) {
         if(res != null && res.items != null) {
           _storeProductList = res.items!.where((item) => item.id != currentItemId).toList();
           update(['more_from_store']);
         }
      }));
    }

    // 4. Local Similar Items (Search based)
    if (name.isNotEmpty) {
      futures.add(_fetchLocalSimilarItems(name, currentItemId, moduleId).then((items) {
          _similarLocalProductList = items;
          update(['similar_local']);
      }));
    }

    try {
      await Future.wait(futures);
    } catch (_) {
    } finally {
      if (_similarItemsLoadingId == currentItemId) {
        _similarItemsLoadingId = null;
      }
    }
    
    // Final fallback for Explore More if still empty
    if (_similarProductList == null || _similarProductList!.isEmpty) {
       _similarProductList = _sameTypeProductList ?? [];
       update(['explore_more']);
    }
  }

  final Map<int, List<Item>?> _exploreMoreCache = {};
  Map<int, List<Item>?> get exploreMoreCache => _exploreMoreCache;
  final Map<String, List<Item>> _localSimilarCache = {};
  
  List<Categories>? _exploreMoreCategories;
  List<Categories>? get exploreMoreCategories => _exploreMoreCategories;
  
  void clearExploreMoreCache() {
    _exploreMoreCache.clear();
    _exploreMoreInFlight.clear();
    _localSimilarCache.clear();
    _exploreMoreCategories = null;
  }

  Future<void> getExploreMoreItems(int categoryId, int moduleId, {bool append = false, bool prefetch = false}) async {
    if (_exploreMoreInFlight.contains(categoryId)) {
      return; // Already fetching this category
    }

    if (!append && !prefetch) {
      // Check if we already have this in cache and can serve it instantly
      if (_exploreMoreCache.containsKey(categoryId) && _exploreMoreCache[categoryId] != null) {
        _similarProductList = _exploreMoreCache[categoryId];
        update(['explore_more']);
        return;
      }
      _similarProductList = null;
      update();
    }
    
    if (prefetch && _exploreMoreCache.containsKey(categoryId)) {
      return; // Already cached or fetching
    }
    
    if (append && _exploreMoreCache.containsKey(categoryId) && _exploreMoreCache[categoryId] != null) {
      if (_similarProductList != null) {
        _similarProductList!.addAll(_exploreMoreCache[categoryId]!);
      } else {
        _similarProductList = _exploreMoreCache[categoryId];
      }
      update();
      return;
    }
    
    _exploreMoreInFlight.add(categoryId);
    try {
      int targetModuleId = (moduleId != 0) ? moduleId : (Get.find<SplashController>().module?.id ?? 0);
      ItemModel? itemModel = await itemServiceInterface.getPopularItemList(
        type: 'all', source: DataSourceEnum.client, offset: 1, categoryIds: categoryId == 0 ? null : [categoryId], moduleId: targetModuleId > 0 ? targetModuleId : null
      );
      
      if (itemModel != null) {
        _exploreMoreCache[categoryId] = itemModel.items;
        
        if (categoryId == 0 && itemModel.categories != null && itemModel.categories!.isNotEmpty) {
          _exploreMoreCategories = itemModel.categories;
        }
        
        if (!prefetch) {
          if (append && _similarProductList != null) {
            _similarProductList!.addAll(itemModel.items!);
          } else {
            _similarProductList = itemModel.items;
          }
          update();
          update(['explore_more']);
        }
      }
    } finally {
      _exploreMoreInFlight.remove(categoryId);
    }
  }

  Future<List<Item>> _fetchLocalSimilarItems(String name, int currentItemId, int moduleId) async {
    String searchKey = name.trim().split(' ')[0];
    if (searchKey.isEmpty) return [];

    String cacheKey = "${moduleId}_$searchKey";
    if (_localSimilarCache.containsKey(cacheKey)) {
      return _localSimilarCache[cacheKey]!.where((item) => item.id != currentItemId).toList();
    }

    List<Item> localItems = [];
    ItemModel? res = await itemServiceInterface.getPopularItemList(
      type: 'all', source: DataSourceEnum.client, offset: 1, search: searchKey, moduleId: moduleId
    );
    
    if (res != null && res.items != null) {
      localItems.addAll(res.items!.where((item) => item.organic == 1));
      _localSimilarCache[cacheKey] = localItems;
    }

    final ids = <int>{};
    return localItems.where((item) => ids.add(item.id!) && item.id != currentItemId).toList();
  }



  void showBottomLoader() {
    _isLoading = true;
    update();
  }

  void setOffset(int offset) {
    _offset = offset;
  }

  bool hasMoreData({bool isPopular = false, bool isSpecial = false}) {
    if(isPopular && _isAggregating){ // Check for aggregation
       if (_currentAggregatedModuleIndex < _aggregatedModuleIds.length - 1) return true;
       return _nationalAggregatedItemList != null && _nationalAggregatedItemList!.length < _pageSize!;
    }else if(isPopular){
       return _popularItemList != null && _popularItemList!.length < _pageSize!;
    }else if(isSpecial){
      return _discountedItemList != null && _discountedItemList!.length < _pageSize!;
    }else{
      return _reviewedItemList != null && _reviewedItemList!.length < _pageSize!;
    }
  }

  bool _isPopularItemListLoaded = false;
  bool _isReviewedItemListLoaded = false;
  bool _isDiscountedItemListLoaded = false;

  final List<String> _popularInFlightOffsets = [];
  final List<String> _reviewedInFlightOffsets = [];
  final List<String> _discountedInFlightOffsets = [];
  final List<String> _nationalInFlightOffsets = [];

  Future<void> getPopularItemList({required String offset, DataSourceEnum dataSource = DataSourceEnum.local, bool notify = false, bool firstTimeCategoryLoad = false, bool reload = false, bool fromLocalTransition = false}) async {
    if(!reload && _isPopularItemListLoaded && offset == '1' && _popularItemList != null && _popularItemList!.isNotEmpty) {
      if(notify) update();
      return;
    }

    if (!reload && dataSource == DataSourceEnum.local && _popularItemList != null) {
      if (!_isPopularItemListLoaded && !_popularInFlightOffsets.contains("client_1")) {
        getPopularItemList(notify: notify, dataSource: DataSourceEnum.client, offset: '1', fromLocalTransition: true);
      }
      return;
    }

    String inFlightKey = "${dataSource.name}_$offset";
    if (_popularInFlightOffsets.contains(inFlightKey)) {
      return;
    }

    if(_searchController.text.isEmpty) {
      _isSearching = false;
      if(notify) update();
    }else{
      _isSearching = true;
      if(notify) update();
    }

    if(offset == '1' && (reload || (dataSource == DataSourceEnum.local && !fromLocalTransition))) {
      _offsetList = [];
      _offset = 1;
      _popularItemList = null;
      _isPopularItemListLoaded = false;
      if(firstTimeCategoryLoad) _categoryList = null;
      if(notify) update();
    }

    if (!_offsetList.contains(offset) || fromLocalTransition) {
      if (!fromLocalTransition) {
        _offsetList.add(offset);
      }
      _popularInFlightOffsets.add(inFlightKey);
      
      try {
        ItemModel? itemModel = await itemServiceInterface.getPopularItemList(
          type: _popularType, source: dataSource, offset: _offset, search: _searchController.text, categoryIds: _selectedCategoryIds, filter: _filter,
          rating: _rating, minPrice: _selectedMinPrice, maxPrice: _selectedMaxPrice,
        );

        if (itemModel != null) {
          if (offset == '1' && !fromLocalTransition) {
            _popularItemList = [];
            if(firstTimeCategoryLoad) _categoryList = [];
          }
          _popularItemList ??= [];
          _popularItemList!.addAll(itemModel.items!);
          if(firstTimeCategoryLoad) {
            _categoryList ??= [];
            _categoryList!.addAll(itemModel.categories!);
          }
          _pageSize = itemModel.totalSize;
          _isLoading = false;
          if(dataSource == DataSourceEnum.client) {
            _isPopularItemListLoaded = true;
          }
        } else {
          _isLoading = false;
        }
        update();

        if(dataSource == DataSourceEnum.local) {
          getPopularItemList(notify : notify, dataSource: DataSourceEnum.client, offset: '1', fromLocalTransition: true);
        }
      } finally {
        _popularInFlightOffsets.remove(inFlightKey);
      }
    } else {
      if(isLoading) {
        _isLoading = false;
        update();
      }
    }
  }

  // New method for National Products Aggregation
  Future<void> getNationalAggregatedItemList({required String offset, DataSourceEnum dataSource = DataSourceEnum.local, bool notify = false, bool fromLocalTransition = false}) async {
      _isAggregating = true; // Ensure flag is set

      if (!fromLocalTransition && dataSource == DataSourceEnum.local && _nationalAggregatedItemList != null) {
        if (!_nationalInFlightOffsets.contains("client_1")) {
          getNationalAggregatedItemList(notify: notify, dataSource: DataSourceEnum.client, offset: '1', fromLocalTransition: true);
        }
        return;
      }

      String inFlightKey = "${dataSource.name}_$offset";
      if (_nationalInFlightOffsets.contains(inFlightKey)) {
        return;
      }

      if(_searchController.text.isEmpty) {
        _isSearching = false;
        if(notify) update();
      }else{
        _isSearching = true;
        if(notify) update();
      }

      if(offset == '1' && (dataSource == DataSourceEnum.local && !fromLocalTransition)) {
        if (_currentAggregatedModuleIndex == 0) {
          _offsetList = [];
          _offset = 1;
          _nationalAggregatedItemList = null;
          if(notify) update();
        } else {
           _offsetList = [];
        }
      }

      if (!_offsetList.contains(offset) || fromLocalTransition) {
        if (!fromLocalTransition) {
          _offsetList.add(offset);
        }
        _nationalInFlightOffsets.add(inFlightKey);

        try {
          // Lazily populate other modules if they weren't available during init
          if (Get.find<SplashController>().moduleList != null && _aggregatedModuleIds.length <= 1) {
             List<int> targetModuleIds = Get.find<SplashController>().moduleList!
                 .where((m) => m.showNationalProducts == true)
                 .map((m) => m.id!)
                 .toList();
             for (var id in targetModuleIds) {
               if (!_aggregatedModuleIds.contains(id)) {
                 _aggregatedModuleIds.add(id);
               }
             }
          }

          if (_aggregatedModuleIds.isEmpty) {
            _nationalAggregatedItemList = [];
            _isLoading = false;
            Future.microtask(() => update());
            return;
          }

          int? currentModuleId;
          if (_currentAggregatedModuleIndex < _aggregatedModuleIds.length) {
            currentModuleId = _aggregatedModuleIds[_currentAggregatedModuleIndex];
          }

          ItemModel? itemModel;
          if (_nationalFilterType == 'latest') {
            itemModel = await itemServiceInterface.getLatestItemList(
              type: _popularType, source: dataSource, offset: _offset, search: _searchController.text, categoryIds: _selectedCategoryIds, filter: _filter,
              rating: _rating, minPrice: _selectedMinPrice, maxPrice: _selectedMaxPrice, moduleId: currentModuleId,
            );
          } else if (_nationalFilterType == 'popular') {
            itemModel = await itemServiceInterface.getPopularItemList(
              type: _popularType, source: dataSource, offset: _offset, search: _searchController.text, categoryIds: _selectedCategoryIds, filter: _filter,
              rating: _rating, minPrice: _selectedMinPrice, maxPrice: _selectedMaxPrice, moduleId: currentModuleId,
            );
          } else if (_nationalFilterType == 'recommended') {
            itemModel = await itemServiceInterface.getPaginatedRecommendedItemList(
              type: _popularType, source: dataSource, offset: _offset, search: _searchController.text, categoryIds: _selectedCategoryIds, filter: _filter,
              rating: _rating, minPrice: _selectedMinPrice, maxPrice: _selectedMaxPrice, moduleId: currentModuleId,
            );
          } else if (_nationalFilterType == 'discounted') {
            itemModel = await itemServiceInterface.getDiscountedItemList(
              type: _popularType, source: dataSource, offset: _offset, search: _searchController.text, categoryIds: _selectedCategoryIds, filter: _filter,
              rating: _rating, minPrice: _selectedMinPrice, maxPrice: _selectedMaxPrice, moduleId: currentModuleId,
            );
          } else if (_nationalFilterType == 'most-reviewed') {
            itemModel = await itemServiceInterface.getReviewedItemList(
              type: _popularType, source: dataSource, offset: _offset, search: _searchController.text, categoryIds: _selectedCategoryIds, filter: _filter,
              rating: _rating, minPrice: _selectedMinPrice, maxPrice: _selectedMaxPrice, moduleId: currentModuleId,
            );
          }

          _prepareNationalAggregatedItems(itemModel, offset, fromLocalTransition: fromLocalTransition);

          if(dataSource == DataSourceEnum.local) {
            getNationalAggregatedItemList(notify : notify, dataSource: DataSourceEnum.client, offset: '1', fromLocalTransition: true);
          }
        } finally {
          _nationalInFlightOffsets.remove(inFlightKey);
        }
      } else {
        if(isLoading) {
          _isLoading = false;
          update();
        }
      }
  }

  void _prepareNationalAggregatedItems(ItemModel? itemModel, String offset, {bool fromLocalTransition = false}) {
    if (itemModel != null) {
      if (offset == '1' && !fromLocalTransition) {
        if (_currentAggregatedModuleIndex == 0) {
          _nationalAggregatedItemList = [];
        }
      }
      _nationalAggregatedItemList ??= [];
      _nationalAggregatedItemList!.addAll(itemModel.items!);
      
      // Aggregation Logic
       if (itemModel.items!.isEmpty && _currentAggregatedModuleIndex < _aggregatedModuleIds.length - 1) {
         //  print('DEBUG: [National] Empty result for module index $_currentAggregatedModuleIndex, switching to next...');
           _currentAggregatedModuleIndex++;
           _offset = 1; 
           _offsetList = [];
           getNationalAggregatedItemList(offset: '1', dataSource: DataSourceEnum.client, notify: true);
           return; 
       } else if (itemModel.totalSize! <= itemModel.offset! * int.parse(itemModel.limit!)) {
       //    print('DEBUG: [National] End of list for module index $_currentAggregatedModuleIndex, preparing next...');
           if (_currentAggregatedModuleIndex < _aggregatedModuleIds.length - 1) {
             _currentAggregatedModuleIndex++;
             _offset = 0; 
             _offsetList = [];
           }
       }

      _pageSize = itemModel.totalSize;
      _isLoading = false;
    } else {
      if (_currentAggregatedModuleIndex < _aggregatedModuleIds.length - 1) {
        //  print('DEBUG: [National] Error/Null result for module index $_currentAggregatedModuleIndex, switching to next...');
          _currentAggregatedModuleIndex++;
          _offset = 1; 
          _offsetList = [];
          getNationalAggregatedItemList(offset: '1', dataSource: DataSourceEnum.client, notify: true);
          return;
      }
      _isLoading = false;
    }
    update();
  }

  Future<void> getReviewedItemList({required String offset, DataSourceEnum dataSource = DataSourceEnum.local, bool notify = false, bool firstTimeCategoryLoad = false, bool reload = false, bool fromLocalTransition = false}) async {
    if(!reload && _isReviewedItemListLoaded && offset == '1' && _reviewedItemList != null && _reviewedItemList!.isNotEmpty) {
      if(notify) update();
      return;
    }

    if (!reload && dataSource == DataSourceEnum.local && _reviewedItemList != null) {
      if (!_isReviewedItemListLoaded && !_reviewedInFlightOffsets.contains("client_1")) {
        getReviewedItemList(notify: notify, dataSource: DataSourceEnum.client, offset: '1', fromLocalTransition: true);
      }
      return;
    }

    String inFlightKey = "${dataSource.name}_$offset";
    if (_reviewedInFlightOffsets.contains(inFlightKey)) {
      return;
    }

    if (_searchController.text.isEmpty) {
      _isSearching = false;
      if (notify) update();
    } else {
      _isSearching = true;
      if (notify) update();
    }

    if (offset == '1' && (reload || (dataSource == DataSourceEnum.local && !fromLocalTransition))) {
      if (!_isAggregating || _currentAggregatedModuleIndex == 0) { // + ahmed
        _offsetList = [];
        _offset = 1;
        _reviewedItemList = null;
        _reviewedCategoriesList = null;
        _isReviewedItemListLoaded = false;
        if(firstTimeCategoryLoad) _categoryList = null;
        if (notify) update();
      } else {
        _offsetList = [];
      }
    }

    if (!_offsetList.contains(offset) || fromLocalTransition) {
      if (!fromLocalTransition) {
        _offsetList.add(offset);
      }
      _reviewedInFlightOffsets.add(inFlightKey);
      
      try {
        // + ahmed
        if (_isAggregating && _aggregatedModuleIds.isEmpty) {
          _reviewedItemList = [];
          _isLoading = false;
          Future.microtask(() => update());
          return;
        }

        int? currentModuleId;
        if (_isAggregating && _currentAggregatedModuleIndex < _aggregatedModuleIds.length) {
          currentModuleId = _aggregatedModuleIds[_currentAggregatedModuleIndex];
        }

        ItemModel? itemModel = await itemServiceInterface.getReviewedItemList(
          type: _reviewedType, source: dataSource, offset: _offset, search: _searchController.text, categoryIds: _selectedCategoryIds,
          filter: _filter, rating: _rating, minPrice: _selectedMinPrice, maxPrice: _selectedMaxPrice, moduleId: currentModuleId, // + ahmed
        );

        _preparedReviewedItems(itemModel, offset, firstTimeCategoryLoad, fromLocalTransition: fromLocalTransition);

        if (dataSource == DataSourceEnum.local) {
          getReviewedItemList(notify: notify, dataSource: DataSourceEnum.client, offset: '1', fromLocalTransition: true);
        }
        if (dataSource == DataSourceEnum.client) {
          _isReviewedItemListLoaded = true;
        }
      } finally {
        _reviewedInFlightOffsets.remove(inFlightKey);
      }
    } else {
      if (_isLoading) {
        _isLoading = false;
        update();
      }
    }
  }

  void _preparedReviewedItems(ItemModel? itemModel, String offset, bool firstTimeCategoryLoad, {bool fromLocalTransition = false}) {
    if (itemModel != null) {
      if (offset == '1' && !fromLocalTransition) {
        if (!_isAggregating || _currentAggregatedModuleIndex == 0) { // + ahmed
           _reviewedItemList = [];
           _reviewedCategoriesList = [];
           if(firstTimeCategoryLoad) _categoryList = [];
        }
      }
      _reviewedItemList ??= []; // + ahmed
      _reviewedCategoriesList ??= []; // + ahmed

      _reviewedItemList!.addAll(itemModel.items!);
      _reviewedCategoriesList!.addAll(itemModel.categories!);
      
      // + ahmed: Recursion for Reviewed Items
      if (_isAggregating) {
         if (itemModel.items!.isEmpty && _currentAggregatedModuleIndex < _aggregatedModuleIds.length - 1) {
             print('DEBUG: [Reviewed] Empty result for module index $_currentAggregatedModuleIndex, switching to next...');
             _currentAggregatedModuleIndex++;
             _offset = 1; 
             _offsetList = [];
             getReviewedItemList(offset: '1', dataSource: DataSourceEnum.client, notify: true);
             return; 
         } else if (itemModel.totalSize! <= itemModel.offset! * int.parse(itemModel.limit!)) {
             print('DEBUG: [Reviewed] End of list for module index $_currentAggregatedModuleIndex, preparing next...');
             if (_currentAggregatedModuleIndex < _aggregatedModuleIds.length - 1) {
               _currentAggregatedModuleIndex++;
               _offset = 0; 
               _offsetList = [];
             }
         }
      }

      if(firstTimeCategoryLoad) _categoryList!.addAll(itemModel.categories!);
      _pageSize = itemModel.totalSize;
      _isLoading = false;
    } else {
      // + ahmed: Handle API Error/Null Result
      if (_isAggregating && _currentAggregatedModuleIndex < _aggregatedModuleIds.length - 1) {
          print('DEBUG: [Reviewed] Error/Null result for module index $_currentAggregatedModuleIndex, switching to next...');
          _currentAggregatedModuleIndex++;
          _offset = 1; 
          _offsetList = [];
          getReviewedItemList(offset: '1', dataSource: DataSourceEnum.client, notify: true);
          return;
      }
      _isLoading = false;
    }
    update();
  }

  Future<void> getDiscountedItemList({required String offset, DataSourceEnum dataSource = DataSourceEnum.local, bool notify = false, bool firstTimeCategoryLoad = false, bool reload = false, bool fromLocalTransition = false}) async {
    if(!reload && _isDiscountedItemListLoaded && offset == '1' && _discountedItemList != null && _discountedItemList!.isNotEmpty) {
      if(notify) update();
      return;
    }

    if (!reload && dataSource == DataSourceEnum.local && _discountedItemList != null) {
      if (!_isDiscountedItemListLoaded && !_discountedInFlightOffsets.contains("client_1")) {
        getDiscountedItemList(notify: notify, dataSource: DataSourceEnum.client, offset: '1', fromLocalTransition: true);
      }
      return;
    }

    String inFlightKey = "${dataSource.name}_$offset";
    if (_discountedInFlightOffsets.contains(inFlightKey)) {
      return;
    }

    if (_searchController.text.isEmpty) {
      _isSearching = false;
      if (notify) update();
    } else {
      _isSearching = true;
      if (notify) update();
    }

    if(offset == '1' && (reload || (dataSource == DataSourceEnum.local && !fromLocalTransition))) {
      _offsetList = [];
      _offset = 1;
      _discountedItemList = null;
      _isDiscountedItemListLoaded = false;
      if(firstTimeCategoryLoad) _categoryList = null;
      if (notify) update();
    }

    if (!_offsetList.contains(offset) || fromLocalTransition) {
      if (!fromLocalTransition) {
        _offsetList.add(offset);
      }
      _discountedInFlightOffsets.add(inFlightKey);
      
      try {
        ItemModel? itemModel = await itemServiceInterface.getDiscountedItemList(
          type: _discountedType, source: dataSource, offset: _offset, search: _searchController.text, categoryIds: _selectedCategoryIds, filter: _filter,
          rating: _rating, minPrice: _selectedMinPrice, maxPrice: _selectedMaxPrice,
        );

        _prepareDiscountedItems(itemModel, offset, firstTimeCategoryLoad, fromLocalTransition: fromLocalTransition);

        if(dataSource == DataSourceEnum.local) {
          getDiscountedItemList(notify: notify, dataSource: DataSourceEnum.client, offset: '1', fromLocalTransition: true);
        }
        if(dataSource == DataSourceEnum.client) {
          _isDiscountedItemListLoaded = true;
        }
      } finally {
        _discountedInFlightOffsets.remove(inFlightKey);
      }
    } else {
      if(isLoading) {
        _isLoading = false;
        update();
      }
    }
  }

  void _prepareDiscountedItems(ItemModel? itemModel, String offset, bool firstTimeCategoryLoad, {bool fromLocalTransition = false}) {
    if (itemModel != null) {
      if (offset == '1' && !fromLocalTransition) {
        _discountedItemList = [];
        if(firstTimeCategoryLoad) _categoryList = [];
      }
      _discountedItemList ??= []; // + ahmed

      _discountedItemList!.addAll(itemModel.items!);
      
      if(firstTimeCategoryLoad) _categoryList!.addAll(itemModel.categories!);
      _pageSize = itemModel.totalSize;
      _isLoading = false;
    } else {
      _isLoading = false;
    }
    update();
  }

  Future<void> getBuyAgainItemList({bool reload = false, bool notify = false}) async {
    if(reload) {
      _buyAgainItemList = null;
    }
    if(notify) {
      update();
    }
    if(_buyAgainItemList == null || reload) {
      ItemModel? itemModel = await itemServiceInterface.getBuyAgainItemList();
      if (itemModel != null) {
        _buyAgainItemList = [];
        _buyAgainItemList!.addAll(itemModel.items!);
      }
      update();
    }
  }

  Future<void> getFeaturedCategoriesItemList(bool reload, bool notify, {DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false}) async {
    if(reload) {
      _featuredCategoriesItem = null;
    }
    if(notify) {
      update();
    }
    if(_featuredCategoriesItem == null || reload || fromRecall) {
      if(dataSource == DataSourceEnum.local) {
        _featuredCategoriesItem = await itemServiceInterface.getFeaturedCategoriesItemList(dataSource);
        update();
        getFeaturedCategoriesItemList(false, notify, dataSource: DataSourceEnum.client, fromRecall: true);
      } else {
        _featuredCategoriesItem = await itemServiceInterface.getFeaturedCategoriesItemList(dataSource);
        update();
      }
    }
  }

  Future<void> getRecommendedItemList(bool reload, String type, bool notify, {DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false}) async {
    if(reload) {
      _recommendedItemList = null;
    }
    if(notify) {
      update();
    }
    if(_recommendedItemList == null || reload || fromRecall) {
      List<Item>? items;
      if(dataSource == DataSourceEnum.local) {
        items = await itemServiceInterface.getRecommendedItemList(type, dataSource);
        _prepareRecommendedItems(items);

        getRecommendedItemList(false, type, notify, dataSource: DataSourceEnum.client, fromRecall: true);
      } else {
        items = await itemServiceInterface.getRecommendedItemList(type, dataSource);
        _prepareRecommendedItems(items);
      }

    }
  }

  void _prepareRecommendedItems(List<Item>? items) {
    if (items != null) {
      _recommendedItemList = [];
      try {
        final profileController = Get.find<ProfileController>();
        if (profileController.shoppingPreference.isCompleted) {
          final prefs = profileController.shoppingPreference;
          List<Item> matchedItems = [];
          List<Item> otherItems = [];
          
          for (var item in items) {
            bool matches = false;
            final nameLower = item.name?.toLowerCase() ?? '';
            final descLower = item.description?.toLowerCase() ?? '';
            
            for (var cat in prefs.favoriteCategories) {
              final catTranslated = cat.tr;
              if (nameLower.contains(cat.toLowerCase()) || descLower.contains(cat.toLowerCase()) ||
                  nameLower.contains(catTranslated.toLowerCase()) || descLower.contains(catTranslated.toLowerCase())) {
                matches = true;
                break;
              }
            }
            if (!matches) {
              for (var target in prefs.targetAudience) {
                if (nameLower.contains(target.toLowerCase()) || descLower.contains(target.toLowerCase())) {
                  matches = true;
                  break;
                }
              }
            }
            if (!matches) {
              for (var style in prefs.favoriteStyles) {
                if (nameLower.contains(style.toLowerCase()) || descLower.contains(style.toLowerCase())) {
                  matches = true;
                  break;
                }
              }
            }
            
            if (matches) {
              matchedItems.add(item);
            } else {
              otherItems.add(item);
            }
          }
          
          _recommendedItemList!.addAll(matchedItems);
          _recommendedItemList!.addAll(otherItems);
        } else {
          _recommendedItemList!.addAll(items);
        }
      } catch (e) {
        _recommendedItemList!.addAll(items);
      }
      _isLoading = false;
    }
    update();
  }

  Future<void> getBasicMedicine(bool reload, bool notify, {DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false}) async {
    if(reload) {
      _basicMedicineModel = null;
    }
    if(notify) {
      update();
    }
    if(_basicMedicineModel == null || reload || fromRecall) {
      if(dataSource == DataSourceEnum.local) {
        _basicMedicineModel = await itemServiceInterface.getBasicMedicine(DataSourceEnum.local);
        _isLoading = false;
        update();
        getBasicMedicine(false, notify, fromRecall: true, dataSource: DataSourceEnum.client);
      } else {
        _basicMedicineModel = await itemServiceInterface.getBasicMedicine(DataSourceEnum.client);
        _isLoading = false;
        update();
      }
    }
  }

  Future<void> getConditionsWiseItem(int id, bool notify) async {
    _conditionWiseProduct = null;
    if(notify) {
      update();
    }
    List<Item>? items = await itemServiceInterface.getConditionsWiseItems(id);
    if (items != null) {
      _conditionWiseProduct = [];
      _conditionWiseProduct!.addAll(items);
      _isLoading = false;
    }
    update();
  }

  Future<void> getCommonConditions(bool notify) async {
    _commonConditions = [];
    if(notify) {
      update();
    }
    List<CommonConditionModel>? conditions = await itemServiceInterface.getCommonConditions();
    if (conditions != null) {
      _commonConditions!.addAll(conditions);
      _isLoading = false;
    }
    update();
  }

  Future<void> getItemDetails({required int itemId, CartModel? cart, Item? item, bool isCampaign = false, bool fetchSimilarItems = true}) async {
    if (item?.name != null) {
      _item = item;
      initData(_item, cart);
      setExistInCart(_item, _selectedVariations);
      update();
      bool isFood = (_item!.moduleType == 'food') || (Get.find<SplashController>().module?.moduleType == 'food');
      if (isCampaign || isFood) {
        if (!isFood) {
          if (fetchSimilarItems) {
            getSimilarItems(
               _item!.name ?? '', 
               _item!.moduleId ?? Get.find<SplashController>().module?.id ?? Get.find<SplashController>().cacheModule?.id ?? 0, 
               _item!.categoryId ?? 0, 
               _item!.id ?? 0, 
               _item!.storeId,
               parentCategoryId: (_item!.categoryIds != null && _item!.categoryIds!.isNotEmpty) 
                   ? int.parse((_item!.categoryIds!.firstWhereOrNull((v) => v.position == 1) ?? _item!.categoryIds!.first).id.toString()) 
                   : 0
            );
          } else {
            _similarProductList = [];
            _similarLocalProductList = [];
            _storeProductList = [];
            _sameTypeProductList = [];
          }
        } else {
          _similarProductList = [];
          _similarLocalProductList = [];
          _storeProductList = [];
          _sameTypeProductList = [];
        }
        if (!isFood && _item!.storeDetails == null && _item!.storeId != null) {
          if (Get.isRegistered<StoreController>()) {
            Get.find<StoreController>().getStoreDetails(Store(id: _item!.storeId), false).then((store) {
              if (store != null) {
                _item!.storeDetails = {
                  'logo_full_url': store.logoFullUrl,
                  'total_items': store.itemCount,
                };
                _item!.storeName = store.name;
                update();
              }
            });
          }
        }
        return;
      }
      // + ahmed: For non-food modules (grocery, ecommerce, etc.) when item data is
      // already available locally, return early without making a server API call.
      // This mirrors the food module behavior and avoids redundant network requests.
      if (fetchSimilarItems) {
        getSimilarItems(
          _item!.name ?? '', 
          _item!.moduleId ?? Get.find<SplashController>().module?.id ?? Get.find<SplashController>().cacheModule?.id ?? 0, 
          _item!.categoryId ?? 0, 
          _item!.id ?? 0, 
          _item!.storeId,
          parentCategoryId: (_item!.categoryIds != null && _item!.categoryIds!.isNotEmpty) 
              ? int.parse((_item!.categoryIds!.firstWhereOrNull((v) => v.position == 1) ?? _item!.categoryIds!.first).id.toString()) 
              : 0
        );
      } else {
        _similarProductList = [];
        _similarLocalProductList = [];
        _storeProductList = [];
        _sameTypeProductList = [];
      }
      if (_item!.storeDetails == null && _item!.storeId != null) {
        if (Get.isRegistered<StoreController>()) {
          Get.find<StoreController>().getStoreDetails(Store(id: _item!.storeId), false).then((store) {
            if (store != null) {
              _item!.storeDetails = {
                'logo_full_url': store.logoFullUrl,
                'total_items': store.itemCount,
              };
              _item!.storeName = store.name;
              update();
            }
          });
        }
      }
      return;
    } else if (_item == null || _item!.id != itemId) {
      _item = null;
      update();
    }

    Item? fullItem = await itemServiceInterface.getItemDetails(itemId);

    if(fullItem != null) {
      _item = fullItem;
      initData(_item, cart);
      setExistInCart(_item, _selectedVariations);
      // Trigger Similar Items Search
      bool isFood = (_item!.moduleType == 'food') || (Get.find<SplashController>().module?.moduleType == 'food');
      if (!isFood) {
        if (fetchSimilarItems) {
          getSimilarItems(
             _item!.name ?? '', 
             _item!.moduleId ?? Get.find<SplashController>().module?.id ?? Get.find<SplashController>().cacheModule?.id ?? 0, 
             _item!.categoryId ?? 0, 
             _item!.id ?? 0, 
             _item!.storeId,
             parentCategoryId: (_item!.categoryIds != null && _item!.categoryIds!.isNotEmpty) 
                 ? int.parse((_item!.categoryIds!.firstWhereOrNull((v) => v.position == 1) ?? _item!.categoryIds!.first).id.toString()) 
                 : 0
          );
        } else {
          _similarProductList = [];
          _similarLocalProductList = [];
          _storeProductList = [];
          _sameTypeProductList = [];
        }
      } else {
        _similarProductList = [];
        _similarLocalProductList = [];
        _storeProductList = [];
        _sameTypeProductList = [];
      }
    }
    update();
  }

  void initData(Item? item, CartModel? cart) {
    if (item != null) {
      item.foodVariations ??= [];
      item.choiceOptions ??= [];
      item.variations ??= [];
      item.addOns ??= [];
    }

    _variationIndex = [];
    _addOnQtyList = [];
    _addOnActiveList = [];
    _selectedVariations = [];
    _collapseVariation = [];
    if(cart != null) {
      _quantity = cart.quantity;
      if (item != null) {
        if (item.addOns != null) {
          _addOnActiveList.addAll(itemServiceInterface.initializeCartAddonActiveList(cart.addOnIds, item.addOns));
          _addOnQtyList.addAll(itemServiceInterface.initializeCartAddonsQtyList(cart.addOnIds, item.addOns));
        }

        if(ModuleHelper.getModuleConfig(item.moduleType).newVariation!) {
          _selectedVariations.addAll(cart.foodVariations!);
          if (item.foodVariations != null) {
            _collapseVariation.addAll(itemServiceInterface.collapseVariation(item.foodVariations!));
          }
        }else {
          if (item.choiceOptions != null) {
            _variationIndex = itemServiceInterface.initializeCartVariationIndexes(cart.variation, item.choiceOptions);
          }
        }
      }
    } else {
      if(item != null) {
        if(ModuleHelper.getModuleConfig(item.moduleType).newVariation!) {
          if (item.foodVariations != null) {
            _selectedVariations.addAll(itemServiceInterface.initializeSelectedVariation(item.foodVariations));
            _collapseVariation.addAll(itemServiceInterface.initializeCollapseVariation(item.foodVariations));
          }
        } else {
          if (item.choiceOptions != null) {
            _variationIndex = itemServiceInterface.initializeVariationIndexes(item.choiceOptions);
          }
        }
        _quantity = 1;
        if (item.addOns != null) {
          _addOnActiveList.addAll(itemServiceInterface.initializeAddonActiveList(item.addOns));
          _addOnQtyList.addAll(itemServiceInterface.initializeAddonQtyList(item.addOns));
        }

        setExistInCart(item, _selectedVariations, notify: true);
      } else {
        _quantity = 1;
      }
    }

  }

  void cartIndexSet() {
    _cartIndex = -1;
  }

  Future<int> setExistInCart(Item? item, List<List<bool?>>? selectedVariations, {bool notify = false}) async {
    String variationType = '';
    if(item!.choiceOptions != null && item.choiceOptions!.isNotEmpty) {
      if(_variationIndex == null || _variationIndex!.length != item.choiceOptions!.length) {
        _variationIndex = itemServiceInterface.initializeVariationIndexes(item.choiceOptions);
      }
      variationType = await itemServiceInterface.prepareVariationType(item.choiceOptions, _variationIndex);
    }

    if(ModuleHelper.getModuleConfig(ModuleHelper.getModule() != null ? ModuleHelper.getModule()!.moduleType : ModuleHelper.getCacheModule()!.moduleType).newVariation!) {
      _cartIndex = await itemServiceInterface.isExistInCartForBottomSheet(Get.find<CartController>().cartList, item.id, null, selectedVariations);
    } else {
      _cartIndex = Get.find<CartController>().isExistInCart(item.id, variationType, false, null);
    }

    if(_cartIndex != -1) {
      _quantity = Get.find<CartController>().cartList[_cartIndex].quantity;
      _addOnActiveList = itemServiceInterface.initializeCartAddonActiveList(Get.find<CartController>().cartList[_cartIndex].addOnIds, item.addOns);
      _addOnQtyList = itemServiceInterface.initializeCartAddonsQtyList(Get.find<CartController>().cartList[_cartIndex].addOnIds, item.addOns);
    } else {
      _quantity = 1;
    }
    if(notify) {
      update();
    }
    return _cartIndex;
  }

  void setAddOnQuantity(bool isIncrement, int index) {
    _addOnQtyList[index] = itemServiceInterface.setAddOnQuantity(isIncrement, _addOnQtyList[index]!);
    update();
  }

  Future<void> setQuantity(bool isIncrement, int? stock,  int? quantityLimit, {bool getxSnackBar = false}) async {
    _quantity = await itemServiceInterface.setQuantity(isIncrement, Get.find<SplashController>().configModel!.moduleConfig!.module!.stock!, stock, _quantity!, quantityLimit, getxSnackBar: getxSnackBar);
    update();
  }

  void setCartVariationIndex(int index, int i, Item? item) {
    _variationIndex![index] = i;
    _quantity = 1;
    setExistInCart(item, _selectedVariations);
    update();
  }

  void showMoreSpecificSection(int index){
    _collapseVariation[index] = !_collapseVariation[index];
    update();
  }

  void setNewCartVariationIndex(int index, int i, Item item) {
    _selectedVariations = itemServiceInterface.setNewCartVariationIndex(index, i, item.foodVariations!, _selectedVariations);
    setExistInCart(item, _selectedVariations);
    // if(!item.foodVariations![index].multiSelect!) {
    //   for(int j = 0; j < _selectedVariations[index].length; j++) {
    //     if(item.foodVariations![index].required!){
    //       _selectedVariations[index][j] = j == i;
    //     }else{
    //       if(_selectedVariations[index][j]!){
    //         _selectedVariations[index][j] = false;
    //       }else{
    //         _selectedVariations[index][j] = j == i;
    //       }
    //     }
    //   }
    // } else {
    //   if(!_selectedVariations[index][i]! && selectedVariationLength(_selectedVariations, index) >= item.foodVariations![index].max!) {
    //     showCustomSnackBar(
    //       '${'maximum_variation_for'.tr} ${item.foodVariations![index].name} ${'is'.tr} ${item.foodVariations![index].max}',
    //       getXSnackBar: true,
    //     );
    //   }else {
    //     _selectedVariations[index][i] = !_selectedVariations[index][i]!;
    //   }
    // }
    update();
  }

  int selectedVariationLength(List<List<bool?>> selectedVariations, int index) {
    return itemServiceInterface.selectedVariationLength(selectedVariations, index);
  }

  void addAddOn(bool isAdd, int index) {
    _addOnActiveList[index] = isAdd;
    update();
  }

  void setImageIndex(int index, bool notify) {
    _imageIndex = index;
    if(notify) {
      update();
    }
  }

  void setSelect(int select, bool notify){
    _productSelect = select;
    if(notify){
      update();
    }
  }

  void setImageSliderIndex(int index) {
    _imageSliderIndex = index;
    update();
  }

  double? getStartingPrice(Item item) {
    return itemServiceInterface.getStartingPrice(item);
  }

  bool isAvailable(Item item) {
    return DateConverter.isAvailable(item.availableTimeStarts, item.availableTimeEnds);
  }

  double? getDiscount(Item item) => item.discount;

  String? getDiscountType(Item item) => item.discountType;

  void navigateToItemPage(Item? item, BuildContext context, {bool inStore = false, bool isCampaign = false}) {
    if(Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText! || item!.moduleType == 'food') {
      ResponsiveHelper.isMobile(context) ? Get.bottomSheet(
        ItemBottomSheet(itemId: item!.id!, inStorePage: inStore, isCampaign: isCampaign, item: item),
        backgroundColor: Colors.transparent, isScrollControlled: true,
      ) : Get.dialog(
        Dialog(child: ItemBottomSheet(itemId: item!.id!, inStorePage: inStore, isCampaign: isCampaign, item: item)),
      );
    }else {
      Get.toNamed(RouteHelper.getItemDetailsRoute(item.id, inStore), arguments: ItemDetailsScreen(itemId: item.id!, inStorePage: inStore, isCampaign: isCampaign, item: item));
    }
  }

  void itemDirectlyAddToCart(Item? item, BuildContext context, {bool inStore = false, bool isCampaign = false}) {
    getItemDetails(itemId: item!.id!, item: item, isCampaign: isCampaign, fetchSimilarItems: false).then((value) {
      bool hasRequiredFoodVariation = _item?.foodVariations != null && _item!.foodVariations!.any((v) => (v.required ?? false) || (v.min ?? 0) > 0);
      bool canQuickAddFood = _item?.moduleType == AppConstants.food && (!hasRequiredFoodVariation);
      
      if (canQuickAddFood || (_item?.variations != null && _item!.variations!.isEmpty && _item?.moduleType != AppConstants.food)) {
        double price = _item!.price!;
        double discount = _item!.discount!;
        double discountPrice = PriceConverter.convertWithDiscount(price, discount, _item!.discountType)!;

        List<List<bool?>>? foodVariations = _item?.foodVariations != null ? itemServiceInterface.initializeSelectedVariation(_item!.foodVariations) : null;
        List<OrderVariation> orderVariations = [];
        if (ModuleHelper.getModuleConfig(_item?.moduleType).newVariation! && _item?.foodVariations != null && foodVariations != null) {
          for(int i=0; i<_item!.foodVariations!.length; i++) {
            if(foodVariations[i].contains(true)) {
              orderVariations.add(OrderVariation(name: _item!.foodVariations![i].name, values: OrderVariationValue(label: [])));
              for(int j=0; j<_item!.foodVariations![i].variationValues!.length; j++) {
                if(foodVariations[i][j]!) {
                  orderVariations[orderVariations.length-1].values!.label!.add(_item!.foodVariations![i].variationValues![j].level);
                }
              }
            }
          }
        }

        CartModel cartModel = CartModel(
          id: null, price: price, discountedPrice: discountPrice, variation: [], foodVariations: foodVariations ?? [], discountAmount: (price - discountPrice), quantity: 1, addOnIds: [], addOns: [], isCampaign: isCampaign,
          stock: _item?.stock, item: _item, quantityLimit: _item?.quantityLimit,
        );

        OnlineCart onlineCart = OnlineCart(
          cartId: null, itemId: _item?.id, itemCampaignId: isCampaign ? _item?.id : null,
          price: price.toString(), variant: '', variation: null,
          variations: ModuleHelper.getModuleConfig(_item?.moduleType).newVariation! ? orderVariations : null,
          quantity: 1, addOnIds: [], addOns: [], addOnQtys: [], model: isCampaign ? 'ItemCampaign' : 'Item',
        );
        if(Get.find<SplashController>().configModel!.moduleConfig!.module!.stock! && _item!.stock! <= 0){
          showCustomSnackBar('out_of_stock'.tr);
        }
        else if (Get.find<CartController>().existAnotherStoreItem(cartModel.item!.storeId, ModuleHelper.getModule() != null
            ? ModuleHelper.getModule()?.id : ModuleHelper.getCacheModule()?.id)) {
          Get.dialog(ConfirmationDialog(
            icon: Images.warning,
            title: 'are_you_sure_to_reset'.tr,
            description: Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText!
                ? 'if_you_continue'.tr : 'if_you_continue_without_another_store'.tr,
            onYesPressed: () {
              Get.find<CartController>().clearCartOnline().then((success) async {
                if (success) {
                  Get.find<CartController>().addToCartOnline(onlineCart, cartModel);
                  Get.back();
                  // showCartSnackBar();
                }
              });
            },
          ), barrierDismissible: false);
        } else {
          Get.find<CartController>().addToCartOnline(onlineCart, cartModel);
          // showCartSnackBar();
        }
      } else if(Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText!
          || _item?.moduleType == AppConstants.food
          || _item?.moduleType == AppConstants.grocery
          || _item?.moduleType == AppConstants.ecommerce){
        ResponsiveHelper.isMobile(Get.context) ? Get.bottomSheet(
          ItemBottomSheet(itemId: _item!.id!, inStorePage: inStore, isCampaign: isCampaign, item: _item),
          backgroundColor: Colors.transparent, isScrollControlled: true,
        ) : Get.dialog(
          Dialog(child: ItemBottomSheet(itemId: _item!.id!, inStorePage: inStore, isCampaign: isCampaign, item: _item)),
        );
      } else {
        Get.toNamed(RouteHelper.getItemDetailsRoute(_item!.id, inStore), arguments: ItemDetailsScreen(itemId: _item!.id!, inStorePage: inStore, item: _item));
      }
    });
  }
  
  Future<void> recordItemView(int itemID) async {
    await itemServiceInterface.recordItemView(itemID);
  }

  Future<void> toggleReviewLike(int reviewID) async {
    ReviewModel? review;
    
    // Check _item reviews
    if (_item != null && _item!.reviews != null) {
      review = _item!.reviews!.firstWhereOrNull((r) => r.id == reviewID);
    }
    
    if (review != null) {
      bool wasLiked = review.isLikedByUser ?? false;
      int oldCount = review.likeCount ?? 0;
      
      review.isLikedByUser = !wasLiked;
      review.likeCount = wasLiked ? (oldCount > 0 ? oldCount - 1 : 0) : oldCount + 1;
      update(); // Update UI immediately
      
      ResponseModel responseModel = wasLiked 
        ? await itemServiceInterface.unlikeReview(reviewID)
        : await itemServiceInterface.likeReview(reviewID);
        
      if (!responseModel.isSuccess) {
        review.isLikedByUser = wasLiked;
        review.likeCount = oldCount;
        showCustomSnackBar(responseModel.message);
        update(); // Revert UI on failure
      }
    }
  }
}
