import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/global_shopping/domain/repositories/global_shopping_repository_interface.dart';

class GlobalShoppingRepository implements GlobalShoppingRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  GlobalShoppingRepository({required this.apiClient, required this.sharedPreferences});

  Map<String, String> _withGuestHeader(String? guestId) {
    final headers = Map<String, String>.from(apiClient.getHeader());
    if (guestId != null && guestId.isNotEmpty) {
      headers['guest-id'] = guestId;
    }
    return headers;
  }

  @override
  Future<Response> searchProducts(String source, String query, int page) async {
    return await apiClient.getData('/api/v1/global-shopping/search?source=$source&query=${Uri.encodeComponent(query)}&page=$page');
  }

  @override
  Future<Response> searchProductsByImage(String source, String imageUrl) async {
    return await apiClient.postData('/api/v1/global-shopping/search-by-image', {
      'source': source,
      'image_url': imageUrl,
    });
  }

  @override
  Future<Response> getProductDetails(String source, String id) async {
    return await apiClient.getData('/api/v1/global-shopping/product/$source/$id');
  }

  @override
  Future<Response> getCart(String guestId) async {
    return await apiClient.getData('/api/v1/global-shopping/cart', headers: _withGuestHeader(guestId));
  }

  @override
  Future<Response> addToCart(String guestId, String source, String productId, int quantity, String variant) async {
    return await apiClient.postData('/api/v1/global-shopping/cart/add', {
      'source': source,
      'external_product_id': productId,
      'quantity': quantity,
      'variant': variant
    }, headers: _withGuestHeader(guestId));
  }

  @override
  Future<Response> removeFromCart(int cartItemId) async {
    return await apiClient.postData('/api/v1/global-shopping/cart/remove/$cartItemId', {});
  }

  @override
  Future<Response> clearCart(String guestId) async {
    return await apiClient.postData('/api/v1/global-shopping/cart/clear', {}, headers: _withGuestHeader(guestId));
  }

  @override
  Future<Response> placeOrder(String guestId, Map<String, dynamic> data) async {
    return await apiClient.postData('/api/v1/global-shopping/order/place', data, headers: _withGuestHeader(guestId));
  }

  @override
  Future<Response> getOrderHistory() async {
    return await apiClient.getData('/api/v1/global-shopping/order/list');
  }

  @override
  Future<Response> trackOrder(int orderId) async {
    return await apiClient.getData('/api/v1/global-shopping/order/$orderId/track');
  }

  @override
  Future<Response> cancelOrder(int orderId) async {
    return await apiClient.postData('/api/v1/global-shopping/order/$orderId/cancel', {});
  }
}
