import 'dart:async';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'package:sixam_mart/features/flash_sale/domain/models/flash_sale_model.dart';
import 'package:sixam_mart/features/flash_sale/domain/models/product_flash_sale.dart';
import 'package:sixam_mart/features/flash_sale/domain/services/flash_sale_service_interface.dart';

import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/helper/address_helper.dart';

import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';

class FlashSaleController extends GetxController implements GetxService {
  final FlashSaleServiceInterface flashSaleServiceInterface;
  FlashSaleController({required this.flashSaleServiceInterface});

  Duration? _duration;
  Duration? get duration => _duration;
  
  Timer? _timer;
  
  FlashSaleModel? _flashSaleModel;
  FlashSaleModel? get flashSaleModel {
    if (_flashSaleModel == null || _flashSaleModel!.activeProducts == null) return _flashSaleModel;
    AddressModel? address = AddressHelper.getUserAddressFromSharedPref();
    int? activeZoneId = address?.zoneId;
    bool moduleStock = Get.find<SplashController>().configModel?.moduleConfig?.module?.stock ?? false;

    List<ActiveProducts> filteredProducts = _flashSaleModel!.activeProducts!.where((p) {
      if (p.item == null) return true;
      if (activeZoneId == null || activeZoneId == 0) return true;
      int? itemZoneId = p.item!.zoneId;
      if ((itemZoneId == null || itemZoneId == 0) && p.item!.storeDetails != null) {
        itemZoneId = p.item!.storeDetails!['zone_id'];
      }
      if (itemZoneId == null || itemZoneId == 0) return true;
      return itemZoneId == activeZoneId || (address != null && address.zoneIds != null && address.zoneIds!.contains(itemZoneId));
    }).toList();

    return FlashSaleModel(
      id: _flashSaleModel!.id,
      moduleId: _flashSaleModel!.moduleId,
      title: _flashSaleModel!.title,
      isPublish: _flashSaleModel!.isPublish,
      adminDiscountPercentage: _flashSaleModel!.adminDiscountPercentage,
      vendorDiscountPercentage: _flashSaleModel!.vendorDiscountPercentage,
      startDate: _flashSaleModel!.startDate,
      endDate: _flashSaleModel!.endDate,
      createdAt: _flashSaleModel!.createdAt,
      updatedAt: _flashSaleModel!.updatedAt,
      activeProducts: filteredProducts,
      translations: _flashSaleModel!.translations,
    );
  }
  
  int _pageIndex = 1;
  int get pageIndex => _pageIndex;
  
  ProductFlashSale? _productFlashSale;
  ProductFlashSale? get productFlashSale {
    if (_productFlashSale == null || _productFlashSale!.products == null) return _productFlashSale;
    AddressModel? address = AddressHelper.getUserAddressFromSharedPref();
    int? activeZoneId = address?.zoneId;
    if (activeZoneId == null || activeZoneId == 0) return _productFlashSale;

    List<Products> filteredProducts = _productFlashSale!.products!.where((p) {
      if (p.item == null) return true;
      if (activeZoneId == null || activeZoneId == 0) return true;
      int? itemZoneId = p.item!.zoneId;
      if ((itemZoneId == null || itemZoneId == 0) && p.item!.storeDetails != null) {
        itemZoneId = p.item!.storeDetails!['zone_id'];
      }
      if (itemZoneId == null || itemZoneId == 0) return true;
      return itemZoneId == activeZoneId || (address != null && address.zoneIds != null && address.zoneIds!.contains(itemZoneId));
    }).toList();

    return ProductFlashSale(
      flashSale: _productFlashSale!.flashSale,
      products: filteredProducts,
      totalSize: filteredProducts.length,
      offset: _productFlashSale!.offset,
    );
  }

  void setPageIndex(int index) {
    _pageIndex = index;
    update();
  }

  final Map<int, FlashSaleModel> _moduleFlashSaleModel = {};

  void switchModule(int? moduleId) {
    if (moduleId != null && _moduleFlashSaleModel.containsKey(moduleId)) {
      _flashSaleModel = _moduleFlashSaleModel[moduleId];
    } else {
      _flashSaleModel = null;
    }
    update();
  }

  void setEmptyFlashSale({bool fromModule = false, bool clearAll = false}) {
    if(fromModule) {
      _flashSaleModel = null;
      if (clearAll) {
        _moduleFlashSaleModel.clear();
      }
      update();
    }
  }

  Future<void> getFlashSale(bool reload, bool notify, {DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false}) async {
    int? currentModuleId = Get.find<SplashController>().module?.id;
    if(!reload && !fromRecall && currentModuleId != null && _moduleFlashSaleModel.containsKey(currentModuleId)) {
      _flashSaleModel = _moduleFlashSaleModel[currentModuleId];
      if(notify) update();
      return;
    }
    if(_flashSaleModel == null || reload && !fromRecall) {
      _flashSaleModel = null;
    }
    if(notify) {
      update();
    }
    if(_flashSaleModel == null || reload || fromRecall) {
      FlashSaleModel? flashSaleModel;
      if(dataSource == DataSourceEnum.local) {
        flashSaleModel = await flashSaleServiceInterface.getFlashSale(DataSourceEnum.local);
        _prepareFlashModel(flashSaleModel);
        getFlashSale(false, notify, dataSource: DataSourceEnum.client, fromRecall: true);
      } else {
        flashSaleModel = await flashSaleServiceInterface.getFlashSale(DataSourceEnum.client);
        _prepareFlashModel(flashSaleModel);
      }

    }
  }

  void _prepareFlashModel(FlashSaleModel? flashSaleModel) {
    if (flashSaleModel != null) {
      _flashSaleModel = flashSaleModel;
      int? currentModuleId = Get.find<SplashController>().module?.id;
      if (currentModuleId != null) {
        _moduleFlashSaleModel[currentModuleId] = flashSaleModel;
      }
      if(_flashSaleModel?.endDate != null) {
        DateTime endTime = DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').parse(_flashSaleModel!.endDate!, true).toLocal();
        _duration = endTime.difference(DateTime.now());
        _timer?.cancel();
        _timer = null;
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          _duration = _duration! - const Duration(seconds: 1);
          update();
        });
      }
    }
    update();
  }

  Future<void> getFlashSaleWithId(int offset, bool reload, int id) async {
    if(reload) {
      _productFlashSale = null;
      update();
    }
    ProductFlashSale? productFlashSale = await flashSaleServiceInterface.getFlashSaleWithId(id, offset);
    if (productFlashSale != null) {

      if(offset == 1){
        _productFlashSale = productFlashSale;
      } else {
        _productFlashSale!.totalSize = productFlashSale.totalSize;
        _productFlashSale!.offset = productFlashSale.offset;
        _productFlashSale!.flashSale = productFlashSale.flashSale;
        _productFlashSale!.products!.addAll(productFlashSale.products!);
      }

      if(_productFlashSale!.flashSale!.endDate != null) {
        DateTime endTime = DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').parse(_productFlashSale!.flashSale!.endDate!, true).toLocal();
        _duration = endTime.difference(DateTime.now());
        _timer?.cancel();
        _timer = null;
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          _duration = _duration! - const Duration(seconds: 1);
          update();
        });
      }
      update();
    }
  }
  
}