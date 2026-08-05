import 'package:sixam_mart/features/global_shopping/domain/models/global_product_model.dart';
import 'package:sixam_mart/features/global_shopping/domain/models/global_cart_item_model.dart';
import 'package:sixam_mart/features/global_shopping/domain/models/global_order_model.dart';

abstract class GlobalShoppingServiceInterface {
  Future<List<GlobalProductModel>?> searchProducts(String source, String query, int page);
  Future<List<GlobalProductModel>?> searchProductsByImage(String source, String imageUrl);
  Future<GlobalProductModel?> getProductDetails(String source, String id);
  Future<List<GlobalCartItemModel>?> getCart(String guestId);
  Future<GlobalCartItemModel?> addToCart(String guestId, String source, String productId, int quantity, String variant);
  Future<bool> removeFromCart(int cartItemId);
  Future<bool> clearCart(String guestId);
  Future<GlobalOrderModel?> placeOrder(String guestId, Map<String, dynamic> data);
  Future<List<GlobalOrderModel>?> getOrderHistory();
  Future<Map<String, dynamic>?> trackOrder(int orderId);
  Future<GlobalOrderModel?> cancelOrder(int orderId);
}
