import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/util/app_constants.dart';

class ItemHistoryController extends GetxController implements GetxService {
  final SharedPreferences sharedPreferences;
  ItemHistoryController({required this.sharedPreferences});

  List<Item> _recentlyViewedList = [];
  List<Item> get recentlyViewedList => _recentlyViewedList;

  List<Store> _recentlyViewedStoreList = [];
  List<Store> get recentlyViewedStoreList => _recentlyViewedStoreList;

  bool _isHistoryEnabled = true;
  bool get isHistoryEnabled => _isHistoryEnabled;

  @override
  void onInit() {
    super.onInit();
    _isHistoryEnabled = sharedPreferences.getBool(AppConstants.isHistoryEnabled) ?? true;
    getHistoryList();
    getStoreHistoryList();
  }

  void addToHistory(Item item) {
    if(!_isHistoryEnabled) return;
    if (_recentlyViewedList.any((e) => e.id == item.id)) {
      _recentlyViewedList.removeWhere((e) => e.id == item.id);
    }
    _recentlyViewedList.insert(0, item);
    if (_recentlyViewedList.length > 10) {
      _recentlyViewedList.removeLast();
    }
    _saveHistory();
    update();
  }

  void addToStoreHistory(Store store) {
    if(!_isHistoryEnabled) return;
    if (_recentlyViewedStoreList.any((e) => e.id == store.id)) {
      _recentlyViewedStoreList.removeWhere((e) => e.id == store.id);
    }
    _recentlyViewedStoreList.insert(0, store);
    if (_recentlyViewedStoreList.length > 10) {
      _recentlyViewedStoreList.removeLast();
    }
    _saveStoreHistory();
    update();
  }

  void getHistoryList() {
    String? history = sharedPreferences.getString(AppConstants.itemHistory);
    if (history != null && history.isNotEmpty) {
      try {
        List<dynamic> list = jsonDecode(history);
        _recentlyViewedList = list.map((e) => Item.fromJson(e)).toList();
      } catch (e) {
        _recentlyViewedList = [];
      }
    }
    update();
  }

  void getStoreHistoryList() {
    String? history = sharedPreferences.getString(AppConstants.storeHistory);
    if (history != null && history.isNotEmpty) {
      try {
        List<dynamic> list = jsonDecode(history);
        _recentlyViewedStoreList = list.map((e) => Store.fromJson(e)).toList();
      } catch (e) {
        _recentlyViewedStoreList = [];
      }
    }
    update();
  }

  void _saveHistory() {
    List<Map<String, dynamic>> list = _recentlyViewedList.map((e) => e.toJson()).toList();
    sharedPreferences.setString(AppConstants.itemHistory, jsonEncode(list));
  }

  void _saveStoreHistory() {
    List<Map<String, dynamic>> list = _recentlyViewedStoreList.map((e) => e.toJson()).toList();
    sharedPreferences.setString(AppConstants.storeHistory, jsonEncode(list));
  }

  void clearHistory() {
    _recentlyViewedList = [];
    _recentlyViewedStoreList = [];
    sharedPreferences.remove(AppConstants.itemHistory);
    sharedPreferences.remove(AppConstants.storeHistory);
    update();
  }

  /// Removes a single item from the local SharedPreferences history.
  /// Server-side "seen" tracking is NOT touched.
  void removeItemFromHistory(int itemId) {
    _recentlyViewedList.removeWhere((e) => e.id == itemId);
    _saveHistory();
    update();
  }

  /// Removes a single store from the local SharedPreferences history.
  /// Server-side "seen" tracking is NOT touched.
  void removeStoreFromHistory(int storeId) {
    _recentlyViewedStoreList.removeWhere((e) => e.id == storeId);
    _saveStoreHistory();
    update();
  }

  void toggleHistory() {
    _isHistoryEnabled = !_isHistoryEnabled;
    sharedPreferences.setBool(AppConstants.isHistoryEnabled, _isHistoryEnabled);
    if(!_isHistoryEnabled) {
      clearHistory();
    }
    update();
  }
}
