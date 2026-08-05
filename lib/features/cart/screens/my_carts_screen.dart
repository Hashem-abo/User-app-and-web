import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/no_data_screen.dart';
import 'package:sixam_mart/features/cart/domain/models/cart_model.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/features/cart/domain/services/cart_service_interface.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/banner/controllers/banner_controller.dart';
import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/features/item/controllers/campaign_controller.dart';
import 'package:sixam_mart/features/flash_sale/controllers/flash_sale_controller.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/features/home/screens/home_screen.dart';
class MyCartsScreen extends StatefulWidget {
  const MyCartsScreen({super.key});

  @override
  State<MyCartsScreen> createState() => _MyCartsScreenState();
}

class _MyCartsScreenState extends State<MyCartsScreen> {
  final Map<int, List<CartModel>> _groupedCarts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllCarts();
  }

  void _loadAllCarts() {
    _groupedCarts.clear();
    List<String> cartsStr = Get.find<SharedPreferences>().getStringList(AppConstants.cartList) ?? [];
    List<CartModel> allCarts = [];
    
    for(String cartStr in cartsStr) {
      try {
        allCarts.add(CartModel.fromJson(jsonDecode(cartStr)));
      } catch(e) {
        debugPrint('Error parsing cart: $e');
      }
    }

    for (var cart in allCarts) {
      if(cart.item != null && cart.item!.moduleId != null) {
        if (!_groupedCarts.containsKey(cart.item!.moduleId)) {
          _groupedCarts[cart.item!.moduleId!] = [];
        }
        _groupedCarts[cart.item!.moduleId!]!.add(cart);
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _emptyCartForModule(int moduleId) async {
    List<String> cartsStr = Get.find<SharedPreferences>().getStringList(AppConstants.cartList) ?? [];
    List<String> remainingCarts = [];
    
    for(String cartStr in cartsStr) {
      try {
        CartModel cart = CartModel.fromJson(jsonDecode(cartStr));
        if (cart.item != null && cart.item!.moduleId != moduleId) {
          remainingCarts.add(cartStr);
        }
      } catch(e) {
        debugPrint('Error parsing cart: $e');
      }
    }
    
    await Get.find<SharedPreferences>().setStringList(AppConstants.cartList, remainingCarts);
    
    if (AuthHelper.isLoggedIn() || AuthHelper.isGuestLoggedIn()) {
      await Get.find<CartController>().clearCartOnline(moduleId: moduleId);
    }
    
    // If the emptied cart is for the current module, clear the active cart list too
    if(Get.find<SplashController>().module?.id == moduleId) {
      await Get.find<CartController>().clearCartList(canRemoveOnline: false);
    }
    
    _loadAllCarts();
  }

  void _openCartForModule(ModuleModel module) {
    int index = Get.find<SplashController>().moduleList?.indexWhere((m) => m.id == module.id) ?? -1;
    if (index != -1) {
      Get.find<SplashController>().switchModule(index, true).then((value) {
        Get.toNamed(RouteHelper.getCartRoute());
      });
    } else {
      Get.find<SplashController>().setModule(module).then((value) {
        Get.toNamed(RouteHelper.getCartRoute());
        Get.find<ItemController>().clearItemLists();
        Get.find<BannerController>().clearBanner();
        Get.find<CategoryController>().clearCategoryList();
        Get.find<CampaignController>().itemAndBasicCampaignNull();
        Get.find<FlashSaleController>().setEmptyFlashSale(fromModule: true);
        Get.find<StoreController>().getPopularStoreList(true, 'all', false);
        Get.find<StoreController>().getLatestStoreList(true, 'all', false);
        Get.find<StoreController>().getFeaturedStoreList();
        HomeScreen.loadData(false, fromModule: true);
       
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'my_carts'.tr),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : _groupedCarts.isEmpty 
          ? NoDataScreen(text: 'cart_is_empty'.tr)
          : ListView.builder(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              itemCount: _groupedCarts.keys.length,
              itemBuilder: (context, index) {
                int moduleId = _groupedCarts.keys.elementAt(index);
                List<CartModel> moduleCarts = _groupedCarts[moduleId]!;
                
                ModuleModel? module = Get.find<SplashController>().moduleList?.firstWhereOrNull((m) => m.id == moduleId);
                if (module == null) return const SizedBox();

                double total = 0;
                int itemsCount = 0;
                Set<int> storeIds = {};
                bool hasUnavailableItems = false;
                
                for (var cart in moduleCarts) {
                  itemsCount += cart.quantity ?? 1;
                  
                  // Same logic as CartController.calculationCart() to get the price
                  double price = cart.item!.price ?? 0;
                  double? discount = cart.item!.discount;
                  String? discountType = cart.item!.discountType;
                  
                  bool isFoodVariation = module.moduleType == 'food';
                  bool haveVariation = false;
                  double variationWithoutDiscountPrice = 0;
                  double variationPrice = 0;
                  
                  CartServiceInterface cartService = Get.find<CartController>().cartServiceInterface;
                  
                  variationPrice = cartService.calculateVariationPrice(isFoodVariation, cart, discount, discountType, variationPrice);
                  variationWithoutDiscountPrice = cartService.calculateVariationWithoutDiscountPrice(isFoodVariation, cart, variationWithoutDiscountPrice);
                  haveVariation = cartService.checkVariation(isFoodVariation, cart);

                  double itemPrice = haveVariation ? variationWithoutDiscountPrice : (price * cart.quantity!);
                  double discountPrice = haveVariation ? (variationWithoutDiscountPrice - variationPrice)
                      : (itemPrice - (PriceConverter.convertWithDiscount(price, discount, discountType)! * cart.quantity!));
                  
                  List<AddOns> addOnList = cartService.prepareAddonList(cart);
                  double addOnsPrice = cartService.calculateAddonPrice(0, addOnList, cart);
                  
                  double subTotal = 0;
                  if(isFoodVariation){
                     subTotal = (itemPrice - (discountPrice + (variationWithoutDiscountPrice - variationPrice))) + addOnsPrice + variationWithoutDiscountPrice;
                  } else {
                     subTotal = (itemPrice - discountPrice);
                  }
                  total += subTotal;
                  
                  if (cart.item!.storeId != null) {
                    storeIds.add(cart.item!.storeId!);
                  }

                  // Stock check
                  int? itemStock = cart.item!.stock;
                  int? cartStock = cart.stock;
                  int? qtyLimit = cart.item!.quantityLimit;
                  bool isFood = cart.item!.moduleType == 'food';

                  if(!isFood && ((itemStock != null && itemStock <= 0) || (cartStock != null && cartStock <= 0) || (qtyLimit != null && qtyLimit <= 0))) {
                    hasUnavailableItems = true;
                  }
                  if(cart.item!.storeDetails != null) {
                    bool storeActive = cart.item!.storeDetails!['active'] == 1 || cart.item!.storeDetails!['active'] == true;
                    bool storeOpen = cart.item!.storeDetails!['open'] == 1 || cart.item!.storeDetails!['open'] == true;
                    if(!storeActive || !storeOpen) {
                      hasUnavailableItems = true;
                    }
                  }
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, blurRadius: 5, spreadRadius: 1)],
                  ),
                  child: Column(
                    children: [
                      // Top row: Module Icon and Name
                      Padding(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  height: 50, width: 50,
                                  padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                  ),
                                  child: CustomImage(
                                    image: module.iconFullUrl ?? '',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(width: Dimensions.paddingSizeSmall),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(module.moduleName ?? '', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                                  ],
                                ),
                              ],
                            ),
                            if(hasUnavailableItems) 
                              Text('item_is_out_of_stock'.tr, style: robotoRegular.copyWith(color: Theme.of(context).colorScheme.error, fontSize: Dimensions.fontSizeSmall))
                            else
                              const SizedBox(),
                          ],
                        ),
                      ),
                      
                      Divider(height: 1, color: Theme.of(context).disabledColor.withOpacity(0.2)),
                      
                      // Middle row: Stats
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                        child: Row(
                          children: [
                            Expanded(child: _buildStatItem('providers'.tr, storeIds.length.toString())),
                            Container(height: 40, width: 1, color: Theme.of(context).disabledColor.withOpacity(0.2)),
                            Expanded(child: _buildStatItem('items'.tr, itemsCount.toString())),
                            Container(height: 40, width: 1, color: Theme.of(context).disabledColor.withOpacity(0.2)),
                            Expanded(child: _buildStatItem('total'.tr, PriceConverter.convertPrice(total))),

                          ],
                        ),
                      ),
                      
                      // Bottom row: Buttons
                      Padding(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                        child: Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                buttonText: 'clear_cart'.tr,
                                transparent: true,
                                textColor: Theme.of(context).textTheme.bodyLarge!.color,
                                isBorder: true,
                                radius: Dimensions.radiusSmall,
                                onPressed: () {
                                  Get.dialog(
                                    AlertDialog(
                                      title: Text('are_you_sure'.tr),
                                      content: Text('you_want_to_remove_all_items_from_cart'.tr),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Get.back(),
                                          child: Text('cancel'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor)),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Get.back();
                                            _emptyCartForModule(moduleId);
                                          },
                                          child: Text('yes'.tr, style: robotoRegular.copyWith(color: Theme.of(context).primaryColor)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeSmall),
                            Expanded(
                              child: CustomButton(
                                buttonText: 'open_cart'.tr,
                                color: Theme.of(context).primaryColor,
                                radius: Dimensions.radiusSmall,
                                onPressed: () => _openCartForModule(module),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildStatItem(String title, String value) {
    return Column(
      children: [
        Text(title, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall)),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        Text(value, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
      ],
    );
  }
}
