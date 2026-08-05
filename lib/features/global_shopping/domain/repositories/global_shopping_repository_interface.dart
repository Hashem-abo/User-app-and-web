import 'package:get/get_connect/http/src/response/response.dart';

abstract class GlobalShoppingRepositoryInterface {
  Future<Response> searchProducts(String source, String query, int page);
  Future<Response> searchProductsByImage(String source, String imageUrl);
  Future<Response> getProductDetails(String source, String id);
  Future<Response> getCart(String guestId);
  Future<Response> addToCart(String guestId, String source, String productId, int quantity, String variant);
  Future<Response> removeFromCart(int cartItemId);
  Future<Response> clearCart(String guestId);
  Future<Response> placeOrder(String guestId, Map<String, dynamic> data);
  Future<Response> getOrderHistory();
  Future<Response> trackOrder(int orderId);
  Future<Response> cancelOrder(int orderId);
}
