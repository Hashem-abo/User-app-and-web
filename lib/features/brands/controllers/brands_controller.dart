import 'package:get/get.dart';
import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'package:sixam_mart/features/brands/domain/models/brands_model.dart';
import 'package:sixam_mart/features/brands/domain/services/brands_service_interface.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';

import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';

class BrandsController extends GetxController implements GetxService {
  final BrandsServiceInterface brandsServiceInterface;
  BrandsController({required this.brandsServiceInterface});

  List<BrandModel>? _brandList;
  List<BrandModel>? get brandList => _brandList;

  List<Item>? _brandItems;
  List<Item>? get brandItems => _brandItems;

  int _offset = 1;
  int get offset => _offset;

  int? _pageSize;
  int? get pageSize => _pageSize;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final Map<int, List<BrandModel>> _moduleBrandList = {};

  void switchModule(int? moduleId) {
    if (moduleId != null && _moduleBrandList.containsKey(moduleId)) {
      _brandList = _moduleBrandList[moduleId];
    } else {
      _brandList = null;
    }
    update();
  }

  void clearBrandList({bool clearAll = false}) {
    _brandList = null;
    if (clearAll) {
      _moduleBrandList.clear();
    }
    update();
  }

  Future<void> getBrandList({DataSourceEnum dataSource = DataSourceEnum.local}) async {
    int? currentModuleId = Get.find<SplashController>().module?.id;
    if (dataSource == DataSourceEnum.local && currentModuleId != null && _moduleBrandList.containsKey(currentModuleId)) {
      _brandList = _moduleBrandList[currentModuleId];
      update();
      getBrandList(dataSource: DataSourceEnum.client);
      return;
    }
    List<BrandModel>? brandList;
    if(dataSource == DataSourceEnum.local) {
      brandList = await brandsServiceInterface.getBrandList(DataSourceEnum.local);
      _prepareBandList(brandList);
      getBrandList(dataSource: DataSourceEnum.client);
    } else {
      brandList = await brandsServiceInterface.getBrandList(DataSourceEnum.client);
      _prepareBandList(brandList);
    }

  }

  void _prepareBandList(List<BrandModel>? brandList) {
    if (brandList != null) {
      _brandList = [];
      _brandList!.addAll(brandList);
      int? currentModuleId = Get.find<SplashController>().module?.id;
      if (currentModuleId != null) {
        _moduleBrandList[currentModuleId] = _brandList!;
      }
    }
    update();
  }

  Future<void> getBrandItemList(int brandId, int offset, bool notify) async {
    _offset = offset;
    if(offset == 1) {
      _brandItems = null;
      if(notify) {
        update();
      }
    }
    ItemModel? brandItemModel = await brandsServiceInterface.getBrandItemList(brandId: brandId, offset: offset);
    if (brandItemModel != null) {
      if (offset == 1) {
        _brandItems = [];
      }
      _brandItems!.addAll(brandItemModel.items!);
      _pageSize = brandItemModel.totalSize;
      _isLoading = false;
    }
    update();
  }

  void showBottomLoader() {
    _isLoading = true;
    update();
  }

}