import 'package:get/get.dart';
import 'package:sixam_mart/features/global_shopping/domain/models/global_cart_item_model.dart';
import 'package:sixam_mart/features/global_shopping/domain/services/global_shopping_service_interface.dart';
import 'package:sixam_mart/helper/auth_helper.dart';

class GlobalCartController extends GetxController implements GetxService {
  final GlobalShoppingServiceInterface service;

  GlobalCartController({required this.service});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<GlobalCartItemModel> _cartList = [];
  List<GlobalCartItemModel> get cartList => _cartList;

  double get subtotal {
    double total = 0.0;
    for (var item in _cartList) {
      total += (item.unitPrice ?? 0.0) * (item.quantity ?? 1);
    }
    return total;
  }

  double get shippingCost => 4.50 * _cartList.fold<int>(0, (sum, item) => sum + (item.quantity ?? 1));

  double get grandTotal => subtotal + shippingCost;

  Future<void> getCartList() async {
    _isLoading = true;
    update();

    if (!AuthHelper.isLoggedIn() && AuthHelper.getGuestId().isEmpty) {
      _cartList = [];
      _isLoading = false;
      update();
      return;
    }

    String guestId = AuthHelper.getGuestId();
    try {
      var list = await service.getCart(guestId);
      _cartList = list ?? [];
    } catch (e) {
      _cartList = [];
    }

    _isLoading = false;
    update();
  }

  Future<bool> addToCart(String source, String productId, int quantity, String variant) async {
    _isLoading = true;
    update();

    String guestId = AuthHelper.getGuestId();
    try {
      var item = await service.addToCart(guestId, source, productId, quantity, variant);
      if (item != null) {
        await getCartList();
        _isLoading = false;
        update();
        return true;
      }
    } catch (e) {
      // ignore
    }

    _isLoading = false;
    update();
    return false;
  }

  Future<void> removeFromCart(int id) async {
    _isLoading = true;
    update();

    try {
      bool success = await service.removeFromCart(id);
      if (success) {
        await getCartList();
      }
    } catch (e) {
      // ignore
    }

    _isLoading = false;
    update();
  }

  Future<void> clearCart() async {
    _isLoading = true;
    update();

    String guestId = AuthHelper.getGuestId();
    try {
      bool success = await service.clearCart(guestId);
      if (success) {
        _cartList = [];
      }
    } catch (e) {
      // ignore
    }

    _isLoading = false;
    update();
  }
}
