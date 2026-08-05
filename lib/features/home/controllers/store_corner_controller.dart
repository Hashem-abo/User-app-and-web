import 'package:get/get.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/home/domain/models/store_corner_model.dart';
import 'package:sixam_mart/features/home/domain/repositories/store_corner_repository.dart';

class StoreCornerController extends GetxController implements GetxService {
  final StoreCornerRepositoryInterface storeCornerRepositoryInterface;
  StoreCornerController({required this.storeCornerRepositoryInterface});

  List<StoreCornerModel>? _storeCornerList;
  List<StoreCornerModel>? get storeCornerList => _storeCornerList;

  int? _pageSize;
  int? get pageSize => _pageSize;

  int _offset = 1;
  int get offset => _offset;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final Map<int, List<StoreCornerModel>> _moduleStoreCornerList = {};
  final Map<int, int> _modulePageSize = {};
  final Map<int, int> _moduleOffset = {};

  Future<void> getStoreCornerList(bool reload) async {
    int? currentModuleId = Get.find<SplashController>().module?.id;
    if (reload) {
      _offset = 1;
      _storeCornerList = null;
      update();
    } else if (currentModuleId != null && _moduleStoreCornerList.containsKey(currentModuleId)) {
      _storeCornerList = _moduleStoreCornerList[currentModuleId];
      _pageSize = _modulePageSize[currentModuleId];
      _offset = _moduleOffset[currentModuleId] ?? 1;
      update();
      return;
    } else {
      _storeCornerList = null;
      _offset = 1;
      _pageSize = null;
    }
    if (_storeCornerList == null || (_pageSize != null && _storeCornerList!.length < _pageSize!)) {
      _isLoading = true;
      update();
      StoreCornerDataModel? storeCornerData = await storeCornerRepositoryInterface.getStoreCorners(offset: _offset);
      if (storeCornerData != null && storeCornerData.storeCorners != null) {
        if (_offset == 1) {
          _storeCornerList = [];
        }
        _storeCornerList!.addAll(storeCornerData.storeCorners!);
        _pageSize = storeCornerData.totalSize;
        _offset = _offset + 1;
        if (currentModuleId != null) {
          _moduleStoreCornerList[currentModuleId] = _storeCornerList!;
          _modulePageSize[currentModuleId] = _pageSize!;
          _moduleOffset[currentModuleId] = _offset;
        }
      }
      _isLoading = false;
      update();
    }
  }

  void setStoreCornerList(StoreCornerDataModel? storeCornerData) {
    if (storeCornerData != null && storeCornerData.storeCorners != null) {
      _storeCornerList = [];
      _storeCornerList!.addAll(storeCornerData.storeCorners!);
      _pageSize = storeCornerData.totalSize;
      _offset = 2;
      int? currentModuleId = Get.find<SplashController>().module?.id;
      if (currentModuleId != null) {
        _moduleStoreCornerList[currentModuleId] = _storeCornerList!;
        _modulePageSize[currentModuleId] = _pageSize!;
        _moduleOffset[currentModuleId] = _offset;
      }
      update();
    }
  }
}
