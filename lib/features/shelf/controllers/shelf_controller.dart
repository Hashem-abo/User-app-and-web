import 'package:get/get.dart';
import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'package:sixam_mart/features/shelf/domain/models/shelf_model.dart';
import 'package:sixam_mart/features/shelf/domain/services/shelf_service_interface.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';

class ShelfController extends GetxController implements GetxService {
  final ShelfServiceInterface shelfServiceInterface;
  ShelfController({required this.shelfServiceInterface});

  List<ShelfModel>? _shelfList;
  List<ShelfModel>? get shelfList => _shelfList;

  int? _pageSize;
  int? get pageSize => _pageSize;

  int _offset = 1;
  int get offset => _offset;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final Map<int, List<ShelfModel>> _moduleShelfList = {};
  final Map<int, int> _modulePageSize = {};
  final Map<int, int> _moduleOffset = {};

  void switchModule(int? moduleId) {
    if (moduleId != null && _moduleShelfList.containsKey(moduleId)) {
      _shelfList = _moduleShelfList[moduleId];
      _pageSize = _modulePageSize[moduleId];
      _offset = _moduleOffset[moduleId] ?? 1;
    } else {
      _shelfList = null;
      _pageSize = null;
      _offset = 1;
    }
    _isLoading = false;
    update();
  }

  void clearShelfList({bool clearAllModuleCache = false}) {
    _shelfList = null;
    _pageSize = null;
    _offset = 1;
    _isLoading = false;
    if (clearAllModuleCache) {
      _moduleShelfList.clear();
      _modulePageSize.clear();
      _moduleOffset.clear();
    }
    update();
  }

  Future<void> getShelfList(bool reload, {DataSourceEnum source = DataSourceEnum.client}) async {
    int? currentModuleId = Get.find<SplashController>().module?.id;

    if (reload) {
      _offset = 1;
      _shelfList = null;
      update();
    } else if (currentModuleId != null && _moduleShelfList.containsKey(currentModuleId)) {
      _shelfList = _moduleShelfList[currentModuleId];
      _pageSize = _modulePageSize[currentModuleId];
      _offset = _moduleOffset[currentModuleId] ?? 1;
      update();
      return;
    } else {
      // If not in cache and not reloading, clear the list to avoid showing old module's data
      _shelfList = null;
      _offset = 1;
      _pageSize = null;
    }
    
    if (_shelfList == null || (_pageSize != null && _shelfList!.length < _pageSize!)) {
      _isLoading = true;
      update();
      ShelfDataModel? shelfData = await shelfServiceInterface.getShelfList(source, offset: _offset);
      if (shelfData != null && shelfData.shelves != null) {
        if (_offset == 1) {
          _shelfList = [];
        }
        _shelfList!.addAll(shelfData.shelves!);
        _pageSize = shelfData.totalSize;
        _offset = _offset + 1;
        
        if (currentModuleId != null) {
          _moduleShelfList[currentModuleId] = _shelfList!;
          _modulePageSize[currentModuleId] = _pageSize!;
          _moduleOffset[currentModuleId] = _offset;
        }
      }
      _isLoading = false;
      update();
    }
  }

  void setShelfList(List<ShelfModel>? shelves) {
    if (shelves != null) {
      _shelfList = [];
      _shelfList!.addAll(shelves);
      _pageSize = shelves.length;
      _offset = 2;
      int? currentModuleId = Get.find<SplashController>().module?.id;
      if (currentModuleId != null) {
        _moduleShelfList[currentModuleId] = _shelfList!;
        _modulePageSize[currentModuleId] = _pageSize!;
        _moduleOffset[currentModuleId] = _offset;
      }
      update();
    }
  }
}
