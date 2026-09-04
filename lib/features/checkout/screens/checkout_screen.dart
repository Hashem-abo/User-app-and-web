import 'package:geolocator/geolocator.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:sixam_mart/common/widgets/address_widget.dart';
import 'package:sixam_mart/features/address/controllers/address_controller.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/coupon/controllers/coupon_controller.dart';
import 'package:sixam_mart/features/home/controllers/home_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/checkout/domain/models/place_order_body_model.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/cart/domain/models/cart_model.dart';
import 'package:sixam_mart/common/models/config_model.dart';
import 'package:sixam_mart/features/location/domain/models/zone_response_model.dart';
import 'package:sixam_mart/features/checkout/controllers/checkout_controller.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/features/pro/controllers/pro_controller.dart';
import 'package:sixam_mart/features/pro/domain/models/pro_active_offer_model.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_dropdown.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/common/widgets/not_logged_in_screen.dart';
import 'package:sixam_mart/features/checkout/widgets/checkout_screen_shimmer_view.dart';
import 'package:sixam_mart/features/checkout/widgets/payment_method_bottom_sheet.dart';
import 'package:sixam_mart/features/checkout/widgets/payment_onboarding_dialog.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/checkout/widgets/bottom_section.dart';
import 'package:sixam_mart/features/checkout/widgets/top_section.dart';
import 'package:flutter/material.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartModel?>? cartList;
  final bool fromCart;
  final int? storeId;
  const CheckoutScreen({super.key, required this.fromCart, required this.cartList, required this.storeId});

  @override
  CheckoutScreenState createState() => CheckoutScreenState();
}

class CheckoutScreenState extends State<CheckoutScreen> {

  final ScrollController _scrollController = ScrollController();
  final JustTheController tooltipController1 = JustTheController();
  final JustTheController tooltipController2 = JustTheController();
  final JustTheController tooltipController3 = JustTheController();

  double? _taxPercent = 0;
  bool? _isCashOnDeliveryActive = false;
  bool? _isDigitalPaymentActive = false;
  bool _isOfflinePaymentActive = false;
  List<CartModel?>? _cartList;
  bool _isWalletActive = false;
  String _deliveryChargeForView = '';

  List<AddressModel> address = [];
  bool canCheckSmall = false;
  double? _payableAmount = 0;
  double badWeatherChargeForToolTip = 0;
  double extraChargeForToolTip = 0;
  bool isPassedVariationPrice = false;

  final TextEditingController guestContactPersonNameController = TextEditingController();
  final TextEditingController guestContactPersonNumberController = TextEditingController();
  final TextEditingController guestEmailController = TextEditingController();
  final TextEditingController guestPasswordController = TextEditingController();
  final TextEditingController guestConfirmPasswordController = TextEditingController();
  final FocusNode guestNumberNode = FocusNode();
  final FocusNode guestEmailNode = FocusNode();
  final FocusNode guestPasswordNode = FocusNode();
  final FocusNode guestConfirmPasswordNode = FocusNode();

  bool _firstTimeCheckPayment = false;
  bool _calledOrderTax = false;

  @override
  void initState() {
    super.initState();

    initCall();
  }

  Future<void> initCall() async {
    bool isLoggedIn = AuthHelper.isLoggedIn();
    Get.find<CheckoutController>().resetOrderTax();
    Get.find<CheckoutController>().initAdditionData();
    Get.find<CheckoutController>().streetNumberController.text = AddressHelper.getUserAddressFromSharedPref()!.streetNumber ?? '';
    Get.find<CheckoutController>().houseController.text = AddressHelper.getUserAddressFromSharedPref()!.house ?? '';
    Get.find<CheckoutController>().floorController.text = AddressHelper.getUserAddressFromSharedPref()!.floor ?? '';
    Get.find<CheckoutController>().couponController.text = '';

    Get.find<CheckoutController>().clearPrevData();
    Get.find<CheckoutController>().getDmTipMostTapped();
    Get.find<CheckoutController>().setPreferenceTimeForView('', isUpdate: false);
    Get.find<CheckoutController>().setExchangeAmount(0);

    Get.find<CheckoutController>().getOfflineMethodList();

    if(Get.find<CheckoutController>().isCreateAccount) {
      Get.find<CheckoutController>().toggleCreateAccount(willUpdate: false);
    }

    if(Get.find<CheckoutController>().isPartialPay){
      Get.find<CheckoutController>().changePartialPayment(isUpdate: false);
    }

    if(isLoggedIn) {
      if(Get.find<ProfileController>().userInfoModel == null) {
        Get.find<ProfileController>().getUserInfo();
      }

      Get.find<CouponController>().getCouponList();

      if(Get.find<AddressController>().addressList == null) {
        Get.find<AddressController>().getAddressList();
      }
    }

    if(widget.storeId == null || widget.cartList != null){
      _cartList = [];
      if(GetPlatform.isWeb) {
       await Get.find<CartController>().getCartDataOnline();
      }
      widget.fromCart ? _cartList!.addAll(Get.find<CartController>().cartList) : _cartList!.addAll(widget.cartList!);
      if(_cartList != null && _cartList!.isNotEmpty && widget.storeId == null) {
        Get.find<CheckoutController>().initCheckoutData(null);
      }
    }
    if(widget.storeId != null){
      Get.find<CheckoutController>().initCheckoutData(widget.storeId);
      Get.find<CouponController>().removeCouponData(false);
    }
    Get.find<CheckoutController>().pickPrescriptionImage(isRemove: true, isCamera: false);
    _isWalletActive = Get.find<SplashController>().configModel!.customerWalletStatus == 1;
    Get.find<CheckoutController>().updateTips(
      Get.find<CheckoutController>().getSharedPrefDmTipIndex().isNotEmpty ? int.parse(Get.find<CheckoutController>().getSharedPrefDmTipIndex()) : 0,
      notify: false,
    );
    Get.find<CheckoutController>().getOfflineMethodList();
    // Get.find<CheckoutController>().initCheckoutData(
    //   Get.find<CartController>().cartList[0].item!.storeId,
    // );
    if (AuthHelper.isLoggedIn()) {
      Get.find<ProController>().getProActiveOffer(moduleType: Get.find<SplashController>().module?.moduleType);
    }
    Get.find<CheckoutController>().tipController.text = Get.find<CheckoutController>().selectedTips != -1 ? AppConstants.tips[Get.find<CheckoutController>().selectedTips] : '';

    if (AuthHelper.isGuestLoggedIn()) {
      guestEmailController.text = 'guest@mile.com';
    }
  }

  void _setSinglePaymentActive() {
    if((!_firstTimeCheckPayment && !_isCashOnDeliveryActive! && _isDigitalPaymentActive! && Get.find<SplashController>().configModel!.activePaymentMethodList!.length == 1) && ((!_isWalletActive && AuthHelper.isLoggedIn()) || !AuthHelper.isLoggedIn()) ) {
      Future.delayed(const Duration(milliseconds: 600), (){
        Get.find<CheckoutController>().setPaymentMethod(2, isUpdate: false);
        Get.find<CheckoutController>().changeDigitalPaymentName(Get.find<SplashController>().configModel!.activePaymentMethodList![0].getWay!, willUpdate: false);
        _firstTimeCheckPayment = true;
      });
    }
  }

  @override
  void dispose() {
    guestContactPersonNameController.dispose();
    guestContactPersonNumberController.dispose();
    guestEmailController.dispose();
    guestPasswordController.dispose();
    guestConfirmPasswordController.dispose();
    guestNumberNode.dispose();
    guestEmailNode.dispose();
    guestPasswordNode.dispose();
    guestConfirmPasswordNode.dispose();

    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    Module? module = Get.find<SplashController>().configModel?.moduleConfig?.module;
    bool guestCheckoutPermission = AuthHelper.isGuestLoggedIn() && (Get.find<SplashController>().configModel?.guestCheckoutStatus ?? false);
    bool isLoggedIn = AuthHelper.isLoggedIn();
    bool isGuestLogIn = AuthHelper.isGuestLoggedIn();

    return Scaffold(
      appBar: CustomAppBar(title: 'checkout'.tr),
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      body: guestCheckoutPermission || AuthHelper.isLoggedIn() ? GetBuilder<ProController>(builder: (proController) {
        return GetBuilder<CheckoutController>(builder: (checkoutController) {
          return GetBuilder<AddressController>(builder: (addressController) {

        List<DropdownItem<int>> addressList = _getDropdownAddressList(context: context, addressList: addressController.addressList, store: checkoutController.store);
        address = _getAddressList(addressList: addressController.addressList, store: checkoutController.store);

        bool todayClosed = false;
        bool tomorrowClosed = false;
        Pivot? moduleData = _getModuleData(store: checkoutController.store);
        AddressModel? userAddrForZone = AddressHelper.getUserAddressFromSharedPref();
        bool isOutZoneStore = false;
        if (checkoutController.store != null && userAddrForZone != null) {
          bool isAllZones = (userAddrForZone.zoneId == 0) || (userAddrForZone.zoneIds != null && userAddrForZone.zoneIds!.contains(0));
          if (!isAllZones) {
            if (userAddrForZone.zoneIds != null && userAddrForZone.zoneIds!.isNotEmpty) {
              isOutZoneStore = !userAddrForZone.zoneIds!.contains(checkoutController.store!.zoneId);
            } else if (userAddrForZone.zoneId != null && checkoutController.store!.zoneId != null) {
              isOutZoneStore = userAddrForZone.zoneId != checkoutController.store!.zoneId;
            }
          }
        }
        if (isOutZoneStore && checkoutController.orderType != 'pickup_center') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            checkoutController.setOrderType('pickup_center', notify: true);
          });
        }

        _isCashOnDeliveryActive = _checkCODActive(store: checkoutController.store);
        _isDigitalPaymentActive = _checkDigitalPaymentActive(store: checkoutController.store);
        _isOfflinePaymentActive = (Get.find<SplashController>().configModel?.offlinePaymentStatus ?? false) && _checkZoneOfflinePaymentOnOff(addressModel: AddressHelper.getUserAddressFromSharedPref(), checkoutController: checkoutController);

        if(checkoutController.isFirstTimeCodActive && (_isCashOnDeliveryActive ?? false) && !AuthHelper.isGuestLoggedIn()){
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if(checkoutController.isFirstTimeCodActive) {
              checkoutController.setPaymentMethod(0);
            }
          });
        }
        if(AuthHelper.isGuestLoggedIn() && checkoutController.paymentMethodIndex == 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            checkoutController.setPaymentMethod(-1, isUpdate: false);
          });
        }

        if(checkoutController.store != null) {
          todayClosed = checkoutController.isStoreClosed(true, checkoutController.store?.active ?? true, checkoutController.store?.schedules);
          tomorrowClosed = checkoutController.isStoreClosed(false, checkoutController.store?.active ?? true, checkoutController.store?.schedules);
          _taxPercent = checkoutController.store?.tax;
        }
        return GetBuilder<CouponController>(builder: (couponController) {
          double? maxCodOrderAmount;

          if(moduleData != null) {
            maxCodOrderAmount = moduleData.maximumCodOrderAmount;
          }
          double price = _calculatePrice(store: checkoutController.store, cartList: _cartList);
          double addOns = _calculateAddonsPrice(store: checkoutController.store, cartList: _cartList);
          double variations = _calculateVariationPrice(store: checkoutController.store, cartList: _cartList, calculateWithoutDiscount: true);
          double? itemDiscountPrice = _calculateDiscountPrice(store: checkoutController.store, cartList: _cartList, price: price, addOns: addOns, calStoreDiscount: false);
          double? storeDiscountPrice = _calculateDiscountPrice(store: checkoutController.store, cartList: _cartList, price: price, addOns: addOns, calStoreDiscount: true);

          double extraDiscount = _getExtraDiscountPrice(storeDiscountPrice, itemDiscountPrice);
          double? discount = _getDiscountPrice(storeDiscountPrice, itemDiscountPrice);
          double couponDiscount = PriceConverter.toFixed(couponController.discount ?? 0);

          double subTotal = _calculateSubTotal(price: price, addOns: addOns, variations: variations, cartList: _cartList);

          double referralDiscount = _calculateReferralDiscount(subTotal, discount, couponDiscount);

          double orderAmount = _calculateOrderAmount(
            price: price, variations: variations, discount: discount, addOns: addOns,
            couponDiscount: couponDiscount, cartList: _cartList, referralDiscount: referralDiscount,
          );

          Future.delayed(const Duration(milliseconds: 50), () {
            double currentCouponDiscount = couponController.discount ?? 0;
            if(checkoutController.isFirstTime || (currentCouponDiscount > 0 && !checkoutController.isFirstTime && !_calledOrderTax)){
              if(currentCouponDiscount > 0){
                _calledOrderTax = true;
              }
              List<OnlineCart> carts = [];

              if(widget.storeId == null || (_cartList != null && _cartList!.isNotEmpty)){
                for (int index = 0; index < (_cartList?.length ?? 0); index++) {
                  CartModel? cart = _cartList![index];
                  if (cart?.item == null) continue;
                  List<int?> addOnIdList = [];
                  List<int?> addOnQtyList = [];
                  if (cart!.addOnIds != null) {
                    for (var addOn in cart.addOnIds!) {
                      addOnIdList.add(addOn.id);
                      addOnQtyList.add(addOn.quantity);
                    }
                  }

                  List<OrderVariation> variations = [];
                  bool isNewVar = (Get.find<SplashController>().getModuleConfig(cart.item!.moduleType).newVariation ?? false);
                  if(isNewVar && cart.item!.foodVariations != null && cart.foodVariations != null) {
                    for(int i=0; i<cart.item!.foodVariations!.length; i++) {
                      if(i < cart.foodVariations!.length && cart.foodVariations![i].contains(true)) {
                        variations.add(OrderVariation(name: cart.item!.foodVariations![i].name, values: OrderVariationValue(label: [])));
                        if (cart.item!.foodVariations![i].variationValues != null) {
                          for(int j=0; j<cart.item!.foodVariations![i].variationValues!.length; j++) {
                            if(j < cart.foodVariations![i].length && (cart.foodVariations![i][j] ?? false)) {
                              variations[variations.length-1].values!.label!.add(cart.item!.foodVariations![i].variationValues![j].level);
                            }
                          }
                        }
                      }
                    }
                  }
                  carts.add(OnlineCart(
                    cartId: cart.id, itemId: cart.item!.id, itemCampaignId: (cart.isCampaign ?? false) ? cart.item!.id : null,
                    price: cart.discountedPrice.toString(), variant: '',
                    variation: isNewVar ? null : cart.variation,
                    variations: isNewVar ? variations : null,
                    quantity: cart.quantity, addOnIds: addOnIdList, addOns: cart.addOns, addOnQtys: addOnQtyList, model: 'Item', itemType: (cart.isCampaign ?? false) ? "AppModelsItemCampaign" : null,
                    note: cart.note,
                  ));
                }
              }

                PlaceOrderBodyModel placeOrderBody = PlaceOrderBodyModel(
                  cart: carts, couponDiscountAmount: couponController.discount, distance: checkoutController.distance,
                  orderAmount: (widget.storeId == null || (_cartList != null && _cartList!.isNotEmpty)) ? subTotal : 0, orderNote: checkoutController.noteController.text, orderType: checkoutController.orderType,
                  paymentMethod: checkoutController.paymentMethodIndex == 0 ? 'cash_on_delivery'
                      : checkoutController.paymentMethodIndex == 1 ? 'wallet'
                      : checkoutController.paymentMethodIndex == 2 ? 'digital_payment' : 'offline_payment',
                  couponCode: (currentCouponDiscount > 0 || (couponController.coupon != null
                      && couponController.freeDelivery)) ? couponController.coupon?.code : null,
                  storeId: (widget.storeId == null || (_cartList != null && _cartList!.isNotEmpty)) ? _cartList![0]?.item?.storeId : widget.storeId,
                  discountAmount: discount, receiverDetails: null, parcelCategoryId: null,
                  chargePayer: null, dmTips: (checkoutController.orderType == 'take_away' || checkoutController.tipController.text == 'not_now') ? '' : checkoutController.tipController.text.trim(),
                  cutlery: Get.find<CartController>().addCutlery ? 1 : 0,
                  unavailableItemNote: Get.find<CartController>().notAvailableIndex != -1 ? Get.find<CartController>().notAvailableList[Get.find<CartController>().notAvailableIndex] : '',
                  deliveryInstruction: checkoutController.selectedInstruction != -1 ? AppConstants.deliveryInstructionList[checkoutController.selectedInstruction] : '',
                  partialPayment: checkoutController.isPartialPay ? 1 : 0, guestId: isGuestLogIn ? int.parse(AuthHelper.getGuestId()) : 0,
                  isBuyNow: widget.fromCart ? 0 : 1,
                  extraPackagingAmount: Get.find<CartController>().needExtraPackage ? (checkoutController.store?.extraPackagingAmount ?? 0) : 0,
                  createNewUser: checkoutController.isCreateAccount ? 1 : 0, password: guestPasswordController.text,
                  isPrescriptionOrder: (widget.storeId != null && (_cartList == null || _cartList!.isEmpty)),
                  bringChangeAmount: checkoutController.paymentMethodIndex == 0 && checkoutController.exchangeAmount > 0 ? checkoutController.exchangeAmount : null,
                  digitalPaymentGateway: checkoutController.paymentMethodIndex == 2 ? checkoutController.digitalPaymentName : null,
                  purchaseCode: checkoutController.paymentMethodIndex == 2 && (checkoutController.digitalPaymentName == 'easy_wallet' || checkoutController.digitalPaymentName == 'floosak') ? checkoutController.purchaseCodeController.text : null,
                  productReferrerId: Get.find<AuthController>().getProductRefCode().isNotEmpty ? Get.find<AuthController>().getProductRefCode() : null,
                  monthlySubscribe: checkoutController.monthlySubscribe,
                );

                checkoutController.getOrderTax(placeOrderBody);
            }
          });

          double additionalCharge = (Get.find<SplashController>().configModel?.additionalChargeStatus ?? false)
              ? (Get.find<SplashController>().configModel?.additionCharge ?? 0) : 0;
          int addrIndex = (checkoutController.addressIndex != null && checkoutController.addressIndex! < address.length) ? checkoutController.addressIndex! : 0;
          AddressModel activeUserAddress = isGuestLogIn
              ? (checkoutController.guestAddress ?? AddressHelper.getUserAddressFromSharedPref() ?? AddressModel(latitude: '0', longitude: '0', address: 'Unknown'))
              : (address.isNotEmpty
                  ? address[addrIndex]
                  : (AddressHelper.getUserAddressFromSharedPref() ?? AddressModel(latitude: '0', longitude: '0', address: 'Unknown')));

          double originalCharge = _calculateOriginalDeliveryCharge(
            store: checkoutController.store, address: activeUserAddress,
            distance: checkoutController.distance, extraCharge: checkoutController.extraCharge,
            surgePrice: checkoutController.surgePrice?.price, surgePriceType: checkoutController.surgePrice?.priceType,
          );
          double deliveryCharge = _calculateDeliveryCharge(
            store: checkoutController.store, address: activeUserAddress, distance: checkoutController.distance,
            extraCharge: checkoutController.extraCharge, orderType: checkoutController.orderType ?? 'delivery', orderAmount: orderAmount,
            surgePrice: checkoutController.surgePrice?.price, surgePriceType: checkoutController.surgePrice?.priceType,
          );

          if(checkoutController.orderType != 'take_away' && checkoutController.store != null) {
            _deliveryChargeForView = deliveryCharge == -1 ? 'calculating'.tr
                : deliveryCharge == 0 ? 'free'.tr : PriceConverter.convertPrice(deliveryCharge);
          }

          double extraPackagingCharge = widget.storeId != null ? 0 : _calculateExtraPackagingCharge(checkoutController);

          final ProActiveBenefit? proBenefit = Get.find<ProController>().activeOfferModel?.benefit;
          final bool isCampaign = _cartList != null && _cartList!.isNotEmpty && (_cartList!.first?.isCampaign ?? false);
          final bool isPro = !isCampaign && (Get.find<ProfileController>().userInfoModel?.proStatus ?? false);
          double proDiscount = isPro ? _calculateProDiscount(subTotal, discount, couponDiscount, proBenefit) : 0;
          double proDeliveryDiscount = (isPro && checkoutController.orderType != 'take_away' && checkoutController.orderType != 'dine_in')
              ? _calculateProDeliveryDiscount(subTotal - discount - couponDiscount, deliveryCharge, proBenefit) : 0;
          // Pro fully covers the delivery fee (full-free or 100% off) -> saver charge options are pointless.
          final bool proFreeDelivery = proDeliveryDiscount > 0 && (proBenefit?.offerType == ProOfferType.fullFree || (proBenefit?.chargeDiscountPercentage ?? 0) >= 100);

          // Saver delivery option fee adjustment (express +charge / slightly_delay -charge); 0 for the standard option.
          final double saverDeliveryAdjustment = (checkoutController.orderType == 'delivery' && checkoutController.isInstantDelivery)
              ? checkoutController.getSaverDeliveryChargeAdjustment(deliveryOption: checkoutController.selectedSaverDeliveryOption)
              : 0;

          double total = _calculateTotal(
            subTotal: subTotal, deliveryCharge: deliveryCharge, discount: discount,
            couponDiscount: couponDiscount, taxIncluded: (checkoutController.taxIncluded == 1), tax: checkoutController.orderTax ?? 0, orderType: checkoutController.orderType ?? 'delivery',
            tips: checkoutController.tips, additionalCharge: additionalCharge, extraPackagingCharge: extraPackagingCharge,
          );

          bool isPrescriptionRequired = _checkPrescriptionRequired();

          total = total - referralDiscount - proDiscount - proDeliveryDiscount + saverDeliveryAdjustment;

          if(widget.storeId != null && !AuthHelper.isGuestLoggedIn() && checkoutController.isFirstTimeCodActive){
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if(checkoutController.isFirstTimeCodActive) {
                checkoutController.setPaymentMethod(0, isUpdate: false);
              }
            });
          }
          checkoutController.setTotalAmount(total - (checkoutController.isPartialPay ? Get.find<ProfileController>().userInfoModel!.walletBalance! : 0));

          if(_payableAmount != checkoutController.viewTotalPrice && checkoutController.distance != null && isLoggedIn) {
            _payableAmount = checkoutController.viewTotalPrice;
            showCashBackSnackBar();
          }

          _setSinglePaymentActive();

          return (checkoutController.distance != null && checkoutController.store != null) ? Column(
            children: [
              ResponsiveHelper.isDesktop(context) ? Container(
                height: 64,
                color: Theme.of(context).primaryColor.withValues(alpha: 0.10),
                child: Center(child: Text('checkout'.tr, style: robotoMedium)),
              ) : const SizedBox(),

              Expanded(child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                child: FooterView(child: SizedBox(
                  width: Dimensions.webMaxWidth,
                  child: ResponsiveHelper.isDesktop(context) ? Padding(
                    padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      Expanded(flex: 6, child: TopSection(
                        checkoutController: checkoutController, charge: originalCharge, deliveryCharge: deliveryCharge,
                        addressList: addressList,
                        tomorrowClosed: tomorrowClosed, todayClosed: todayClosed, module : module, price: price,
                        discount: discount, addOns: addOns, address: address, cartList: _cartList, isCashOnDeliveryActive: _isCashOnDeliveryActive!,
                        isDigitalPaymentActive: _isDigitalPaymentActive!, isWalletActive: _isWalletActive, storeId: widget.storeId,
                        total: total, isOfflinePaymentActive: _isOfflinePaymentActive, guestNameTextEditingController: guestContactPersonNameController,
                        guestNumberTextEditingController: guestContactPersonNumberController, guestNumberNode: guestNumberNode,
                        guestEmailController: guestEmailController, guestEmailNode: guestEmailNode,
                        tooltipController1: tooltipController1, tooltipController2: tooltipController2, dmTipsTooltipController: tooltipController3,
                        guestPasswordController: guestPasswordController, guestConfirmPasswordController: guestConfirmPasswordController,
                        guestPasswordNode: guestPasswordNode, guestConfirmPasswordNode: guestConfirmPasswordNode, variationPrice: isPassedVariationPrice ? variations : 0,
                        deliveryChargeForView: _deliveryChargeForView, badWeatherCharge: badWeatherChargeForToolTip, extraChargeForToolTip: extraChargeForToolTip,
                        proFreeDelivery: proFreeDelivery,
                      )),
                      const SizedBox(width: Dimensions.paddingSizeLarge),

                      Expanded(flex: 4, child: BottomSection(
                        checkoutController: checkoutController, total: total, module: module!, subTotal: subTotal,
                        discount: discount, couponController: couponController, taxIncluded: (checkoutController.taxIncluded == 1), tax: checkoutController.orderTax!,
                        deliveryCharge: deliveryCharge,
                        todayClosed: todayClosed, tomorrowClosed: tomorrowClosed, orderAmount: orderAmount,
                        maxCodOrderAmount: maxCodOrderAmount, storeId: widget.storeId, taxPercent: _taxPercent, price: price, addOns : addOns,
                        isPrescriptionRequired: isPrescriptionRequired, checkoutButton: _orderPlaceButton(
                          checkoutController, todayClosed, tomorrowClosed, orderAmount,
                          deliveryCharge, checkoutController.orderTax!, discount, total, maxCodOrderAmount, isPrescriptionRequired,
                        ),
                        referralDiscount: referralDiscount, proDiscount: proDiscount, proDeliveryDiscount: proDeliveryDiscount,
                        variationPrice: isPassedVariationPrice ? variations : 0, extraDiscount: extraDiscount,
                        cartList: _cartList,
                      )),
                    ]),
                  ) : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    TopSection(
                      checkoutController: checkoutController, charge: originalCharge, deliveryCharge: deliveryCharge,
                      addressList: addressList,
                      tomorrowClosed: tomorrowClosed, todayClosed: todayClosed, module : module, price: price,
                      discount: discount, addOns: addOns, address: address, cartList: _cartList, isCashOnDeliveryActive: _isCashOnDeliveryActive!,
                      isDigitalPaymentActive: _isDigitalPaymentActive!, isWalletActive: _isWalletActive, storeId: widget.storeId,
                      total: total, isOfflinePaymentActive: _isOfflinePaymentActive, guestNameTextEditingController: guestContactPersonNameController,
                      guestNumberTextEditingController: guestContactPersonNumberController, guestNumberNode: guestNumberNode,
                      guestEmailController: guestEmailController, guestEmailNode: guestEmailNode,
                      tooltipController1: tooltipController1, tooltipController2: tooltipController2, dmTipsTooltipController: tooltipController3,
                      guestPasswordController: guestPasswordController, guestConfirmPasswordController: guestConfirmPasswordController,
                      guestPasswordNode: guestPasswordNode, guestConfirmPasswordNode: guestConfirmPasswordNode, variationPrice: isPassedVariationPrice ? variations : 0,
                      deliveryChargeForView: _deliveryChargeForView, badWeatherCharge: badWeatherChargeForToolTip, extraChargeForToolTip: extraChargeForToolTip,
                      proFreeDelivery: proFreeDelivery,
                    ),

                    BottomSection(
                      checkoutController: checkoutController, total: total, module: module!, subTotal: subTotal,
                      discount: discount, couponController: couponController, taxIncluded: (checkoutController.taxIncluded == 1), tax: checkoutController.orderTax!,
                      deliveryCharge: deliveryCharge,
                      todayClosed: todayClosed, tomorrowClosed: tomorrowClosed, orderAmount: orderAmount,
                      maxCodOrderAmount: maxCodOrderAmount, storeId: widget.storeId, taxPercent: _taxPercent, price: price, addOns : addOns,
                      isPrescriptionRequired: isPrescriptionRequired, checkoutButton: _orderPlaceButton(
                        checkoutController, todayClosed, tomorrowClosed, orderAmount, deliveryCharge,
                        checkoutController.orderTax!, discount, total, maxCodOrderAmount, isPrescriptionRequired,
                      ),
                      referralDiscount: referralDiscount, proDiscount: proDiscount, proDeliveryDiscount: proDeliveryDiscount,
                      variationPrice: isPassedVariationPrice ? variations : 0, extraDiscount: extraDiscount,
                      cartList: _cartList,
                    )
                  ]),
                )),
              )),

              ResponsiveHelper.isDesktop(context) ? const SizedBox() : Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.1), blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    /*Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeExtraSmall),
                      child: Row(children: [
                        Text(
                          checkoutController.isPartialPay ? 'due_payment'.tr : 'total_amount'.tr,
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                        ),

                        (checkoutController.taxIncluded == 1) ? Text(' ${'vat_tax_inc'.tr}', style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor,
                        )) : const SizedBox(),

                        const Expanded(child: SizedBox()),

                        PriceConverter.convertAnimationPrice(
                          checkoutController.viewTotalPrice,
                          textStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                        ),
                      ]),
                    ),*/

                    if(_cartList != null && _cartList!.map((cart) => cart?.item?.storeId).toSet().length > 1)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.2)),
                        ),
                        child: Row(children: [
                          Icon(Icons.auto_awesome, color: Theme.of(context).primaryColor, size: 16),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          Expanded(child: Text(
                            "note_more_than_one_order".tr,
                            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                          )),
                        ]),
                      ),

                    _orderPlaceButton(
                        checkoutController, todayClosed, tomorrowClosed, orderAmount, deliveryCharge, checkoutController.orderTax ?? 0, discount, total, maxCodOrderAmount, isPrescriptionRequired,
                    ),
                  ],
                ),
              ),

            ],
          ) : const CheckoutScreenShimmerView();
        });
      });
      });
      }) : NotLoggedInScreen(callBack: (value){
        initCall();
        setState(() {});
      }),
    );
  }


  Widget _orderPlaceButton(CheckoutController checkoutController, bool todayClosed, bool tomorrowClosed,
      double orderAmount, double? deliveryCharge, double tax, double? discount, double total, double? maxCodOrderAmount, bool isPrescriptionRequired) {
    return Container(
      width: Dimensions.webMaxWidth,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeLarge),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // if (checkoutController.orderType != 'take_away' && checkoutController.estimatedDuration != null && checkoutController.estimatedDuration! > 0)
            //   Padding(
            //     padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         Icon(Icons.timer_outlined, color: Theme.of(context).primaryColor, size: 20),
            //         const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            //         Text(
            //           '${'estimated_delivery_time'.tr == 'estimated_delivery_time' ? 'الوقت التقريبي للوصول' : 'estimated_delivery_time'.tr}: ${(checkoutController.estimatedDuration! / 60).ceil()} - ${(checkoutController.estimatedDuration! / 60).ceil() + 5} ${'minutes'.tr == 'minutes' ? 'دقيقة' : 'minutes'.tr}',
            //           style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor),
            //         ),
            //       ],
            //     ),
            //   ),
            CustomButton(
              isLoading: checkoutController.isLoading,
              buttonText: '${'confirm_order'.tr} - ${PriceConverter.convertPrice(total)}',
              onPressed: checkoutController.acceptTerms ? () {
          bool isAvailable = true;
          DateTime scheduleStartDate = DateTime.now();
          DateTime scheduleEndDate = DateTime.now();
          bool isGuestLogIn = AuthHelper.isGuestLoggedIn();
          if(checkoutController.timeSlots == null || checkoutController.timeSlots!.isEmpty) {
            isAvailable = false;
          }else {
            DateTime date = DateTime.now().add(Duration(days: checkoutController.selectedDateSlot));
            DateTime startTime = checkoutController.timeSlots![checkoutController.selectedTimeSlot].startTime!;
            DateTime endTime = checkoutController.timeSlots![checkoutController.selectedTimeSlot].endTime!;
            scheduleStartDate = DateTime(date.year, date.month, date.day, startTime.hour, startTime.minute+1);
            scheduleEndDate = DateTime(date.year, date.month, date.day, endTime.hour, endTime.minute+1);
            if(_cartList != null){
              for (CartModel? cart in _cartList!) {
                if (!DateConverter.isAvailable(
                  cart!.item!.availableTimeStarts, cart.item!.availableTimeEnds,
                  time: checkoutController.store!.scheduleOrder! ? scheduleStartDate : null,
                ) && !DateConverter.isAvailable(
                  cart.item!.availableTimeStarts, cart.item!.availableTimeEnds,
                  time: checkoutController.store!.scheduleOrder! ? scheduleEndDate : null,
                )) {
                  isAvailable = false;
                  break;
                }
              }
            }
          }

          if(isGuestLogIn && checkoutController.guestAddress == null && checkoutController.orderType != 'take_away' && checkoutController.orderType != 'pickup_center') {
            showCustomSnackBar('please_setup_your_delivery_address_first'.tr);
          } else if(isGuestLogIn && guestContactPersonNumberController.text.trim().isEmpty) {
            showCustomSnackBar('please_enter_contact_person_number'.tr);
          } else if(isGuestLogIn && (checkoutController.orderType == 'take_away' || checkoutController.orderType == 'pickup_center') && guestContactPersonNameController.text.isEmpty) {
            showCustomSnackBar('please_enter_contact_person_name'.tr);
          }else if(isGuestLogIn && (checkoutController.orderType == 'take_away' || checkoutController.orderType == 'pickup_center') && guestEmailController.text.isEmpty) {
            showCustomSnackBar('please_enter_contact_person_email'.tr);
          }else if(isGuestLogIn && checkoutController.isCreateAccount && guestPasswordController.text.isEmpty) {
            showCustomSnackBar('enter_password'.tr);
          }else if(isGuestLogIn && checkoutController.isCreateAccount && guestConfirmPasswordController.text.isEmpty) {
            showCustomSnackBar('enter_confirm_password'.tr);
          }else if(isGuestLogIn && checkoutController.isCreateAccount && (guestPasswordController.text != guestConfirmPasswordController.text)) {
            showCustomSnackBar('confirm_password_does_not_matched'.tr);
          }else if(isPrescriptionRequired && checkoutController.pickedPrescriptions.isEmpty) {
            showCustomSnackBar('you_must_upload_prescription_for_this_order'.tr);
          } else if(!_isCashOnDeliveryActive! && !_isDigitalPaymentActive! && !_isWalletActive && !_isOfflinePaymentActive) {
            showCustomSnackBar('no_payment_method_is_enabled'.tr);
          }else if(checkoutController.paymentMethodIndex == 1 && !checkoutController.isPartialPay && ((Get.find<ProfileController>().userInfoModel?.walletBalance ?? 0) < total)) {
            showCustomSnackBar('you_do_not_have_sufficient_balance_in_wallet'.tr);
          }else if(checkoutController.paymentMethodIndex == 2 && (checkoutController.digitalPaymentName == 'easy_wallet' || checkoutController.digitalPaymentName == 'floosak' || (checkoutController.digitalPaymentName?.toLowerCase().contains('wallet') ?? false) || (checkoutController.digitalPaymentName?.toLowerCase().contains('floosak') ?? false)) && checkoutController.purchaseCodeController.text.trim().isEmpty) {
            final digitalGateways = Get.find<SplashController>().configModel?.activePaymentMethodList;
            final selectedGateway = digitalGateways?.firstWhereOrNull((g) => g.getWay == checkoutController.digitalPaymentName);
            Get.dialog(
              PaymentOnboardingDialog(
                paymentMethodName: checkoutController.digitalPaymentName ?? '',
                paymentTitle: selectedGateway?.getWayTitle ?? (checkoutController.digitalPaymentName == 'easy_wallet' ? 'Easy Wallet' : 'Floosak'),
                paymentImage: selectedGateway?.getWayImageFullUrl,
                totalPrice: total,
              ),
            );
          }else if(checkoutController.paymentMethodIndex == -1) {
            if(ResponsiveHelper.isDesktop(context)){
              if(_isCashOnDeliveryActive! || _isDigitalPaymentActive! || _isWalletActive || _isOfflinePaymentActive){
                Get.dialog(Dialog(backgroundColor: Colors.transparent, child: PaymentMethodBottomSheet(
                  isCashOnDeliveryActive: _isCashOnDeliveryActive!, isDigitalPaymentActive: _isDigitalPaymentActive!,
                  isWalletActive: _isWalletActive, storeId: widget.storeId, totalPrice: total, isOfflinePaymentActive: _isOfflinePaymentActive,
                )));
              }else{
                showCustomSnackBar('no_payment_method_found'.tr);
              }
            }else{
              if(_isCashOnDeliveryActive! || _isDigitalPaymentActive! || _isWalletActive || _isOfflinePaymentActive){
                Get.bottomSheet(
                  PaymentMethodBottomSheet(
                    isCashOnDeliveryActive: _isCashOnDeliveryActive!, isDigitalPaymentActive: _isDigitalPaymentActive!,
                    isWalletActive: _isWalletActive, storeId: widget.storeId, totalPrice: total, isOfflinePaymentActive: _isOfflinePaymentActive,
                  ),
                  backgroundColor: Colors.transparent, isScrollControlled: true, useRootNavigator: true,
                );
              }else{
                showCustomSnackBar('no_payment_method_found'.tr);
              }
            }
          } else if(AuthHelper.isGuestLoggedIn() && checkoutController.paymentMethodIndex == 0) {
            showCustomSnackBar('cash_on_delivery_is_not_available_for_guest_user'.tr);
          } else if(orderAmount < checkoutController.store!.minimumOrder! && widget.storeId == null) {
            showCustomSnackBar('${'minimum_order_amount_is'.tr} ${checkoutController.store!.minimumOrder}');
          }else if(checkoutController.tipController.text.isNotEmpty && checkoutController.tipController.text != 'not_now' && double.parse(checkoutController.tipController.text.trim()) < 0) {
            showCustomSnackBar('tips_can_not_be_negative'.tr);
          }else if((checkoutController.selectedDateSlot == 0 && todayClosed) || (checkoutController.selectedDateSlot == 1 && tomorrowClosed)) {
            showCustomSnackBar(Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText!
                ? 'restaurant_is_closed'.tr : 'store_is_closed'.tr);
          }else if(checkoutController.paymentMethodIndex == 0 && _isCashOnDeliveryActive! && maxCodOrderAmount != null && maxCodOrderAmount != 0 && (total > maxCodOrderAmount) && widget.storeId == null){
            showCustomSnackBar('${'you_cant_order_more_then'.tr} ${PriceConverter.convertPrice(maxCodOrderAmount)} ${'in_cash_on_delivery'.tr}');
          }else if (checkoutController.timeSlots == null || checkoutController.timeSlots!.isEmpty) {
            if(checkoutController.store!.scheduleOrder!) {
              showCustomSnackBar('select_a_time'.tr);
            }else {
              showCustomSnackBar(Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText!
                  ? 'restaurant_is_closed'.tr : 'store_is_closed'.tr);
            }
          }else if (!isAvailable) {
            showCustomSnackBar('one_or_more_products_are_not_available_for_this_selected_time'.tr);
          }else if (checkoutController.orderType == 'pickup_center' && checkoutController.selectedPickupCenter == null) {
            showCustomSnackBar('select_center'.tr);
          }else if (checkoutController.orderType != 'take_away' && checkoutController.orderType != 'pickup_center' && checkoutController.distance == -1 && deliveryCharge == -1) {
            showCustomSnackBar('delivery_fee_not_set_yet'.tr);
          }else if (widget.storeId != null && (_cartList == null || _cartList!.isEmpty) && checkoutController.pickedPrescriptions.isEmpty) {
            showCustomSnackBar('please_upload_your_prescription_images'.tr);
          }else if (!checkoutController.acceptTerms) {
            showCustomSnackBar('please_accept_privacy_policy_trams_conditions_refund_policy_first'.tr);
          }else if (checkoutController.orderType != 'take_away' && checkoutController.orderType != 'pickup_center' && (address.isEmpty || !address[checkoutController.addressIndex!].zoneIds!.contains(checkoutController.store!.zoneId))) {
            showCustomSnackBar(address.isEmpty ? 'please_setup_your_delivery_address_first'.tr : 'delivery_address_is_not_valid_for_the_selected_zone'.tr);
          }
          else {

            int addrIndex = (checkoutController.addressIndex != null && checkoutController.addressIndex! < address.length) ? checkoutController.addressIndex! : 0;
            AddressModel? finalAddress = isGuestLogIn ? checkoutController.guestAddress : (address.isEmpty ? AddressHelper.getUserAddressFromSharedPref() : address[addrIndex]);

            if(isGuestLogIn) {
              String number = (checkoutController.countryDialCode ?? '') + guestContactPersonNumberController.text.trim();
              AddressModel? prefAddress = AddressHelper.getUserAddressFromSharedPref();
              finalAddress = AddressModel(
                id: checkoutController.guestAddress?.id,
                addressType: checkoutController.guestAddress?.addressType ?? 'others',
                contactPersonName: guestContactPersonNameController.text.isNotEmpty ? guestContactPersonNameController.text : 'Guest User',
                contactPersonNumber: number,
                address: checkoutController.guestAddress?.address ?? prefAddress?.address ?? '',
                latitude: checkoutController.guestAddress?.latitude ?? prefAddress?.latitude ?? '0',
                longitude: checkoutController.guestAddress?.longitude ?? prefAddress?.longitude ?? '0',
                zoneId: checkoutController.guestAddress?.zoneId ?? prefAddress?.zoneId,
                email: guestEmailController.text.isNotEmpty ? guestEmailController.text : 'guest@mile.com',
                streetNumber: checkoutController.guestAddress?.streetNumber,
                house: checkoutController.guestAddress?.house,
                floor: checkoutController.guestAddress?.floor,
              );
            }

            if(!isGuestLogIn && finalAddress!.contactPersonNumber == 'null'){
              finalAddress.contactPersonNumber = Get.find<ProfileController>().userInfoModel!.phone;
            }

            if(widget.storeId == null || (_cartList != null && _cartList!.isNotEmpty)){

              List<OnlineCart> carts = [];
              for (int index = 0; index < _cartList!.length; index++) {
                CartModel cart = _cartList![index]!;
                List<int?> addOnIdList = [];
                List<int?> addOnQtyList = [];
                for (var addOn in cart.addOnIds!) {
                  addOnIdList.add(addOn.id);
                  addOnQtyList.add(addOn.quantity);
                }

                List<OrderVariation> variations = [];
                if(Get.find<SplashController>().getModuleConfig(cart.item!.moduleType).newVariation!) {
                  for(int i=0; i<cart.item!.foodVariations!.length; i++) {
                    if(cart.foodVariations![i].contains(true)) {
                      variations.add(OrderVariation(name: cart.item!.foodVariations![i].name, values: OrderVariationValue(label: [])));
                      for(int j=0; j<cart.item!.foodVariations![i].variationValues!.length; j++) {
                        if(cart.foodVariations![i][j]!) {
                          variations[variations.length-1].values!.label!.add(cart.item!.foodVariations![i].variationValues![j].level);
                        }
                      }
                    }
                  }
                }
                carts.add(OnlineCart(
                  cartId: cart.id, itemId: cart.item!.id, itemCampaignId: cart.isCampaign! ? cart.item!.id : null,
                  price: cart.discountedPrice.toString(), variant: '',
                  variation: Get.find<SplashController>().getModuleConfig(cart.item!.moduleType).newVariation! ? null : cart.variation,
                  variations: Get.find<SplashController>().getModuleConfig(cart.item!.moduleType).newVariation! ? variations : null,
                  quantity: cart.quantity, addOnIds: addOnIdList, addOns: cart.addOns, addOnQtys: addOnQtyList, model: 'Item', itemType: cart.isCampaign! ? "AppModelsItemCampaign" : null,
                  note: cart.note,
                ));
              }

              PlaceOrderBodyModel placeOrderBody = PlaceOrderBodyModel(
                cart: carts, couponDiscountAmount: Get.find<CouponController>().discount, distance: checkoutController.distance,
                scheduleAt: !checkoutController.store!.scheduleOrder! ? null : (checkoutController.selectedDateSlot == 0
                    && checkoutController.selectedTimeSlot == 0) ? null : DateConverter.dateToDateAndTime(scheduleEndDate),
                orderAmount: total, orderNote: checkoutController.noteController.text, orderType: checkoutController.orderType,
                paymentMethod: checkoutController.paymentMethodIndex == 0 ? 'cash_on_delivery'
                    : checkoutController.paymentMethodIndex == 1 ? 'wallet'
                    : checkoutController.paymentMethodIndex == 2 ? 'digital_payment' : 'offline_payment',
                couponCode: (Get.find<CouponController>().discount! > 0 || (Get.find<CouponController>().coupon != null
                    && Get.find<CouponController>().freeDelivery)) ? Get.find<CouponController>().coupon!.code : null,
                storeId: _cartList![0]!.item!.storeId,
                address: (checkoutController.orderType == 'pickup_center' && checkoutController.selectedPickupCenter != null)
                    ? '${checkoutController.selectedPickupCenter!.name ?? ''} - ${checkoutController.selectedPickupCenter!.address ?? ''}'
                    : finalAddress!.address,
                latitude: (checkoutController.orderType == 'pickup_center' && checkoutController.selectedPickupCenter != null)
                    ? checkoutController.selectedPickupCenter!.latitude
                    : finalAddress!.latitude,
                longitude: (checkoutController.orderType == 'pickup_center' && checkoutController.selectedPickupCenter != null)
                    ? checkoutController.selectedPickupCenter!.longitude
                    : finalAddress!.longitude,
                senderZoneId: null, addressType: finalAddress!.addressType,
                contactPersonName: finalAddress.contactPersonName ?? '${Get.find<ProfileController>().userInfoModel!.fName} '
                    '${Get.find<ProfileController>().userInfoModel!.lName}',
                contactPersonNumber: finalAddress.contactPersonNumber ?? Get.find<ProfileController>().userInfoModel!.phone,
                streetNumber: isGuestLogIn ? finalAddress.streetNumber??'' : checkoutController.streetNumberController.text.trim(),
                house: isGuestLogIn ? finalAddress.house??'' : checkoutController.houseController.text.trim(),
                floor: isGuestLogIn ? finalAddress.floor??'' : checkoutController.floorController.text.trim(),
                discountAmount: discount, taxAmount: tax, receiverDetails: null, parcelCategoryId: null,
                chargePayer: null, dmTips: (checkoutController.orderType == 'take_away' || checkoutController.orderType == 'pickup_center' || checkoutController.tipController.text == 'not_now') ? '' : checkoutController.tipController.text.trim(),
                cutlery: Get.find<CartController>().addCutlery ? 1 : 0,
                unavailableItemNote: Get.find<CartController>().notAvailableIndex != -1 ? Get.find<CartController>().notAvailableList[Get.find<CartController>().notAvailableIndex] : '',
                deliveryInstruction: checkoutController.selectedInstruction != -1 ? AppConstants.deliveryInstructionList[checkoutController.selectedInstruction] : '',
                partialPayment: checkoutController.isPartialPay ? 1 : 0, guestId: isGuestLogIn ? int.parse(AuthHelper.getGuestId()) : 0,
                isBuyNow: widget.fromCart ? 0 : 1, guestEmail: isGuestLogIn ? finalAddress.email : null,
                extraPackagingAmount: Get.find<CartController>().needExtraPackage ? checkoutController.store!.extraPackagingAmount : 0,
                createNewUser: checkoutController.isCreateAccount ? 1 : 0, password: guestPasswordController.text,
                bringChangeAmount: checkoutController.paymentMethodIndex == 0 && checkoutController.exchangeAmount > 0 ? checkoutController.exchangeAmount : null,
                storeDistances: checkoutController.storeDistances.map((key, value) => MapEntry(key.toString(), value)),
                digitalPaymentGateway: checkoutController.paymentMethodIndex == 2 ? checkoutController.digitalPaymentName : null,
                purchaseCode: checkoutController.paymentMethodIndex == 2 && (checkoutController.digitalPaymentName == 'easy_wallet' || checkoutController.digitalPaymentName == 'floosak') ? checkoutController.purchaseCodeController.text : null,
                productReferrerId: Get.find<AuthController>().getProductRefCode().isNotEmpty ? Get.find<AuthController>().getProductRefCode() : null,
                saverDeliveryType: checkoutController.saverDeliveryType,
                monthlySubscribe: checkoutController.monthlySubscribe,
                pickupCenterName: checkoutController.orderType == 'pickup_center' ? checkoutController.selectedPickupCenter?.name : null,
                phone: checkoutController.orderType == 'pickup_center' ? (checkoutController.selectedPickupCenter?.phone ?? finalAddress!.contactPersonNumber ?? Get.find<ProfileController>().userInfoModel?.phone) : finalAddress!.contactPersonNumber,
              );

              if(checkoutController.paymentMethodIndex == 3){
                Get.toNamed(RouteHelper.getOfflinePaymentScreen(
                  placeOrderBody: placeOrderBody, zoneId: checkoutController.store!.zoneId!, total: checkoutController.viewTotalPrice!,
                  maxCodOrderAmount: maxCodOrderAmount, fromCart: widget.fromCart, isCodActive: _isCashOnDeliveryActive, forParcel: false,
                ));
              } else {
                checkoutController.placeOrder(placeOrderBody, checkoutController.store!.zoneId, total, maxCodOrderAmount, widget.fromCart, _isCashOnDeliveryActive!, checkoutController.pickedPrescriptions);
              }
            }else{
              checkoutController.placePrescriptionOrder(
                widget.storeId, checkoutController.store!.zoneId, checkoutController.distance,
                (checkoutController.orderType == 'pickup_center' && checkoutController.selectedPickupCenter != null)
                    ? '${checkoutController.selectedPickupCenter!.name ?? ''} - ${checkoutController.selectedPickupCenter!.address ?? ''}'
                    : finalAddress!.address!,
                (checkoutController.orderType == 'pickup_center' && checkoutController.selectedPickupCenter != null)
                    ? checkoutController.selectedPickupCenter!.longitude!
                    : finalAddress!.longitude!,
                (checkoutController.orderType == 'pickup_center' && checkoutController.selectedPickupCenter != null)
                    ? checkoutController.selectedPickupCenter!.latitude!
                    : finalAddress!.latitude!,
                checkoutController.noteController.text,
                checkoutController.pickedPrescriptions, (checkoutController.orderType == 'take_away' || checkoutController.tipController.text == 'not_now')
                ? '' : checkoutController.tipController.text.trim(), checkoutController.selectedInstruction != -1
                ? AppConstants.deliveryInstructionList[checkoutController.selectedInstruction] : '', 0, 0, widget.fromCart, _isCashOnDeliveryActive!,
              );
            }
          }
        } : null),
          ],
        ),
      ),
    );
  }

  List<DropdownItem<int>> _getDropdownAddressList({required BuildContext context, required List<AddressModel>? addressList, required Store? store}) {
    List<DropdownItem<int>> dropDownAddressList = [];
    List<AddressModel> addresses = _getAddressList(addressList: addressList, store: store);

    for (int index = 0; index < addresses.length; index++) {
      dropDownAddressList.add(DropdownItem<int>(
        value: index,
        child: SizedBox(
          width: context.width > Dimensions.webMaxWidth ? Dimensions.webMaxWidth - 50 : context.width - 50,
          child: AddressWidget(
            address: addresses[index],
            fromAddress: false,
            fromCheckout: true,
          ),
        ),
      ));
    }

    return dropDownAddressList;
  }

  String _getAddressKey(AddressModel address) {
    String lat = (double.tryParse(address.latitude ?? '') ?? 0).toStringAsFixed(3);
    String lng = (double.tryParse(address.longitude ?? '') ?? 0).toStringAsFixed(3);
    String addrText = (address.address ?? '').trim().toLowerCase();
    return '${lat}_${lng}_$addrText';
  }

  List<AddressModel> _getAddressList({required List<AddressModel>? addressList, required Store? store}) {
    List<AddressModel> address = [];
    Set<String> addedKeys = {};

    AddressModel? defaultAddress = AddressHelper.getUserAddressFromSharedPref();
    if (defaultAddress != null) {
      address.add(defaultAddress);
      addedKeys.add(_getAddressKey(defaultAddress));
      if (defaultAddress.id != null) {
        addedKeys.add('id_${defaultAddress.id}');
      }
    }

    if(addressList != null && addressList.isNotEmpty) {
      List<AddressModel> reversedList = addressList.reversed.toList();

      for(int index=0; index<reversedList.length; index++) {
        AddressModel item = reversedList[index];
        bool inZone = true;
        if (store != null && store.zoneId != null) {
          int targetZone = store.zoneId!;
          bool matchZoneId = (item.zoneId != null && item.zoneId.toString() == targetZone.toString());
          bool matchZoneIds = (item.zoneIds != null && item.zoneIds!.any((z) => z.toString() == targetZone.toString()));
          inZone = matchZoneId || matchZoneIds || item.zoneId == null;
        }
        if(inZone) {
          if (!(item.latitude == '15.369445' && item.longitude == '44.191006')) {
            String key = _getAddressKey(item);
            String idKey = item.id != null ? 'id_${item.id}' : key;
            if (!addedKeys.contains(key) && !addedKeys.contains(idKey)) {
              address.add(item);
              addedKeys.add(key);
              addedKeys.add(idKey);
            }
          }
        }
      }

      for(int index=0; index<reversedList.length; index++) {
        AddressModel item = reversedList[index];
        if (!(item.latitude == '15.369445' && item.longitude == '44.191006')) {
          String key = _getAddressKey(item);
          String idKey = item.id != null ? 'id_${item.id}' : key;
          if (!addedKeys.contains(key) && !addedKeys.contains(idKey)) {
            address.add(item);
            addedKeys.add(key);
            addedKeys.add(idKey);
          }
        }
      }
    }
    return address;
  }

  Pivot? _getModuleData({required Store? store}) {
    Pivot? moduleData;
    int? currentModuleId = Get.find<SplashController>().module?.id;
    AddressModel? userAddress = AddressHelper.getUserAddressFromSharedPref();
    if(store != null && userAddress?.zoneData != null && currentModuleId != null) {
      for(ZoneData zData in userAddress!.zoneData!) {
        if (zData.modules != null) {
          for(Modules m in zData.modules!) {
            if(m.id == currentModuleId && m.pivot != null && (m.pivot!.zoneId == store.zoneId || zData.id == store.zoneId)) {
              moduleData = m.pivot;
              break;
            }
          }
        }
      }
    }
    return moduleData;
  }

  bool _checkCODActive({required Store? store}) {
    if (AuthHelper.isGuestLoggedIn()) {
      return false;
    }
    return true;
  }

  bool _checkDigitalPaymentActive({required Store? store}) {
    return true;
  }

  double _calculatePrice({required Store? store, required List<CartModel?>? cartList}) {
    double price = 0;
    if(cartList != null) {
      for (var cartModel in cartList) {
        if (cartModel?.item == null) continue;
        bool isNewVariation = (Get.find<SplashController>().getModuleConfig(cartModel!.item!.moduleType).newVariation ?? false);
        if(isNewVariation){
          price = price + ((cartModel.item!.price ?? 0) * (cartModel.quantity ?? 1));
        } else {
          price = _calculateVariationPrice(store: store, cartList: cartList);
        }
      }
    }
    return PriceConverter.toFixed(price);
  }

  double _calculateAddonsPrice({required Store? store, required List<CartModel?>? cartList}) {
    double addOns = 0;
    if(store != null && cartList != null) {
      for (var cartModel in cartList) {
        if (cartModel?.item == null || cartModel?.addOnIds == null || cartModel?.item?.addOns == null) continue;
        List<AddOns> addOnList = [];
        for (var addOnId in cartModel!.addOnIds!) {
          for (AddOns addOnsItem in cartModel.item!.addOns!) {
            if (addOnsItem.id == addOnId.id) {
              addOnList.add(addOnsItem);
              break;
            }
          }
        }
        for (int index = 0; index < addOnList.length; index++) {
          double p = addOnList[index].price ?? 0;
          int q = (index < cartModel.addOnIds!.length) ? (cartModel.addOnIds![index].quantity ?? 1) : 1;
          addOns = addOns + (p * q);
        }
      }
    }
    return PriceConverter.toFixed(addOns);
  }

  double _calculateVariationPrice({required Store? store, required List<CartModel?>? cartList, bool calculateDiscount = false, bool calculateWithoutDiscount = false}) {
    double variationPrice = 0;
    double variationDiscount = 0;
    if(store != null && cartList != null) {
      for (var cartModel in cartList) {
        if (cartModel?.item == null) continue;
        double? discount = cartModel!.item!.discount;
        String? discountType = cartModel.item!.discountType;

        bool isNewVar = Get.find<SplashController>().getModuleConfig(cartModel.item!.moduleType).newVariation ?? false;
        if(isNewVar) {
          isPassedVariationPrice = true;
          if (cartModel.item!.foodVariations != null && cartModel.foodVariations != null) {
            for(int index = 0; index< cartModel.item!.foodVariations!.length; index++) {
              if (index < cartModel.foodVariations!.length && cartModel.item!.foodVariations![index].variationValues != null) {
                for(int i=0; i<cartModel.item!.foodVariations![index].variationValues!.length; i++) {
                  if(i < cartModel.foodVariations![index].length && (cartModel.foodVariations![index][i] ?? false)) {
                    double optPrice = cartModel.item!.foodVariations![index].variationValues![i].optionPrice ?? 0;
                    int qty = cartModel.quantity ?? 1;
                    double? converted = PriceConverter.convertWithDiscount(optPrice, discount, discountType, isFoodVariation: true);
                    variationPrice += ((converted ?? optPrice) * qty);
                    variationDiscount += (optPrice * qty);
                  }
                }
              }
            }
          }
        } else {

          String variationType = '';
          if (cartModel.variation != null) {
            for(int i=0; i<cartModel.variation!.length; i++) {
              variationType = cartModel.variation![i].type ?? '';
            }
          }

          if(cartModel.item!.variations != null && cartModel.item!.variations!.isNotEmpty) {
            for (Variation variation in cartModel.item!.variations!) {
              if (variation.type == variationType) {
                variationPrice += ((variation.price ?? 0) * (cartModel.quantity ?? 1));
                break;
              }
            }
          } else {
            double itemPrice = cartModel.item!.price ?? 0;
            int qty = cartModel.quantity ?? 1;
            double? converted = PriceConverter.convertWithDiscount(itemPrice, discount, discountType);
            variationDiscount += ((converted ?? itemPrice) * qty);
            variationPrice += (itemPrice * qty);
          }

        }
      }
    }
    if(calculateDiscount) {
      return (variationDiscount - variationPrice);
    } else if(calculateWithoutDiscount) {
      return variationDiscount;
    } else {
      return variationPrice;
    }
  }

  double _calculateDiscountPrice({required Store? store, required List<CartModel?>? cartList, required double price, required double addOns, required bool calStoreDiscount}) {
    double discount = 0;
    if (store != null && cartList != null) {
      for (var cartModel in cartList) {
        double? dis = (store.discount != null
            && DateConverter.isAvailable(store.discount!.startTime, store.discount!.endTime))
            && calStoreDiscount ? store.discount!.discount : cartModel!.item!.discount;

        String? disType = (store.discount != null
            && DateConverter.isAvailable(store.discount!.startTime, store.discount!.endTime))
            && calStoreDiscount ? 'percent' : cartModel?.item!.discountType;

        if(Get.find<SplashController>().getModuleConfig(cartModel!.item!.moduleType).newVariation!) {
          double d = ((cartModel.item!.price! - PriceConverter.convertWithDiscount(cartModel.item!.price!, dis, disType)!) * cartModel.quantity!);
          discount = discount + d;
          if(disType == 'percent' && discount != 0) {
            discount = discount + _calculateFoodVariationDiscount(cartModel: cartModel);
          }
        } else {
          String variationType = '';
          double variationPrice = 0;
          double variationWithoutDiscountPrice = 0;
          for(int i=0; i<cartModel.variation!.length; i++) {
            variationType = cartModel.variation![i].type!;
          }
          if(cartModel.item!.variations!.isNotEmpty){
            for (Variation variation in cartModel.item!.variations!) {
              if (variation.type == variationType) {
                variationPrice += (PriceConverter.convertWithDiscount(variation.price!, dis, disType)! * cartModel.quantity!);
                variationWithoutDiscountPrice += (variation.price! * cartModel.quantity!);
                break;
              }
            }
            discount = discount + (variationWithoutDiscountPrice - variationPrice);

          } else {
            double d = ((cartModel.item!.price! - PriceConverter.convertWithDiscount(cartModel.item!.price!, dis, disType)!) * cartModel.quantity!);
            discount = discount + d;
          }
        }

      }
    }

    if(calStoreDiscount){
      if (store != null && store.discount != null) {
        if (store.discount!.maxDiscount != 0 && store.discount!.maxDiscount! < discount) {
          discount = store.discount!.maxDiscount!;
        }
        if (store.discount!.minPurchase != 0 && store.discount!.minPurchase! > (price + addOns)) {
          discount = 0;
        }
      }
    }
    return PriceConverter.toFixed(discount);
  }

  double _getDiscountPrice(double storeDiscountPrice, double itemDiscountPrice) {
    double discountPrice = 0;
    if(storeDiscountPrice > itemDiscountPrice) {
      discountPrice = storeDiscountPrice;
    } else if(itemDiscountPrice > storeDiscountPrice) {
      discountPrice = itemDiscountPrice;
    } else {
      discountPrice = itemDiscountPrice;
    }
    return discountPrice;
  }

  double _getExtraDiscountPrice(double storeDiscountPrice, double itemDiscountPrice) {
    double extraDiscount = 0;
    if(storeDiscountPrice > itemDiscountPrice) {
      extraDiscount = storeDiscountPrice - itemDiscountPrice;
    } else if(itemDiscountPrice > storeDiscountPrice) {
      extraDiscount = 0;
    } else {
      extraDiscount = 0;
    }
    return extraDiscount;
  }

  double _calculateFoodVariationDiscount({required CartModel? cartModel}) {
    double variationPrice = 0;
    double variationDiscount = 0;
    if(cartModel != null) {
      double? discount = cartModel.item!.discount;
      String? discountType = cartModel.item!.discountType;
      for (int index = 0; index < cartModel.item!.foodVariations!.length; index++) {
        for (int i = 0; i < cartModel.item!.foodVariations![index].variationValues!.length; i++) {
          if (cartModel.foodVariations![index][i]!) {
            variationPrice += (PriceConverter.convertWithDiscount(
                cartModel.item!.foodVariations![index].variationValues![i].optionPrice!, discount, discountType,
                isFoodVariation: true)! * cartModel.quantity!);
            variationDiscount +=
            (cartModel.item!.foodVariations![index].variationValues![i].optionPrice! * cartModel.quantity!);
          }
        }
      }
    }
    return (variationDiscount - variationPrice);
  }

  double _calculateOrderAmount({required double price, required double variations, required double discount, required double addOns, required double couponDiscount, required List<CartModel?>? cartList, required double referralDiscount}) {
    double orderAmount = 0;
    double variationPrice = 0;
    if(cartList != null && cartList.isNotEmpty && Get.find<SplashController>().getModuleConfig(cartList[0]?.item?.moduleType).newVariation!){
      variationPrice = variations;
    }
    orderAmount = (price + variationPrice - discount) + addOns - couponDiscount - referralDiscount;
    return PriceConverter.toFixed(orderAmount);
  }

  double _calculateSubTotal({required double price, required double addOns, required double variations, required List<CartModel?>? cartList}) {
    double subTotal = 0;
    bool isFoodVariation = false;

    if(cartList != null && cartList.isNotEmpty) {
      isFoodVariation = Get.find<SplashController>().getModuleConfig(cartList[0]!.item!.moduleType).newVariation!;
    }
    if(isFoodVariation){
      subTotal = price + addOns + variations;
    } else {
      subTotal = price;
    }

    return subTotal;
  }

  double _calculateSingleOriginalDeliveryCharge({required Store? store, required AddressModel address, required double? distance, required double? extraCharge, double? surgePrice, String? surgePriceType}) {
    double deliveryCharge = -1;

    Pivot? moduleData;
    List<ZoneData>? zList = address.zoneData ?? AddressHelper.getUserAddressFromSharedPref()?.zoneData;
    int? currentModuleId = Get.find<SplashController>().module?.id;
    if(store != null && zList != null && currentModuleId != null) {
      for(ZoneData zData in zList) {
        if (zData.modules != null) {
          for(Modules m in zData.modules!) {
            if(m.id == currentModuleId && m.pivot != null && m.pivot!.zoneId == store.zoneId) {
              moduleData = m.pivot;
              break;
            }
          }
        }
      }
    }
    double perKmCharge = 0;
    double minimumCharge = 0;
    double? maximumCharge = 0;

    bool isBatchedOrder = Get.find<CheckoutController>().isAiBatched;

    if(store != null && store.selfDeliverySystem == 1) {
      perKmCharge = isBatchedOrder ? (store.perKmShippingChargeGroup ?? store.perKmShippingCharge ?? 0) : (store.perKmShippingCharge ?? 0);
      minimumCharge = isBatchedOrder ? (store.minimumShippingChargeGroup ?? store.minimumShippingCharge ?? 0) : (store.minimumShippingCharge ?? 0);
      maximumCharge = store.maximumShippingCharge;
    }else if(store != null && moduleData != null && moduleData.deliveryChargeType == 'distance') {
      perKmCharge = isBatchedOrder ? (moduleData.perKmShippingChargeGroup ?? store.perKmShippingChargeGroup ?? moduleData.perKmShippingCharge ?? 0) : (moduleData.perKmShippingCharge ?? 0);
      minimumCharge = isBatchedOrder ? (moduleData.minimumShippingChargeGroup ?? store.minimumShippingChargeGroup ?? moduleData.minimumShippingCharge ?? 0) : (moduleData.minimumShippingCharge ?? 0);
      maximumCharge = moduleData.maximumShippingCharge;
    } else if(store != null && moduleData != null && moduleData.deliveryChargeType == 'fixed') {
      perKmCharge = moduleData.fixedShippingCharge ?? 0;
      minimumCharge = moduleData.fixedShippingCharge ?? 0;
      maximumCharge = moduleData.fixedShippingCharge ?? 0;
    } else if (store != null) {
      ConfigModel? configModel = Get.find<SplashController>().configModel;
      perKmCharge = (store.perKmShippingCharge != null && store.perKmShippingCharge! > 0) ? store.perKmShippingCharge!
          : (configModel?.perKmShippingCharge ?? 150);
      minimumCharge = (store.minimumShippingCharge != null && store.minimumShippingCharge! > 0) ? store.minimumShippingCharge!
          : (configModel?.minimumShippingCharge ?? 300);
    }

    if (perKmCharge == 0) {
      ConfigModel? configModel = Get.find<SplashController>().configModel;
      perKmCharge = configModel?.perKmShippingCharge ?? 150;
    }
    if (minimumCharge == 0) {
      ConfigModel? configModel = Get.find<SplashController>().configModel;
      minimumCharge = configModel?.minimumShippingCharge ?? 300;
    }

    final checkoutController = Get.find<CheckoutController>();
    if (checkoutController.orderType == 'pickup_center') {
      double calcDistance = 0;
      if (checkoutController.selectedPickupCenter != null && checkoutController.selectedPickupCenter!.latitude != null) {
        double? sLat = double.tryParse(store?.latitude ?? '');
        double? sLng = double.tryParse(store?.longitude ?? '');
        double? pLat = double.tryParse(checkoutController.selectedPickupCenter!.latitude!);
        double? pLng = double.tryParse(checkoutController.selectedPickupCenter!.longitude!);
        if (sLat != null && sLng != null && pLat != null && pLng != null && sLat != 0 && pLat != 0) {
          calcDistance = Geolocator.distanceBetween(sLat, sLng, pLat, pLng) / 1000;
        }
      }
      if (calcDistance == 0 && distance != null && distance > 0) {
        calcDistance = distance;
      }
      if (calcDistance == 0) {
        calcDistance = 2.5;
      }

      bool isSameZone = store != null && checkoutController.selectedPickupZone != null && store.zoneId == checkoutController.selectedPickupZone!.id;

      String? chargeType = isSameZone ? moduleData?.pickupCenterChargeType : moduleData?.pickupCenterOutsideChargeType;
      double fixedCharge = isSameZone ? (moduleData?.pickupCenterFixedCharge ?? 0) : (moduleData?.pickupCenterOutsideFixedCharge ?? 0);
      double pkCharge = isSameZone ? (moduleData?.pickupCenterPerKmCharge ?? 0) : (moduleData?.pickupCenterOutsidePerKmCharge ?? 0);
      double minCharge = isSameZone ? (moduleData?.pickupCenterMinimumCharge ?? 0) : (moduleData?.pickupCenterOutsideMinimumCharge ?? 0);

      if (chargeType == 'fixed') {
        deliveryCharge = fixedCharge;
      } else {
        if (pkCharge <= 0) pkCharge = perKmCharge;
        if (minCharge <= 0) minCharge = minimumCharge;
        deliveryCharge = calcDistance * pkCharge;
        if (deliveryCharge < minCharge) {
          deliveryCharge = minCharge;
        }
      }
      return deliveryCharge;
    }

    double calcDistance = 0;
    if (store != null && store.latitude != null && address.latitude != null) {
      double? sLat = double.tryParse(store.latitude!);
      double? sLng = double.tryParse(store.longitude!);
      double? aLat = double.tryParse(address.latitude!);
      double? aLng = double.tryParse(address.longitude!);
      if (sLat != null && sLng != null && aLat != null && aLng != null && aLat != 0 && sLat != 0) {
        calcDistance = Geolocator.distanceBetween(sLat, sLng, aLat, aLng) / 1000;
      }
    }
    if (calcDistance == 0 && distance != null && distance > 0) {
      calcDistance = distance;
    }
    if (calcDistance == 0) {
      calcDistance = 2.5;
    }

    if(store != null) {
      deliveryCharge = calcDistance * perKmCharge;

      if(deliveryCharge < minimumCharge) {
        deliveryCharge = minimumCharge;
      }else if(maximumCharge != null && maximumCharge > 0 && deliveryCharge > maximumCharge) {
        deliveryCharge = maximumCharge;
      }
    }

    if(store != null && store.selfDeliverySystem == 0 && extraCharge != null) {
      extraChargeForToolTip = extraCharge;
      deliveryCharge = deliveryCharge + extraCharge;
    }

    if(store != null && store.selfDeliverySystem == 0 && surgePrice != null && surgePrice > 0) {
      if(surgePriceType == 'percent') {
        badWeatherChargeForToolTip = (deliveryCharge * (surgePrice/100));
        deliveryCharge = deliveryCharge + (deliveryCharge * (surgePrice/100));
      } else {
        badWeatherChargeForToolTip = surgePrice;
        deliveryCharge = deliveryCharge + surgePrice;
      }
    }

    return (deliveryCharge / 100).ceilToDouble() * 100;
  }

  double _calculateOriginalDeliveryCharge({required Store? store, required AddressModel address, required double? distance, required double? extraCharge, double? surgePrice, String? surgePriceType}) {
      List<Store>? stores = Get.find<CheckoutController>().stores;
      if (stores != null && stores.isNotEmpty && Get.find<CheckoutController>().storeDistances.isNotEmpty) {
          double totalBaseCharge = 0;
          for(Store s in stores) {
              double dist = Get.find<CheckoutController>().storeDistances[s.id] ?? 0;
              totalBaseCharge += _calculateSingleOriginalDeliveryCharge(store: s, address: address, distance: dist, extraCharge: 0, surgePrice: 0, surgePriceType: surgePriceType);
          }
          
          double totalDeliveryCharge = totalBaseCharge;
          if (store != null && store.selfDeliverySystem == 0 && extraCharge != null) {
              totalDeliveryCharge += extraCharge;
          }
          if (store != null && store.selfDeliverySystem == 0 && surgePrice != null && surgePrice > 0) {
              if (surgePriceType == 'percent') {
                  totalDeliveryCharge += (totalDeliveryCharge * (surgePrice / 100));
              } else {
                  totalDeliveryCharge += surgePrice;
              }
          }
          return totalDeliveryCharge;
      }
      return _calculateSingleOriginalDeliveryCharge(store: store, address: address, distance: distance, extraCharge: extraCharge, surgePrice: surgePrice, surgePriceType: surgePriceType);
  }
  
  // Wrapper to handle multi-store aggregation for the view, but the recursive call in _calculateDeliveryCharge needs the single store logic.
  // Actually, _calculateDeliveryCharge (above) calls this function.
  // If I change this function to Aggregate, then _calculateDeliveryCharge (above) would aggregate aggregates if I am not careful.
  // My update to _calculateDeliveryCharge above calls this function in a loop.
  // So this function MUST remain "Single Store Calculation".
  // BUT `build` calls this function to show `originalCharge`.
  // So I need a new function or handle it?
  // Let's modify the call site in `build`.
  // Or, I can check if the call comes from Loop or Global?
  // Easier: Rename this to `_calculateSingleStoreOriginalDeliveryCharge` and make `_calculateOriginalDeliveryCharge` an aggregator?
  // But I cannot easily rename without changing all calls.
  // Wait, `_calculateDeliveryCharge` in MY new code above calls `_calculateOriginalDeliveryCharge`.
  // I should change MY new code above to call `_calculateSingleStoreOriginalDeliveryCharge` if I create it.
  // But I can't easily create a new function because of loose context limits (I am replacing chunks).
  
  // Strategy:
  // Check if `store` passed is ONE or if we should iterate. 
  // The `build` method passes `checkoutController.store` (which is just one store).
  // Inside `_calculateDeliveryCharge` I pass `s` (one store).
  // So I need `_calculateOriginalDeliveryCharge` to handle "If I am passed a store, calculate for it. If I am passed null (or check stores list?), calculate for all".
  // But `build` passes `checkoutController.store`.
  
  // I will rely on the fact that `_calculateDeliveryCharge` (final) is what matters most.
  // The `originalCharge` variable in `build` is for display "Delivery Fee: $X".
  // If I don't update `_calculateOriginalDeliveryCharge` to aggregate, the "Original" display will be wrong (too low).
  
  // I'll update `_calculateOriginalDeliveryCharge` to aggregate if called with the "primary" store but multiple stores exist.
  // How to keys?
  // If `Get.find<CheckoutController>().stores.length > 1` and `store == Get.find<CheckoutController>().stores[0]`.
  // This is risky.
  
  // Better: I will stick to modifying `build` lines where `_calculateOriginalDeliveryCharge` is called?
  // `build` has detailed logic.
  // `double originalCharge = _calculateOriginalDeliveryCharge(...)`
  
  // Actually, I'll modify `_calculateOriginalDeliveryCharge` to check:
  // If existing stores > 1, iterate and sum.
  // BUT beware of recursion if I use it inside the loop in `_calculateDeliveryCharge`.
  // In `_calculateDeliveryCharge`, I am iterating `stores` and calling `_calculateOriginalDeliveryCharge(store: s, ...)`.
  // If `_calculateOriginalDeliveryCharge` ALSO iterates, we get N*N.
  // I need to prevent that.
  
  // Solution: Add an optional param `bool aggregate = true`.
  // But I can't change signature easily.
  
  // I will duplicate the logic in `_calculateDeliveryCharge` (as I did) calling `_calculateOriginalDeliveryCharge`.
  // AND I will modify `_calculateOriginalDeliveryCharge` to Aggregate IF it detects it's called for the View.
  // How to detect?
  // I can check if `store` arg matches `checkoutController.store`.
  // And if `stores` list has more than 1.
  
  // Let's modify `_calculateOriginalDeliveryCharge` to BE the single calculator.
  // And create a new aggregator calculation in `build`?
  // No, `build` is huge.
  
  // Okay, I will modify `_calculateOriginalDeliveryCharge` to be the Aggregator.
  // And internally it will perform the calculation.
  // BUT `_calculateDeliveryCharge` (which I just wrote) calls it.
  // I will revert the change to `_calculateDeliveryCharge`? No.
  
  // Let's rewrite `_calculateOriginalDeliveryCharge` to allow Single vs Multi.
  // "If `Get.find<CheckoutController>().stores` > 1 AND I am not inside a loop?"
  // I can't know if I am inside a loop.
  
  // Alternative:
  // I already updated `_calculateDeliveryCharge` to loop.
  // Inside the loop, it calls `_calculateOriginalDeliveryCharge`.
  // That call passes a specific `store` `s`.
  // So `_calculateOriginalDeliveryCharge` receives `s`.
  // If `s` != `checkoutController.store`, then it knows it's a specific store.
  // But `checkoutController.store` is the first store! So for the first store, it matches.
  
  // Let's look at `_calculateOriginalDeliveryCharge` inputs.
  // `distance` input.
  // In the loop, I pass `storeDistances[s.id]`.
  // In `build`, it passes `checkoutController.distance` (which I set to first store distance).
  
  // So `_calculateOriginalDeliveryCharge` will perform Single Calculation based on inputs.
  // This is CORRECT for the Loop in `_calculateDeliveryCharge`.
  // BUT for `build` calling `_calculateOriginalDeliveryCharge` (lines 298-302), it passes single args.
  // So `originalCharge` calculated in `build` will be WRONG (only first store).
  
  // Logic:
  // `build` should calculate `originalCharge` by summing.
  // `_calculateOriginalDeliveryCharge` should remain "Single Store Calculator".
  // `_calculateDeliveryCharge` (modified above) handles summing for the final charge.
  
  // Problem: `originalCharge` in `build` is shown to user. It must be correct.
  // I need to update the CALL SITE in `build` or update the function to be smart.
  // Modifying `build` is hard (long function, indentation).
  
  // I will make `_calculateOriginalDeliveryCharge` smart.
  // If `stores` > 1 AND `store` matches `checkoutController.store` (first store) AND `distance` matches first store distance... 
  // It's ambiguous.
  
  // Best approach:
  // Rename `_calculateOriginalDeliveryCharge` to `_calculateSingleOriginalDeliveryCharge`.
  // Create `_calculateOriginalDeliveryCharge` that aggregates.
  // Using the chunks approach:
  
  // Rename the current function body to `_calculateSingleOriginalDeliveryCharge`.
  // And define `_calculateOriginalDeliveryCharge` to call it.
  
/*
  double _calculateSingleOriginalDeliveryCharge(...) { ... existing logic ... }

  double _calculateOriginalDeliveryCharge(...) {
      List<Store>? stores = ...;
      if (stores > 1) {
         double total = 0;
         for (s in stores) {
            total += _calculateSingleOriginalDeliveryCharge(s, storeDistances[s.id], ...);
         }
         return total;
      }
      return _calculateSingleOriginalDeliveryCharge(store, ...);
  }
*/
  
  // This works perfect.
  // Chunk 2: Replace `_calculateOriginalDeliveryCharge` definition and body.


  double _calculateDeliveryCharge({required Store? store, required AddressModel address, required double? distance, required double? extraCharge, required double orderAmount,
    required String orderType, double? surgePrice, String? surgePriceType}) {
    if (orderType != 'take_away' && (distance == null || distance == -1) && Get.find<CheckoutController>().storeDistances.isEmpty) {
      return -1;
    }

    List<Store>? stores = Get.find<CheckoutController>().stores;
    if (stores != null && stores.isNotEmpty) {
      if (orderType != 'take_away' && Get.find<CheckoutController>().storeDistances.length < stores.length) {
        return -1;
      }
      double totalBaseDeliveryCharge = 0;
      bool anyStoreRequiresDelivery = false;
      for (Store s in stores) {
        double dist = Get.find<CheckoutController>().storeDistances[s.id] ?? 0;
        double baseFee = _calculateSingleOriginalDeliveryCharge(store: s, address: address, distance: dist, extraCharge: 0, surgePrice: 0, surgePriceType: surgePriceType);
        
        ConfigModel? configModel = Get.find<SplashController>().configModel;
        bool isStoreFree = s.freeDelivery!;
        bool isAdminFreeAll = configModel?.adminFreeDelivery?.status == true && configModel?.adminFreeDelivery?.type == 'free_delivery_to_all_store';
        bool isAdminFreeOver = configModel?.adminFreeDelivery?.status == true && configModel?.adminFreeDelivery?.type == 'free_delivery_by_order_amount' && (configModel!.adminFreeDelivery?.freeDeliveryOver != null && orderAmount >= configModel.adminFreeDelivery!.freeDeliveryOver!);
        bool isCouponFree = Get.find<CouponController>().freeDelivery;
        bool isGuestNoAddress = AuthHelper.isGuestLoggedIn() && (Get.find<CheckoutController>().guestAddress == null && Get.find<CheckoutController>().orderType != 'take_away');

        bool isFree = (orderType == 'take_away' || s.freeDelivery! || isAdminFreeAll || isAdminFreeOver || isCouponFree || isGuestNoAddress);

        if (!isFree) {
          totalBaseDeliveryCharge += baseFee;
          anyStoreRequiresDelivery = true;
        }
      }

      if (anyStoreRequiresDelivery) {
        if (store != null && store.selfDeliverySystem == 0 && extraCharge != null) {
          totalBaseDeliveryCharge += extraCharge;
        }
        if (store != null && store.selfDeliverySystem == 0 && surgePrice != null && surgePrice > 0) {
          if (surgePriceType == 'percent') {
            totalBaseDeliveryCharge += (totalBaseDeliveryCharge * (surgePrice / 100));
          } else {
            totalBaseDeliveryCharge += surgePrice;
          }
        }
      }
      return (totalBaseDeliveryCharge / 100).ceilToDouble() * 100;
    }
    
    // Fallback to single store logic if stores list is empty (shouldn't happen with updated controller)
    double deliveryCharge = _calculateSingleOriginalDeliveryCharge(store: store, address: address, distance: distance, extraCharge: extraCharge, surgePrice: surgePrice, surgePriceType: surgePriceType);

    ConfigModel? configModel = Get.find<SplashController>().configModel;

    if (orderType == 'take_away' || (store != null && store.freeDelivery!)
        || (configModel?.adminFreeDelivery?.status == true && (configModel?.adminFreeDelivery?.type != null && configModel?.adminFreeDelivery?.type == 'free_delivery_to_all_store'))
        || (configModel?.adminFreeDelivery?.status == true && (configModel?.adminFreeDelivery?.type != null &&  configModel?.adminFreeDelivery?.type == 'free_delivery_by_order_amount') && (configModel!.adminFreeDelivery?.freeDeliveryOver != null && orderAmount >= configModel.adminFreeDelivery!.freeDeliveryOver!))
        || Get.find<CouponController>().freeDelivery || (AuthHelper.isGuestLoggedIn() && (Get.find<CheckoutController>().guestAddress == null && Get.find<CheckoutController>().orderType != 'take_away'))) {
      deliveryCharge = 0;
    }

    return (deliveryCharge / 100).ceilToDouble() * 100;
  }

  double _calculateTotal({
    required double subTotal, required double deliveryCharge, required double discount,
    required double couponDiscount, required bool taxIncluded, required double tax,
    required String orderType, required double tips, required double additionalCharge, required double extraPackagingCharge,
  }) {
    double validDeliveryCharge = deliveryCharge > 0 ? deliveryCharge : 0;

    return PriceConverter.toFixed(
        subTotal + validDeliveryCharge - discount- couponDiscount + (taxIncluded ? 0 : tax)
            + ((orderType != 'take_away' && Get.find<SplashController>().configModel!.dmTipsStatus == 1) ? tips : 0)
            + additionalCharge + extraPackagingCharge
    );
  }

  bool _checkZoneOfflinePaymentOnOff({required AddressModel? addressModel, required CheckoutController checkoutController}) {
    bool status = false;
    ZoneData? zoneData;
    List<ZoneData>? zList = addressModel?.zoneData ?? AddressHelper.getUserAddressFromSharedPref()?.zoneData;
    if (zList != null) {
      for (var data in zList) {
        if(data.id == checkoutController.store?.zoneId) {
          zoneData = data;
          break;
        }
      }
    }
    status = zoneData?.offlinePayment ?? (Get.find<SplashController>().configModel?.offlinePaymentStatus ?? false);
    return status;
  }

  bool _checkPrescriptionRequired() {
    bool attachmentReq = Get.find<SplashController>().configModel?.moduleConfig?.module?.orderAttachment ?? false;
    if(widget.storeId == null && attachmentReq) {
      if (_cartList != null) {
        for (var cart in _cartList!) {
          if(cart?.item?.isPrescriptionRequired ?? false) {
            return true;
          }
        }
      }
    }
    return false;
  }

  double _calculateExtraPackagingCharge(CheckoutController checkoutController) {
    if((checkoutController.store?.extraPackagingStatus ?? true) && (Get.find<CartController>().needExtraPackage)) {
      return checkoutController.store?.extraPackagingAmount ?? 0;
    }
    return 0;
  }

  double _calculateReferralDiscount(double subTotal, double discount, double couponDiscount) {
    double referralDiscount = 0;
    if(Get.find<ProfileController>().userInfoModel != null &&  Get.find<ProfileController>().userInfoModel!.isValidForDiscount!) {
      if (Get.find<ProfileController>().userInfoModel!.discountAmountType! == "percentage") {
        referralDiscount = (Get.find<ProfileController>().userInfoModel!.discountAmount! / 100) * (subTotal - discount - couponDiscount);
      } else {
        referralDiscount = Get.find<ProfileController>().userInfoModel!.discountAmount!;
      }
    }
    return PriceConverter.toFixed(referralDiscount);
  }

  double _calculateProDiscount(double subTotal, double discount, double couponDiscount, ProActiveBenefit? benefit) {
    if (benefit == null || benefit.type != ProBenefitType.discount) return 0;
    final bool meetsMinOrder = benefit.minOrderStatus != true || subTotal >= (benefit.minOrderAmount ?? 0);
    if (!meetsMinOrder) return 0;
    final double base = subTotal - discount - couponDiscount;
    if (base < 0) return 0;
    double proDiscount = base * ((benefit.percentage ?? 0) / 100);
    if (benefit.maxAmount != null && benefit.maxAmount! > 0 && proDiscount > benefit.maxAmount!) {
      proDiscount = benefit.maxAmount!;
    }
    if (proDiscount > base) proDiscount = base;
    return PriceConverter.toFixed(proDiscount);
  }

  double _calculateProDeliveryDiscount(double base, double deliveryCharge, ProActiveBenefit? benefit) {
    if (benefit == null || benefit.type != ProBenefitType.deliveryFee) return 0;
    if (deliveryCharge <= 0) return 0;
    final bool meetsMinOrder = benefit.minOrderStatus != true || base >= (benefit.minOrderAmount ?? 0);
    if (!meetsMinOrder) return 0;
    if (benefit.offerType == ProOfferType.fullFree) return PriceConverter.toFixed(deliveryCharge);
    double discount = deliveryCharge * ((benefit.chargeDiscountPercentage ?? 0) / 100);
    return PriceConverter.toFixed(discount);
  }

  Future<void> showCashBackSnackBar() async {
    await Get.find<HomeController>().getCashBackData(_payableAmount!);
    double? cashBackAmount = Get.find<HomeController>().cashBackData?.cashbackAmount ?? 0;
    String? cashBackType = Get.find<HomeController>().cashBackData?.cashbackType ?? '';
    String text = '${'you_will_get'.tr} ${cashBackType == 'amount' ? PriceConverter.convertPrice(cashBackAmount) : '${cashBackAmount.toStringAsFixed(0)}%'} ${'cash_back_after_completing_order'.tr}';
    if(cashBackAmount > 0) {
      showCustomSnackBar(text, isError: false);
    }
  }

}