import 'package:get/get.dart';
import 'package:sixam_mart/features/global_shopping/domain/models/global_product_model.dart';
import 'package:sixam_mart/features/global_shopping/domain/models/global_cart_item_model.dart';
import 'package:sixam_mart/features/global_shopping/domain/models/global_order_model.dart';
import 'package:sixam_mart/features/global_shopping/domain/repositories/global_shopping_repository_interface.dart';
import 'package:sixam_mart/features/global_shopping/domain/services/global_shopping_service_interface.dart';

class GlobalShoppingService implements GlobalShoppingServiceInterface {
  final GlobalShoppingRepositoryInterface repo;

  GlobalShoppingService({required this.repo});

  @override
  Future<List<GlobalProductModel>?> searchProducts(String source, String query, int page) async {
    Response response = await repo.searchProducts(source, query, page);
    if (response.statusCode == 200 && response.body != null) {
      return (response.body as List).map((p) => GlobalProductModel.fromJson(p)).toList();
    }
    return null;
  }

  @override
  Future<List<GlobalProductModel>?> searchProductsByImage(String source, String imageUrl) async {
    Response response = await repo.searchProductsByImage(source, imageUrl);
    if (response.statusCode == 200 && response.body != null) {
      return (response.body as List).map((p) => GlobalProductModel.fromJson(p)).toList();
    }
    return null;
  }

  @override
  Future<GlobalProductModel?> getProductDetails(String source, String id) async {
    Response response = await repo.getProductDetails(source, id);
    if (response.statusCode == 200 && response.body != null) {
      return GlobalProductModel.fromJson(response.body);
    }
    return null;
  }

  @override
  Future<List<GlobalCartItemModel>?> getCart(String guestId) async {
    Response response = await repo.getCart(guestId);
    if (response.statusCode == 200 && response.body != null) {
      return (response.body as List).map((c) => GlobalCartItemModel.fromJson(c)).toList();
    }
    return null;
  }

  @override
  Future<GlobalCartItemModel?> addToCart(String guestId, String source, String productId, int quantity, String variant) async {
    Response response = await repo.addToCart(guestId, source, productId, quantity, variant);
    if (response.statusCode == 201 && response.body != null) {
      return GlobalCartItemModel.fromJson(response.body);
    }
    return null;
  }

  @override
  Future<bool> removeFromCart(int cartItemId) async {
    Response response = await repo.removeFromCart(cartItemId);
    return response.statusCode == 200;
  }

  @override
  Future<bool> clearCart(String guestId) async {
    Response response = await repo.clearCart(guestId);
    return response.statusCode == 200;
  }

  @override
  Future<GlobalOrderModel?> placeOrder(String guestId, Map<String, dynamic> data) async {
    Response response = await repo.placeOrder(guestId, data);
    if (response.statusCode == 201 && response.body != null) {
      return GlobalOrderModel.fromJson(response.body);
    }
    return null;
  }

  @override
  Future<List<GlobalOrderModel>?> getOrderHistory() async {
    Response response = await repo.getOrderHistory();
    if (response.statusCode == 200 && response.body != null) {
      return (response.body as List).map((o) => GlobalOrderModel.fromJson(o)).toList();
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>?> trackOrder(int orderId) async {
    Response response = await repo.trackOrder(orderId);
    if (response.statusCode == 200 && response.body != null) {
      return Map<String, dynamic>.from(response.body);
    }
    return null;
  }

  @override
  Future<GlobalOrderModel?> cancelOrder(int orderId) async {
    Response response = await repo.cancelOrder(orderId);
    if (response.statusCode == 200 && response.body != null) {
      return GlobalOrderModel.fromJson(response.body);
    }
    return null;
  }
}
