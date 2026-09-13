import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suliman/features/favourite/domain/models/wish_list_model.dart';
import 'package:suliman/util/app_constants.dart';

class WishListController extends GetxController implements GetxService {
  final SharedPreferences sharedPreferences;
  WishListController({required this.sharedPreferences});

  List<WishListModel> _wishLists = [];
  List<WishListModel> get wishLists => _wishLists;

  @override
  void onInit() {
    super.onInit();
    getWishLists();
  }

  void getWishLists() {
    String? data = sharedPreferences.getString(AppConstants.cartWishList);
    if (data != null) {
      try {
        Iterable l = json.decode(data);
        _wishLists = List<WishListModel>.from(l.map((model) => WishListModel.fromJson(model)));
      } catch (e) {
        _wishLists = [];
      }
    }
    update();
  }

  Future<void> addWishList(WishListModel wishList) async {
    _wishLists.add(wishList);
    await sharedPreferences.setString(AppConstants.cartWishList, jsonEncode(_wishLists));
    
    if(wishList.reminderDate != null) {
      _scheduleNotification(wishList);
    }
    
    update();
  }

  Future<void> deleteWishList(int index) async {
    _wishLists.removeAt(index);
    await sharedPreferences.setString(AppConstants.cartWishList, jsonEncode(_wishLists));
    update();
  }

  void _scheduleNotification(WishListModel wishList) async {
    // Note: In a real app, timezone-aware scheduling is used.
    // For this implementation, we focus on storage and UI as requested.
  }
}
