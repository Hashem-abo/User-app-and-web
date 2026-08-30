import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart/common/models/response_model.dart';
import 'package:sixam_mart/features/order/domain/models/order_cancellation_body.dart';
import 'package:sixam_mart/features/order/domain/models/order_details_model.dart';
import 'package:sixam_mart/features/order/domain/models/order_model.dart';
import 'package:sixam_mart/features/order/domain/services/order_service_interface.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/cart/domain/models/cart_model.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/module_helper.dart';
import 'package:sixam_mart/features/checkout/domain/models/place_order_body_model.dart';

import 'package:sixam_mart/features/order/domain/models/monthly_order_model.dart';

class OrderController extends GetxController implements GetxService {
  final OrderServiceInterface orderServiceInterface;

  OrderController({required this.orderServiceInterface});

  List<MonthlyOrder>? _monthlyOrders;
  List<MonthlyOrder>? get monthlyOrders => _monthlyOrders;

  PaginatedOrderModel? _runningOrderModel;
  PaginatedOrderModel? get runningOrderModel => _runningOrderModel;

  PaginatedOrderModel? _historyOrderModel;
  PaginatedOrderModel? get historyOrderModel => _historyOrderModel;

  List<OrderDetailsModel>? _orderDetails;
  List<OrderDetailsModel>? get orderDetails => _orderDetails;

  OrderModel? _trackModel;
  OrderModel? get trackModel => _trackModel;

  void clearPrevOrderData({bool notify = false}) {
    _trackModel = null;
    _orderDetails = null;
    if(notify) {
      update();
    }
  }

  ResponseModel? _responseModel;
  ResponseModel? get responseModel => _responseModel;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isReordering = false;
  bool get isReordering => _isReordering;

  bool _showCancelled = false;
  bool get showCancelled => _showCancelled;

  bool _showBottomSheet = true;
  bool get showBottomSheet => _showBottomSheet;

  bool _showOneOrder = true;
  bool get showOneOrder => _showOneOrder;

  List<String?>? _refundReasons;
  List<String?>? get refundReasons => _refundReasons;

  int _selectedReasonIndex = -1;
  int get selectedReasonIndex => _selectedReasonIndex;

  XFile? _refundImage;
  XFile? get refundImage => _refundImage;

  String? _cancelReason;
  String? get cancelReason => _cancelReason;

  List<CancellationData>? _orderCancelReasons;
  List<CancellationData>? get orderCancelReasons => _orderCancelReasons;

  bool _isExpanded = false;
  bool get isExpanded => _isExpanded;

  List<String?>? _supportReasons;
  List<String?>? get supportReasons => _supportReasons;

  final List<String> _selectedParcelCancelReason = [];
  List<String>? get selectedParcelCancelReason => _selectedParcelCancelReason;

  void expandedUpdate(bool status){
    _isExpanded = status;
    update();
  }

  void setOrderCancelReason(String? reason){
    _cancelReason = reason;
    update();
  }

  void selectReason(int index, {bool isUpdate = true}){
    if(_selectedReasonIndex == index) {
      _selectedReasonIndex = -1;
    }else {
      _selectedReasonIndex = index;
    }

    if(isUpdate) {
      update();
    }
  }

  void showOrders(){
    _showOneOrder = !_showOneOrder;
    update();
  }

  void showRunningOrders({bool canUpdate = true}){
    _showBottomSheet = !_showBottomSheet;
    if(canUpdate) {
      update();
    }
  }

  void pickRefundImage(bool isRemove) async {
    if(isRemove) {
      _refundImage = null;
    }else {
      _refundImage = await ImagePicker().pickImage(source: ImageSource.gallery);
      update();
    }
  }

  Future<void> getOrderCancelReasons()async {
    _orderCancelReasons = null;
    _orderCancelReasons = await orderServiceInterface.getCancelReasons();
    update();
  }

  Future<void> getRefundReasons() async {
    _selectedReasonIndex = 0;
    _refundReasons = null;
    _refundReasons = await orderServiceInterface.getRefundReasons();
    update();
  }

  Future<void> submitRefundRequest(String note, String? orderId)async {
    _isLoading = true;
    update();
    await orderServiceInterface.submitRefundRequest(_selectedReasonIndex, _refundReasons, note, orderId, _refundImage);
    _isLoading = false;
    update();
  }

  Future<void> getRunningOrders(int offset, {bool isUpdate = false, bool fromDashboard = false}) async {
    if(offset == 1) {
      _runningOrderModel = null;
      if(isUpdate) {
        update();
      }
    }
    PaginatedOrderModel? orderModel = await orderServiceInterface.getRunningOrderList(offset, fromDashboard);
    if (orderModel != null) {
      if (offset == 1) {
        _runningOrderModel = orderModel;
      }else {
        _runningOrderModel!.orders!.addAll(orderModel.orders!);
        _runningOrderModel!.offset = orderModel.offset;
        _runningOrderModel!.totalSize = orderModel.totalSize;
      }
      update();
    }
  }

  Future<void> getHistoryOrders(int offset, {bool isUpdate = false}) async {
    if(offset == 1) {
      _historyOrderModel = null;
      if(isUpdate) {
        update();
      }
    }
    PaginatedOrderModel? orderModel = await orderServiceInterface.getHistoryOrderList(offset);
    if (orderModel != null) {
      if (offset == 1) {
        _historyOrderModel = orderModel;
      }else {
        _historyOrderModel!.orders!.addAll(orderModel.orders!);
        _historyOrderModel!.offset = orderModel.offset;
        _historyOrderModel!.totalSize = orderModel.totalSize;
      }
      update();
    }
  }

  Future<void> getSupportReasons() async {
    _supportReasons = await orderServiceInterface.getSupportReasonsList();
    update();
  }

  Future<List<OrderDetailsModel>?> getOrderDetails(String orderID) async {
    _orderDetails = null;
    _isLoading = true;
    _showCancelled = false;

    if(_trackModel == null || (_trackModel!.orderType != 'parcel' && !_trackModel!.prescriptionOrder!)) {
      List<OrderDetailsModel>? detailsList = await orderServiceInterface.getOrderDetails(orderID, AuthHelper.isLoggedIn() ? null : AuthHelper.getGuestId());
      _isLoading = false;
      if (detailsList != null) {
        _orderDetails = [];
        _orderDetails!.addAll(detailsList);
      }
    }else {
      _isLoading = false;
      _orderDetails = [];
    }
    update();
    return _orderDetails;
  }

  Future<ResponseModel?> trackOrder(String? orderID, OrderModel? orderModel, bool fromTracking,
      {String? contactNumber, bool? fromGuestInput = false}) async {
    _trackModel = null;
    _responseModel = null;
    if(!fromTracking) {
      _orderDetails = null;
    }
    _showCancelled = false;
    if(orderModel == null) {
      _isLoading = true;
      Response response = await orderServiceInterface.trackOrder(
        orderID, AuthHelper.isLoggedIn() ? null : AuthHelper.getGuestId(),
        contactNumber: contactNumber,
      );
      if (response.statusCode == 200) {
        _trackModel = OrderModel.fromJson(response.body);
        _responseModel = ResponseModel(true, response.body.toString());
      } else {
        _responseModel = ResponseModel(false, response.statusText);
      }
      _isLoading = false;
      update();
    } else {
      _trackModel = orderModel;
      _responseModel = ResponseModel(true, 'Successful');
    }
    return _responseModel;
  }

  Future<ResponseModel?> timerTrackOrder(String orderID, {String? contactNumber}) async {
    _showCancelled = false;

    Response response = await orderServiceInterface.trackOrder(
      orderID, AuthHelper.isLoggedIn() ? null : AuthHelper.getGuestId(),
      contactNumber: contactNumber,
    );
    if (response.statusCode == 200) {
      _trackModel = OrderModel.fromJson(response.body);
      _responseModel = ResponseModel(true, response.body.toString());
    } else {
      _responseModel = ResponseModel(false, response.statusText);
    }
    update();

    return _responseModel;
  }

  Future<bool> cancelOrder({required int orderID, String? reason, String? guestId, required bool isParcel, List<String>? reasons, String? comment}) async {
    _isLoading = true;
    update();
    bool success = await orderServiceInterface.cancelOrder(orderID: orderID.toString(), reason: reason, guestId: guestId, isParcel: isParcel, reasons: reasons, comment: comment);
    _isLoading = false;
    Get.back();
    if (success) {
      OrderModel? orderModel = orderServiceInterface.prepareOrderModel(_runningOrderModel, orderID);
      if(_runningOrderModel != null) {
        _runningOrderModel!.orders!.remove(orderModel);
      }
      _showCancelled = true;
    }
    update();
    return success;
  }

  Future<bool> switchToCOD(String? orderID, {String? guestId}) async {
    _isLoading = true;
    update();
    bool isSuccess = await orderServiceInterface.switchToCOD(orderID, guestId: guestId);
    _isLoading = false;
    update();
    return isSuccess;
  }

  void paymentRedirect({required String url, required bool canRedirect, required String? contactNumber,
    required Function onClose, required final String? addFundUrl, required final String? subscriptionUrl,
    required final String orderID, int? storeId, required bool createAccount, required String guestId}) {

    orderServiceInterface.paymentRedirect(
      url: url, canRedirect: canRedirect, contactNumber: contactNumber, onClose: onClose,
      addFundUrl: addFundUrl, subscriptionUrl: subscriptionUrl, orderID: orderID, storeId: storeId,
      createAccount: createAccount, guestId: guestId,
    );
  }

  void toggleParcelCancelReason(String reason, bool isSelected) {
    if (isSelected) {
      if (!_selectedParcelCancelReason.contains(reason)) {
        _selectedParcelCancelReason.add(reason);
      }
    } else {
      _selectedParcelCancelReason.remove(reason);
    }
    update();
  }

  bool isReasonSelected(String reason) {
    return _selectedParcelCancelReason.contains(reason);
  }

  void clearSelectedParcelCancelReason() {
    _selectedParcelCancelReason.clear();
  }

  Future<bool> submitParcelReturn({required int orderId, required int returnOtp, String? contactNumber}) async {
    bool isSuccess = await orderServiceInterface.submitParcelReturn(orderId: orderId, orderStatus: 'returned', returnOtp: returnOtp);
    if(isSuccess) {
      await getRunningOrders(1, isUpdate: true);
    }
    return isSuccess;
  }

  void reorder(int orderId, {OrderModel? order}) async {
    if (_isReordering) return;
    _isReordering = true;
    _isLoading = true;
    update();

    try {
      OrderModel? orderModel = order;
      if (orderModel == null) {
        orderModel = orderServiceInterface.prepareOrderModel(_runningOrderModel, orderId);
        orderModel ??= orderServiceInterface.prepareOrderModel(_historyOrderModel, orderId);
      }

      if (orderModel != null && orderModel.orderType == 'parcel') {
        if (orderModel.parcelCategory != null) {
          SplashController splashController = Get.find<SplashController>();
          int index = splashController.moduleList?.indexWhere((m) => m.moduleType == 'parcel') ?? -1;
          if (index != -1) {
            await splashController.switchModule(index, true);
          }
          Get.toNamed(RouteHelper.getParcelLocationRoute(
            orderModel.parcelCategory!,
            pickupAddress: orderModel.deliveryAddress,
            destinationAddress: orderModel.receiverDetails,
          ));
        }
        return;
      }

      List<OrderDetailsModel>? details = await orderServiceInterface.getOrderDetails(orderId.toString(), AuthHelper.isLoggedIn() ? null : AuthHelper.getGuestId());

      if (details != null && details.isNotEmpty) {
        CartController cartController = Get.find<CartController>();
        if (details[0].itemDetails!.moduleId != null) {
          int currentModuleId = Get.find<SplashController>().module?.id ?? ModuleHelper.getCacheModule()?.id ?? 0;
          if (currentModuleId != details[0].itemDetails!.moduleId) {
            await cartController.forcefullySetModule(details[0].itemDetails!.moduleId!);
            await cartController.getCartDataOnline();
          }
        }
        Set<int> reorderStoreIds = {};
        if (orderModel?.store != null && orderModel!.store!.id != null) {
          reorderStoreIds.add(orderModel.store!.id!);
        }
        for (var d in details) {
          if (d.itemDetails != null) {
            if (d.itemDetails!.storeId != null) {
              reorderStoreIds.add(d.itemDetails!.storeId!);
            }
            if (d.itemDetails!.storeDetails != null && d.itemDetails!.storeDetails!['id'] != null) {
              int? id = int.tryParse(d.itemDetails!.storeDetails!['id'].toString());
              if (id != null) reorderStoreIds.add(id);
            }
          }
        }

        if (reorderStoreIds.isNotEmpty) {
          await cartController.clearStoreCartItems(reorderStoreIds);
        }

        for (var detail in details) {
           if(detail.itemDetails != null) {
              List<List<bool?>> selectedFoodVariations = [];
              if (detail.itemDetails!.foodVariations != null && detail.itemDetails!.foodVariations!.isNotEmpty) {
                for (int i = 0; i < detail.itemDetails!.foodVariations!.length; i++) {
                  selectedFoodVariations.add([]);
                  for (int j = 0; j < detail.itemDetails!.foodVariations![i].variationValues!.length; j++) {
                    bool isSelected = false;
                    if (detail.foodVariation != null) {
                       var group = detail.foodVariation!.firstWhereOrNull((element) => element.name == detail.itemDetails!.foodVariations![i].name);
                       if (group != null && group.variationValues != null) {
                          var val = group.variationValues!.firstWhereOrNull((v) => v.level == detail.itemDetails!.foodVariations![i].variationValues![j].level);
                          if (val != null) isSelected = true;
                       }
                    }
                    selectedFoodVariations[i].add(isSelected);
                  }
                }
              }

              CartModel cartModel = CartModel(
                  id: null,
                  price: detail.price,
                  discountedPrice: detail.price ?? 0,
                  variation: detail.variation ?? [],
                  foodVariations: selectedFoodVariations,
                  discountAmount: 0,
                  quantity: detail.quantity,
                  addOnIds: [], 
                  addOns: [], 
                  isCampaign: false,
                  stock: detail.itemDetails!.stock,
                  item: detail.itemDetails,
                  quantityLimit: detail.itemDetails!.quantityLimit,
                  note: detail.note,
              );
              cartController.addToCart(cartModel, null);
              if(AuthHelper.isLoggedIn() || AuthHelper.isGuestLoggedIn()) {
                List<OrderVariation> variations = [];
                if(Get.find<SplashController>().getModuleConfig(detail.itemDetails!.moduleType).newVariation!) {
                  for(int i=0; i<detail.itemDetails!.foodVariations!.length; i++) {
                    if(selectedFoodVariations[i].contains(true)) {
                      variations.add(OrderVariation(name: detail.itemDetails!.foodVariations![i].name, values: OrderVariationValue(label: [])));
                      for(int j=0; j<detail.itemDetails!.foodVariations![i].variationValues!.length; j++) {
                        if(selectedFoodVariations[i][j]!) {
                          variations[variations.length-1].values!.label!.add(detail.itemDetails!.foodVariations![i].variationValues![j].level);
                        }
                      }
                    }
                  }
                }
                OnlineCart onlineCart = OnlineCart(
                    cartId: null, itemId: detail.itemDetails!.id, itemCampaignId: null,
                    price: detail.price.toString(), variant: '', variation: detail.variation ?? [],
                    variations: Get.find<SplashController>().getModuleConfig(detail.itemDetails!.moduleType).newVariation! ? variations : null,
                    quantity: detail.quantity, addOnIds: [], addOns: [], addOnQtys: [], model: 'Item',
                    note: detail.note,
                );
                await cartController.cartServiceInterface.addToCartOnline(onlineCart);
              }
           }
        }
        
        cartController.isPreventCartOverwritten = false;
        if(AuthHelper.isLoggedIn() || AuthHelper.isGuestLoggedIn()) {
           await cartController.getCartDataOnline();
        }
        Get.toNamed(RouteHelper.getCartRoute());
      }
    } finally {
      _isReordering = false;
      _isLoading = false;
      update();
    }
  }

  Future<void> getMonthlyOrderList({bool reload = true, String? moduleType, bool notify = true}) async {
    if(reload) {
      _monthlyOrders = null;
      if(notify) update();
    }
    final MonthlyOrderModel? result = await orderServiceInterface.getMonthlyOrderList(offset: 1, moduleType: moduleType);
    if(result != null) {
      _monthlyOrders = result.items;
      update();
    }
  }

  Future<bool> removeMonthlyOrder(int id) async {
    update();
    final bool isSuccess = await orderServiceInterface.removeMonthlyOrder(id);
    if(isSuccess) {
      _monthlyOrders?.removeWhere((MonthlyOrder order) => order.id == id);
    }
    update();
    return isSuccess;
  }

}