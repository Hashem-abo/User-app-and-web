import 'dart:async';
import 'package:get/get.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/features/cart/domain/models/cart_model.dart';
import 'package:sixam_mart/features/cart/domain/models/online_cart_model.dart';
import 'package:sixam_mart/features/cart/domain/services/cart_service_interface.dart';
import 'package:sixam_mart/features/checkout/domain/models/place_order_body_model.dart';
import 'package:sixam_mart/features/home/screens/home_screen.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/module_helper.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/route_helper.dart';

class CartController extends GetxController implements GetxService {
  final CartServiceInterface cartServiceInterface;

  CartController({required this.cartServiceInterface});
  
  Timer? _noteTimer;

  List<CartModel> _cartList = [];
  List<CartModel> get cartList => _cartList;

  double _subTotal = 0;
  double get subTotal => _subTotal;

  double _itemPrice = 0;
  double get itemPrice => _itemPrice;

  double _itemDiscountPrice = 0;
  double get itemDiscountPrice => _itemDiscountPrice;

  double _addOns = 0;
  double get addOns => _addOns;

  double _variationPrice = 0;
  double get variationPrice => _variationPrice;

  List<List<AddOns>> _addOnsList = [];
  List<List<AddOns>> get addOnsList => _addOnsList;

  List<bool> _availableList = [];
  List<bool> get availableList => _availableList;

  List<String> notAvailableList = ['Remove it from my cart', 'I’ll wait until it’s restocked', 'Please cancel the order', 'Call me ASAP', 'Notify me when it’s back'];
  bool _addCutlery = false;
  bool get addCutlery => _addCutlery;

  int _notAvailableIndex = -1;
  int get notAvailableIndex => _notAvailableIndex;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _needExtraPackage = true;
  bool get needExtraPackage => _needExtraPackage;

  bool _isExpanded = true;
  bool get isExpanded => _isExpanded;

  int? _directAddCartItemIndex = -1;
  int? get directAddCartItemIndex => _directAddCartItemIndex;

  int? _selectedStoreId;
  int? get selectedStoreId => _selectedStoreId;

  void setSelectedStoreId(int? storeId, {bool notify = true}) {
    _selectedStoreId = storeId;
    if(notify) {
      update();
    }
  }

  void setDirectlyAddToCartIndex(int? index) {
    _directAddCartItemIndex = index;
  }

  int? _cartIndexToReplace;
  int? get cartIndexToReplace => _cartIndexToReplace;

  void setCartIndexToReplace(int? index) {
    _cartIndexToReplace = index;
  }

  void toggleExtraPackage({bool willUpdate = true}) {
    _needExtraPackage = !_needExtraPackage;
    if(willUpdate) {
      update();
    }
  }

  void setAvailableIndex(int index, {bool willUpdate = true}) {
    _notAvailableIndex = cartServiceInterface.availableSelectedIndex(_notAvailableIndex, index);
    if(willUpdate) {
      update();
    }
  }

  void updateCutlery({bool willUpdate = true}){
    _addCutlery = !_addCutlery;
    if(willUpdate) {
      update();
    }
  }

  Future<void> forcefullySetModule(int moduleId) async {
    int index = Get.find<SplashController>().moduleList?.indexWhere((m) => m.id == moduleId) ?? -1;
    if(index != -1) {
      await Get.find<SplashController>().switchModule(index, true);
    }
  }

  void _checkAndSwitchModule(int? targetModuleId) {
    if (targetModuleId == null) return;
    int? currentModuleId = Get.find<SplashController>().module?.id;
    if (currentModuleId != null && currentModuleId != targetModuleId) {
      forcefullySetModule(targetModuleId);
      Get.toNamed(RouteHelper.getCartRoute());
    }
  }

  double calculationCart() {
    _addOnsList = [];
    _availableList = [];
    _itemPrice = 0;
    _itemDiscountPrice = 0;
    _addOns = 0;
    _variationPrice = 0;
    bool isFoodVariation = false;
    double variationWithoutDiscountPrice = 0;
    bool haveVariation = false;
    for (var cartModel in cartList) {

      isFoodVariation = ModuleHelper.getModuleConfig(cartModel.item!.moduleType).newVariation!;
      double? discount = cartModel.item!.discount;
      String? discountType = cartModel.item!.discountType;

      List<AddOns> addOnList = cartServiceInterface.prepareAddonList(cartModel);

      _addOnsList.add(addOnList);
      bool isAvailable = DateConverter.isAvailable(cartModel.item!.availableTimeStarts, cartModel.item!.availableTimeEnds);

      // Robust stock check
      int? itemStock = cartModel.item!.stock;
      int? cartStock = cartModel.stock;
      int? qtyLimit = cartModel.item!.quantityLimit;
      bool isFood = cartModel.item!.moduleType == 'food';

      if(!isFood && ((itemStock != null && itemStock <= 0) || (cartStock != null && cartStock <= 0) || (qtyLimit != null && qtyLimit <= 0))) {
        isAvailable = false;
      }

      if(isAvailable && !isFoodVariation && cartModel.variation != null && cartModel.variation!.isNotEmpty) {
        String variationType = '';
        for(int i=0; i<cartModel.variation!.length; i++) {
          variationType = cartModel.variation![i].type!;
        }
        for (var variation in cartModel.item!.variations!) {
          if (variation.type == variationType) {
            if(variation.stock != null && variation.stock! <= 0) {
              isAvailable = false;
            }
            break;
          }
        }
      }

      // Store status check
      if(isAvailable && cartModel.item!.storeDetails != null) {
        bool storeActive = cartModel.item!.storeDetails!['active'] == 1 || cartModel.item!.storeDetails!['active'] == true;
        bool storeOpen = cartModel.item!.storeDetails!['open'] == 1 || cartModel.item!.storeDetails!['open'] == true;
        if(!storeActive || !storeOpen) {
          isAvailable = false;
        }
      }

      _availableList.add(isAvailable);

      _addOns = cartServiceInterface.calculateAddonPrice(_addOns, addOnList, cartModel);

      _variationPrice = cartServiceInterface.calculateVariationPrice(isFoodVariation, cartModel, discount, discountType, _variationPrice);

      variationWithoutDiscountPrice = cartServiceInterface.calculateVariationWithoutDiscountPrice(isFoodVariation, cartModel, variationWithoutDiscountPrice);
      haveVariation = cartServiceInterface.checkVariation(isFoodVariation, cartModel);

      double price = haveVariation ? variationWithoutDiscountPrice : (cartModel.item!.price! * cartModel.quantity!);
      double discountPrice = haveVariation ? (variationWithoutDiscountPrice - _variationPrice)
          : (price - (PriceConverter.convertWithDiscount(cartModel.item!.price!, discount, discountType)! * cartModel.quantity!));

      _itemPrice = _itemPrice + price;
      _itemDiscountPrice = _itemDiscountPrice + discountPrice;

      haveVariation = false;
    }
    if(isFoodVariation){
      _itemDiscountPrice = _itemDiscountPrice + (variationWithoutDiscountPrice - _variationPrice);
      _variationPrice =  variationWithoutDiscountPrice;
      _subTotal = (_itemPrice - _itemDiscountPrice) + _addOns + _variationPrice;
    } else {
      _subTotal = (_itemPrice - _itemDiscountPrice);
    }

    return _subTotal;
  }

  Map<String, double> getSubTotalForStore(int storeId) {
    double total = 0;
    double itemPrice = 0;
    double itemDiscountPrice = 0;
    double addOns = 0;
    double variationPrice = 0;
    bool isFoodVariation = false;
    double variationWithoutDiscountPrice = 0;
    bool haveVariation = false;
    
    for (var cartModel in cartList) {
      if (cartModel.item!.storeId != storeId) {
        continue;
      }
      
      isFoodVariation = ModuleHelper.getModuleConfig(cartModel.item!.moduleType).newVariation!;
      double? discount = cartModel.item!.discount;
      String? discountType = cartModel.item!.discountType;

      List<AddOns> addOnList = cartServiceInterface.prepareAddonList(cartModel);

      addOns = cartServiceInterface.calculateAddonPrice(addOns, addOnList, cartModel);
      variationPrice = cartServiceInterface.calculateVariationPrice(isFoodVariation, cartModel, discount, discountType, variationPrice);
      variationWithoutDiscountPrice = cartServiceInterface.calculateVariationWithoutDiscountPrice(isFoodVariation, cartModel, variationWithoutDiscountPrice);
      haveVariation = cartServiceInterface.checkVariation(isFoodVariation, cartModel);

      double price = haveVariation ? variationWithoutDiscountPrice : (cartModel.item!.price! * cartModel.quantity!);
      double discountPrice = haveVariation ? (variationWithoutDiscountPrice - variationPrice)
          : (price - (PriceConverter.convertWithDiscount(cartModel.item!.price!, discount, discountType)! * cartModel.quantity!));

      itemPrice = itemPrice + price;
      itemDiscountPrice = itemDiscountPrice + discountPrice;

      haveVariation = false;
    }
    
    if(isFoodVariation){
      itemDiscountPrice = itemDiscountPrice + (variationWithoutDiscountPrice - variationPrice);
      variationPrice =  variationWithoutDiscountPrice;
      total = (itemPrice - itemDiscountPrice) + addOns + variationPrice;
    } else {
      total = (itemPrice - itemDiscountPrice);
    }

    return {
      'total': total,
      'itemPrice': itemPrice,
      'itemDiscountPrice': itemDiscountPrice,
      'addOns': addOns,
      'variationPrice': variationPrice,
    };
  }

  Future<void> addToCart(CartModel cartModel, int? index) async {
    _cartDataRequestId++;
    if(index != null && index != -1) {
      _cartList.replaceRange(index, index+1, [cartModel]);
    }else {
      if (_cartIndexToReplace != null && _cartIndexToReplace! < _cartList.length) {
        _cartList.removeAt(_cartIndexToReplace!);
        _cartIndexToReplace = null;
      }
      _cartList.add(cartModel);
    }
    Get.find<ItemController>().setExistInCart(cartModel.item, null, notify: true);
    await cartServiceInterface.addSharedPrefCartList(_cartList);

    calculationCart();
    update();
    _checkAndSwitchModule(cartModel.item!.moduleId);
  }

  int? getCartId(int cartIndex) {
    return cartServiceInterface.getCartId(cartIndex, _cartList);
  }

  Future<void> setQuantity(bool isIncrement, int cartIndex, int? stock, int ? quantityLimit) async {
    int oldQuantity = _cartList[cartIndex].quantity!;
    _cartList[cartIndex].quantity = await cartServiceInterface.decideItemQuantity(isIncrement, _cartList, cartIndex, stock, quantityLimit, Get.find<SplashController>().configModel!.moduleConfig!.module!.stock!);

    calculationCart();
    update();

    double discountedPrice = await cartServiceInterface.calculateDiscountedPrice(_cartList[cartIndex], _cartList[cartIndex].quantity!, ModuleHelper.getModuleConfig(_cartList[cartIndex].item!.moduleType).newVariation!);
    if(ModuleHelper.getModuleConfig(_cartList[cartIndex].item!.moduleType).newVariation!) {
     Get.find<ItemController>().setExistInCart(_cartList[cartIndex].item, null, notify: true);
    }

    if(_cartList[cartIndex].id != null) {
      updateCartQuantityOnline(_cartList[cartIndex].id!, discountedPrice, _cartList[cartIndex].quantity!, cartIndex, oldQuantity);
    }

  }

  Future<void> removeFromCart(int index, {Item? item}) async {
    int? cartId = _cartList[index].id;
    CartModel cartModel = _cartList[index];
    _cartList.removeAt(index);
    calculationCart();
    update();
    Get.find<ItemController>().cartIndexSet();
    if(cartId != null) {
      removeCartItemOnline(cartId, item: item, cartIndex: index, cartModel: cartModel);
    }
    if(Get.find<ItemController>().item != null) {
      Get.find<ItemController>().cartIndexSet();
    }

  }

  Future<void> clearCartList({bool canRemoveOnline = true}) async {
    _cartDataRequestId++;
    _cartList = [];
    if((AuthHelper.isLoggedIn() || AuthHelper.isGuestLoggedIn()) && (ModuleHelper.getModule() != null || ModuleHelper.getCacheModule() != null) && canRemoveOnline) {
      await clearCartOnline();
    }
  }

  int isExistInCart(int? itemID, String variationType, bool isUpdate, int? cartIndex) {
    return cartServiceInterface.isExistInCart(_cartList, itemID, variationType, isUpdate, cartIndex);
  }

  bool existAnotherStoreItem(int? storeID, int? moduleId) {
    return cartServiceInterface.existAnotherStoreItem(storeID, moduleId, _cartList);
  }

  void setCurrentIndex(int index, bool notify) {
    _currentIndex = index;
    if(notify) {
      update();
    }
  }

  Future<bool> addToCartOnline(OnlineCart onlineCart, CartModel cartModel) async {
    if (_cartIndexToReplace != null && _cartIndexToReplace! < _cartList.length) {
      int index = _cartIndexToReplace!;
      _cartIndexToReplace = null;
      await removeFromCart(index);
    }
    
    // Optimistic update
    _cartList.add(cartModel);
    calculationCart();
    update();

    bool success = false;
    List<OnlineCartModel>? onlineCartList = await cartServiceInterface.addToCartOnline(onlineCart);
    if(onlineCartList != null) {
      _cartList = [];
      _cartList.addAll(cartServiceInterface.formatOnlineCartToLocalCart(onlineCartModel: onlineCartList));
      cartServiceInterface.addSharedPrefCartList(_cartList);
      calculationCart();
      success = true;
      _checkAndSwitchModule(cartModel.item!.moduleId);
    } else {
      _cartList.remove(cartModel);
      calculationCart();
      update();
    }

    return success;
  }

  Future<bool> updateCartOnline(OnlineCart onlineCart, CartModel cartModel, {bool notify = true}) async {
    // Optimistic update: replace old item with new one
    int index = _cartList.indexWhere((element) => element.id == onlineCart.cartId);
    CartModel? oldCartModel;
    if(index != -1) {
      oldCartModel = _cartList[index];
      _cartList[index] = cartModel;
    }
    calculationCart();
    if(notify) {
      update();
    }

    bool success = false;
    List<OnlineCartModel>? onlineCartList = await cartServiceInterface.updateCartOnline(onlineCart);
    if(onlineCartList != null) {
      _cartList = [];
      _cartList.addAll(cartServiceInterface.formatOnlineCartToLocalCart(onlineCartModel: onlineCartList));
      cartServiceInterface.addSharedPrefCartList(_cartList);
      calculationCart();
      success = true;
    } else {
      if(index != -1 && oldCartModel != null) {
        _cartList[index] = oldCartModel;
        calculationCart();
        update();
      }
    }

    return success;
  }

  Future<void> updateCartQuantityOnline(int cartId, double price, int quantity, int cartIndex, int oldQuantity) async {
    // No loading set here to keep UI responsive
    bool success = await cartServiceInterface.updateCartQuantityOnline(cartId, price, quantity);
    if(success) {
      await getCartDataOnline();
      calculationCart();
    } else {
      _cartList[cartIndex].quantity = oldQuantity;
      calculationCart();
      update();
    }
  }

  bool isPreventCartOverwritten = false;
  int _cartDataRequestId = 0;

  Future<void> getCartDataOnline() async {
    if (isPreventCartOverwritten) return;
    int requestId = ++_cartDataRequestId;
    if(ModuleHelper.getModule() != null || ModuleHelper.getCacheModule() != null) {
      List<OnlineCartModel>? onlineCartList = await cartServiceInterface.getCartDataOnline();
      if (isPreventCartOverwritten || requestId != _cartDataRequestId) return;
      if(onlineCartList != null) {
        _cartList = [];
        _cartList.addAll(cartServiceInterface.formatOnlineCartToLocalCart(onlineCartModel: onlineCartList));
        cartServiceInterface.addSharedPrefCartList(_cartList);
        calculationCart();
      }
      update();
    }
  }

  Future<bool> removeCartItemOnline(int cartId, {Item? item, int? cartIndex, CartModel? cartModel}) async {
    // No loading set here
    bool success = await cartServiceInterface.removeCartItemOnline(cartId);
    if(success) {
      await getCartDataOnline();
      if(item != null) {
        Get.find<ItemController>().setExistInCart(item, null, notify: true);
      }
    } else {
      if(cartIndex != null && cartModel != null) {
        _cartList.insert(cartIndex, cartModel);
        calculationCart();
        update();
      }
    }
    return success;
  }

  Future<bool> clearCartOnline({int? moduleId}) async {
    _isLoading = true;
    update();
    bool success = await cartServiceInterface.clearCartOnline(moduleId: moduleId);
    if(success) {
      int? currentModuleId = Get.find<SplashController>().module?.id ?? ModuleHelper.getCacheModule()?.id;
      if (moduleId == null || moduleId == currentModuleId) {
        _cartList = [];
        calculationCart();
      }
    }
    _isLoading = false;
    update();
    return success;
  }

  int cartQuantity(int itemId) {
    return cartServiceInterface.cartQuantity(itemId, _cartList);
  }

  String cartVariant(int itemId) {
    return cartServiceInterface.cartVariant(itemId, _cartList);
  }

  void setExpanded(bool setExpand) {
    _isExpanded = setExpand;
    update();
  }

  List<int> getModuleWithCartList() {
    return cartServiceInterface.getModuleWithCartList();
  }

  Map<int, int> getModuleCartCounts() {
    return cartServiceInterface.getModuleCartCounts();
  }

  Future<void> updateCartItemNote(int index, String? note) async {
    _cartList[index].note = note;
    await cartServiceInterface.addSharedPrefCartList(_cartList);
    // update(); // We don't call update() here to prevent focus loss while typing
    
    _noteTimer?.cancel();
    _noteTimer = Timer(const Duration(milliseconds: 500), () {
      if((AuthHelper.isLoggedIn() || AuthHelper.isGuestLoggedIn())) {
        updateCartOnline(OnlineCart(
          cartId: _cartList[index].id,
          itemId: _cartList[index].item!.id,
          price: _cartList[index].price.toString(),
          quantity: _cartList[index].quantity,
          variation: _cartList[index].variation,
          addOnIds: _cartList[index].addOnIds?.map((e) => e.id).toList(),
          addOnQtys: _cartList[index].addOnIds?.map((e) => e.quantity).toList(),
          model: 'Item',
          note: note,
        ), _cartList[index], notify: false);
      }
    });
  }

}