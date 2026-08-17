import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sixam_mart/common/widgets/login_suggestion_bottomsheet.dart';
import 'package:sixam_mart/common/widgets/confirmation_dialog.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/checkout/domain/models/place_order_body_model.dart';
import 'package:sixam_mart/features/cart/widgets/extra_packaging_widget.dart';
import 'package:sixam_mart/features/cart/widgets/not_available_bottom_sheet_widget.dart';
import 'package:sixam_mart/features/checkout/controllers/checkout_controller.dart';
import 'package:sixam_mart/features/checkout/screens/checkout_screen.dart';
import 'package:sixam_mart/features/coupon/controllers/coupon_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/pro/widgets/pro_cart_banner_widget.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/features/cart/domain/models/cart_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/module_helper.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/item_widget.dart';
import 'package:sixam_mart/common/widgets/card_design/item_card.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/common/widgets/no_data_screen.dart';
import 'package:sixam_mart/common/widgets/web_constrained_box.dart';
import 'package:sixam_mart/common/widgets/web_page_title_widget.dart';
import 'package:sixam_mart/features/cart/widgets/cart_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/cart/widgets/web_cart_items_widget.dart';
import 'package:sixam_mart/features/cart/widgets/web_suggested_item_view_widget.dart';
import 'package:sixam_mart/features/cart/widgets/add_to_monthly_widget.dart';
import 'package:sixam_mart/features/home/screens/home_screen.dart';
import 'package:sixam_mart/features/store/screens/store_screen.dart';
import 'package:sixam_mart/features/favourite/controllers/wish_list_controller.dart';
import 'package:sixam_mart/features/favourite/domain/models/wish_list_model.dart';
import 'package:intl/intl.dart';

class CartScreen extends StatefulWidget {
  final bool fromNav;
  const CartScreen({super.key, required this.fromNav});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final ScrollController scrollController = ScrollController();
  GlobalKey<ExpandableBottomSheetState> key = GlobalKey();

  final GlobalKey _widgetKey = GlobalKey();
  double _height = 0;

  @override
  void initState() {
    super.initState();

    initCall();

  }

  Future<void> initCall() async {
    _initialBottomSheetShowHide();
    if(Get.find<CartController>().cartList.isEmpty) {
      await Get.find<CartController>().getCartDataOnline();
    }
    if(Get.find<CartController>().cartList.isNotEmpty){
      if (Get.find<CartController>().selectedStoreId == null) {
        Get.find<CartController>().setSelectedStoreId(Get.find<CartController>().cartList[0].item!.storeId, notify: false);
      }
      if (kDebugMode) {
        print('----cart item : ${Get.find<CartController>().cartList[0].toJson()}');
      }

      if(Get.find<CartController>().addCutlery){
        Get.find<CartController>().updateCutlery(willUpdate: false);
      }
      if(Get.find<CartController>().needExtraPackage){
        Get.find<CartController>().toggleExtraPackage(willUpdate: false);
      }
      Get.find<CartController>().setAvailableIndex(-1, willUpdate: false);
      Get.find<StoreController>().getCartStoreSuggestedItemList(Get.find<CartController>().selectedStoreId ?? Get.find<CartController>().cartList[0].item!.storeId);
      Get.find<StoreController>().getStoreDetails(Store(id: Get.find<CartController>().cartList[0].item!.storeId, name: null), false, fromCart: true);
      Get.find<CartController>().calculationCart();
      showReferAndEarnSnackBar();
    }
  }

  void _initialBottomSheetShowHide() {
    Future.delayed(const Duration(milliseconds: 600), () {
      key.currentState?.expand();
    }).then((_) {
      Future.delayed(const Duration(seconds: 3), () {
        key.currentState?.contract();
      });
    });

    if(AuthHelper.isGuestLoggedIn() && (GetPlatform.isAndroid || GetPlatform.isIOS)) {
      Future.delayed(const Duration(milliseconds: 3000), () {
        if(Get.currentRoute == RouteHelper.cart && Get.isBottomSheetOpen == false) {
          Get.bottomSheet(LoginSuggestionBottomSheet(fromCartPage: true), isScrollControlled: true);
        }
      });
    }
  }

  void _getExpandedBottomSheetHeight() {
    if (_widgetKey.currentContext != null) {
      final RenderBox renderBox = _widgetKey.currentContext!.findRenderObject() as RenderBox;
      final size = renderBox.size;

      setState(() {
        _height = size.height;
      });
    }
  }

  void _onExpanded() {
    _getExpandedBottomSheetHeight();
  }

  void _onContracted() {
    setState(() {
      _height = 0;
    });
  }

  void _showModuleCartBottomSheet(BuildContext context, CartController cartController) {
    List<ModuleModel>? moduleList = Get.find<SplashController>().moduleList;
    Map<int, int> cartCounts = cartController.getModuleCartCounts();
    ModuleModel? currentModule = Get.find<SplashController>().module;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (con) => Container(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeLarge),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            height: 4, width: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          Text(
            'each_department_has_its_own_cart'.tr == 'each_department_has_its_own_cart' ? 'لكل قسم سلة خاصة به' : 'each_department_has_its_own_cart'.tr,
            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: moduleList?.length ?? 0,
            itemBuilder: (context, index) {
              ModuleModel module = moduleList![index];
              bool isActive = module.id == currentModule?.id;
              int count = cartCounts[module.id] ?? 0;

              return InkWell(
                onTap: () async {
                  if(!isActive) {
                    await Get.find<SplashController>().switchModule(index, true);
                  }
                  if(Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                  margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    color: isActive ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Theme.of(context).disabledColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    border: Border.all(color: isActive ? Theme.of(context).primaryColor : Colors.transparent, width: 1),
                  ),
                  child: Row(children: [
                    Expanded(child: Text(
                      '${'cart'.tr == 'cart' ? 'سلة' : 'cart'.tr} ${module.moduleName!}',
                      style: robotoMedium.copyWith(color: isActive ? Theme.of(context).primaryColor : null),
                    )),
                    Text(
                      count > 0 ? '$count' : ('empty'.tr == 'empty' ? 'فارغة' : 'empty'.tr),
                      style: robotoRegular.copyWith(color: count > 0 ? null : Theme.of(context).disabledColor),
                    ),
                  ]),
                ),
              );
            },
          ),
        ]),
      ),
    );
  }

  final TextEditingController _shareLinkController = TextEditingController();

  void _showShareBottomSheet(BuildContext context) {
    CartController cartController = Get.find<CartController>();
    List<Map<String, dynamic>> items = [];
    for (var cartModel in cartController.cartList) {
      items.add({'id': cartModel.item!.id, 'qty': cartModel.quantity});
    }
    String data = base64Encode(utf8.encode(jsonEncode(items)));
    String link = '${AppConstants.webHostedUrl}${RouteHelper.getShareCartRoute(data)}';
    if (AuthHelper.isLoggedIn()) {
      String refCode = Get.find<ProfileController>().userInfoModel?.refCode ?? '';
      if (refCode.isNotEmpty) {
        link = link.contains('?') ? '$link&ref=$refCode' : '$link?ref=$refCode';
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (con) => Container(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeLarge),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            height: 4, width: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          Text(
            'share_cart'.tr == 'share_cart' ? 'مشاركة السلة' : 'share_cart'.tr,
            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
          ),
          Text(
            'share_this_cart_with_others'.tr == 'share_this_cart_with_others' ? 'شارك هذه السلة مع الآخرين' : 'share_this_cart_with_others'.tr,
            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          _buildShareOption(
            context,
            'copy_current_cart_link'.tr == 'copy_current_cart_link' ? 'نسخ رابط السلة الحالية' : 'copy_current_cart_link'.tr,
            Icons.copy,
            () {
              Clipboard.setData(ClipboardData(text: link));
              showCustomSnackBar('link_copied'.tr, isError: false);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          _buildShareOption(
            context,
            'share_via_apps'.tr == 'share_via_apps' ? 'مشاركة عبر التطبيقات' : 'share_via_apps'.tr,
            Icons.send,
            () {
              Share.share(link);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          Divider(color: Theme.of(context).disabledColor.withValues(alpha: 0.2)),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          Text(
            'open_cart_from_link'.tr == 'open_cart_from_link' ? 'قم بفتح سلة من رابط' : 'open_cart_from_link'.tr,
            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).disabledColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.1)),
            ),
            child: Row(children: [
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Icon(Icons.link, color: Theme.of(context).primaryColor),
              Expanded(child: TextField(
                controller: _shareLinkController,
                decoration: InputDecoration(
                  hintText: 'paste_cart_link_here'.tr == 'paste_cart_link_here' ? 'ألصق رابط سلة هنا' : 'paste_cart_link_here'.tr,
                  hintStyle: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                ),
              )),
              IconButton(
                icon: Icon(Icons.paste, color: Theme.of(context).primaryColor),
                onPressed: () async {
                  ClipboardData? data = await Clipboard.getData('text/plain');
                  if(data?.text != null) {
                    _shareLinkController.text = data!.text!;
                  }
                },
              ),
            ]),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          CustomButton(
            buttonText: 'open_cart'.tr == 'open_cart' ? 'فتح السلة' : 'open_cart'.tr,
            onPressed: () => _openSharedCart(_shareLinkController.text),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
        ]),
      ),
    );
  }

  void _showWishListBottomSheet(BuildContext context) {
    TextEditingController groupNameController = TextEditingController(text: 'home_purchases'.tr == 'home_purchases' ? 'مشتريات البيت' : 'home_purchases'.tr);
    DateTime? selectedDate = DateTime.now().add(const Duration(days: 7));
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (con) => StatefulBuilder(builder: (context, setState) {
        return Container(
          padding: EdgeInsets.only(
            left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault, 
            top: Dimensions.paddingSizeLarge, bottom: MediaQuery.of(context).viewInsets.bottom + Dimensions.paddingSizeLarge,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(height: 4, width: 40, decoration: BoxDecoration(color: Theme.of(context).disabledColor.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Text('save_as_wish_list'.tr == 'save_as_wish_list' ? 'حفظ كقائمة الامنيات' : 'save_as_wish_list'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              Align(alignment: Alignment.centerRight, child: Text('group_name'.tr == 'group_name' ? 'اسم المجموعة' : 'group_name'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor))),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              TextField(
                controller: groupNameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              Align(alignment: Alignment.centerRight, child: Text('set_reminder_date'.tr == 'set_reminder_date' ? 'تحديد موعد تذكير' : 'set_reminder_date'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor))),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              InkWell(
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() => selectedDate = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeDefault),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.5)),
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  ),
                  child: Row(children: [
                    Icon(Icons.calendar_today, color: Theme.of(context).primaryColor, size: 20),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Text(selectedDate != null ? DateFormat('dd/MM/yyyy').format(selectedDate!) : 'select_date'.tr),
                  ]),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              CustomButton(
                buttonText: 'save'.tr == 'save' ? 'حفظ' : 'save'.tr,
                onPressed: () {
                  if (groupNameController.text.isEmpty) {
                    showCustomSnackBar('please_enter_group_name'.tr);
                  } else {
                    Get.find<WishListController>().addWishList(WishListModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: groupNameController.text,
                      items: Get.find<CartController>().cartList,
                      reminderDate: selectedDate,
                    ));
                    Navigator.pop(context);
                    showCustomSnackBar('wish_list_saved_successfully'.tr == 'wish_list_saved_successfully' ? 'تم حفظ قائمة الامنيات بنجاح' : 'wish_list_saved_successfully'.tr, isError: false);
                  }
                },
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
            ]),
          ),
        );
      }),
    );
  }

  Widget _buildShareOption(BuildContext context, String title, IconData icon, Function onTap) {
    return InkWell(
      onTap: onTap as void Function()?,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).disabledColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.1)),
        ),
        child: Row(children: [
          Expanded(child: Text(title, style: robotoMedium)),
          Icon(icon, size: 20),
        ]),
      ),
    );
  }

  void _openSharedCart(String link) async {
    if(link.isEmpty) {
      showCustomSnackBar('please_paste_a_link'.tr);
      return;
    }
    Uri? uri = Uri.tryParse(link);
    String? data = uri?.queryParameters['data'];
    if(data == null || data.isEmpty) {
      showCustomSnackBar('invalid_cart_link'.tr);
      return;
    }

    try {
      final decoded = jsonDecode(utf8.decode(base64Decode(data.replaceAll(' ', '+'))));
      if (decoded is List) {
        showCustomLoading();
        CartController cartController = Get.find<CartController>();

        for (var itemData in decoded) {
          int itemId = itemData['id'];
          int quantity = itemData['qty'];
          
          Item? item = await Get.find<ItemController>().itemServiceInterface.getItemDetails(itemId);
          if (item != null) {
            double price = item.price!;
            double discountedPrice = PriceConverter.convertWithDiscount(price, item.discount, item.discountType)!;
            
            CartModel cartModel = CartModel(
              id: null, price: price, discountedPrice: discountedPrice, variation: [], foodVariations: [], discountAmount: 0, quantity: quantity, addOnIds: [], addOns: [], isCampaign: false, stock: item.stock, item: item, quantityLimit: item.quantityLimit,
            );
            
            OnlineCart onlineCart = OnlineCart(
              cartId: null, itemId: item.id, itemCampaignId: null, price: discountedPrice.toString(), variant: '',
              variation: [], variations: [], quantity: quantity, addOnIds: [], addOns: [], addOnQtys: [], model: 'item',
            );
            await cartController.addToCartOnline(onlineCart, cartModel);
          }
        }
        hideCustomLoading();
        _shareLinkController.clear();
        Navigator.pop(Get.context!);
        showCustomSnackBar('cart_imported_successfully'.tr, isError: false);
      }
    } catch (e) {
      hideCustomLoading();
      debugPrint('Error processing shared cart: $e');
      showCustomSnackBar('failed_to_import_cart'.tr);
    }
  }

  void showCustomLoading() {
    showDialog(context: Get.context!, barrierDismissible: false, builder: (con) => const Center(child: CircularProgressIndicator()));
  }

  void hideCustomLoading() {
    Navigator.pop(Get.context!);
  }

  @override
  Widget build(BuildContext context) {

    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(
        title: 'my_cart'.tr,
        backButton: true,
        onBackPressed: () {
          if (Navigator.canPop(context)) {
            Get.back();
          } else {
            Get.offAllNamed(RouteHelper.getInitialRoute());
          }
        },
        titleWidget: GetBuilder<CartController>(builder: (cartController) {
          List<ModuleModel>? moduleList = Get.find<SplashController>().moduleList;

          int storeCount = 0;
          Set<int> storeIds = {};
          for(var cart in cartController.cartList) {
            storeIds.add(cart.item!.storeId!);
          }
          storeCount = storeIds.length;

          return (moduleList != null && moduleList.length > 1) ? InkWell(
            onTap: () => _showModuleCartBottomSheet(context, cartController),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Flexible(child: Text(
                '${'my_cart'.tr} ($storeCount ${'stores'.tr})',
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge!.color),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              )),
              Icon(Icons.keyboard_arrow_down, color: Theme.of(context).textTheme.bodyLarge!.color, size: 18),
            ]),
          ) : Text(
            '${'my_cart'.tr} ($storeCount ${'stores'.tr})',
            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge!.color),
            maxLines: 1, overflow: TextOverflow.ellipsis,
          );
        }),
        actionWidget: Row(children: [
          IconButton(
            iconSize: 20,
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
            constraints: const BoxConstraints(),
            icon: Icon(Icons.playlist_add, color: Theme.of(context).primaryColor),
            onPressed: () => _showWishListBottomSheet(context),
          ),
          IconButton(
            iconSize: 20,
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
            constraints: const BoxConstraints(),
            icon: Icon(Icons.share, color: Theme.of(context).primaryColor),
            onPressed: () => _showShareBottomSheet(context),
          ),
        ]),
      ),
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      body: GetBuilder<StoreController>(builder: (storeController) {
        return GetBuilder<CartController>(builder: (cartController) {
          bool isFoodOrGrocery = ModuleHelper.getModule()?.moduleType == 'food' || ModuleHelper.getModule()?.moduleType == 'grocery';
          int? selectedStoreId = cartController.selectedStoreId;
          Map<String, double>? storeTotals;
          if (isFoodOrGrocery && selectedStoreId != null) {
            storeTotals = cartController.getSubTotalForStore(selectedStoreId);
          }

          return cartController.cartList.isNotEmpty ? Column(children: [

            Expanded(
              child: ExpandableBottomSheet(
                key: key,
                persistentHeader: const SizedBox(),

                background: Column(children: [

                  WebScreenTitleWidget(title: 'cart_list'.tr),

                   Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.only(
                        top: Dimensions.paddingSizeSmall,
                      ) : EdgeInsets.zero,
                      child: FooterView(
                        child: SizedBox(
                          width: Dimensions.webMaxWidth,
                          child: Column(children: [

                            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              ResponsiveHelper.isDesktop(context) ? WebCardItemsWidget(cartList: cartController.cartList) : Expanded(
                                flex: 7,
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                                  WebConstrainedBox(
                                    dataLength: cartController.cartList.length, minLength: 5, minHeight: 0.6,
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).cardColor,
                                        ),
                                        child: Builder(
                                          builder: (context) {
                                            Map<int, List<int>> groupedCart = {};
                                            for (int i = 0; i < cartController.cartList.length; i++) {
                                              int storeId = cartController.cartList[i].item!.storeId!;
                                              if (!groupedCart.containsKey(storeId)) {
                                                groupedCart[storeId] = [];
                                              }
                                              groupedCart[storeId]!.add(i);
                                            }

                                            bool isFoodOrGrocery = ModuleHelper.getModule()?.moduleType == 'food' || ModuleHelper.getModule()?.moduleType == 'grocery';
                                            
                                            if (isFoodOrGrocery) {
                                              int selectedStoreId = (cartController.selectedStoreId != null && groupedCart.containsKey(cartController.selectedStoreId))
                                                   ? cartController.selectedStoreId!
                                                   : groupedCart.keys.first;

                                              if (cartController.selectedStoreId != selectedStoreId) {
                                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                                  cartController.setSelectedStoreId(selectedStoreId, notify: false);
                                                  Get.find<StoreController>().getCartStoreSuggestedItemList(selectedStoreId);
                                                  
                                                  // Update SplashController module in background
                                                  int? newModuleId = cartController.cartList[groupedCart[selectedStoreId]![0]].item!.moduleId;
                                                  if (newModuleId != null) {
                                                    int moduleIndex = Get.find<SplashController>().moduleList?.indexWhere((m) => m.id == newModuleId) ?? -1;
                                                    if (moduleIndex != -1 && Get.find<SplashController>().module?.id != newModuleId) {
                                                      Get.find<SplashController>().switchModule(moduleIndex, true);
                                                    }
                                                  }
                                                });
                                              }
                                              
                                              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                                // Tabs
                                                SizedBox(
                                                  height: 50,
                                                  child: ListView.builder(
                                                    scrollDirection: Axis.horizontal,
                                                    itemCount: groupedCart.length,
                                                    itemBuilder: (context, index) {
                                                      int storeId = groupedCart.keys.elementAt(index);
                                                      String storeName = cartController.cartList[groupedCart[storeId]![0]].item!.storeName ?? '';
                                                      bool isSelected = storeId == selectedStoreId;
                                                      
                                                      return InkWell(
                                                        onTap: () {
                                                          cartController.setSelectedStoreId(storeId);
                                                          Get.find<StoreController>().getCartStoreSuggestedItemList(storeId);
                                                          
                                                          // Update SplashController module in background
                                                          int? newModuleId = cartController.cartList[groupedCart[storeId]![0]].item!.moduleId;
                                                          if (newModuleId != null) {
                                                            int moduleIndex = Get.find<SplashController>().moduleList?.indexWhere((m) => m.id == newModuleId) ?? -1;
                                                            if (moduleIndex != -1 && Get.find<SplashController>().module?.id != newModuleId) {
                                                              Get.find<SplashController>().switchModule(moduleIndex, true);
                                                            }
                                                          }
                                                        },
                                                        child: Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
                                                          margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                                                          decoration: BoxDecoration(
                                                            color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withValues(alpha: 0.1),
                                                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                                          ),
                                                          child: Row(children: [
                                                            Text(
                                                              storeName,
                                                              style: robotoMedium.copyWith(color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge!.color),
                                                            ),
                                                            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                                            Container(
                                                              padding: const EdgeInsets.all(4),
                                                              decoration: BoxDecoration(
                                                                color: isSelected ? Colors.white : Theme.of(context).primaryColor,
                                                                shape: BoxShape.circle,
                                                              ),
                                                              child: Text(
                                                                '${groupedCart[storeId]!.length}',
                                                                style: robotoRegular.copyWith(fontSize: 10, color: isSelected ? Theme.of(context).primaryColor : Colors.white),
                                                              ),
                                                            ),
                                                          ]),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(height: Dimensions.paddingSizeDefault),
                                                
                                                // Items for selected store
                                                ListView.builder(
                                                  physics: const NeverScrollableScrollPhysics(),
                                                  shrinkWrap: true,
                                                  itemCount: groupedCart[selectedStoreId]!.length,
                                                  itemBuilder: (context, i) {
                                                    int index = groupedCart[selectedStoreId]![i];
                                                    return CartItemWidget(
                                                      cart: cartController.cartList[index],
                                                      cartIndex: index,
                                                      addOns: cartController.addOnsList[index],
                                                      isAvailable: cartController.availableList[index],
                                                      showDivider: i != groupedCart[selectedStoreId]!.length - 1,
                                                    );
                                                  },
                                                ),
                                                
                                                // Add more from this store button
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                                                  child: InkWell(
                                                    onTap: () {
                                                      cartController.forcefullySetModule(cartController.cartList[groupedCart[selectedStoreId]![0]].item!.moduleId!);
                                                      Get.toNamed(
                                                        RouteHelper.getStoreRoute(id: selectedStoreId, page: 'item'),
                                                        arguments: StoreScreen(store: Store(id: selectedStoreId), fromModule: false),
                                                      );
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                                        border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.5)),
                                                      ),
                                                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                                        Icon(Icons.add_circle_outline_sharp, color: Theme.of(context).primaryColor, size: 20),
                                                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                                        Text(
                                                          'add_more_from_this_store'.tr == 'add_more_from_this_store' ? 'أضف المزيد من منتجات هذا المتجر' : 'add_more_from_this_store'.tr,
                                                          style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeDefault),
                                                        ),
                                                      ]),
                                                    ),
                                                  ),
                                                ),
                                              ]);
                                            } else {
                                                int firstStoreId = groupedCart.keys.first;
                                                StoreController storeController = Get.find<StoreController>();
                                                if (storeController.cartSuggestStoreId != firstStoreId) {
                                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                                    storeController.getCartStoreSuggestedItemList(firstStoreId);
                                                  });
                                                }
                                                
                                                return Column(children: groupedCart.entries.map((entry) {
                                                int storeId = entry.key;
                                                List<int> indices = entry.value;
                                                List<CartModel> itemsForThisStore = indices.map((index) => cartController.cartList[index]).toList();
                                                String storeName = cartController.cartList[indices[0]].item!.storeName ?? '';

                                                return Container(
                                                  margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context).cardColor,
                                                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
                                                  ),
                                                  child: Column(children: [
                                                    Stack(children: [
                                                      Positioned(
                                                        top: 0, bottom: 0, right: 0,
                                                        child: Container(
                                                          width: 30,
                                                          decoration: BoxDecoration(
                                                            color: Theme.of(context).primaryColor.withValues(alpha: 0.8),
                                                            borderRadius: const BorderRadius.only(topRight: Radius.circular(Dimensions.radiusDefault), bottomRight: Radius.circular(Dimensions.radiusDefault)),
                                                          ),
                                                          child: Center(
                                                            child: RotatedBox(
                                                              quarterTurns: 3,
                                                              child: Text(
                                                                storeName,
                                                                textAlign: TextAlign.center,
                                                                maxLines: 1, overflow: TextOverflow.ellipsis,
                                                                style: robotoBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeSmall),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),

                                                      Padding(
                                                        padding: const EdgeInsets.only(right: 30),
                                                        child: ListView.builder(
                                                          physics: const NeverScrollableScrollPhysics(),
                                                          shrinkWrap: true,
                                                          itemCount: indices.length,
                                                          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                                          itemBuilder: (context, i) {
                                                            int index = indices[i];
                                                            return CartItemWidget(
                                                              cart: cartController.cartList[index],
                                                              cartIndex: index,
                                                              addOns: cartController.addOnsList[index],
                                                              isAvailable: cartController.availableList[index],
                                                              showDivider: i != indices.length - 1,
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ]),

                                                    Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                                                      child: InkWell(
                                                        onTap: () {
                                                          cartController.forcefullySetModule(cartController.cartList[indices[0]].item!.moduleId!);
                                                          Get.toNamed(
                                                            RouteHelper.getStoreRoute(id: storeId, page: 'item'),
                                                            arguments: StoreScreen(store: Store(id: storeId), fromModule: false),
                                                          );
                                                        },
                                                        child: Container(
                                                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                                            border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.5)),
                                                          ),
                                                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                                            Icon(Icons.add_circle_outline_sharp, color: Theme.of(context).primaryColor, size: 20),
                                                            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                                            Text(
                                                              'add_more_from_this_store'.tr == 'add_more_from_this_store' ? 'أضف المزيد من منتجات هذا المتجر' : 'add_more_from_this_store'.tr,
                                                              style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeDefault),
                                                            ),
                                                          ]),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: Dimensions.paddingSizeSmall),
                                                  ]),
                                                );
                                              }).toList());
                                            }
                                          }
                                        ),
                                      ),

                                       if (_isGroceryOrPharmacy(cartController) && !_hasCampaignOrFlashSaleItem(cartController) && (AuthHelper.isLoggedIn() && Get.find<SplashController>().configModel?.monthlyOrderRemainder == 1)) ...[
                                         const MonthlyReorderSection(),
                                         const SizedBox(height: Dimensions.paddingSizeLarge),
                                       ],

                                      ExtraPackagingWidget(cartController: cartController),

                                      !ResponsiveHelper.isDesktop(context) ? suggestedItemView(cartController.cartList) : const SizedBox(),

                                    ]),
                                  ),
                                  const SizedBox(height: Dimensions.paddingSizeSmall),

                                  !ResponsiveHelper.isDesktop(context) ? pricingView(cartController, cartController.cartList[0].item!, storeTotals) : const SizedBox(),

                                ]),
                              ),
                              ResponsiveHelper.isDesktop(context) ? const SizedBox(width: Dimensions.paddingSizeSmall) : const SizedBox(),

                              ResponsiveHelper.isDesktop(context) ? Expanded(flex: 4, child: pricingView(cartController, cartController.cartList[0].item!, storeTotals)) : const SizedBox(),
                            ]),

                            ResponsiveHelper.isDesktop(context) ? WebSuggestedItemViewWidget(cartList: cartController.cartList) : const SizedBox(),
                            const SizedBox(height: Dimensions.paddingSizeExtraOverLarge),

                          ]),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: _height),

                ]),

                onIsExtendedCallback: _onExpanded,
                onIsContractedCallback: _onContracted,

                expandableContent: isDesktop ? const SizedBox() : Container(
                  width: context.width,
                  key: _widgetKey,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusDefault), topRight: Radius.circular(Dimensions.radiusDefault)),
                  ),
                  child: Column(children: [
                    Container(
                      padding: const EdgeInsets.only(
                        left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall, top: Dimensions.paddingSizeSmall,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusDefault), topRight: Radius.circular(Dimensions.radiusDefault)),
                      ),
                      child: Column(children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('item_price'.tr, style: robotoRegular),
                          PriceConverter.convertAnimationPrice(storeTotals != null ? storeTotals['itemPrice']! : cartController.itemPrice, textStyle: robotoRegular),
                        ]),
                        SizedBox(height: (storeTotals != null ? storeTotals['variationPrice']! > 0 : cartController.variationPrice > 0) && ModuleHelper.getModuleConfig(cartController.cartList.first.item!.moduleType).newVariation!
                            ? Dimensions.paddingSizeSmall : 0),

                        (storeTotals != null ? storeTotals['variationPrice']! > 0 : cartController.variationPrice > 0) && ModuleHelper.getModuleConfig(cartController.cartList.first.item!.moduleType).newVariation! ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('variations'.tr, style: robotoRegular),
                            Text(
                              '(+) ${PriceConverter.convertPrice(storeTotals != null ? storeTotals['variationPrice']! : cartController.variationPrice)}',
                              style: robotoRegular, //textDirection: TextDirection.ltr,
                            ),
                          ],
                        ) : const SizedBox(),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('discount'.tr, style: robotoRegular),
                          storeController.store != null ? Row(children: [
                            Text('(-)', style: robotoRegular),
                            PriceConverter.convertAnimationPrice(storeTotals != null ? storeTotals['itemDiscountPrice']! : cartController.itemDiscountPrice, textStyle: robotoRegular),
                          ]) : Text('calculating'.tr, style: robotoRegular),
                        ]),
                        SizedBox(height: Get.find<SplashController>().configModel!.moduleConfig!.module!.addOn! ? Dimensions.paddingSizeSmall : 0),

                        Get.find<SplashController>().configModel!.moduleConfig!.module!.addOn! ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('addons'.tr, style: robotoRegular),
                            Row(children: [
                              Text('(+)', style: robotoRegular),
                              PriceConverter.convertAnimationPrice(storeTotals != null ? storeTotals['addOns']! : cartController.addOns, textStyle: robotoRegular),
                            ]),
                          ],
                        ) : const SizedBox(),

                      ]),
                    ),

                  ]),
                ),

              ),
            ),

            ResponsiveHelper.isDesktop(context) ? const SizedBox.shrink() : CheckoutButton(
              cartController: cartController, 
              availableList: cartController.availableList,
              onPriceTap: () {
                if (cartController.isExpanded) {
                  cartController.setExpanded(false);
                  key.currentState?.contract();
                } else {
                  cartController.setExpanded(true);
                  key.currentState?.expand();
                }
              },
            ),

          ]) : const NoDataScreen(isCart: true, text: '', showFooter: true);
        });
      }),
    );
  }

  Widget pricingView(CartController cartController, Item item, Map<String, double>? storeTotals){
    return Container(
      decoration: ResponsiveHelper.isDesktop(context) ? BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular( ResponsiveHelper.isDesktop(context) ? Dimensions.radiusDefault : Dimensions.radiusSmall),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
      ) : null,
      child: GetBuilder<StoreController>(
        builder: (storeController) {
          return Column(children: [

            ResponsiveHelper.isDesktop(context) ? ExtraPackagingWidget(cartController: cartController) : const SizedBox(),

            ResponsiveHelper.isDesktop(context) ? Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                child: Text('order_summary'.tr, style: robotoBold),
              ),
            ) : const SizedBox(),

            !ResponsiveHelper.isDesktop(context) && Get.find<SplashController>().getModuleConfig(item.moduleType).newVariation!
            && (storeController.store != null && storeController.store!.cutlery!) ? Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2, spreadRadius: 1, offset: const Offset(0, 1))],
              ),
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
              margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
              child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Image.asset(Images.cutlery, height: 18, width: 18, color: Theme.of(context).textTheme.bodyLarge!.color,),
                const SizedBox(width: Dimensions.paddingSizeDefault),

                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('add_cutlery'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                    Text('do_not_have_cutlery'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall)),
                  ]),
                ),

                Transform.scale(
                  scale: 0.7,
                  child: CupertinoSwitch(
                    value: cartController.addCutlery,
                    activeTrackColor: Theme.of(context).primaryColor,
                    onChanged: (bool? value) {
                      cartController.updateCutlery();
                    },
                    inactiveTrackColor: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                  ),
                ),

              ]),
            ) : const SizedBox(),

            ResponsiveHelper.isDesktop(context) ? const SizedBox() : Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2, spreadRadius: 1, offset: const Offset(0, 1))],
                // border: Border.all(color: Theme.of(context).primaryColor, width: 0.5),
              ),
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              margin: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall) : EdgeInsets.zero,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: (){
                      if(ResponsiveHelper.isDesktop(context)) {
                        Get.dialog(const Dialog(child: NotAvailableBottomSheetWidget()));
                      } else {
                        showModalBottomSheet(
                          context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                          builder: (con) => const NotAvailableBottomSheetWidget(),
                        );
                      }
                    },
                    child: Row(children: [
                      Expanded(child: Text('if_any_product_is_not_available'.tr, style: robotoMedium, maxLines: 2, overflow: TextOverflow.ellipsis)),
                      const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                    ]),
                  ),

                  cartController.notAvailableIndex != -1 ? Row(children: [
                    Text(cartController.notAvailableList[cartController.notAvailableIndex].tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)),

                    IconButton(
                      onPressed: ()=> cartController.setAvailableIndex(-1),
                      icon: const Icon(Icons.clear, size: 18),
                    )
                  ]) : const SizedBox(),
                ],
              ),
            ),
            ResponsiveHelper.isDesktop(context) ? const SizedBox() : const SizedBox(height: Dimensions.paddingSizeSmall),

            // Total
            ResponsiveHelper.isDesktop(context) ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('item_price'.tr, style: robotoRegular),
                  PriceConverter.convertAnimationPrice(storeTotals != null ? storeTotals['itemPrice']! : cartController.itemPrice, textStyle: robotoRegular),
                ]),
                SizedBox(height: (storeTotals != null ? storeTotals['variationPrice']! > 0 : cartController.variationPrice > 0) ? Dimensions.paddingSizeSmall : 0),

                Get.find<SplashController>().getModuleConfig(item.moduleType).newVariation! && (storeTotals != null ? storeTotals['variationPrice']! > 0 : cartController.variationPrice > 0) ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('variations'.tr, style: robotoRegular),
                    Text('(+) ${PriceConverter.convertPrice(storeTotals != null ? storeTotals['variationPrice']! : cartController.variationPrice)}', style: robotoRegular),
                  ],
                ) : const SizedBox(),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('discount'.tr, style: robotoRegular),
                  storeController.store != null ? Row(children: [
                    Text('(-)', style: robotoRegular),
                    PriceConverter.convertAnimationPrice(storeTotals != null ? storeTotals['itemDiscountPrice']! : cartController.itemDiscountPrice, textStyle: robotoRegular),
                  ]) : Text('calculating'.tr, style: robotoRegular),
                  // Text('(-) ${PriceConverter.convertPrice(cartController.itemDiscountPrice)}', style: robotoRegular, textDirection: TextDirection.ltr),
                ]),
                SizedBox(height: Get.find<SplashController>().configModel!.moduleConfig!.module!.addOn! ? 10 : 0),

                Get.find<SplashController>().configModel!.moduleConfig!.module!.addOn! ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('addons'.tr, style: robotoRegular),
                    Text('(+) ${PriceConverter.convertPrice(storeTotals != null ? storeTotals['addOns']! : cartController.addOns)}', style: robotoRegular),
                  ],
                ) : const SizedBox(),
              ]),
            ) : const SizedBox(),

            ResponsiveHelper.isDesktop(context) ? CheckoutButton(cartController: cartController, availableList: cartController.availableList) : const SizedBox.shrink(),

          ]);
        }
      ),
    );
  }

  Widget suggestedItemView(List<CartModel> cartList){
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).disabledColor.withValues(alpha: 0.1)),
      width: double.infinity,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        GetBuilder<StoreController>(builder: (storeController) {
          List<Item>? suggestedItems;
          if(storeController.cartSuggestItemModel != null){
            suggestedItems = [];
            List<int> cartIds = [];
            for (CartModel cartItem in cartList) {
              cartIds.add(cartItem.item!.id!);
            }
            for (Item item in storeController.cartSuggestItemModel!.items!) {
              if(!cartIds.contains(item.id)){
                suggestedItems.add(item);
              }
            }
          }
          return storeController.cartSuggestItemModel != null && suggestedItems!.isNotEmpty ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
                child: Text('you_may_also_like'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
              ),

              SizedBox(
                height: (ModuleHelper.getModule()?.moduleType == 'food') ? 230 : 380,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: suggestedItems.length,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
                      child: ItemCard(
                        item: suggestedItems![index],
                        isFood: suggestedItems[index].moduleType == 'food',
                        isShop: suggestedItems[index].moduleType != 'food',
                        width: 200,
                      ),
                    );
                  },
                ),
              ),
            ],
          ) : const SizedBox();
        }),
      ]),
    );
  }

  Future<void> showReferAndEarnSnackBar() async {
    String text = 'your_referral_discount_added_on_your_first_order'.tr;
    if(Get.find<ProfileController>().userInfoModel != null &&  Get.find<ProfileController>().userInfoModel!.isValidForDiscount!) {
      showCustomSnackBar(text, isError: false);
    }
  }

  bool _isGroceryOrPharmacy(CartController cartController) {
    final String? moduleType = cartController.cartList.isNotEmpty ? cartController.cartList[0].item?.moduleType : null;
    return moduleType == AppConstants.grocery || moduleType == AppConstants.pharmacy;
  }

  bool _hasCampaignOrFlashSaleItem(CartController cartController) {
    return cartController.cartList.any((cart) => (cart.isCampaign ?? false) || (cart.item?.flashSale ?? 0) > 0);
  }

}

class CheckoutButton extends StatelessWidget {
  final CartController cartController;
  final List<bool> availableList;
  final Function? onPriceTap;
  const CheckoutButton({super.key, required this.cartController, required this.availableList, this.onPriceTap});

  @override
  Widget build(BuildContext context) {
    bool isFoodOrGrocery = ModuleHelper.getModule()?.moduleType == 'food' || ModuleHelper.getModule()?.moduleType == 'grocery';
    int? selectedStoreId = (cartController.selectedStoreId != null && cartController.cartList.any((cart) => cart.item!.storeId == cartController.selectedStoreId))
        ? cartController.selectedStoreId!
        : (cartController.cartList.isNotEmpty ? cartController.cartList[0].item!.storeId : null);

    return Container(
      width: Dimensions.webMaxWidth,
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pro member banner (upgrade prompt or active benefit)
            if (!ResponsiveHelper.isDesktop(context))
              Padding(
                padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                child: ProCartBannerWidget(
                  subtotal: isFoodOrGrocery && selectedStoreId != null
                      ? (cartController.getSubTotalForStore(selectedStoreId)['total'] ?? cartController.subTotal)
                      : cartController.subTotal,
                  redirectRoute: RouteHelper.getCartRoute(),
                ),
              ),
            Row(
              children: [
            // Price Display Box
            Expanded(
              flex: 1,
              child: InkWell(
                onTap: onPriceTap as void Function()?,
                child: Container(
                  height: 55,
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.keyboard_arrow_down, color: Colors.grey[600], size: 20),
                      Text(
                        PriceConverter.convertPrice(isFoodOrGrocery && selectedStoreId != null ? cartController.getSubTotalForStore(selectedStoreId)['total']! : cartController.subTotal),
                        style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.black),
                        //textDirection: TextDirection.ltr,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),

            // Proceed to order Button
            Builder(
              builder: (context) {
                bool isUnavailable = false;
                bool allUnavailable = true;
                if (isFoodOrGrocery && selectedStoreId != null) {
                  for(int i=0; i<cartController.cartList.length; i++) {
                    if(cartController.cartList[i].item!.storeId == selectedStoreId) {
                      if (!availableList[i]) {
                        isUnavailable = true;
                      } else {
                        allUnavailable = false;
                      }
                    }
                  }
                } else {
                  isUnavailable = availableList.contains(false);
                  allUnavailable = !availableList.contains(true);
                }

                if (cartController.cartList.isEmpty) {
                  allUnavailable = false;
                  isUnavailable = false;
                }

                return Expanded(
                  flex: 2,
                  child: CustomButton(
                    buttonText: 'proceed_to_checkout'.tr,
                    radius: 15,
                    height: 55,
                    onPressed: allUnavailable ? null : () {
                      Get.find<CheckoutController>().updateFirstTime();
                      Get.find<CheckoutController>().updateFirstTimeCodActive();

                      if (isUnavailable) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return ConfirmationDialog(
                              icon: Images.warning,
                              description: 'some_items_unavailable_proceed_anyway'.tr == 'some_items_unavailable_proceed_anyway' 
                                  ? 'بعض العناصر غير متوفرة في المخزون. هل تريد المتابعة بدونها؟' 
                                  : 'some_items_unavailable_proceed_anyway'.tr,
                              onYesPressed: () {
                                Get.back();
                                List<int> toRemove = [];
                                for(int i=0; i<cartController.cartList.length; i++) {
                                  if (isFoodOrGrocery && selectedStoreId != null) {
                                    if(cartController.cartList[i].item!.storeId == selectedStoreId && !availableList[i]) {
                                      toRemove.add(i);
                                    }
                                  } else {
                                    if(!availableList[i]) {
                                      toRemove.add(i);
                                    }
                                  }
                                }
                                for(int i=toRemove.length-1; i>=0; i--) {
                                  cartController.removeFromCart(toRemove[i]);
                                }

                                if (Get.find<SplashController>().module == null) {
                                  int i = 0;
                                  List<ModuleModel>? mList = Get.find<SplashController>().moduleList;
                                  if (mList != null) {
                                    for (i = 0; i < mList.length; i++) {
                                      if (cartController.cartList.isNotEmpty && cartController.cartList[0].item?.moduleId == mList[i].id) {
                                        break;
                                      }
                                    }
                                    if (i < mList.length) {
                                      Get.find<SplashController>().switchModule(i, true);
                                    }
                                  }
                                }
                                Get.find<CouponController>().removeCouponData(false);

                                if (isFoodOrGrocery && selectedStoreId != null) {
                                  List<CartModel> filteredCartList = cartController.cartList.where((cart) => cart.item?.storeId == selectedStoreId).toList();
                                  Get.toNamed(RouteHelper.getCheckoutRoute('cart'), arguments: CheckoutScreen(
                                    fromCart: false,
                                    cartList: filteredCartList,
                                    storeId: selectedStoreId,
                                  ));
                                } else {
                                  Get.toNamed(RouteHelper.getCheckoutRoute('cart'));
                                }
                              },
                            );
                          }
                        );
                      } else {
                        if (Get.find<SplashController>().module == null) {
                          int i = 0;
                          List<ModuleModel>? mList = Get.find<SplashController>().moduleList;
                          if (mList != null) {
                            for (i = 0; i < mList.length; i++) {
                              if (cartController.cartList.isNotEmpty && cartController.cartList[0].item?.moduleId == mList[i].id) {
                                break;
                              }
                            }
                            if (i < mList.length) {
                              Get.find<SplashController>().switchModule(i, true);
                            }
                          }
                        }
                        Get.find<CouponController>().removeCouponData(false);
                        
                        if (isFoodOrGrocery && selectedStoreId != null) {
                          List<CartModel> filteredCartList = cartController.cartList.where((cart) => cart.item?.storeId == selectedStoreId).toList();
                          
                          Get.toNamed(RouteHelper.getCheckoutRoute('cart'), arguments: CheckoutScreen(
                            fromCart: false,
                            cartList: filteredCartList,
                            storeId: selectedStoreId,
                          ));
                        } else {
                          Get.toNamed(RouteHelper.getCheckoutRoute('cart'));
                        }
                      }
                    },
                  ),
                );
              }
            ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
