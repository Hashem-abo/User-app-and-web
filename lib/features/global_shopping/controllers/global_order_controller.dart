import 'package:get/get.dart';
import 'package:sixam_mart/features/global_shopping/domain/models/global_order_model.dart';
import 'package:sixam_mart/features/global_shopping/domain/services/global_shopping_service_interface.dart';
import 'package:sixam_mart/helper/auth_helper.dart';

class GlobalOrderController extends GetxController implements GetxService {
  final GlobalShoppingServiceInterface service;

  GlobalOrderController({required this.service});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<GlobalOrderModel> _orders = [];
  List<GlobalOrderModel> get orders => _orders;

  GlobalOrderModel? _currentOrder;
  GlobalOrderModel? get currentOrder => _currentOrder;

  Map<String, dynamic>? _trackingData;
  Map<String, dynamic>? get trackingData => _trackingData;

  Future<void> getOrders() async {
    _isLoading = true;
    update();

    try {
      var list = await service.getOrderHistory();
      _orders = list ?? [];
    } catch (e) {
      _orders = [];
    }

    _isLoading = false;
    update();
  }

  Future<GlobalOrderModel?> placeOrder(Map<String, dynamic> checkoutData) async {
    _isLoading = true;
    update();

    String guestId = AuthHelper.getGuestId();
    GlobalOrderModel? order;
    try {
      order = await service.placeOrder(guestId, checkoutData);
    } catch (e) {
      // ignore
    }

    _isLoading = false;
    update();
    return order;
  }

  Future<void> trackOrder(int orderId) async {
    _isLoading = true;
    update();

    try {
      _trackingData = await service.trackOrder(orderId);
    } catch (e) {
      _trackingData = null;
    }

    _isLoading = false;
    update();
  }

  Future<bool> cancelOrder(int orderId) async {
    _isLoading = true;
    update();

    try {
      var cancelled = await service.cancelOrder(orderId);
      if (cancelled != null) {
        await getOrders();
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
}
