import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/history/controllers/item_history_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/checkout/domain/models/place_order_body_model.dart';
import 'package:sixam_mart/features/cart/domain/models/cart_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/search/domain/services/openai_service.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/cart_snackbar.dart';
import 'package:sixam_mart/common/widgets/confirmation_dialog.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/features/checkout/screens/checkout_screen.dart';
import 'package:sixam_mart/features/item/widgets/details_app_bar_widget.dart';
import 'package:sixam_mart/features/item/widgets/details_web_view_widget.dart';
import 'package:sixam_mart/features/item/widgets/item_image_view_widget.dart';
import 'package:sixam_mart/features/item/widgets/item_title_view_widget.dart';
import 'package:sixam_mart/features/item/widgets/similar_local_products_widget.dart';
import 'package:sixam_mart/features/item/widgets/similar_products_same_type_widget.dart';
import 'package:sixam_mart/features/item/widgets/more_from_store_widget.dart';
import 'package:sixam_mart/features/item/widgets/explore_more_similar_products_widget.dart';
import 'package:sixam_mart/features/item/screens/virtual_try_on_screen.dart';
import 'package:sixam_mart/features/item/screens/ar_furniture_screen.dart';
import 'package:sixam_mart/features/item/screens/reels_page.dart';
import 'package:sixam_mart/common/widgets/card_design/item_card.dart';
import 'package:sixam_mart/common/widgets/item_shimmer.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/common/widgets/rating_bar.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/features/review/screens/item_review_screen.dart';
import 'package:sixam_mart/helper/color_converter.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/product_question/controllers/product_question_controller.dart';
import 'package:sixam_mart/features/product_question/screens/product_question_screen.dart';
import 'package:sixam_mart/features/product_question/widgets/ask_question_dialog.dart';
import 'package:sixam_mart/features/product_question/widgets/product_question_widget.dart';
import 'package:sixam_mart/features/report/widgets/report_bottom_sheet.dart';
import 'package:sixam_mart/features/coupon/controllers/coupon_controller.dart';
import 'package:sixam_mart/features/review/controllers/review_controller.dart';
import 'package:sixam_mart/features/coupon/domain/models/coupon_model.dart';
import 'package:sixam_mart/features/item/widgets/item_coupon_widget.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';

class ItemDetailsScreen extends StatefulWidget {
  final int itemId;
  final bool inStorePage;
  final bool isCampaign;
  final Item? item;
  const ItemDetailsScreen({super.key, required this.itemId, required this.inStorePage, this.isCampaign = false, this.item});

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  final Size size = Get.size;
  final GlobalKey<ScaffoldMessengerState> _globalKey = GlobalKey();
  final GlobalKey<DetailsAppBarWidgetState> _key = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<ItemController>().recordItemView(widget.itemId);
      if(AuthHelper.isLoggedIn()) {
        Get.find<StoreController>().getFollowedStores();
      }
      if(widget.item != null) {
        Get.find<ItemHistoryController>().addToHistory(widget.item!);
      }

      Get.find<ItemController>().clearExploreMoreCache();
      Get.find<ItemController>().getItemDetails(itemId: widget.itemId, item: widget.item, isCampaign: widget.isCampaign);
      Get.find<ItemController>().setSelect(0, false);

      Future.delayed(const Duration(milliseconds: 350), () {
        if(Get.find<SplashController>().configModel!.productQuestionStatus!) {
          Get.find<ProductQuestionController>().getProductQuestionList(widget.itemId, 1, reload: true);
        }
        Get.find<CouponController>().getCouponList();
      });
    });
  }

  bool _isScrolled = false;

  void _scrollListener() {
    // Top scroll logic for app bar
    bool isScrolled = _scrollController.offset >= 50;
    if (isScrolled != _isScrolled) {
      setState(() {
        _isScrolled = isScrolled;
      });
    }
  }



  final bool _showLocal = true;
  bool _isEditing = false;
  int _localQuantity = 1;
  bool _isDescriptionExpanded = false;
  final int _selectedTabIndex = 0;
  final bool _isAddedToHistory = false;

  @override
  Widget build(BuildContext context) {
    bool isShop = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.ecommerce;
    bool isFood = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.food;

    return GetBuilder<CartController>(builder: (cartController) {
      return GetBuilder<ItemController>(builder: (itemController) {

        Item? item = itemController.item;
        
        int? stock = 0;
        CartModel? cartModel;
        OnlineCart? cart;
        double priceWithAddons = 0;
        double priceWithDiscount = 0;
        if (item != null) {
          priceWithDiscount = PriceConverter.convertWithDiscount(item.price, item.discount, item.discountType)!;
        }
        int? cartId = cartController.getCartId(itemController.cartIndex);
        Variation? variation;
        if(item != null && itemController.variationIndex != null){
          List<String> variationList = [];
          List<ChoiceOptions> choiceOptions = item.choiceOptions ?? [];
          List<Variation> variations = item.variations ?? [];
          List<AddOns> addOns = item.addOns ?? [];

          if (itemController.variationIndex!.length == choiceOptions.length) {
            for (int index = 0; index < choiceOptions.length; index++) {
              variationList.add(choiceOptions[index].options![itemController.variationIndex![index]].replaceAll(' ', ''));
            }
          }
          String variationType = '';
          bool isFirst = true;
          for (var variation in variationList) {
            if (isFirst) {
              variationType = '$variationType$variation';
              isFirst = false;
            } else {
              variationType = '$variationType-$variation';
            }
          }

          double? price = item.price;
          stock = item.stock ?? 0;
          for (Variation v in variations) {
            if (v.type == variationType) {
              price = v.price;
              variation = v;
              stock = v.stock;
              break;
            }
          }

          double? discount = item.discount;
          String? discountType = item.discountType;
          priceWithDiscount = PriceConverter.convertWithDiscount(price, discount, discountType)!;
          double priceWithQuantity = priceWithDiscount * itemController.quantity!;
          double addonsCost = 0;
          List<AddOn> addOnIdList = [];
          List<AddOns> addOnsList = [];
          
          if (itemController.addOnActiveList.length == addOns.length && itemController.addOnQtyList.length == addOns.length) {
            for (int index = 0; index < addOns.length; index++) {
              if (itemController.addOnActiveList[index]) {
                addonsCost = addonsCost + (addOns[index].price! * itemController.addOnQtyList[index]!);
                addOnIdList.add(AddOn(id: addOns[index].id, quantity: itemController.addOnQtyList[index]));
                addOnsList.add(addOns[index]);
              }
            }
          }

          cartModel = CartModel(
            id: null, price: price, discountedPrice: priceWithDiscount, variation: variation != null ? [variation] : [], foodVariations: [],
            discountAmount: (price! - PriceConverter.convertWithDiscount(price, discount, discountType)!),
            quantity: itemController.quantity, addOnIds: addOnIdList, addOns: addOnsList, isCampaign: item.availableDateStarts != null, stock: stock, item: item,
            quantityLimit: item.quantityLimit,
          );

          List<int?> listOfAddOnId = _getSelectedAddonIds(addOnIdList: addOnIdList);
          List<int?> listOfAddOnQty = _getSelectedAddonQtnList(addOnIdList: addOnIdList);

          cart = OnlineCart(
            cartId: cartId, itemId: widget.itemId, itemCampaignId: widget.isCampaign ? widget.itemId : null, price: priceWithDiscount.toString(), variant: '',
            variation: variation != null ? [variation] : [], variations: null,
            quantity: (itemController.cartIndex != -1 && itemController.cartIndex < cartController.cartList.length) ? cartController.cartList[itemController.cartIndex].quantity 
              : itemController.quantity, addOnIds: listOfAddOnId, addOns: addOnsList, addOnQtys: listOfAddOnQty, model: widget.isCampaign ? 'ItemCampaign' : 'Item'
          );
          priceWithAddons = priceWithQuantity + (Get.find<SplashController>().configModel!.moduleConfig!.module!.addOn! ? addonsCost : 0);
        }

        return Scaffold(
          key: _globalKey,
          backgroundColor: Theme.of(context).cardColor,
          extendBodyBehindAppBar: ResponsiveHelper.isDesktop(context) ? false : true,
          endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
          appBar: ResponsiveHelper.isDesktop(context)? CustomAppBar(title: item?.name ?? '') : DetailsAppBarWidget(key: _key, title: item?.name ?? '', isScrolled: _isScrolled, item: item),
          floatingActionButton: (item != null && item.videoFullUrl != null && item.videoFullUrl!.isNotEmpty && !ResponsiveHelper.isDesktop(context)) 
              ? Padding(
                  padding: EdgeInsets.only(bottom: 75),
                  child: FloatingActionButton(
                    onPressed: () {
                      Get.to(() => ReelsPage(videoUrl: item.videoFullUrl!, item: item));
                    },
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    child: Container(
                      height: 55,
                      width: 55,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        border: Border.all(color: Theme.of(context).primaryColor, width: 2),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 5, spreadRadius: 1)],
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            child: CustomImage(
                              image: item.imageFullUrl ?? '',
                              fit: BoxFit.cover,
                              height: 55, width: 55,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              color: Colors.black.withOpacity(0.4),
                            ),
                            child: const Center(
                              child: Icon(Icons.play_arrow, color: Colors.white, size: 30),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : null,

          body: SafeArea(top: false, child: (item != null) ? ResponsiveHelper.isDesktop(context) ? DetailsWebViewWidget(
            cartModel: cartModel, stock: stock, priceWithAddOns: priceWithAddons, cart: cart,
          ) : Column(children: [
            Expanded(child: NestedScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Center(child: SizedBox(width: Dimensions.webMaxWidth, child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ItemImageViewWidget(item: item, isCampaign: widget.isCampaign),
                    
                    Padding(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                    const SizedBox(height: 20),
                    

                    Builder(
                      builder: (context) {
                        return ItemTitleViewWidget(
                          item: item, inStorePage: widget.inStorePage, isCampaign: item.availableDateStarts != null,
                          inStock: (Get.find<SplashController>().configModel!.moduleConfig!.module!.stock! && stock! <= 0),
                          price: priceWithDiscount,
                        );
                      }
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_getTryOnCategory(item) != null) ...[
                          InkWell(
                            onTap: () {
                              String category = _getTryOnCategory(item) ?? 'clothing';
                              // Use VirtualTryOnScreen for ALL categories to ensure AI Advice integration
                              // and consistent 2D overlay behavior (since assets are likely 2D images).
                              List<String> images = [];
                              if (item.imagesFullUrl != null && item.imagesFullUrl!.isNotEmpty) {
                                images.addAll(item.imagesFullUrl!);
                              } else if (item.imageFullUrl != null) {
                                images.add(item.imageFullUrl!);
                              }
                              if (item.variations != null) {
                                for (var v in item.variations!) {
                                  if (v.imagesFullUrl != null && v.imagesFullUrl!.isNotEmpty) {
                                    for (var img in v.imagesFullUrl!) {
                                      if (!images.contains(img)) images.add(img);
                                    }
                                  }
                                }
                              }
                              
                              String selectedImageUrl = item.imageFullUrl ?? '';
                              if (variation != null && variation.imagesFullUrl != null && variation.imagesFullUrl!.isNotEmpty) {
                                selectedImageUrl = variation.imagesFullUrl!.first;
                              }

                              Get.to(() => VirtualTryOnScreen(
                                imageUrl: selectedImageUrl,
                                imageList: images,
                                category: category,
                              ));
                            },
                            child: Container(
                              width: 140,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.blueGrey[600]!, width: 1),
                              ),
                              child: Text(
                                'virtual_try_on'.tr,
                                style: robotoMedium.copyWith(color: Colors.blueGrey[800], fontSize: Dimensions.fontSizeDefault),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        
                        InkWell(
                          onTap: () async {
                             if (!AuthHelper.isLoggedIn()) {
                               showCustomSnackBar('you_are_not_logged_in'.tr);
                               return;
                             }
                             final aiService = OpenAIService();
                             final limitStatus = await aiService.checkAiLimit('account_advice');
                             if (limitStatus == AiLimitStatus.limitReached) return;
                             final bool deductPoints = limitStatus == AiLimitStatus.pointsApproved;

                             Get.dialog(const Center(child: CustomLoaderWidget()));
                             String category = _getTryOnCategory(item) ?? 'general';
                             String variations = '';
                             if (item.choiceOptions != null) {
                               variations = item.choiceOptions!.map((e) => '${e.title}: ${e.options?.join(', ')}').join('; ');
                             }
                             String storeName = item.storeName ?? 'Unknown Store';
                             String storeRating = (item.avgRating ?? 0.0).toStringAsFixed(1);
                             final advice = await aiService.getAccountAdvice(item.name ?? '', item.description ?? '', category, variations, storeName, storeRating);
                             Get.back(); // Close loading dialog
                             if (advice != null) {
                               await aiService.recordAiUsage('account_advice', deductPoints: deductPoints);
                               Get.dialog(
                                 Dialog(
                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                   insetPadding: const EdgeInsets.all(20),
                                   child: Container(
                                     width: Get.width,
                                     constraints: BoxConstraints(maxHeight: Get.height * 0.75),
                                     padding: const EdgeInsets.all(20),
                                     decoration: BoxDecoration(
                                       color: Theme.of(context).cardColor,
                                       borderRadius: BorderRadius.circular(20),
                                     ),
                                     child: Column(
                                       mainAxisSize: MainAxisSize.min,
                                       crossAxisAlignment: CrossAxisAlignment.start,
                                       children: [
                                         Row(
                                           children: [
                                             Container(
                                               padding: const EdgeInsets.all(10),
                                               decoration: BoxDecoration(
                                                 color: Theme.of(context).primaryColor.withOpacity(0.1),
                                                 shape: BoxShape.circle,
                                               ),
                                               child: Icon(Icons.auto_awesome, color: Theme.of(context).primaryColor, size: 24),
                                             ),
                                             const SizedBox(width: 15),
                                             Expanded(
                                               child: Text(
                                                 'advisor'.tr,
                                                 style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                                               ),
                                             ),
                                             IconButton(
                                               onPressed: () => Get.back(),
                                               icon: const Icon(Icons.close),
                                               splashRadius: 20,
                                               padding: EdgeInsets.zero,
                                               constraints: const BoxConstraints(),
                                             ),
                                           ],
                                         ),
                                         const SizedBox(height: 15),
                                         const Divider(height: 1, thickness: 1),
                                         const SizedBox(height: 15),
                                         Flexible(
                                           child: Scrollbar(
                                             child: SingleChildScrollView(
                                               physics: const BouncingScrollPhysics(),
                                               child: MarkdownBody(
                                                 data: advice,
                                                 selectable: true,
                                                 styleSheet: MarkdownStyleSheet(
                                                   p: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.8)),
                                                   h1: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                                                   h2: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                                                   h3: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                                                   listBullet: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                                                 ),
                                               ),
                                             ),
                                           ),
                                         ),
                                         const SizedBox(height: 20),
                                         SizedBox(
                                           width: double.infinity,
                                           child: ElevatedButton(
                                             style: ElevatedButton.styleFrom(
                                               backgroundColor: Theme.of(context).primaryColor,
                                               padding: const EdgeInsets.symmetric(vertical: 12),
                                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                               elevation: 0,
                                             ),
                                             onPressed: () => Get.back(),
                                             child: Text('ok'.tr, style: robotoBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeLarge)),
                                           ),
                                         ),
                                       ],
                                     ),
                                   ),
                                 ),
                               );
                             } else {
                               showCustomSnackBar('failed_to_get_advice'.tr);
                             }
                          },
                          child: Container(
                            width: _getTryOnCategory(item) != null ? 140 :340,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blueGrey[600]!, width: 1),
                            ),
                            child: Text(
                              'advisor'.tr,
                              style: robotoMedium.copyWith(color: Colors.blueGrey[800], fontSize: Dimensions.fontSizeDefault),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GetBuilder<CouponController>(builder: (couponController) {
                      List<CouponModel> storeCoupons = [];
                      if(couponController.couponList != null && widget.item != null) {
                         for (var coupon in couponController.couponList!) {
                           if(coupon.storeId == widget.item!.storeId || coupon.storeId == 0 || coupon.storeId == null
                               || coupon.couponType == 'free_delivery' || coupon.couponType == 'default'
                               || coupon.couponType == 'zone_wise' || coupon.couponType == 'first_order') {
                             storeCoupons.add(coupon);
                           }
                         }
                      }

                      return (storeCoupons.isNotEmpty) ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 1),
                          Text('available_offers'.tr.isNotEmpty ? 'available_offers'.tr : 'coupons'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          SizedBox(
                            height: 110, 
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: storeCoupons.length,
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return ItemCouponWidget(coupon: storeCoupons[index]);
                              },
                            ),
                          ),
                          const SizedBox(height: 1),
                        ],
                      ) : const SizedBox();
                    }),
                    const SizedBox(height: 5),

                    // Description (Moved Here)
                    (item.description != null && item.description!.isNotEmpty && item.moduleType != AppConstants.food) ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('description'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                        
                        Text(
                          item.description!,
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7)),
                          maxLines: _isDescriptionExpanded ? null : 2,
                          overflow: _isDescriptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                        ),

                        if(item.description!.length > 150)
                          InkWell(
                            onTap: () {
                              setState(() {
                                _isDescriptionExpanded = !_isDescriptionExpanded;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                              child: Text(
                                _isDescriptionExpanded ? 'show_less'.tr : 'show_more'.tr,
                                style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeDefault),
                              ),
                            ),
                          ),
                      ],
                    ) : const SizedBox(),

                    // Variation
                    if (item.choiceOptions != null && item.choiceOptions!.isNotEmpty) ...[
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: item.choiceOptions!.length,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, index) {
                          String title = item.choiceOptions![index].title ?? '';
                          List<String>? options = item.choiceOptions![index].options;
                          
                          if (title.isEmpty || options == null || options.isEmpty) {
                            return const SizedBox();
                          }
                          
                          bool isColor = title.toLowerCase().contains('color') || title.contains('لون');

                          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(title, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
                            SizedBox(height: (item.variations != null && item.variations!.isNotEmpty) ? Dimensions.paddingSizeExtraSmall : 0),
                            
                            isColor ? SizedBox(
                              height: 110,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: item.choiceOptions![index].options!.length,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                itemBuilder: (context, i) {
                                  String optionName = item.choiceOptions![index].options![i].trim();
                                  bool isSelected = itemController.variationIndex != null && itemController.variationIndex!.length > index && itemController.variationIndex![index] == i;
                                  Color? color = ColorConverter.getColorFromOption(optionName);

                                  Variation? matchingVariation;
                                  if (item.variations != null) {
                                    matchingVariation = item.variations!.firstWhereOrNull((v) => v.type!.contains(optionName));
                                  }
                                  String? variantImageUrl;
                                  if (matchingVariation != null && matchingVariation.imagesFullUrl != null && matchingVariation.imagesFullUrl!.isNotEmpty) {
                                    variantImageUrl = matchingVariation.imagesFullUrl!.first;
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.only(right: 15),
                                    child: InkWell(
                                      onTap: () {
                                        itemController.setCartVariationIndex(index, i, item);
                                        if (_scrollController.hasClients) {
                                          _scrollController.animateTo(0.0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                                        }
                                      },
                                      child: Container(
                                        width: 90,
                                        padding: isSelected ? const EdgeInsets.all(4) : EdgeInsets.zero,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                                          border: isSelected ? Border.all(color: Theme.of(context).primaryColor, width: 4) : Border.all(color: Colors.transparent),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                          child: variantImageUrl != null
                                            ? CustomImage(
                                                image: variantImageUrl,
                                                fit: BoxFit.cover,
                                                height: 90, width: 90,
                                              )
                                            : CustomImage(
                                                image: item.imageFullUrl ?? '',
                                                fit: BoxFit.cover,
                                                height: 90, width: 90,
                                              ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ) : GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 10,
                                childAspectRatio: (1 / 0.25),
                              ),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: item.choiceOptions![index].options!.length,
                              itemBuilder: (context, i) {
                                String optionName = item.choiceOptions![index].options![i].trim();
                                bool isSelected = itemController.variationIndex != null && itemController.variationIndex!.length > index && itemController.variationIndex![index] == i;
                                
                                // Default Text Variation
                                return InkWell(
                                  onTap: () {
                                    itemController.setCartVariationIndex(index, i, item);
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: isSelected ? [] : [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 4, spreadRadius: 1, offset: const Offset(0, 2))],
                                      border: isSelected ? Border.all(color: Theme.of(context).primaryColor, width: 1) : null,
                                    ),
                                    child: Text(
                                      optionName,
                                      textAlign: TextAlign.center,
                                      maxLines: 1, overflow: TextOverflow.ellipsis,
                                      style: robotoRegular.copyWith(
                                        color: isSelected ? Theme.of(context).cardColor : Theme.of(context).textTheme.bodyLarge!.color,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: index != item.choiceOptions!.length-1 ? Dimensions.paddingSizeLarge : 0),
                          ]);
                        },
                      ),
                      const SizedBox(height: Dimensions.paddingSizeLarge),
                    ],

                    // Questions Section
                    GetBuilder<ProductQuestionController>(builder: (productQuestionController) {
                      bool hasQuestions = productQuestionController.productQuestionModel != null && productQuestionController.productQuestionModel!.questions != null && productQuestionController.productQuestionModel!.questions!.isNotEmpty;
                      
                      return (Get.find<SplashController>().configModel!.productQuestionStatus!) ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text('product_questions'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                              hasQuestions ? InkWell(
                                onTap: () => Get.to(() => ProductQuestionScreen(item: item)),
                                child: Text('view_more'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeDefault)),
                              ) : const SizedBox(),
                            ]),
                          ),
                          
                          if(hasQuestions) 
                            SizedBox(
                              height: 185, 
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: productQuestionController.productQuestionModel!.questions!.length > 5 ? 5 : productQuestionController.productQuestionModel!.questions!.length,
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return ProductQuestionWidget(question: productQuestionController.productQuestionModel!.questions![index]);
                                },
                              ),
                            )
                          else
                            Center(child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                              child: Text('no_questions_yet'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor)),
                            )),

                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          // Ask Question Button (Always shown at bottom)
                          InkWell(
                            onTap: () {
                              if(Get.find<AuthController>().isLoggedIn()) {
                                Get.toNamed(RouteHelper.getAddQuestionRoute(item));
                              } else {
                                showCustomSnackBar('you_must_login_to_ask_question'.tr);
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              height: 45,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.5), width: 1),
                              ),
                              child: Text(
                                'ask_question'.tr,
                                style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color?.withOpacity(0.8)),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: Dimensions.paddingSizeDefault),
                        ],
                      ) : const SizedBox();
                    }),

                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    // Reviews Section
                    GetBuilder<ReviewController>(builder: (reviewController) {
                      return (item.reviews != null && item.reviews!.isNotEmpty) ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text('rate_and_review'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                              InkWell(
                                onTap: () => Get.to(() => ItemReviewScreen(reviewList: item.reviews!, item: item)),
                                child: Text('view_more'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor)),
                              ),
                            ]),
                          ),

                          // Rating Summary
                          Padding(
                            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Average Score
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        item.avgRating != null ? item.avgRating!.toStringAsFixed(1) : '0.0',
                                        style: robotoBold.copyWith(fontSize: 48),
                                      ),
                                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                      RatingBar(rating: item.avgRating ?? 0.0, size: 18, ratingCount: null),
                                      const SizedBox(height: Dimensions.paddingSizeSmall),
                                      Text(
                                        '${'based_on'.tr} ${item.ratingCount ?? 0} ${'review_from_trusted_sources'.tr.isNotEmpty ? 'review_from_trusted_sources'.tr : 'reviews'}',
                                        textAlign: TextAlign.center,
                                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: Dimensions.paddingSizeLarge),

                                // Rating Bars
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: List.generate(5, (index) {
                                      int rating = 5 - index;
                                      int count = item.reviews!.where((r) => r.rating == rating).length;
                                      double percentage = item.reviews!.isNotEmpty ? (count / item.reviews!.length) : 0;

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 3.0),
                                        child: Row(
                                          children: [
                                            Text('$rating', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                                            const SizedBox(width: 4),
                                            Icon(Icons.star, size: 14, color: Theme.of(context).primaryColor),
                                            const SizedBox(width: Dimensions.paddingSizeSmall),
                                            Expanded(
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                                child: LinearProgressIndicator(
                                                  value: percentage,
                                                  minHeight: 6,
                                                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                                                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: Dimensions.paddingSizeSmall),
                                            SizedBox(
                                              width: 35,
                                              child: Text('${(percentage * 100).toInt()}%', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Review List
                          SizedBox(
                            height: 160,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: item.reviews!.length,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return Container(
                                  width: 300,
                                  margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                                    border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                          child: const Icon(Icons.person, size: 20, color: Colors.grey),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.reviews![index].customerName ?? '',
                                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  RatingBar(rating: item.reviews![index].rating!.toDouble(), ratingCount: null, size: 12),
                                                  const SizedBox(width: Dimensions.paddingSizeSmall),
                                                  Text(
                                                    DateConverter.isoStringToLocalDateOnly(item.reviews![index].createdAt!),
                                                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: Dimensions.paddingSizeSmall),

                                    Expanded(child: Text(
                                      item.reviews![index].comment ?? '',
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: Colors.black87,
                                        height: 1.4,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    )),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Expanded(
                                          child: (item.reviews![index].attachment != null && item.reviews![index].attachment!.isNotEmpty) ? SizedBox(
                                            height: 30,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: item.reviews![index].attachment!.length,
                                              itemBuilder: (context, i) {
                                                return Container(
                                                  margin: const EdgeInsets.only(right: Dimensions.paddingSizeExtraSmall),
                                                  child: InkWell(
                                                    onTap: () => Get.toNamed(RouteHelper.getReviewImageViewerRoute(item.reviews![index], item, i)),
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                                      child: CustomImage(
                                                        image: '${Get.find<SplashController>().configModel?.baseUrls?.reviewImageUrl}/${item.reviews![index].attachment![i]}',
                                                        height: 30, width: 30, fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ) : const SizedBox(),
                                        ),
                                        const SizedBox(width: Dimensions.paddingSizeSmall),

                                        Row(children: [
                                          InkWell(
                                            onTap: () {
                                              if(Get.find<AuthController>().isLoggedIn()) {
                                                Get.find<ReviewController>().toggleReviewLike(item.reviews![index].id!);
                                              } else {
                                                showCustomSnackBar('you_must_login_to_like_review'.tr);
                                              }
                                            },
                                            child: Row(children: [
                                              Icon(
                                                item.reviews![index].isLikedByUser == true ? Icons.thumb_up : Icons.thumb_up_off_alt,
                                                size: 16,
                                                color: item.reviews![index].isLikedByUser == true ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                                              ),
                                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                              Text(
                                                '${item.reviews![index].likeCount ?? 0}',
                                                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                                              ),
                                            ]),
                                          ),
                                          const SizedBox(width: Dimensions.paddingSizeSmall),

                                          InkWell(
                                            onTap: () {
                                              if(Get.find<AuthController>().isLoggedIn()) {
                                                Get.bottomSheet(ReportBottomSheet(reportableId: item.reviews![index].id!, reportableType: 'review'));
                                              } else {
                                                showCustomSnackBar('you_must_login_to_report'.tr);
                                              }
                                            },
                                            child: Icon(Icons.report_gmailerrorred, size: 18, color: Theme.of(context).disabledColor),
                                          ),
                                        ]),
                                      ],
                                    ),
                                  ]),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                        ],
                      ) : Column(children: [
                        Container(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          ),
                          child: Row(children: [
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('how_do_i_rate_this_product'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                              Text('how_do_i_rate_this_product_desc'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                            ])),
                            const SizedBox(width: Dimensions.paddingSizeSmall),
                            Icon(Icons.stars, color: Theme.of(context).primaryColor, size: 25),
                          ]),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        Container(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          ),
                          child: Row(children: [
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('where_do_the_ratings_come_from'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                              Text('where_do_the_ratings_come_from_desc'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                            ])),
                            const SizedBox(width: Dimensions.paddingSizeSmall),
                            Icon(Icons.info, color: Theme.of(context).primaryColor, size: 25),
                          ]),
                        ),
                      ]);
                    }),

                    const Divider(),

                    // Store Card
                    (item.moduleId != 1) ? InkWell(
                      onTap: () {
                        if(widget.inStorePage) {
                          Get.back();
                        }else {
                          Get.offNamed(RouteHelper.getStoreRoute(id: item.storeId, page: 'item'));
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, spreadRadius: 1)],
                        ),
                        child: Column(children: [
                          // Row 1: Logo, Name & Stats, Chevron
                          Row(children: [
                            // 1. Logo
                            ClipRRect(
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              child: CustomImage(
                                image: item.storeDetails != null ? item.storeDetails!['logo_full_url'] ?? '' : '',
                                height: 45, width: 45, fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 10),
                            
                            // 2. Name & Stats
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Row(children: [
                                  Text(item.storeName ?? '', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                                  const SizedBox(width: 5),
                                  (item.verifiedSeller == 1 || (item.storeDetails != null && item.storeDetails!['verified_seller'] == 1))
                                      ? Image.asset(Images.verifiedBadge2, width: 16, height: 16)
                                      : const SizedBox.shrink(),
                                ]),
                                const SizedBox(height: 5),
                                
                                // Stats (Wrap to avoid overflow)
                                Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 5, runSpacing: 2, children: [
                                  Row(mainAxisSize: MainAxisSize.min, children: [
                                    Text(double.tryParse(item.avgRating.toString())?.toStringAsFixed(1) ?? '0', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor)),
                                    const SizedBox(width: 2),
                                    const Icon(Icons.star, size: 12, color: Colors.amber),
                                    const SizedBox(width: 2),
                                    Text('(${item.ratingCount ?? 0})', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor)),
                                  ]),
                                  Text('|', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor)),
                                  Text('${item.storeDetails != null ? item.storeDetails!['total_items'] ?? 0 : 0} ${'items'.tr}', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor)),
                                  if ((item.orderCount ?? 0) > 0) ...[
                                    Text('|', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor)),
                                    Text('${'sold'.tr} ${item.orderCount} ${item.unitType ?? 'piece'.tr}', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor)),
                                  ],
                                ]),
                              ]),
                            ),
                            
                            // 3. Chevron
                            Icon(Icons.chevron_right, size: 16, color: Theme.of(context).disabledColor),
                          ]),
                          
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          
                          // Row 3: Buttons
                          Row(children: [
                            
                             Expanded(
                              child: GetBuilder<StoreController>(builder: (storeController) {
                                bool isFollowed = storeController.followedStoreIds.contains(item.storeId);
                                return InkWell(
                                  onTap: () {
                                    if (isFollowed) {
                                      storeController.unfollowStore(item.storeId);
                                    } else {
                                      storeController.followStore(item.storeId);
                                    }
                                  },
                                  child: Container(
                                    height: 35,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                      border: Border.all(color: Colors.blueGrey[400]!, width: 1),
                                    ),
                                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                      Text(
                                        isFollowed ? 'تمت المتابعة' : 'متابعة', // Followed or Follow
                                        style: robotoMedium.copyWith(color: Colors.blueGrey[800], fontSize: Dimensions.fontSizeSmall),
                                      ),
                                      const SizedBox(width: 5),
                                       Icon(isFollowed ? Icons.check : Icons.add, size: 16, color: Colors.blueGrey[800]),
                                    ]),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  if(widget.inStorePage) {
                                    Get.back();
                                  }else {
                                    Get.offNamed(RouteHelper.getStoreRoute(id: item.storeId, page: 'item'));
                                  }
                                },
                                child: Container(
                                  height: 35,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                    border: Border.all(color: Colors.blueGrey[400]!, width: 1),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                       Text(
                                        'كل المنتجات', // All Products
                                        style: robotoMedium.copyWith(color: Colors.blueGrey[800], fontSize: Dimensions.fontSizeSmall),
                                      ),
                                      const SizedBox(width: 5),
                                      Icon(Icons.grid_view_rounded, size: 16, color: Colors.blueGrey[800]),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ]),
                        ]),
                      )
                    ) : const SizedBox(),

                    // Quantity
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    item.isPrescriptionRequired! ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      ),
                      child: Text(
                        '* ${'prescription_required'.tr}',
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).colorScheme.error),
                      ),
                    ) : const SizedBox(),


                    (item.nutritionsName != null && item.nutritionsName!.isNotEmpty) ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('nutrition_details'.tr, style: robotoMedium),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                        Wrap(children: List.generate(item.nutritionsName!.length, (index) {
                          return Text(
                            '${item.nutritionsName![index]}${item.nutritionsName!.length-1 == index ? '.' : ', '}',
                            style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color?.withOpacity(0.5)),
                          );
                        })),
                        const SizedBox(height: Dimensions.paddingSizeLarge),
                      ],
                    ) : const SizedBox(),

                    (item.allergiesName != null && item.allergiesName!.isNotEmpty) ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('allergic_ingredients'.tr, style: robotoMedium),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                        Wrap(children: List.generate(item.allergiesName!.length, (index) {
                          return Text(
                            '${item.allergiesName![index]}${item.allergiesName!.length-1 == index ? '.' : ', '}',
                            style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color?.withOpacity(0.5)),
                          );
                        })),
                        const SizedBox(height: Dimensions.paddingSizeLarge),
                      ],
                    ) : const SizedBox(),

                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    // Similar Products Section
                    // Dynamic Recommendation Tabs
                    // Dynamic Recommendation Sections
                    if (!isFood) ...[
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const SimilarLocalProductsWidget(),
                        const SimilarProductsSameTypeWidget(),
                        const MoreFromStoreWidget(),
                      ]),
                    ],                        ],
                      ),
                    ),
                  ],
                ))),
                ),
              ];
            },
            body: ExploreMoreSimilarProductsWidget(
              item: item,
              isFood: isFood,
              isShop: isShop,
            ),
          ),

          ),

            GetBuilder<CartController>(
              builder: (cartController) {
                int cartIndex = cartController.cartList.indexWhere((element) => element.item!.id == item.id);
                double? price = item.price;
                double? discount = item.discount;
                String? discountType = item.discountType;
                double priceWithDiscount = PriceConverter.convertWithDiscount(price, discount, discountType)!;
                
                int? stock = item.stock ?? 0;

                Variation? variation;
                bool isNewVariation = Get.find<SplashController>().getModuleConfig(item.moduleType).newVariation!;

                if(!isNewVariation) {
                   if(item.variations != null && item.variations!.isNotEmpty) {
                     List<String> variationTypes = item.variations![0].type!.split('-');
                     if(item.choiceOptions != null && variationTypes.length == item.choiceOptions!.length) {
                       int? sameIndex = 0;
                       List<int> selectedVariations = [];
                       if (itemController.variationIndex != null && itemController.variationIndex!.length >= item.choiceOptions!.length) {
                         for(int i=0; i<item.choiceOptions!.length; i++) {
                           selectedVariations.add(itemController.variationIndex![i]);
                         }

                         for(int i=0; i<item.variations!.length; i++) {
                           List<String> valueVariations = item.variations![i].type!.split('-');
                           bool match = true;
                           for(int j=0; j<variationTypes.length; j++) {
                             if(itemController.variationIndex!.length > j && item.choiceOptions![j].options!.length > itemController.variationIndex![j]) {
                               if(valueVariations[j].trim() != item.choiceOptions![j].options![itemController.variationIndex![j]].trim()) {
                                 match = false;
                                 break;
                               }
                             } else {
                               match = false;
                               break;
                             }
                           }
                           if(match) {
                             sameIndex = i;
                             break;
                           }
                         }
                         if(sameIndex != null && sameIndex < item.variations!.length && item.variations![sameIndex].stock! > 0) {
                            variation = item.variations![sameIndex];
                            stock = variation.stock;
                            price = variation.price!;
                            priceWithDiscount = PriceConverter.convertWithDiscount(price, discount, discountType)!;
                         }
                       }
                     }
                   }
                }

                String variationType = '';
                if(!isNewVariation) {
                   if(item.choiceOptions != null && item.choiceOptions!.isNotEmpty && itemController.variationIndex != null && itemController.variationIndex!.length >= item.choiceOptions!.length) {
                     List<String> variationList = [];
                     for (int index = 0; index < item.choiceOptions!.length; index++) {
                       if (item.choiceOptions![index].options != null && item.choiceOptions![index].options!.length > itemController.variationIndex![index]) {
                         variationList.add(item.choiceOptions![index].options![itemController.variationIndex![index]].replaceAll(' ', ''));
                       }
                     }
                     bool isFirst = true;
                     for (var variation in variationList) {
                       if (isFirst) {
                         variationType = '$variationType$variation';
                         isFirst = false;
                       } else {
                         variationType = '$variationType-$variation';
                       }
                     }
                   }
                }
                cartIndex = cartController.isExistInCart(item.id, variationType, false, null);

                double priceWithAddons = priceWithDiscount;
                List<AddOn> addOnIdList = [];
                List<AddOns> addOnsList = [];
                if (item.addOns != null && itemController.addOnActiveList.length >= item.addOns!.length && itemController.addOnQtyList.length >= item.addOns!.length) {
                  for (int index = 0; index < item.addOns!.length; index++) {
                    if (itemController.addOnActiveList[index]) {
                      priceWithAddons = priceWithAddons + (item.addOns![index].price! * itemController.addOnQtyList[index]!);
                      addOnIdList.add(AddOn(id: item.addOns![index].id, quantity: itemController.addOnQtyList[index]!));
                      addOnsList.add(item.addOns![index]);
                    }
                  }
                }


                return Container(
                  width: 1170,
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  child: (_isEditing && cartIndex != -1) ? Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      border: Border.all(color: Theme.of(context).primaryColor),
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('quantity'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                      
                      Row(children: [
                        InkWell(
                          onTap: () {
                             if(_localQuantity > 1) {
                               setState(() => _localQuantity--);
                             } else if(_localQuantity == 1 && cartIndex != -1) {
                               cartController.removeFromCart(cartIndex);
                               setState(() => _isEditing = false);
                             }
                          },
                          child: Container(
                            height: 30, width: 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              color: (_localQuantity == 1 && cartIndex != -1) ? Theme.of(context).disabledColor.withOpacity(0.1) : Theme.of(context).primaryColor.withOpacity(0.1),
                            ),
                            child: Icon(
                              (_localQuantity == 1 && cartIndex != -1) ? Icons.delete_outline : Icons.remove,
                              color: (_localQuantity == 1 && cartIndex != -1) ? Theme.of(context).colorScheme.error : Theme.of(context).primaryColor,
                              size: 20,
                            ),
                          ),
                        ),
                        
                        SizedBox(
                          width: 40,
                          child: Center(
                            child: Text(
                              _localQuantity.toString(),
                              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                            ),
                          ),
                        ),

                        InkWell(
                          onTap: () {
                             if(!Get.find<SplashController>().configModel!.moduleConfig!.module!.stock! || stock! > _localQuantity) {
                                setState(() => _localQuantity++);
                             } else {
                               showCustomSnackBar('out_of_stock'.tr);
                             }
                          },
                          child: Container(
                            height: 30, width: 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                            ),
                            child: Icon(
                              Icons.add,
                              color: Theme.of(context).primaryColor,
                              size: 20,
                            ),
                          ),
                        ),
                      ]),

                        Row(children: [
                        Text(
                          PriceConverter.convertPrice( priceWithAddons * _localQuantity ),
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                          textDirection: TextDirection.ltr,
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        InkWell(
                          onTap: () async {
                              List<OrderVariation> variations = _getSelectedVariations(
                                isFoodVariation: Get.find<SplashController>().getModuleConfig(item.moduleType).newVariation!,
                                foodVariations: item.foodVariations!, selectedVariations: itemController.selectedVariations,
                              );
                              List<int?> listOfAddonId = _getSelectedAddonIds(addOnIdList: addOnIdList);
                              List<int?> listOfAddonQty = _getSelectedAddonQtnList(addOnIdList: addOnIdList);

                              OnlineCart onlineCart = OnlineCart(
                                cartId: (cartIndex != -1) ? cartController.cartList[cartIndex].id : null,
                                itemId: item.id,
                                itemCampaignId: widget.isCampaign ? item.id : null,
                                price: priceWithAddons.toString(),
                                variant: '',
                                variation: variation != null ? [variation] : null,
                                variations: isNewVariation ? variations : null,
                                quantity: _localQuantity,
                                addOnIds: listOfAddonId,
                                addOns: addOnsList,
                                addOnQtys: listOfAddonQty,
                                model: widget.isCampaign ? 'ItemCampaign' : 'Item',
                              );
                              
                              if(widget.isCampaign) {
                                CartModel cartModel = CartModel(
                                    id: null, price: price, discountedPrice: priceWithDiscount, variation: variation != null ? [variation] : [], foodVariations: itemController.selectedVariations,
                                    discountAmount: (price! - PriceConverter.convertWithDiscount(price, discount, discountType)!),
                                    quantity: _localQuantity, addOnIds: addOnIdList, addOns: addOnsList, isCampaign: widget.isCampaign, stock: stock, item: item, quantityLimit: item.quantityLimit
                                );
                                Get.toNamed(RouteHelper.getCheckoutRoute('campaign'), arguments: CheckoutScreen(
                                  storeId: null, fromCart: false, cartList: [cartModel],
                                ));
                              }else {
                                if (Get.find<CartController>().existAnotherStoreItem(
                                  item.storeId, Get.find<SplashController>().module != null
                                    ? Get.find<SplashController>().module!.id : Get.find<SplashController>().cacheModule!.id,
                                )) {
                                  Get.dialog(ConfirmationDialog(
                                    icon: Images.warning,
                                    title: 'are_you_sure_to_reset'.tr,
                                    description: Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText!
                                        ? 'if_you_continue'.tr : 'if_you_continue_without_another_store'.tr,
                                    onYesPressed: () {
                                      Get.back();
                                      Get.find<CartController>().clearCartOnline().then((success) async {
                                        if(success) {
                                          Get.find<CartController>().addToCartOnline(onlineCart, cartModel!);
                                          _key.currentState?.shake();
                                          // showCartSnackBar(duration: const Duration(milliseconds: 1500));
                                        }
                                      });
                                    },
                                  ), barrierDismissible: false);
                                } else {
                                  if(cartIndex != -1){
                                    Get.find<CartController>().updateCartOnline(onlineCart, cartModel!);
                                  } else {
                                    Get.find<CartController>().addToCartOnline(onlineCart, cartModel!);
                                    _key.currentState?.shake();
                                  }
                                }
                              }
                              setState(() => _isEditing = false);
                            },
                          child: Container(
                            height: 30, width: 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              color: Theme.of(context).primaryColor,
                            ),
                            child: Icon(Icons.check, color: Theme.of(context).cardColor, size: 20),
                          ),
                        ),
                      ]),

                    ]),
                  ) : Row(children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                          if(discount! > 0) ...[
                             Row(children: [
                               Container(
                                 padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                 decoration: BoxDecoration(
                                   color: Theme.of(context).colorScheme.error,
                                   borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                 ),
                                 child: Text(
                                   (discountType == 'percent' ? '-$discount%' : '-${PriceConverter.convertPrice(discount)}'),
                                   style: robotoRegular.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeSmall),
                                 ),
                               ),
                               const SizedBox(width: 10),

                               Text(
                                 PriceConverter.convertPrice(price),
                                 style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, decoration: TextDecoration.lineThrough, fontSize: Dimensions.fontSizeSmall),
                               ),
                             ]),
                             const SizedBox(height: 5),
                          ],

                          Text(
                            PriceConverter.convertPrice(priceWithDiscount),
                            style: robotoBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeExtraLarge),
                          ),
                        ]),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),

                      Expanded(
                        child: CustomButton(
                          isLoading: cartController.isLoading,
                          buttonText: (item.moduleType != 'food' && Get.find<SplashController>().configModel!.moduleConfig!.module!.stock! && stock! <= 0) ? 'out_of_stock'.tr
                              : item.availableDateStarts != null ? 'order_now'.tr : cartIndex != -1 ? 'update_in_cart'.tr : 'add_to_cart'.tr,
                          onPressed: (cart == null || cartModel == null) ? null : (item.moduleType == 'food' || !Get.find<SplashController>().configModel!.moduleConfig!.module!.stock! || stock! > 0) ?  () async {
                            if(item.moduleType == 'food' || !Get.find<SplashController>().configModel!.moduleConfig!.module!.stock! || stock! > 0) {
                              if (cartIndex != -1) {
                                   setState(() {
                                      _localQuantity = cartController.cartList[cartIndex].quantity!;
                                      _isEditing = true;
                                   });
                              } else {
                                  if (Get.find<CartController>().existAnotherStoreItem(
                                    item.storeId, Get.find<SplashController>().module != null
                                      ? Get.find<SplashController>().module!.id : Get.find<SplashController>().cacheModule!.id,
                                  )) {
                                    Get.dialog(ConfirmationDialog(
                                      icon: Images.warning,
                                      title: 'are_you_sure_to_reset'.tr,
                                      description: Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText!
                                          ? 'if_you_continue'.tr : 'if_you_continue_without_another_store'.tr,
                                      onYesPressed: () {
                                        Get.back();
                                        Get.find<CartController>().clearCartOnline().then((success) async {
                                          if(success) {
                                            Get.find<CartController>().addToCartOnline(cart!, cartModel!);
                                            _key.currentState?.shake();
                                            // showCartSnackBar();
                                            setState(() {
                                               _isEditing = true;
                                               _localQuantity = 1;
                                            });
                                          }
                                        });
                                      },
                                    ), barrierDismissible: false);
                                  } else {
                                    Get.find<CartController>().addToCartOnline(cart!, cartModel!);
                                    _key.currentState?.shake();
                                    // showCartSnackBar();
                                    setState(() {
                                      _isEditing = true;
                                      _localQuantity = 1;
                                    });
                                  }
                              }
                            }
                          } : null,
                        ),
                      ),
                    ]),
                );
              }
            ),

          ]) : const Center(child: CircularProgressIndicator())),
        );
      });
    });
  }

  List<OrderVariation> _getSelectedVariations({required bool isFoodVariation, required List<FoodVariation>? foodVariations, required List<List<bool?>> selectedVariations}) {
    List<OrderVariation> variations = [];
    if(isFoodVariation && foodVariations != null && selectedVariations.length >= foodVariations.length) {
      for(int i=0; i<foodVariations.length; i++) {
        if(selectedVariations[i].contains(true)) {
          variations.add(OrderVariation(name: foodVariations[i].name, values: OrderVariationValue(label: [])));
          if (foodVariations[i].variationValues != null && selectedVariations[i].length >= foodVariations[i].variationValues!.length) {
            for(int j=0; j<foodVariations[i].variationValues!.length; j++) {
              if(selectedVariations[i][j] == true) {
                variations[variations.length-1].values!.label!.add(foodVariations[i].variationValues![j].level);
              }
            }
          }
        }
      }
    }
    return variations;
  }

  List<int?> _getSelectedAddonIds({required List<AddOn> addOnIdList }) {
    List<int?> listOfAddOnId = [];
    for (var addOn in addOnIdList) {
      listOfAddOnId.add(addOn.id);
    }
    return listOfAddOnId;
  }

  List<int?> _getSelectedAddonQtnList({required List<AddOn> addOnIdList }) {
    List<int?> listOfAddOnQty = [];
    for (var addOn in addOnIdList) {
      listOfAddOnQty.add(addOn.quantity);
    }
    return listOfAddOnQty;
  }

  double _getItemDetailsDiscountPrice({required CartModel cart}) {
    double discountedPrice = 0;

    double? discount = cart.item!.discount;
    String? discountType = cart.item!.discountType;
    String variationType = cart.variation != null && cart.variation!.isNotEmpty ? cart.variation![0].type! : '';

    if(cart.variation != null && cart.variation!.isNotEmpty){
      for (Variation variation in cart.item!.variations!) {
        if (variation.type == variationType) {
          discountedPrice = (PriceConverter.convertWithDiscount(variation.price!, discount, discountType)! * cart.quantity!);
          break;
        }
      }
    } else {
      discountedPrice = (PriceConverter.convertWithDiscount(cart.item!.price!, discount, discountType)! * cart.quantity!);
    }

    return discountedPrice;
  }

  String? _getTryOnCategory(Item item) {
    String text = '${item.name} ${item.description}'.toLowerCase();
    
    // Check categories (English & Arabic)
    // if (text.contains('glass') || text.contains('spectacle') || text.contains('eyewear') || text.contains('نظار') || text.contains('عدسات')) {
    //   return 'glasses';
    // } else 
    if (text.contains('shirt') || text.contains('pant') || text.contains('dress') || text.contains('jacket') || text.contains('cloth') || 
               text.contains('قميص') || text.contains('تيشرت') || text.contains('فستان') || text.contains('ملابس') || text.contains('ثوب') || text.contains('عباية')|| text.contains('بنطلون') || text.contains('جاكت') || text.contains('بدلة')) {
      return 'clothing';
    } 
    // else if (text.contains('ring') || text.contains('necklace') || text.contains('earring') || text.contains('jewel') || 
    //            text.contains('خاتم') || text.contains('قلادة') || text.contains('قرط') || text.contains('مجوهرات') || text.contains('عقد') || text.contains('سوار')) {
    //   return 'jewellery';
    // } else if (text.contains('watch') || text.contains('clock') || text.contains('ساعة') || text.contains('ساعات')) {
    //   return 'watch';
    // } else if (text.contains('chair') || text.contains('table') || text.contains('sofa') || text.contains('furniture') || text.contains('lamp') ||
    //            text.contains('كرسي') || text.contains('طاولة') || text.contains('كنب') || text.contains('أريكة') || text.contains('أثاث') || text.contains('سرير')) {
    //   return 'furniture';
    // }
    
    // Fallback based on typical category IDs could be added here if available
    return null;
  }


}

class QuantityButton extends StatelessWidget {
  final bool isIncrement;
  final int? quantity;
  final bool isCartWidget;
  final int? stock;
  final bool isExistInCart;
  final int cartIndex;
  final int? quantityLimit;
  final CartController cartController;
  const QuantityButton({super.key,
    required this.isIncrement,
    required this.quantity,
    required this.stock,
    required this.isExistInCart,
    required this.cartIndex,
    this.isCartWidget = false,
    this.quantityLimit,
    required this.cartController,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: cartController.isLoading ? null : () {
        if(isExistInCart) {
          if (!isIncrement && quantity! > 1) {
            Get.find<CartController>().setQuantity(false, cartIndex, stock, quantityLimit);
          } else if (isIncrement && quantity! > 0) {
            if(quantity! < stock! || !Get.find<SplashController>().configModel!.moduleConfig!.module!.stock!) {
              Get.find<CartController>().setQuantity(true, cartIndex, stock, quantityLimit);
            }else {
              showCustomSnackBar('out_of_stock'.tr);
            }
          }
        } else {
          if (!isIncrement && quantity! > 1) {
            Get.find<ItemController>().setQuantity(false, stock, quantityLimit);
          } else if (isIncrement && quantity! > 0) {
            if(quantity! < stock! || !Get.find<SplashController>().configModel!.moduleConfig!.module!.stock!) {
              Get.find<ItemController>().setQuantity(true, stock, quantityLimit);
            }else {
              showCustomSnackBar('out_of_stock'.tr);
            }
          }

        }
      },
      child: Container(
        height: 30, width: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          color: (quantity! == 1 && !isIncrement) || cartController.isLoading ? Theme.of(context).disabledColor.withValues(alpha: 0.1) : Theme.of(context).primaryColor.withValues(alpha: 0.1),
        ),
        child: Center(
          child: Icon(
            isIncrement ? Icons.add : Icons.remove,
            color: (quantity! == 1 && !isIncrement) || cartController.isLoading ? Theme.of(context).disabledColor : Theme.of(context).primaryColor,
            size: isCartWidget ? 26 : 20,
          ),
        ),
      ),
    );
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;
  SliverDelegate({required this.child, this.height = 100});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
