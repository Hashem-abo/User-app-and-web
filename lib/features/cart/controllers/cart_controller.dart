import 'dart:async';
import 'package:get/get.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/cart/domain/models/cart_model.dart';
import 'package:sixam_mart/features/cart/domain/models/online_cart_model.dart' hide Variation;
import 'package:sixam_mart/features/cart/domain/services/cart_service_interface.dart';
import 'package:sixam_mart/features/checkout/domain/models/place_order_body_model.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/module_helper.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';

class CartController extends GetxController implements GetxService {
  final CartServiceInterface cartServiceInterface;

  CartController({required this.cartServiceInterface});
  
  Timer? _noteTimer;
  final Map<int, Timer> _quantityDebounceTimers = {};
  final Map<int, int> _originalQuantities = {};
  final Set<int> _activeQuantitySyncItemIds = {};
  final Set<int> _pendingSubsequentSync = {};

  bool hasPendingQuantityUpdates([int? cartId]) {
    if (cartId != null) {
      return _quantityDebounceTimers.containsKey(cartId) || _activeQuantitySyncItemIds.contains(cartId);
    }
    return _quantityDebounceTimers.isNotEmpty || _activeQuantitySyncItemIds.isNotEmpty;
  }

  @override
  void onClose() {
    _noteTimer?.cancel();
    for (var timer in _quantityDebounceTimers.values) {
      timer.cancel();
    }
    _quantityDebounceTimers.clear();
    super.onClose();
  }

  List<CartModel> _cartList = [];
  List<CartModel> get cartList {
    AddressModel? address = AddressHelper.getUserAddressFromSharedPref();
    int? activeZoneId = address?.zoneId;
    if (activeZoneId == null || activeZoneId == 0) {
      return _cartList;
    }
    return _cartList.where((cartItem) {
      if (cartItem.item == null) return true;
      int? itemZoneId = cartItem.item!.zoneId;
      if ((itemZoneId == null || itemZoneId == 0) && cartItem.item!.storeDetails != null) {
        itemZoneId = cartItem.item!.storeDetails!['zone_id'];
      }
      if (itemZoneId == null || itemZoneId == 0) return true;
      return itemZoneId == activeZoneId || (address != null && address.zoneIds != null && address.zoneIds!.contains(itemZoneId));
    }).toList();
  }

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

  bool _isAddToCartLoading = false;
  bool get isAddToCartLoading => _isAddToCartLoading;

  final Set<int> _addingCartItemIds = {};
  Set<int> get addingCartItemIds => _addingCartItemIds;

  bool isItemAdding(int? itemId) {
    if (itemId == null) return _isAddToCartLoading;
    return _addingCartItemIds.contains(itemId);
  }

  bool _isSameItemVariation(CartModel a, CartModel b) {
    if (a.item?.id != b.item?.id) return false;
    if (a.item?.storeId != b.item?.storeId) return false;

    // Standard variations
    List<Variation>? varA = a.variation;
    List<Variation>? varB = b.variation;
    bool hasVarA = varA != null && varA.isNotEmpty;
    bool hasVarB = varB != null && varB.isNotEmpty;
    if (hasVarA != hasVarB) return false;
    if (varA != null && varB != null && hasVarA) {
      if (varA.length != varB.length) return false;
      List<String> typesA = varA.map<String>((dynamic v) => (v.type ?? '').toString().trim().toLowerCase()).toList()..sort();
      List<String> typesB = varB.map<String>((dynamic v) => (v.type ?? '').toString().trim().toLowerCase()).toList()..sort();
      for (int i = 0; i < typesA.length; i++) {
        if (typesA[i] != typesB[i]) return false;
      }
    }

    // Food variations
    List<List<bool?>>? foodVarA = a.foodVariations;
    List<List<bool?>>? foodVarB = b.foodVariations;
    bool hasFoodVarA = foodVarA != null && foodVarA.isNotEmpty;
    bool hasFoodVarB = foodVarB != null && foodVarB.isNotEmpty;
    if (hasFoodVarA != hasFoodVarB) return false;
    if (foodVarA != null && foodVarB != null && hasFoodVarA) {
      if (foodVarA.length != foodVarB.length) return false;
      for (int i = 0; i < foodVarA.length; i++) {
        List<bool?> subA = foodVarA[i];
        List<bool?> subB = foodVarB[i];
        if (subA.length != subB.length) return false;
        for (int j = 0; j < subA.length; j++) {
          if (subA[j] != subB[j]) return false;
        }
      }
    }

    // Addons
    List<AddOn>? addOnA = a.addOnIds;
    List<AddOn>? addOnB = b.addOnIds;
    bool hasAddonA = addOnA != null && addOnA.isNotEmpty;
    bool hasAddonB = addOnB != null && addOnB.isNotEmpty;
    if (hasAddonA != hasAddonB) return false;
    if (addOnA != null && addOnB != null && hasAddonA) {
      if (addOnA.length != addOnB.length) return false;
      List<String> addonKeysA = addOnA.map((addon) => '${addon.id}_${addon.quantity}').toList()..sort();
      List<String> addonKeysB = addOnB.map((addon) => '${addon.id}_${addon.quantity}').toList()..sort();
      for (int i = 0; i < addonKeysA.length; i++) {
        if (addonKeysA[i] != addonKeysB[i]) return false;
      }
    }

    return true;
  }

  List<CartModel> _deduplicateCartList(List<CartModel> list) {
    List<CartModel> result = [];
    for (var item in list) {
      int index = result.indexWhere((existing) => _isSameItemVariation(existing, item));

      if (index != -1) {
        result[index].quantity = (result[index].quantity ?? 1) + (item.quantity ?? 1);
      } else {
        result.add(item);
      }
    }
    return result;
  }

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
    _cartList = _deduplicateCartList(_cartList);
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
      if(isAvailable) {
        if(cartModel.item!.storeDetails != null) {
          if (cartModel.item!.storeDetails!['active'] != null) {
            bool storeActive = cartModel.item!.storeDetails!['active'] == 1 || cartModel.item!.storeDetails!['active'] == true || cartModel.item!.storeDetails!['active'] == '1';
            if(!storeActive) {
              isAvailable = false;
            }
          }
          if (cartModel.item!.storeDetails!['open'] != null) {
            bool storeOpen = cartModel.item!.storeDetails!['open'] == 1 || cartModel.item!.storeDetails!['open'] == true || cartModel.item!.storeDetails!['open'] == '1';
            if(!storeOpen) {
              isAvailable = false;
            }
          }
        }
        if(isAvailable && Get.isRegistered<StoreController>()) {
          Store? currentStore = Get.find<StoreController>().store;
          if(currentStore != null && currentStore.id == cartModel.item!.storeId) {
            bool storeActive = currentStore.active ?? true;
            bool storeOpen = currentStore.open == null || currentStore.open == 1;
            if(!storeActive || !storeOpen) {
              isAvailable = false;
            }
          }
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
      int existingIndex = _cartList.indexWhere((existing) => _isSameItemVariation(existing, cartModel));
      if (existingIndex != -1) {
        _cartList[existingIndex].quantity = (_cartList[existingIndex].quantity ?? 0) + (cartModel.quantity ?? 1);
      } else {
        _cartList.add(cartModel);
      }
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

  Future<void> setQuantity(
    bool isIncrement,
    int cartIndex,
    int? stock,
    int? quantityLimit, {
    int? cartId,
    CartModel? cartModel,
  }) async {
    // 1. Resolve safe index
    int resolvedIndex = cartIndex;
    if (resolvedIndex < 0 || resolvedIndex >= _cartList.length) {
      if (cartId != null) {
        resolvedIndex = _cartList.indexWhere((c) => c.id == cartId);
      } else if (cartModel != null) {
        resolvedIndex = _cartList.indexOf(cartModel);
      }
    }
    if (resolvedIndex < 0 || resolvedIndex >= _cartList.length) {
      return;
    }

    CartModel currentCartItem = _cartList[resolvedIndex];
    int currentQuantity = currentCartItem.quantity ?? 1;

    // 2. Decide new quantity safely
    int newQuantity = currentQuantity;
    bool isFood = currentCartItem.item?.moduleType == 'food';
    bool moduleStock = Get.find<SplashController>().configModel?.moduleConfig?.module?.stock ?? false;

    if (isIncrement) {
      int totalCartQtyOtherVariations = 0;
      int? itemId = currentCartItem.item?.id;
      if (itemId != null) {
        for (int i = 0; i < _cartList.length; i++) {
          if (i == resolvedIndex) continue;
          if (_cartList[i].item?.id == itemId) {
            totalCartQtyOtherVariations += (_cartList[i].quantity ?? 0);
          }
        }
      }

      int? effectiveStock = stock ?? currentCartItem.stock ?? currentCartItem.item?.stock;
      int? effectiveLimit = quantityLimit ?? currentCartItem.quantityLimit ?? currentCartItem.item?.quantityLimit;

      if (!isFood && moduleStock && effectiveStock != null && (totalCartQtyOtherVariations + currentQuantity + 1) > effectiveStock) {
        showCustomSnackBar('out_of_stock'.tr);
        return;
      } else if (effectiveLimit != null && effectiveLimit != 0 && (totalCartQtyOtherVariations + currentQuantity + 1) > effectiveLimit) {
        showCustomSnackBar('${'maximum_quantity_limit'.tr} $effectiveLimit');
        return;
      } else {
        newQuantity = currentQuantity + 1;
      }
    } else {
      if (currentQuantity <= 1) {
        await removeFromCart(
          resolvedIndex,
          item: currentCartItem.item,
          cartId: currentCartItem.id ?? cartId,
          cartModel: currentCartItem,
        );
        return;
      }
      newQuantity = currentQuantity - 1;
    }

    // 3. Apply Optimistic Update Immediately (0ms UI latency!)
    currentCartItem.quantity = newQuantity;
    calculationCart();
    update();

    await cartServiceInterface.addSharedPrefCartList(_cartList);

    if (currentCartItem.item?.moduleType != null && ModuleHelper.getModuleConfig(currentCartItem.item!.moduleType).newVariation!) {
      Get.find<ItemController>().setExistInCart(currentCartItem.item, null, notify: true);
    }

    // 4. Debounced Server Sync
    int? onlineCartId = currentCartItem.id ?? cartId;
    if (onlineCartId != null) {
      _scheduleQuantitySync(onlineCartId, currentQuantity);
    }
  }

  void _scheduleQuantitySync(int cartId, int previousQuantity) {
    _originalQuantities.putIfAbsent(cartId, () => previousQuantity);
    _quantityDebounceTimers[cartId]?.cancel();
    _quantityDebounceTimers[cartId] = Timer(const Duration(milliseconds: 350), () {
      _quantityDebounceTimers.remove(cartId);
      _syncCartQuantityToServer(cartId);
    });
  }

  Future<void> _syncCartQuantityToServer(int cartId) async {
    if (_activeQuantitySyncItemIds.contains(cartId)) {
      _pendingSubsequentSync.add(cartId);
      return;
    }

    int itemIndex = _cartList.indexWhere((c) => c.id == cartId);
    if (itemIndex == -1) {
      _originalQuantities.remove(cartId);
      _pendingSubsequentSync.remove(cartId);
      return;
    }

    CartModel cartItem = _cartList[itemIndex];
    int targetQuantity = cartItem.quantity ?? 1;
    int originalQuantity = _originalQuantities[cartId] ?? targetQuantity;

    _activeQuantitySyncItemIds.add(cartId);

    try {
      double discountedPrice = await cartServiceInterface.calculateDiscountedPrice(
        cartItem,
        targetQuantity,
        ModuleHelper.getModuleConfig(cartItem.item!.moduleType).newVariation!,
      );

      bool success = await cartServiceInterface.updateCartQuantityOnline(cartId, discountedPrice, targetQuantity);

      if (success) {
        _originalQuantities.remove(cartId);
        await cartServiceInterface.addSharedPrefCartList(_cartList);
        calculationCart();
      } else {
        int currentIdx = _cartList.indexWhere((c) => c.id == cartId);
        if (currentIdx != -1) {
          _cartList[currentIdx].quantity = originalQuantity;
          calculationCart();
          update();
          await cartServiceInterface.addSharedPrefCartList(_cartList);
          showCustomSnackBar('failed_to_update_cart_quantity'.tr);
        }
        _originalQuantities.remove(cartId);
      }
    } catch (e) {
      int currentIdx = _cartList.indexWhere((c) => c.id == cartId);
      if (currentIdx != -1) {
        _cartList[currentIdx].quantity = originalQuantity;
        calculationCart();
        update();
        await cartServiceInterface.addSharedPrefCartList(_cartList);
      }
      _originalQuantities.remove(cartId);
    } finally {
      _activeQuantitySyncItemIds.remove(cartId);

      if (_pendingSubsequentSync.remove(cartId)) {
        int checkIdx = _cartList.indexWhere((c) => c.id == cartId);
        if (checkIdx != -1 && _cartList[checkIdx].quantity != targetQuantity) {
          _syncCartQuantityToServer(cartId);
        }
      }
    }
  }

  Future<void> flushPendingQuantityUpdates() async {
    List<int> pendingCartIds = _quantityDebounceTimers.keys.toList();
    for (int cartId in pendingCartIds) {
      _quantityDebounceTimers[cartId]?.cancel();
      _quantityDebounceTimers.remove(cartId);
    }

    List<Future<void>> futures = [];
    for (int cartId in pendingCartIds) {
      futures.add(_syncCartQuantityToServer(cartId));
    }
    await Future.wait(futures);

    int maxWaitMs = 3000;
    while (_activeQuantitySyncItemIds.isNotEmpty && maxWaitMs > 0) {
      await Future.delayed(const Duration(milliseconds: 50));
      maxWaitMs -= 50;
    }
  }

  Future<void> removeFromCart(int index, {Item? item, int? cartId, CartModel? cartModel}) async {
    int targetIndex = index;
    if (targetIndex < 0 || targetIndex >= _cartList.length) {
      if (cartId != null) {
        targetIndex = _cartList.indexWhere((c) => c.id == cartId);
      } else if (cartModel != null) {
        targetIndex = _cartList.indexOf(cartModel);
      }
    }
    if (targetIndex < 0 || targetIndex >= _cartList.length) return;

    CartModel modelToRemove = _cartList[targetIndex];
    int? onlineCartId = modelToRemove.id ?? cartId;

    if (onlineCartId != null) {
      _quantityDebounceTimers[onlineCartId]?.cancel();
      _quantityDebounceTimers.remove(onlineCartId);
      _originalQuantities.remove(onlineCartId);
      _pendingSubsequentSync.remove(onlineCartId);
    }

    _cartList.removeAt(targetIndex);
    calculationCart();
    update();
    await cartServiceInterface.addSharedPrefCartList(_cartList);
    Get.find<ItemController>().cartIndexSet();

    if (onlineCartId != null) {
      removeCartItemOnline(onlineCartId, item: item ?? modelToRemove.item, cartIndex: targetIndex, cartModel: modelToRemove);
    }
    if (Get.find<ItemController>().item != null) {
      Get.find<ItemController>().cartIndexSet();
    }
  }

  Future<void> clearCartList({bool canRemoveOnline = true}) async {
    _cartDataRequestId++;
    for (var timer in _quantityDebounceTimers.values) {
      timer.cancel();
    }
    _quantityDebounceTimers.clear();
    _originalQuantities.clear();
    _activeQuantitySyncItemIds.clear();
    _pendingSubsequentSync.clear();

    _cartList = [];
    if((AuthHelper.isLoggedIn() || AuthHelper.isGuestLoggedIn()) && (ModuleHelper.getModule() != null || ModuleHelper.getCacheModule() != null) && canRemoveOnline) {
      await clearCartOnline();
    }
  }

  Future<void> clearStoreCartItems(Set<int> storeIds) async {
    _cartDataRequestId++;
    List<int> cartIdsToRemove = [];
    _cartList.removeWhere((cartItem) {
      if (cartItem.item != null) {
        int? sId = cartItem.item!.storeId;
        if (sId == null && cartItem.item!.storeDetails != null && cartItem.item!.storeDetails!['id'] != null) {
          sId = int.tryParse(cartItem.item!.storeDetails!['id'].toString());
        }
        if (sId != null && storeIds.contains(sId)) {
          if (cartItem.id != null) {
            cartIdsToRemove.add(cartItem.id!);
            _quantityDebounceTimers[cartItem.id!]?.cancel();
            _quantityDebounceTimers.remove(cartItem.id!);
            _originalQuantities.remove(cartItem.id!);
            _pendingSubsequentSync.remove(cartItem.id!);
          }
          return true;
        }
      }
      return false;
    });

    await cartServiceInterface.addSharedPrefCartList(_cartList);
    calculationCart();
    update();

    if (AuthHelper.isLoggedIn() || AuthHelper.isGuestLoggedIn()) {
      for (int cartId in cartIdsToRemove) {
        await cartServiceInterface.removeCartItemOnline(cartId);
      }
    }
  }

  int isExistInCart(int? itemID, String variationType, bool isUpdate, int? cartIndex) {
    return cartServiceInterface.isExistInCart(_cartList, itemID, variationType, isUpdate, cartIndex);
  }

  bool existAnotherStoreItem(int? storeID, int? moduleId) {
    return cartServiceInterface.existAnotherStoreItem(storeID, moduleId, _cartList);
  }

  void filterCartForModuleLocal(int? targetModuleId) {
    if (targetModuleId != null) {
      _cartList.removeWhere((c) => c.item != null && c.item!.moduleId != targetModuleId);
    } else {
      _cartList = [];
    }
    calculationCart();
    update();
  }

  void setCurrentIndex(int index, bool notify) {
    _currentIndex = index;
    if(notify) {
      update();
    }
  }

  Future<bool> addToCartOnline(OnlineCart onlineCart, CartModel cartModel) async {
    int? itemId = cartModel.item?.id;
    if (itemId != null && _addingCartItemIds.contains(itemId)) {
      return false; // DEBOUNCE: Prevent duplicate request while item is being added!
    }

    if (itemId != null) {
      _addingCartItemIds.add(itemId);
    }
    _isAddToCartLoading = true;
    update();

    try {
      int existingIndex = _cartList.indexWhere((existing) => _isSameItemVariation(existing, cartModel));
      if (existingIndex != -1) {
        int oldQty = _cartList[existingIndex].quantity ?? 0;
        int addQty = cartModel.quantity ?? 1;
        int newQty = oldQty + addQty;
        int? stock = cartModel.stock ?? cartModel.item?.stock;
        int? limit = cartModel.item?.quantityLimit ?? cartModel.quantityLimit;
        if (limit != null && newQty > limit) {
          newQty = limit;
        }
        if (stock != null && newQty > stock) {
          newQty = stock;
        }
        _cartList[existingIndex].quantity = newQty;
        calculationCart();
        update();

        if (_cartList[existingIndex].id != null) {
          _scheduleQuantitySync(_cartList[existingIndex].id!, oldQty);
        }
        await cartServiceInterface.addSharedPrefCartList(_cartList);
        _isAddToCartLoading = false;
        _addingCartItemIds.remove(itemId);
        return true;
      }

      if (cartModel.item != null && cartModel.item!.id != null) {
        int totalCartQty = 0;
        for (var c in _cartList) {
          if (c.item != null && c.item!.id == cartModel.item!.id) {
            totalCartQty += (c.quantity ?? 0);
          }
        }
        int? stock = cartModel.stock ?? cartModel.item!.stock;
        bool isFood = cartModel.item!.moduleType == 'food';
        bool moduleStock = Get.find<SplashController>().configModel!.moduleConfig!.module!.stock!;
        if (!isFood && moduleStock && stock != null && (totalCartQty + (cartModel.quantity ?? 1)) > stock) {
          showCustomSnackBar('out_of_stock'.tr);
          return false;
        }
        int? limit = cartModel.item!.quantityLimit ?? cartModel.quantityLimit;
        if (limit != null && limit != 0 && (totalCartQty + (cartModel.quantity ?? 1)) > limit) {
          showCustomSnackBar('${'maximum_quantity_limit'.tr} $limit');
          return false;
        }
      }

      if (_cartIndexToReplace != null && _cartIndexToReplace! < _cartList.length) {
        int index = _cartIndexToReplace!;
        _cartIndexToReplace = null;
        await removeFromCart(index);
      }
      
      // Optimistic update
      _cartList.add(cartModel);
      _cartList = _deduplicateCartList(_cartList);
      calculationCart();
      update();

      bool success = false;
      List<OnlineCartModel>? onlineCartList = await cartServiceInterface.addToCartOnline(onlineCart);
      if(onlineCartList != null) {
        List<CartModel> rawList = cartServiceInterface.formatOnlineCartToLocalCart(onlineCartModel: onlineCartList);
        List<CartModel> deduplicated = _deduplicateCartList(rawList);

        if (_quantityDebounceTimers.isNotEmpty || _activeQuantitySyncItemIds.isNotEmpty) {
          for (var item in deduplicated) {
            if (item.id != null && (_quantityDebounceTimers.containsKey(item.id) || _activeQuantitySyncItemIds.contains(item.id))) {
              int localIdx = _cartList.indexWhere((c) => c.id == item.id);
              if (localIdx != -1) {
                item.quantity = _cartList[localIdx].quantity;
              }
            }
          }
        }

        _cartList = deduplicated;
        await cartServiceInterface.addSharedPrefCartList(_cartList);
        calculationCart();
        success = true;
        _checkAndSwitchModule(cartModel.item!.moduleId);
      } else {
        _cartList.remove(cartModel);
        calculationCart();
        update();
      }

      return success;
    } finally {
      if (itemId != null) {
        _addingCartItemIds.remove(itemId);
      }
      _isAddToCartLoading = false;
      update();
    }
  }

  Future<bool> updateCartOnline(OnlineCart onlineCart, CartModel cartModel, {bool notify = true}) async {
    if (cartModel.item != null && cartModel.item!.id != null) {
      int totalCartQtyOtherVariations = 0;
      for (var c in _cartList) {
        if (c.id == onlineCart.cartId) continue;
        if (c.item != null && c.item!.id == cartModel.item!.id) {
          totalCartQtyOtherVariations += (c.quantity ?? 0);
        }
      }
      int? stock = cartModel.stock ?? cartModel.item!.stock;
      bool isFood = cartModel.item!.moduleType == 'food';
      bool moduleStock = Get.find<SplashController>().configModel!.moduleConfig!.module!.stock!;
      if (!isFood && moduleStock && stock != null && (totalCartQtyOtherVariations + (cartModel.quantity ?? 1)) > stock) {
        showCustomSnackBar('out_of_stock'.tr);
        return false;
      }
      int? limit = cartModel.item!.quantityLimit ?? cartModel.quantityLimit;
      if (limit != null && limit != 0 && (totalCartQtyOtherVariations + (cartModel.quantity ?? 1)) > limit) {
        showCustomSnackBar('${'maximum_quantity_limit'.tr} $limit');
        return false;
      }
    }

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
      List<CartModel> rawList = cartServiceInterface.formatOnlineCartToLocalCart(onlineCartModel: onlineCartList);
      List<CartModel> deduplicated = _deduplicateCartList(rawList);

      if (_quantityDebounceTimers.isNotEmpty || _activeQuantitySyncItemIds.isNotEmpty) {
        for (var item in deduplicated) {
          if (item.id != null && (_quantityDebounceTimers.containsKey(item.id) || _activeQuantitySyncItemIds.contains(item.id))) {
            int localIdx = _cartList.indexWhere((c) => c.id == item.id);
            if (localIdx != -1) {
              item.quantity = _cartList[localIdx].quantity;
            }
          }
        }
      }

      _cartList = deduplicated;
      await cartServiceInterface.addSharedPrefCartList(_cartList);
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
      await cartServiceInterface.addSharedPrefCartList(_cartList);
      calculationCart();
    } else {
      int itemIdx = _cartList.indexWhere((c) => c.id == cartId);
      if (itemIdx != -1) {
        _cartList[itemIdx].quantity = oldQuantity;
      } else if (cartIndex >= 0 && cartIndex < _cartList.length) {
        _cartList[cartIndex].quantity = oldQuantity;
      }
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
        List<CartModel> rawList = cartServiceInterface.formatOnlineCartToLocalCart(onlineCartModel: onlineCartList);
        List<CartModel> deduplicated = _deduplicateCartList(rawList);

        if (_quantityDebounceTimers.isNotEmpty || _activeQuantitySyncItemIds.isNotEmpty) {
          for (var item in deduplicated) {
            if (item.id != null && (_quantityDebounceTimers.containsKey(item.id) || _activeQuantitySyncItemIds.contains(item.id))) {
              int localIdx = _cartList.indexWhere((c) => c.id == item.id);
              if (localIdx != -1) {
                item.quantity = _cartList[localIdx].quantity;
              }
            }
          }
        }

        _cartList = deduplicated;
        await cartServiceInterface.addSharedPrefCartList(_cartList);
        calculationCart();
      }
      update();
    }
  }

  Future<bool> removeCartItemOnline(int cartId, {Item? item, int? cartIndex, CartModel? cartModel}) async {
    // No loading set here
    bool success = await cartServiceInterface.removeCartItemOnline(cartId);
    if(success) {
      await cartServiceInterface.addSharedPrefCartList(_cartList);
      if(item != null) {
        Get.find<ItemController>().setExistInCart(item, null, notify: true);
      }
    } else {
      if(cartModel != null) {
        int insertIdx = (cartIndex != null && cartIndex >= 0 && cartIndex <= _cartList.length) ? cartIndex : _cartList.length;
        _cartList.insert(insertIdx, cartModel);
        calculationCart();
        update();
        await cartServiceInterface.addSharedPrefCartList(_cartList);
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
    if (index < 0 || index >= _cartList.length) return;
    _cartList[index].note = note;
    await cartServiceInterface.addSharedPrefCartList(_cartList);
    // update(); // We don't call update() here to prevent focus loss while typing
    
    _noteTimer?.cancel();
    _noteTimer = Timer(const Duration(milliseconds: 500), () {
      if (index < 0 || index >= _cartList.length) return;
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