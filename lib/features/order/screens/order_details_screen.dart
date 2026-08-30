import 'dart:async';
import 'package:sixam_mart/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:sixam_mart/common/widgets/web_menu_bar.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/order/widgets/parcel_cancelation/cancellation_reason_bottom_sheet.dart';
import 'package:sixam_mart/features/order/widgets/parcel_cancelation/slider_button_widget.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/order/controllers/order_controller.dart';
import 'package:sixam_mart/features/order/domain/models/order_details_model.dart';
import 'package:sixam_mart/features/order/domain/models/order_model.dart';
import 'package:sixam_mart/features/location/domain/models/zone_response_model.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/confirmation_dialog.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_dialog.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/features/checkout/widgets/offline_success_dialog.dart';
import 'package:sixam_mart/features/order/widgets/cancellation_dialogue_widget.dart';
import 'package:sixam_mart/features/order/widgets/order_calcuation_widget.dart';
import 'package:sixam_mart/features/order/widgets/order_info_widget.dart';
import 'package:sixam_mart/features/review/screens/rate_review_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel? orderModel;
  final int? orderId;
  final bool fromNotification;
  final bool fromOfflinePayment;
  final String? contactNumber;
  const OrderDetailsScreen({super.key, required this.orderModel, required this.orderId, this.fromNotification = false, this.fromOfflinePayment = false, this.contactNumber});

  @override
  OrderDetailsScreenState createState() => OrderDetailsScreenState();
}

class OrderDetailsScreenState extends State<OrderDetailsScreen> {
  Timer? _timer;
  double? _maxCodOrderAmount;
  bool? _isCashOnDeliveryActive = false;
  final ScrollController scrollController = ScrollController();

  void _loadData(BuildContext context, bool reload) async {
    String? contact = (widget.contactNumber != null && widget.contactNumber != 'null' && widget.contactNumber!.isNotEmpty) 
        ? widget.contactNumber 
        : Get.find<OrderController>().trackModel?.deliveryAddress?.contactPersonNumber;

    await Get.find<OrderController>().trackOrder(widget.orderId.toString(), reload ? null : widget.orderModel, false, contactNumber: contact).then((value) {
      if(widget.fromOfflinePayment) {
        Future.delayed(const Duration(seconds: 2), () => showAnimatedDialog(Get.context!, OfflineSuccessDialog(orderId: widget.orderId)));
      }
    });
    Get.find<OrderController>().timerTrackOrder(widget.orderId.toString(), contactNumber: contact);
    Get.find<OrderController>().getOrderDetails(widget.orderId.toString());

    _timer?.cancel();
    if (Get.find<OrderController>().trackModel?.orderStatus != 'delivered' &&
        Get.find<OrderController>().trackModel?.orderStatus != 'failed' &&
        Get.find<OrderController>().trackModel?.orderStatus != 'canceled') {
      _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
        Get.find<OrderController>().timerTrackOrder(widget.orderId.toString(), contactNumber: contact);
      });
    }
  }

  void _startApiCall(){
    _timer?.cancel();
  }

  @override
  void initState() {
    super.initState();
    if (Get.find<OrderController>().trackModel?.id != widget.orderId) {
      Get.find<OrderController>().clearPrevOrderData();
    }
    _loadData(context, false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    
    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) async {
        if(widget.fromNotification || widget.fromOfflinePayment) {
          Get.offAllNamed(RouteHelper.getInitialRoute());
        } else {
          return;
        }
      },
      child: GetBuilder<OrderController>(builder: (orderController) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: isDesktop ? const WebMenuBar() : AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).textTheme.bodyLarge!.color),
              onPressed: () => Navigator.pop(context),
            ),
            centerTitle: true,
            title: Text('order_details'.tr, style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color, fontSize: Dimensions.fontSizeLarge)),
            actions: [
              IconButton(
                icon: Icon(Icons.refresh, color: Theme.of(context).textTheme.bodyLarge!.color),
                onPressed: () {
                  _loadData(context, true);
                },
              ),
              if (orderController.trackModel != null) PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Theme.of(context).textTheme.bodyLarge!.color),
                onSelected: (value) {
                  if (value == 'reorder') {
                    orderController.reorder(orderController.trackModel!.id!, order: orderController.trackModel);
                  } else if (value == 'review') {
                    _handleReviewButton(orderController, orderController.trackModel!);
                  } else if (value == 'track') {
                    _handleTrackOrder(orderController.trackModel!);
                  }
                },
                itemBuilder: (BuildContext context) {
                  List<PopupMenuEntry<String>> items = [];
                  OrderModel order = orderController.trackModel!;
                  bool ongoing = (order.orderStatus != 'delivered' && order.orderStatus != 'failed' && order.orderStatus != 'canceled' && order.orderStatus != 'refund_requested'
                      && order.orderStatus != 'refunded' && order.orderStatus != 'refund_request_canceled');
                  
                  if (!ongoing) {
                    items.add(PopupMenuItem<String>(
                      value: 'reorder',
                      child: Text('reorder'.tr),
                    ));
                    if (_ButtonVisibilityHelper.shouldShowReviewButton(order, orderController)) {
                      items.add(PopupMenuItem<String>(
                        value: 'review',
                        child: Text('review'.tr),
                      ));
                    }
                  } else {
                    items.add(PopupMenuItem<String>(
                      value: 'track',
                      child: Text('track_order'.tr),
                    ));
                  }
                  return items;
                },
              ),
            ],
          ),
          endDrawer: const MenuDrawer(),
          endDrawerEnableOpenDragGesture: false,
          body: SafeArea(child: GetBuilder<OrderController>(builder: (orderController) {
            double deliveryCharge = 0;
            double itemsPrice = 0;
            double discount = 0;
            double couponDiscount = 0;
            double tax = 0;
            double addOns = 0;
            double dmTips = 0;
            double additionalCharge = 0;
            double extraPackagingCharge = 0;
            double referrerBonusAmount = 0;
            OrderModel? order = orderController.trackModel;
            bool parcel = false;
            bool prescriptionOrder = false;
            bool taxIncluded = false;
            bool ongoing = false;
            bool showChatPermission = true;
            if(orderController.orderDetails != null  && order != null) {
              parcel = order.orderType == 'parcel';
              prescriptionOrder = order.prescriptionOrder ?? false;
              deliveryCharge = order.deliveryCharge ?? 0;
              couponDiscount = order.couponDiscountAmount ?? 0;
              discount = (order.storeDiscountAmount ?? 0) + (order.flashAdminDiscountAmount ?? 0) + (order.flashStoreDiscountAmount ?? 0);
              tax = order.totalTaxAmount ?? 0;
              dmTips = order.dmTips ?? 0;
              taxIncluded = order.taxStatus ?? false;
              additionalCharge = order.additionalCharge ?? 0;
              extraPackagingCharge = order.extraPackagingAmount ?? 0;
              referrerBonusAmount = order.referrerBonusAmount ?? 0;
              if(prescriptionOrder) {
                double orderAmount = order.orderAmount ?? 0;
                itemsPrice = (orderAmount + discount) - ((taxIncluded ? 0 : tax) + deliveryCharge) - additionalCharge;
              } else{
                for(OrderDetailsModel orderDetails in orderController.orderDetails!) {
                  if(orderDetails.addOns != null) {
                    for(AddOn addOn in orderDetails.addOns!) {
                      addOns = addOns + ((addOn.price ?? 0) * (addOn.quantity ?? 0));
                    }
                  }
                  itemsPrice = itemsPrice + ((orderDetails.price ?? 0) * (orderDetails.quantity ?? 0));
                }
              }

              if(!parcel && order.store != null) {
                List<ZoneData>? zList = order.deliveryAddress?.zoneData ?? AddressHelper.getUserAddressFromSharedPref()?.zoneData;
                if(zList != null) {
                  for(ZoneData zData in zList) {
                    if(zData.id == order.store!.zoneId){
                      _isCashOnDeliveryActive = zData.cashOnDelivery;
                    }
                    if(zData.modules != null) {
                      for(Modules m in zData.modules!) {
                        if(m.id == order.store!.moduleId) {
                          _maxCodOrderAmount = m.pivot?.maximumCodOrderAmount;
                          break;
                        }
                      }
                    }
                  }
                }
              }

              if (order.store != null) {
                if (order.store!.storeBusinessModel == 'commission') {
                  showChatPermission = true;
                } else if (order.store!.storeSubscription != null && order.store!.storeBusinessModel == 'subscription') {
                  showChatPermission = order.store!.storeSubscription!.chat == 1;
                } else {
                  showChatPermission = false;
                }
              } else {
                showChatPermission = AuthHelper.isLoggedIn();
              }

              ongoing = (order.orderStatus != 'delivered' && order.orderStatus != 'failed' && order.orderStatus != 'canceled' && order.orderStatus != 'refund_requested'
              && order.orderStatus != 'refunded' && order.orderStatus != 'refund_request_canceled');

            }
            double subTotal = itemsPrice + addOns;
            double total = itemsPrice + addOns - discount + (taxIncluded ? 0 : tax) + deliveryCharge - couponDiscount + dmTips + additionalCharge + extraPackagingCharge - referrerBonusAmount;

            bool isCurrentOrderData = orderController.orderDetails != null && order != null && orderController.trackModel != null && orderController.trackModel!.id == widget.orderId;

            return isCurrentOrderData ? Column(children: [

              isDesktop ? Container(
                height: 64,
                color: Theme.of(context).primaryColor.withValues(alpha: 0.10),
                child: Center(child: Text('order_details'.tr, style: robotoMedium)),
              ) : const SizedBox(),

              Expanded(child: SingleChildScrollView(
                controller: scrollController,
                child: FooterView(
                  child: SizedBox(
                    width: Dimensions.webMaxWidth,
                    child: Column(children: [
                      isDesktop ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Expanded(
                          flex: 6,
                          child : OrderInfoWidget(
                            order: order, ongoing: ongoing, parcel: parcel, prescriptionOrder: prescriptionOrder,
                            timerCancel : () => _timer?.cancel(), startApiCall : () =>  _startApiCall(),
                            orderController: orderController, showChatPermission: showChatPermission,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeLarge),

                        Expanded(
                          flex: 4,
                          child: OrderCalculationWidget(
                            orderController: orderController, order: order, ongoing: ongoing, parcel: parcel,
                            prescriptionOrder: prescriptionOrder, deliveryCharge: deliveryCharge, itemsPrice: itemsPrice,
                            discount: discount, couponDiscount: couponDiscount, tax: tax, addOns: addOns, dmTips: dmTips,
                            taxIncluded: taxIncluded, subTotal: subTotal, total: total,
                            bottomView: buildBottomView(orderController, order, parcel, total), extraPackagingAmount: extraPackagingCharge,
                            referrerBonusAmount: referrerBonusAmount, timerCancel : () => _timer?.cancel(), startApiCall : () =>  _startApiCall(),
                          ),
                        ),
                      ]) : const SizedBox(),

                      isDesktop ? const SizedBox() : OrderInfoWidget(
                        order: order, ongoing: ongoing, parcel: parcel, prescriptionOrder: prescriptionOrder,
                        timerCancel : () => _timer?.cancel(), startApiCall : () =>  _startApiCall(),
                        orderController: orderController, showChatPermission: showChatPermission,
                      ),

                      isDesktop ? const SizedBox() : OrderCalculationWidget(
                        orderController: orderController, order: order, ongoing: ongoing, parcel: parcel,
                        prescriptionOrder: prescriptionOrder, deliveryCharge: deliveryCharge, itemsPrice: itemsPrice,
                        discount: discount, couponDiscount: couponDiscount, tax: tax, addOns: addOns, dmTips: dmTips, taxIncluded: taxIncluded, subTotal: subTotal, total: total,
                        bottomView:  buildBottomView(orderController, order, parcel, total), extraPackagingAmount: extraPackagingCharge, referrerBonusAmount: referrerBonusAmount,
                        timerCancel : () => _timer?.cancel(), startApiCall : () =>  _startApiCall(),
                      ),
                    ]),
                  ),
                ),
              )),

              isDesktop ? const SizedBox() : buildBottomView(orderController, order, parcel, total),

            ]) : const CustomLoaderWidget();
          })),
        );
      }),
    );
  }

  Widget buildBottomView(OrderController orderController, OrderModel order, bool parcel, double total) {
    return parcel ? _buildParcelBottomView(orderController, order, parcel, total) : _buildRegularBottomView(orderController, order, parcel, total);
  }

  Widget _buildRegularBottomView(OrderController orderController, OrderModel order, bool parcel, double totalPrice) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    final showCancelButton = _ButtonVisibilityHelper.shouldShowCancelButton(order, orderController);
    final showTrackDeliveryButton = _ButtonVisibilityHelper.shouldShowTrackDeliveryButton(order);
    final showReviewButton = _ButtonVisibilityHelper.shouldShowReviewButton(order, orderController);
    final showSwitchToCodButton = _ButtonVisibilityHelper.shouldShowSwitchToCodButton(order, _isCashOnDeliveryActive!);
    final showFailedCodButton = _ButtonVisibilityHelper.shouldShowFailedOrderCodButton(order);

    final showDecoration = showCancelButton || showTrackDeliveryButton || showReviewButton || showSwitchToCodButton;

    return Container(
      padding: EdgeInsets.all(!isDesktop && showDecoration ? Dimensions.paddingSizeDefault : 0),
      decoration: !isDesktop && showDecoration ? BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
      ) : null,
      child: Column(children: [
        if (!orderController.showCancelled) ...[
          _buildActionButtonsRow(
            showCancelButton: showCancelButton,
            showTrackDeliveryButton: showTrackDeliveryButton,
            isDesktop: isDesktop,
            order: order,
            parcel: parcel,
            onCancelPressed: () => _handleCancelOrder(orderController, order),
            onTrackPressed: () => _handleTrackOrder(order),
          ),

          if (showSwitchToCodButton)
            _buildSwitchToCodButton(orderController, order, parcel, totalPrice),
        ] else
          _buildCancelledOrderWidget(isDesktop),

        if (showReviewButton)
          _buildReviewButton(orderController, order),

        if (showFailedCodButton)
          _buildFailedOrderCodButton(orderController, order),

        const SizedBox(height: Dimensions.paddingSizeSmall),
        _buildInvoiceButton(order.id.toString()),
      ]),
    );
  }

  // Refactored parcel bottom view
  Widget _buildParcelBottomView(OrderController orderController, OrderModel order, bool parcel, double totalPrice) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    final showCancelButton = _ButtonVisibilityHelper.shouldShowParcelCancelButton(order, orderController);
    final showTrackDeliveryButton = _ButtonVisibilityHelper.shouldShowParcelTrackButton(order);
    final showReturnOtp = _ButtonVisibilityHelper.shouldShowParcelReturnOtp(order);
    final showReviewButton = _ButtonVisibilityHelper.shouldShowParcelReviewButton(order);
    final showSwitchToCodButton = _ButtonVisibilityHelper.shouldShowSwitchToCodButton(order, _isCashOnDeliveryActive!);
    final showFailedCodButton = _ButtonVisibilityHelper.shouldShowFailedOrderCodButton(order);

    final showDecoration = showCancelButton || showTrackDeliveryButton || showReturnOtp || showReviewButton || showSwitchToCodButton;

    return Container(
      padding: EdgeInsets.all(!isDesktop && showDecoration ? Dimensions.paddingSizeDefault : 0),
      decoration: !isDesktop && showDecoration ? BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
      ) : null,
      child: Column(children: [
        if (!orderController.showCancelled) ...[
          _buildParcelActionButtonsRow(
            showCancelButton: showCancelButton,
            showTrackDeliveryButton: showTrackDeliveryButton,
            order: order,
            parcel: parcel,
            isDesktop: isDesktop,
            onCancelPressed: () => _handleParcelCancel(orderController, order, isDesktop),
            onTrackPressed: () => _handleTrackOrder(order),
          ),

          if (_ButtonVisibilityHelper.shouldShowSwitchToCodButton(order, _isCashOnDeliveryActive!))
            _buildSwitchToCodButton(orderController, order, parcel, totalPrice),
        ] else
          _buildCancelledOrderWidget(isDesktop),

        if (showReturnOtp) ...[
          _buildParcelReturnOtpDisplay(order),
          SizedBox(height: Dimensions.paddingSizeSmall),

          _buildParcelReturnSlider(orderController, order),
        ],

        if (showReviewButton)
          _buildReviewButton(orderController, order),

        if (showFailedCodButton)
          _buildFailedOrderCodButton(orderController, order),

        const SizedBox(height: Dimensions.paddingSizeSmall),
        _buildInvoiceButton(order.id.toString()),
      ]),
    );
  }

  Widget _buildInvoiceButton(String orderId) {
    return CustomButton(
      buttonText: 'طباعة فاتورة',
      transparent: true,
      color: Theme.of(context).disabledColor.withOpacity(0.1),
      textColor: Theme.of(context).disabledColor,
      isBorder: true,
      onPressed: () {
        Get.toNamed(RouteHelper.getInvoiceRoute(orderId));
      },
    );
  }

  Widget _buildActionButtonsRow({required bool showCancelButton, required bool showTrackDeliveryButton, required bool isDesktop, required OrderModel order,
    required bool parcel, required VoidCallback onCancelPressed, required VoidCallback onTrackPressed}) {
    return Row(children: [
      if (showCancelButton)
        Expanded(
          child: CustomButton(
            isBorder: true,
            color: Colors.transparent,
            onPressed: onCancelPressed,
            buttonText: parcel ? 'cancel_delivery'.tr : 'cancel_order'.tr,
            textColor: Theme.of(context).disabledColor,
          ),
        ),

      if (showCancelButton && showTrackDeliveryButton)
        SizedBox(width: Dimensions.paddingSizeSmall),

      if (showTrackDeliveryButton)
        Expanded(
          child: CustomButton(
            buttonText: parcel ? 'track_delivery'.tr : 'track_order'.tr,
            onPressed: onTrackPressed,
          ),
        ),
    ]);
  }

  Widget _buildParcelActionButtonsRow({required bool showCancelButton, required bool showTrackDeliveryButton, required OrderModel order, required bool parcel,
    required bool isDesktop, required VoidCallback onCancelPressed, required VoidCallback onTrackPressed}) {
    return Row(children: [
      if (showCancelButton)
        Expanded(
          child: CustomButton(
            isBorder: true,
            color: Colors.transparent,
            onPressed: onCancelPressed,
            buttonText: 'cancel_delivery'.tr,
            textColor: Theme.of(context).disabledColor,
          ),
        ),

      if (showCancelButton && showTrackDeliveryButton)
        SizedBox(width: Dimensions.paddingSizeSmall),

      if (showTrackDeliveryButton)
        Expanded(
          child: CustomButton(
            buttonText: 'track_delivery'.tr,
            onPressed: onTrackPressed,
          ),
        ),
    ]);
  }

  Widget _buildSwitchToCodButton(OrderController orderController, OrderModel order, bool parcel, double totalPrice) {
    return CustomButton(
      buttonText: 'switch_to_cod'.tr,
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeSmall,
      ),
      onPressed: () => _handleSwitchToCod(orderController, order, parcel, totalPrice),
    );
  }

  Widget _buildCancelledOrderWidget(bool isDesktop) {
    return Center(
      child: Container(
        width: Dimensions.webMaxWidth,
        height: 50,
        margin: isDesktop ? null : const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
          vertical: Dimensions.paddingSizeSmall,
        ),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(width: 2, color: Theme.of(context).primaryColor),
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        ),
        child: Text(
          'order_cancelled'.tr,
          style: robotoMedium.copyWith(color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }

  Widget _buildReviewButton(OrderController orderController, OrderModel order) {
    return CustomButton(
      buttonText: 'review'.tr,
      onPressed: () => _handleReviewButton(orderController, order),
    );
  }

  Widget _buildFailedOrderCodButton(OrderController orderController, OrderModel order) {
    return CustomButton(
      buttonText: 'switch_to_cash_on_delivery'.tr,
      onPressed: () => _handleFailedOrderCod(orderController, order),
    );
  }

  Widget _buildParcelReturnOtpDisplay(OrderModel order) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(
        'parcel_returned_otp'.tr,
        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
      ),

      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeExtraSmall,
            vertical: 2,
          ),
          child: Text(
            order.parcelCancellation!.returnOtp.toString(),
            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
          ),
        ),
      ),
    ]);
  }

  Widget _buildParcelReturnSlider(OrderController orderController, OrderModel order) {
    return SliderButton(
      label: Text(
        'parcel_received'.tr,
        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
      ),
      dismissThresholds: 0.5, dismissible: false, shimmer: true, width: 1170,
      height: 60, buttonSize: 50, radius: 10,
      icon: Center(
        child: Icon(
          Get.find<LocalizationController>().isLtr ? Icons.double_arrow_sharp : Icons.keyboard_arrow_left,
          color: Colors.white,
          size: 20.0,
        ),
      ),
      isLtr: Get.find<LocalizationController>().isLtr,
      boxShadow: const BoxShadow(blurRadius: 0),
      buttonColor: Theme.of(context).primaryColor,
      backgroundColor: const Color(0xffF4F7FC),
      baseColor: Theme.of(context).primaryColor,
      action: () async {
        bool isSuccess = await orderController.submitParcelReturn(
          orderId: order.id!,
          returnOtp: order.parcelCancellation!.returnOtp!,
          contactNumber: widget.contactNumber,
        );

        if (mounted && isSuccess) {
          showCustomSnackBar('parcel_returned_successfully'.tr, isError: false);
        }
      },
    );
  }

  void _handleCancelOrder(OrderController orderController, OrderModel order) {
    orderController.setOrderCancelReason('');
    Get.dialog(CancellationDialogueWidget(
      orderId: order.id,
      contactNumber: widget.contactNumber,
    ));
  }

  void _handleParcelCancel(OrderController orderController, OrderModel order, bool isDesktop) {
    final isBeforePickup = ['pending', 'accepted', 'confirmed'].contains(order.orderStatus);
    final cancellationSheet = CancellationReasonBottomSheet(
      isBeforePickup: isBeforePickup,
      orderId: order.id,
      contactNumber: widget.contactNumber,
      chargePayerSender: order.chargePayer == 'sender',
      orderAmount: order.orderAmount ?? 0,
      dmTips: order.dmTips ?? 0,
    );

    if (isDesktop) {
      Get.dialog(Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
        insetPadding: const EdgeInsets.all(20),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: cancellationSheet,
      ));
    } else {
      showCustomBottomSheet(child: cancellationSheet);
    }
  }

  Future<void> _handleTrackOrder(OrderModel order) async {
    _timer?.cancel();
    await Get.toNamed(RouteHelper.getOrderTrackingRoute(order.id, widget.contactNumber))?.whenComplete(() => _startApiCall());
  }

  void _handleSwitchToCod(OrderController orderController, OrderModel order, bool parcel, double totalPrice) {
    Get.dialog(ConfirmationDialog(
      icon: Images.warning,
      description: 'are_you_sure_to_switch'.tr,
      onYesPressed: () {
        final canSwitchToCod = _canSwitchToCashOnDelivery(parcel, totalPrice);

        if (canSwitchToCod) {
          orderController.switchToCOD(order.id.toString());
        } else {
          if (Get.isDialogOpen!) Get.back();
             showCustomSnackBar('${'you_cant_order_more_then'.tr} ${PriceConverter.convertPrice(_maxCodOrderAmount)} ${'in_cash_on_delivery'.tr}'
          );
        }
      },
    ));
  }

  void _handleReviewButton(OrderController orderController, OrderModel order) {
    final orderDetailsList = <OrderDetailsModel>[];
    final orderDetailsIdList = <int?>[];

    for (var orderDetail in orderController.orderDetails!) {
      if (!orderDetailsIdList.contains(orderDetail.itemDetails!.id)) {
        orderDetailsList.add(orderDetail);
        orderDetailsIdList.add(orderDetail.itemDetails!.id);
      }
    }

    Get.toNamed(RouteHelper.getRateReviewRoute(), arguments: RateReviewScreen(
      orderDetailsList: orderDetailsList,
      deliveryMan: order.deliveryMan,
      orderID: order.id,
      reviews: order.reviews,
    ));
  }

  void _handleFailedOrderCod(OrderController orderController, OrderModel order) {
    Get.dialog(ConfirmationDialog(
      icon: Images.warning,
      description: 'are_you_sure_to_switch'.tr,
      onYesPressed: () {
        orderController.switchToCOD(order.id.toString()).then((isSuccess) {
          Get.back();
          if (isSuccess) Get.back();
        });
      },
    ));
  }

  bool _canSwitchToCashOnDelivery(bool parcel, double totalPrice) {
    if (parcel) return true;

    return (_maxCodOrderAmount != null && totalPrice < _maxCodOrderAmount!) || _maxCodOrderAmount == null || _maxCodOrderAmount == 0;
  }
}


class _ButtonVisibilityHelper {
  static bool shouldShowCancelButton(OrderModel order, OrderController orderController) {
    final isUserLoggedIn = Get.find<AuthController>().isLoggedIn();
    final hasGuestOrderDetails = orderController.orderDetails != null && orderController.orderDetails!.isNotEmpty && orderController.orderDetails![0].isGuest == 1;

    final canCancel = isUserLoggedIn || hasGuestOrderDetails;

    return order.orderStatus == 'pending' && canCancel;
  }

  static bool shouldShowParcelCancelButton(OrderModel order, OrderController orderController) {
    final isUserLoggedIn = Get.find<AuthController>().isLoggedIn();
    final isGuestLoggedIn = Get.find<AuthController>().isGuestLoggedIn();
    final hasGuestOrderDetails = orderController.orderDetails != null && orderController.orderDetails!.isNotEmpty && orderController.orderDetails![0].isGuest == 1;

    final canCancel = isUserLoggedIn || hasGuestOrderDetails;
    final cancellableStatuses = ['pending', 'accepted', 'confirmed', 'processing', 'handover', 'picked_up'];

    if(isGuestLoggedIn){
      return order.orderStatus == 'pending' && canCancel;
    }else{
      return cancellableStatuses.contains(order.orderStatus) && canCancel;
    }
  }

  static bool shouldShowTrackDeliveryButton(OrderModel order) {
    final trackableStatuses = ['pending', 'accepted', 'confirmed', 'processing', 'handover', 'picked_up'];
    final isPendingWithoutDigitalPayment = order.orderStatus == 'pending' && order.paymentMethod != 'digital_payment';

    return isPendingWithoutDigitalPayment || trackableStatuses.contains(order.orderStatus);
  }

  static bool shouldShowParcelTrackButton(OrderModel order) {
    final trackableStatuses = ['pending', 'accepted', 'confirmed', 'processing', 'handover', 'picked_up'];
    return trackableStatuses.contains(order.orderStatus);
  }

  static bool shouldShowReviewButton(OrderModel order, OrderController orderController) {
    if (AuthHelper.isGuestLoggedIn()) return false;
    if (order.orderStatus != 'delivered') return false;

    return orderController.orderDetails!.isNotEmpty && orderController.orderDetails![0].itemCampaignId == null && canReviews(order.reviews, orderController);
  }

  static bool shouldShowParcelReviewButton(OrderModel order) {
    if (AuthHelper.isGuestLoggedIn()) return false;

    final canReview = order.orderStatus == 'delivered' || order.orderStatus == 'returned';
    if (!canReview) return false;

    return order.deliveryMan != null && (order.reviews == null || order.reviews!.isEmpty);
  }

  static bool canReviews(List<Reviews>? reviews, OrderController orderController) {
    if(AuthHelper.isLoggedIn()) {
      if(reviews != null && reviews.isNotEmpty){
        for (int i = 0; i < orderController.orderDetails!.length; i++) {
          for(int j = 0; j < reviews.length; j++) {
            if(orderController.orderDetails![i].itemId == reviews[j].itemId) {
              return false;
            }
          }
        }
      }
    }
    return true;
  }

  static bool shouldShowSwitchToCodButton(OrderModel order, bool isCashOnDeliveryActive) {
    return order.orderStatus == 'pending' && order.paymentStatus == 'unpaid' && order.paymentMethod == 'digital_payment' && isCashOnDeliveryActive;
  }

  static bool shouldShowParcelReturnOtp(OrderModel order) {
    return order.orderStatus != 'returned' && order.parcelCancellation != null && order.parcelCancellation!.beforePickup == 0 && order.parcelCancellation!.returnOtp != null;
  }

  static bool shouldShowFailedOrderCodButton(OrderModel order) {
    return order.orderStatus == 'failed' && Get.find<SplashController>().configModel!.cashOnDelivery!;
  }
}
