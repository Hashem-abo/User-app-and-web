import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'package:sixam_mart/features/category/domain/models/category_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/category/domain/services/category_service_interface.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';

class CategoryController extends GetxController implements GetxService {
  final CategoryServiceInterface categoryServiceInterface;
  CategoryController({required this.categoryServiceInterface});

  List<CategoryModel>? _categoryList;
  List<CategoryModel>? get categoryList => _categoryList;

  List<CategoryModel>? _subCategoryList;
  List<CategoryModel>? get subCategoryList => _subCategoryList;

  List<CategoryModel>? _subSubCategoryList;
  List<CategoryModel>? get subSubCategoryList => _subSubCategoryList;

  List<Item>? _categoryItemList;
  List<Item>? get categoryItemList => _categoryItemList;

  List<Store>? _categoryStoreList;
  List<Store>? get categoryStoreList => _categoryStoreList;

  List<Item>? _searchItemList = [];
  List<Item>? get searchItemList => _searchItemList;

  List<Store>? _searchStoreList = [];
  List<Store>? get searchStoreList => _searchStoreList;

  List<bool>? _interestSelectedList;
  List<bool>? get interestSelectedList => _interestSelectedList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isCategoryLoaded = false;
  bool get isCategoryLoaded => _isCategoryLoaded;

  final Map<int, List<CategoryModel>> _moduleCategoryList = {};
  final Map<int, List<bool>> _moduleInterestSelectedList = {};

  int? _pageSize;
  int? get pageSize => _pageSize;

  int? _restPageSize;
  int? get restPageSize => _restPageSize;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  int _subCategoryIndex = 0;
  int get subCategoryIndex => _subCategoryIndex;

  String _type = 'all';
  String get type => _type;

  bool _isStore = false;
  bool get isStore => _isStore;

  String? _searchText = '';
  String? get searchText => _searchText;

  int _offset = 1;
  int get offset => _offset;

  void switchModule(int? moduleId) {
    if (moduleId != null && _moduleCategoryList.containsKey(moduleId)) {
      _categoryList = _moduleCategoryList[moduleId];
      _interestSelectedList = _moduleInterestSelectedList[moduleId];
      _isCategoryLoaded = true;
    } else {
      _categoryList = null;
      _interestSelectedList = null;
      _isCategoryLoaded = false;
    }
    update();
  }

  void clearCategoryList({bool clearAllModuleCache = false}) {
    _categoryList = null;
    _interestSelectedList = null;
    _isCategoryLoaded = false;
    if (clearAllModuleCache) {
      _moduleCategoryList.clear();
      _moduleInterestSelectedList.clear();
      _subCategoryCache.clear();
      _subSubCategoryCache.clear();
      _categoryDetailsCache.clear();
      _categorySubCategoryCache.clear();
      _subCategoryItemCache.clear();
      _subCategoryStoreCache.clear();
      _subCategoryItemTotalSize.clear();
      _subCategoryStoreTotalSize.clear();
    }
    update();
  }

  void clearCategoryItemList({bool clearSessionCache = false}) {
    _categoryItemList = null;
    _categoryStoreList = null;
    if (clearSessionCache) {
      _subCategoryItemCache.clear();
      _subCategoryStoreCache.clear();
      _subCategoryItemTotalSize.clear();
      _subCategoryStoreTotalSize.clear();
    }
    update();
  }

  Future<void> getCategoryList(bool reload, {bool allCategory = false, DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false}) async {
    int? currentModuleId = Get.find<SplashController>().module?.id;
    
    if(reload) {
      _moduleCategoryList.clear();
      _moduleInterestSelectedList.clear();
    }

    if(!reload && currentModuleId != null && _moduleCategoryList.containsKey(currentModuleId)) {
      _categoryList = _moduleCategoryList[currentModuleId];
      _interestSelectedList = _moduleInterestSelectedList[currentModuleId];
      _isCategoryLoaded = true;
      update();
      return;
    } else if (!reload) {
      // If not in cache and not reloading, clear the list to avoid showing old module's data
      _categoryList = null;
      _interestSelectedList = null;
      _isCategoryLoaded = false;
    }

    if(_categoryList == null || reload || fromRecall) {
      if(reload) {
        _categoryList = null;
      }
      List<CategoryModel>? categoryList;
      if(dataSource == DataSourceEnum.local) {
        categoryList = await categoryServiceInterface.getCategoryList(allCategory, source: DataSourceEnum.local);
        _prepareCategoryList(categoryList);
        getCategoryList(false, fromRecall: true, allCategory: allCategory, dataSource: DataSourceEnum.client);
      } else {
        categoryList = await categoryServiceInterface.getCategoryList(allCategory, source: DataSourceEnum.client);
        _prepareCategoryList(categoryList);
        _isCategoryLoaded = true;
      }

    }
  }

  void _prepareCategoryList(List<CategoryModel>? categoryList) {
    if (categoryList != null) {
      _categoryList = [];
      _interestSelectedList = [];
      _categoryList!.addAll(categoryList);
      for(int i = 0; i < _categoryList!.length; i++) {
        _interestSelectedList!.add(false);
      }
      
      int? currentModuleId = Get.find<SplashController>().module?.id;
      if (currentModuleId != null) {
        _moduleCategoryList[currentModuleId] = _categoryList!;
        _moduleInterestSelectedList[currentModuleId] = _interestSelectedList!;
      }
      
      if(_categoryList!.isNotEmpty) {
        getSubCategoryList(_categoryList![0].id.toString());
      }
    }
    update();
  }

  final Map<String, List<CategoryModel>> _subCategoryCache = {};
  final Map<String, List<CategoryModel>> _subSubCategoryCache = {};
  final Map<String, CategoryModel> _categoryDetailsCache = {};
  final Map<String, int> _subCategoryItemTotalSize = {};
  final Map<String, int> _subCategoryStoreTotalSize = {};
  int _subCategoryFetchGeneration = 0;

  void getSubCategoryList(String? categoryID) async {
    _subCategoryIndex = 0;
    final int generation = ++_subCategoryFetchGeneration;

    if (categoryID != null && _subCategoryCache.containsKey(categoryID)) {
      // 0ms instant display from cache
      _subCategoryList = _subCategoryCache[categoryID];
      if (_subCategoryList!.isNotEmpty) {
        _subCategoryIndex = 0;
        getSubSubCategoryList(_subCategoryList![0].id.toString());
      }
      update();
      // Background revalidation without blanking UI
      _revalidateSubCategoryList(categoryID, generation);
      return;
    }

    _subCategoryList = null;
    _categoryItemList = null;
    _subSubCategoryList = null;
    update();

    List<CategoryModel>? subCategoryList = await categoryServiceInterface.getSubCategoryList(categoryID);
    if (_subCategoryFetchGeneration != generation) return;

    if (subCategoryList != null) {
      _subCategoryList = [];
      _subCategoryList!.addAll(subCategoryList);
      if (categoryID != null) {
        _subCategoryCache[categoryID] = _subCategoryList!;
      }
      if (_subCategoryList!.isNotEmpty) {
        _subCategoryIndex = 0;
        getSubSubCategoryList(_subCategoryList![0].id.toString());
      }
    }
    update();
  }

  void _revalidateSubCategoryList(String categoryID, int generation) async {
    List<CategoryModel>? subCategoryList = await categoryServiceInterface.getSubCategoryList(categoryID);
    if (_subCategoryFetchGeneration != generation) return;
    if (subCategoryList != null) {
      _subCategoryCache[categoryID] = subCategoryList;
      _subCategoryList = subCategoryList;
      update();
    }
  }

  void getSubSubCategoryList(String? categoryID) async {
    if (categoryID != null && _subSubCategoryCache.containsKey(categoryID)) {
      _subSubCategoryList = _subSubCategoryCache[categoryID];
      update();
      return;
    }
    _subSubCategoryList = null;
    update();
    List<CategoryModel>? subCategoryList = await categoryServiceInterface.getSubCategoryList(categoryID);
    if (subCategoryList != null) {
      _subSubCategoryList = [];
      _subSubCategoryList!.addAll(subCategoryList);
      if (categoryID != null) {
        _subSubCategoryCache[categoryID] = _subSubCategoryList!;
      }
    }
    update();
  }

  List<CategoryModel>? _browseBySubCategoryList;
  List<CategoryModel>? get browseBySubCategoryList => _browseBySubCategoryList;

  final Map<String, List<CategoryModel>> _categorySubCategoryCache = {};

  void getBrowseBySubCategoryList(String categoryId) async {
    if (_categorySubCategoryCache.containsKey(categoryId)) {
      _browseBySubCategoryList = _categorySubCategoryCache[categoryId];
      update();
      return;
    }
    
    _browseBySubCategoryList = null;
    update();
    List<CategoryModel>? subCategoryList = await categoryServiceInterface.getSubCategoryList(categoryId);
    if (subCategoryList != null) {
      _browseBySubCategoryList = [];
      _browseBySubCategoryList!.addAll(subCategoryList);
      _categorySubCategoryCache[categoryId] = _browseBySubCategoryList!;
    }
    update();
  }

  CategoryModel? _categoryModel;
  CategoryModel? get categoryModel => _categoryModel;

  void getCategoryDetails(String categoryID) async {
    if (_categoryDetailsCache.containsKey(categoryID)) {
      _categoryModel = _categoryDetailsCache[categoryID];
      update();
      return;
    }
    _categoryModel = null;
    update();
    CategoryModel? category = await categoryServiceInterface.getCategoryDetails(categoryID);
    if (category != null) {
      _categoryModel = category;
      _categoryDetailsCache[categoryID] = category;
    }
    update();
  }

  int _subCategoryRequestGeneration = 0;
  final Map<String, List<Item>> _subCategoryItemCache = {};
  final Map<String, List<Store>> _subCategoryStoreCache = {};

  void setSubCategoryIndex(int index, String? categoryID) {
    _subCategoryIndex = index;
    _subCategoryRequestGeneration++;
    String targetId = _subCategoryIndex == 0 ? (categoryID ?? '') : (_subCategoryList![index].id?.toString() ?? '');
    String cacheKey = '${targetId}_$_type';

    if(_isStore) {
      if (_subCategoryStoreCache.containsKey(cacheKey)) {
        _categoryStoreList = _subCategoryStoreCache[cacheKey];
        _restPageSize = _subCategoryStoreTotalSize[cacheKey];
        update();
        getCategoryStoreList(targetId, 1, _type, false);
      } else {
        _categoryStoreList = null;
        update();
        getCategoryStoreList(targetId, 1, _type, true);
      }
    } else {
      if (_subCategoryItemCache.containsKey(cacheKey)) {
        _categoryItemList = _subCategoryItemCache[cacheKey];
        _pageSize = _subCategoryItemTotalSize[cacheKey];
        update();
        getCategoryItemList(targetId, 1, _type, false);
      } else {
        _categoryItemList = null;
        update();
        getCategoryItemList(targetId, 1, _type, true);
      }
    }
  }

  void getCategoryItemList(String? categoryID, int offset, String type, bool notify) async {
    _offset = offset;
    final int generation = _subCategoryRequestGeneration;
    String cacheKey = '${categoryID ?? ''}_$type';
    if(offset == 1) {
      if(_type == type) {
        _isSearching = false;
      }
      _type = type;
      if (!_subCategoryItemCache.containsKey(cacheKey)) {
        _categoryItemList = null;
      } else {
        _categoryItemList = _subCategoryItemCache[cacheKey];
        _pageSize = _subCategoryItemTotalSize[cacheKey];
      }
      if(notify) {
        update();
      }
    }
    ItemModel? categoryItem = await categoryServiceInterface.getCategoryItemList(categoryID, offset, type);
    // Guard against stale responses from rapid subcategory switching
    if (_subCategoryRequestGeneration != generation) return;

    if (categoryItem != null) {
      if (offset == 1) {
        _categoryItemList = [];
      }
      _categoryItemList!.addAll(categoryItem.items!);
      _pageSize = categoryItem.totalSize;
      _isLoading = false;
      if (offset == 1 && categoryID != null) {
        _subCategoryItemCache[cacheKey] = List.from(_categoryItemList!);
        if (_pageSize != null) {
          _subCategoryItemTotalSize[cacheKey] = _pageSize!;
        }
      }
    }
    update();
  }

  void getCategoryStoreList(String? categoryID, int offset, String type, bool notify) async {
    _offset = offset;
    final int generation = _subCategoryRequestGeneration;
    String cacheKey = '${categoryID ?? ''}_$type';
    if(offset == 1) {
      if(_type == type) {
        _isSearching = false;
      }
      _type = type;
      if (!_subCategoryStoreCache.containsKey(cacheKey)) {
        _categoryStoreList = null;
      } else {
        _categoryStoreList = _subCategoryStoreCache[cacheKey];
        _restPageSize = _subCategoryStoreTotalSize[cacheKey];
      }
      if(notify) {
        update();
      }
    }
    StoreModel? categoryStore = await categoryServiceInterface.getCategoryStoreList(categoryID, offset, type);
    // Guard against stale responses from rapid subcategory switching
    if (_subCategoryRequestGeneration != generation) return;

    if (categoryStore != null) {
      if (offset == 1) {
        _categoryStoreList = [];
      }
      _categoryStoreList!.addAll(categoryStore.stores!);
      _restPageSize = categoryStore.totalSize;
      _isLoading = false;
      if (offset == 1 && categoryID != null) {
        _subCategoryStoreCache[cacheKey] = List.from(_categoryStoreList!);
        if (_restPageSize != null) {
          _subCategoryStoreTotalSize[cacheKey] = _restPageSize!;
        }
      }
    }
    update();
  }

  void searchData(String? query, String? categoryID, String type) async {
    if((_isStore && query!.isNotEmpty) || (!_isStore && query!.isNotEmpty /*&& query != _itemResultText*/)) {
      _searchText = query;
      _type = type;
      _isStore ? _searchStoreList = null : _searchItemList = null;
      _isSearching = true;
      update();

      Response response = await categoryServiceInterface.getSearchData(query, categoryID, _isStore, type);
      if (response.statusCode == 200) {
        if (query.isEmpty) {
          _isStore ? _searchStoreList = [] : _searchItemList = [];
        } else {
          if (_isStore) {
            _searchStoreList = [];
            _searchStoreList!.addAll(StoreModel.fromJson(response.body).stores!);
            update();
          } else {
            _searchItemList = [];
            _searchItemList!.addAll(ItemModel.fromJson(response.body).items!);
          }
        }
      }
      update();
    }
  }

  void toggleSearch() {
    _isSearching = !_isSearching;
    _searchItemList = [];
    if(_categoryItemList != null) {
      _searchItemList!.addAll(_categoryItemList!);
    }
    update();
  }

  void showBottomLoader() {
    _isLoading = true;
    update();
  }

  Future<bool> saveInterest(List<int?> interests) async {
    _isLoading = true;
    update();
    bool isSuccess = await categoryServiceInterface.saveUserInterests(interests);
    _isLoading = false;
    update();
    return isSuccess;
  }

  void addInterestSelection(int index) {
    _interestSelectedList![index] = !_interestSelectedList![index];
    update();
  }

  void setRestaurant(bool isRestaurant) {
    _isStore = isRestaurant;
    update();
  }

  void setCategoryList(List<CategoryModel>? categories) {
    _prepareCategoryList(categories);
    _isCategoryLoaded = true;
    update();
  }
}
