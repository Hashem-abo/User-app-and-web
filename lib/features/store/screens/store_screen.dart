import 'dart:async';
import 'package:flutter/rendering.dart';
import 'package:sixam_mart/features/review/controllers/review_controller.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/features/checkout/controllers/checkout_controller.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/features/history/controllers/item_history_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/favourite/controllers/favourite_controller.dart';
import 'package:sixam_mart/features/category/domain/models/category_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/vendor_type_badge_widget.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/common/widgets/paginated_list_view.dart';
import 'package:sixam_mart/common/widgets/web_item_widget.dart';
import 'package:sixam_mart/common/widgets/web_menu_bar.dart';
import 'package:sixam_mart/features/checkout/screens/checkout_screen.dart';
import 'package:sixam_mart/features/store/widgets/store_banner_widget.dart';
import 'package:sixam_mart/features/store/widgets/store_description_view_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/store/widgets/store_details_screen_shimmer_widget.dart';
import 'package:sixam_mart/features/store/widgets/bottom_cart_widget.dart';
import 'package:sixam_mart/features/store/widgets/filter_widget.dart';
import 'package:sixam_mart/features/store/widgets/recommended_store_item_widget.dart';
import 'package:sixam_mart/common/widgets/card_design/item_card.dart';
import 'package:sixam_mart/features/review/widgets/rating_widget.dart';
import 'package:sixam_mart/features/review/widgets/review_list_widget.dart';
import 'package:sixam_mart/features/pro/controllers/pro_controller.dart';
import 'package:sixam_mart/features/pro/widgets/pro_plan_banner_widget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class StoreScreen extends StatefulWidget {
  final Store? store;
  final bool fromModule;
  final String slug;
  const StoreScreen({super.key, required this.store, required this.fromModule, this.slug = ''});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  int _selectedTab = 0;
  Timer? _debounce;
  final Map<int, GlobalKey> categoryKeys = {};
  bool _isScrollingToCategory = false;

  void _scrollToCategory(int index) async {
    final storeController = Get.find<StoreController>();
    setState(() {
      _isScrollingToCategory = true;
    });
    storeController.setCategoryIndexOnly(index);
    
    if (!storeController.loadedCategoryIndexes.contains(index)) {
      await storeController.loadUntilCategory(index);
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = categoryKeys[index];
      if (key != null && key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 500),
          alignment: 0.0,
        ).then((_) {
          Future.delayed(const Duration(milliseconds: 100), () {
            setState(() {
              _isScrollingToCategory = false;
            });
          });
        });
      } else {
        setState(() {
          _isScrollingToCategory = false;
        });
      }
    });
  }

  void _onScroll() {
    if (_isScrollingToCategory) return;
    final storeController = Get.find<StoreController>();
    if (storeController.categoryList == null || storeController.categoryList!.isEmpty) return;
    
    double tabBarHeight = 120.0;
    int activeIndex = -1;

    for (int index in storeController.loadedCategoryIndexes) {
      final key = categoryKeys[index];
      if (key == null || key.currentContext == null) continue;
      
      final RenderBox? renderBox = key.currentContext!.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final position = renderBox.localToGlobal(Offset.zero);
        if (position.dy < tabBarHeight + 100 && position.dy > 0) {
          activeIndex = index;
          break;
        }
      }
    }

    if (activeIndex != -1 && activeIndex != storeController.categoryIndex) {
      storeController.setCategoryIndexOnly(activeIndex);
    }
  }

  @override
  void initState() {
    super.initState();

    initDataCall();
  }

  @override
  void dispose() {
    super.dispose();

    scrollController.dispose();
    _debounce?.cancel();
    Get.find<StoreController>().initSearchData();
    if(Get.find<StoreController>().isSearching) {
      Get.find<StoreController>().changeSearchStatus(isUpdate: false);
    }
  }

  Future<void> initDataCall() async {
    if (AuthHelper.isLoggedIn()) {
      Get.find<StoreController>().getFollowedStores();
      if(Get.find<SplashController>().proStaus) {
        Get.find<ProController>().getProActiveOffer(moduleType: Get.find<SplashController>().module?.moduleType);
      }
    }
    Get.find<StoreController>().resetFilter(isUpdate: false);
    if(Get.find<StoreController>().isSearching) {
      Get.find<StoreController>().changeSearchStatus(isUpdate: false);
    }
    Get.find<StoreController>().initSearchData();
    Get.find<StoreController>().hideAnimation();
    int? storeId = widget.store?.id;
    if(storeId == null && Get.parameters['id'] != null) {
      storeId = int.tryParse(Get.parameters['id']!);
    }

    // Start secondary requests immediately in parallel — don't wait for store details
    final int resolvedId = storeId ?? 0;

    // Kick off store details; when done, fire dependent calls
    Get.find<StoreController>().getStoreDetails(Store(id: resolvedId), widget.fromModule, slug: widget.slug).then((store) {
      Get.find<StoreController>().showButtonAnimation();
      if(store != null) {
        Get.find<ItemHistoryController>().addToStoreHistory(store);
        final int id = store.id ?? resolvedId;
        // Fire all secondary requests concurrently after we have the store id
        Get.find<StoreController>().getStoreBannerList(id);
        Get.find<StoreController>().getRestaurantRecommendedItemList(id, false);
        Get.find<StoreController>().getStoreCategoryItems(id, notify: false);
        bool isFood = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == 'food';
        if (isFood) {
          Get.find<StoreController>().initializeCategoryData(id);
        } else {
          Get.find<StoreController>().getStoreItemList(id, 1, 'all', false);
        }
        // Defer reviews to reduce initial load
        Future.delayed(const Duration(milliseconds: 400), () {
          Get.find<ReviewController>().getStoreReviewList(id.toString());
        });
      }
    });

    // Categories can load in parallel with store details
    if(Get.find<CategoryController>().categoryList == null) {
      Get.find<CategoryController>().getCategoryList(true);
    }

    scrollController.addListener(() {
      if(scrollController.position.userScrollDirection == ScrollDirection.reverse){
        if(Get.find<StoreController>().showFavButton){
          Get.find<StoreController>().changeFavVisibility();
          Get.find<StoreController>().hideAnimation();
        }
      }else{
        if(!Get.find<StoreController>().showFavButton){
          Get.find<StoreController>().changeFavVisibility();
          Get.find<StoreController>().showButtonAnimation();
        }
      }
      bool isFood = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == 'food';
      if (_selectedTab == 0 && isFood && !Get.find<StoreController>().isSearching) {
        _onScroll();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: GetBuilder<StoreController>(builder: (storeController) {
        return GetBuilder<CategoryController>(builder: (categoryController) {
          return GetBuilder<FavouriteController>(builder: (favouriteController) {
            Store? store;
            if(storeController.store != null && storeController.store!.name != null && categoryController.categoryList != null) {
              store = storeController.store;
              storeController.setCategoryList();
            }

          return (storeController.store != null && storeController.store!.name != null) ? CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: scrollController,
            slivers: [

              ResponsiveHelper.isDesktop(context) ? SliverToBoxAdapter(
                child: Container(
                  color: const Color(0xFF171A29),
                  padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                  alignment: Alignment.center,
                  child: Center(child: SizedBox(width: Dimensions.webMaxWidth, child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                    child: Row(children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          child: Stack(
                            children: [
                              CustomImage(
                                fit: BoxFit.cover, height: 240, width: 590,
                                image: store?.coverPhotoFullUrl ?? '',
                              ),

                              store?.discount != null ? Positioned(
                                bottom: 0, left: 0, right: 0,
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                  child: Text('${store?.discount!.discountType == 'percent' ? '${store?.discount!.discount}%'
                                      : PriceConverter.convertPrice(store?.discount!.discount)} '
                                      '${'discount_will_be_applicable_when_order_amount_exceeds_is_more_than'.tr} ${PriceConverter.convertPrice(store?.discount!.minPurchase)},'
                                      ' ${'Max'.tr}: ${PriceConverter.convertPrice(store?.discount!.maxDiscount)} ${'discount_is_applicable'.tr}',
                                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ) : const SizedBox(),

                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeLarge),

                      Expanded(child: StoreDescriptionViewWidget(store: store)),

                    ]),
                  ))),
                ),
              ) : SliverToBoxAdapter(
                child: Stack(children: [
                  Column(children: [
                    Container(
                      height: 350, width: double.infinity,
                      alignment: Alignment.topCenter,
                      child: CustomImage(
                         fit: BoxFit.cover, height: 300, width: double.infinity,
                         image: '${store!.coverPhotoFullUrl}',
                      ),
                    ),
                  ]),

                  if (store.verifiedSeller == 1)
                    const Positioned(
                      left: Dimensions.paddingSizeDefault,
                      top: 190,
                      child: _VerifiedChip(),
                    ),

                  Padding(
                    padding: const EdgeInsets.only(top: 240),
                    child: Column(children: [
                      SizedBox(
                        width: Dimensions.webMaxWidth,
                        child: Column(children: [
                           Container(
                              margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                border: Border.all(color: Theme.of(context).cardColor, width: 1),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))],
                              ),
                              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Store Logo (Right in RTL)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                        child: CustomImage(
                                          image: '${store.logoFullUrl}',
                                          height: 50, width: 50, fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: Dimensions.paddingSizeSmall),

                                      // Store Info (Middle)
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(children: [
                                              Flexible(
                                                child: Text(
                                                  store.name!, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                                                  maxLines: 2, overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (store.verifiedSeller == 1) ...[
                                                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                                Icon(Icons.verified, color: Theme.of(context).primaryColor, size: 16),
                                              ],
                                              if (store.vendorType.isNotEmpty) ...[
                                                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                                VendorTypeBadgeWidget(store: store),
                                              ],
                                            ]),
                                            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                            Text(
                                              store.address ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: Dimensions.paddingSizeSmall),

                                      // Follow Button (Left in RTL)
                                      InkWell(
                                        onTap: () {
                                          if (AuthHelper.isLoggedIn()) {
                                            bool isFollowed = storeController.followedStoreIds.contains(store!.id);
                                            if (isFollowed) {
                                              storeController.unfollowStore(store.id);
                                            } else {
                                              storeController.followStore(store.id);
                                            }
                                          } else {
                                            showCustomSnackBar('you_are_not_logged_in'.tr);
                                          }
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: storeController.followedStoreIds.contains(store.id) ? Theme.of(context).cardColor : Theme.of(context).primaryColor,
                                            border: storeController.followedStoreIds.contains(store.id) ? Border.all(color: Theme.of(context).primaryColor) : null,
                                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                                          child: Text(
                                            storeController.followedStoreIds.contains(store.id) ? 'unfollow'.tr : 'follow'.tr, 
                                            style: robotoMedium.copyWith(
                                              color: storeController.followedStoreIds.contains(store.id) ? Theme.of(context).primaryColor : Colors.white, 
                                              fontSize: Dimensions.fontSizeSmall
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: Dimensions.paddingSizeDefault),
                                  
                                  // Stats Row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      // Rating
                                      Row(children: [
                                        Text(store.avgRating!.toStringAsFixed(1), style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                        const Icon(Icons.star, color: Colors.orange, size: 16),
                                      ]),

                                      Container(height: 15, width: 1, color: Theme.of(context).disabledColor.withValues(alpha: 0.5)),

                                      // Products Count
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(text: '${storeController.store?.itemCount ?? storeController.storeItemModel?.totalSize ?? 0} ', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyMedium!.color)),
                                            TextSpan(text: 'items'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)),
                                          ],
                                        ),
                                      ),
                                      
                                      Container(height: 15, width: 1, color: Theme.of(context).disabledColor.withValues(alpha: 0.5)),
                                      // Status
                                      Container(
                                        decoration: BoxDecoration(
                                          color: storeController.isStoreOpenNow(store.active!, store.schedules) ? Colors.green : Colors.red,
                                          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
                                        child: Text(
                                          storeController.isStoreOpenNow(store.active!, store.schedules) ? 'open'.tr : 'closed'.tr,
                                          style: robotoMedium.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeSmall),
                                        ),
                                      ),
                                      
                                    ],
                                  ),
                                ],
                              ),
                           ),

                        const SizedBox(height: Dimensions.paddingSizeSmall),
                       // const SizedBox(),
                       // const SizedBox(height: Dimensions.paddingSizeSmall),

                        store.announcementActive??false ? Container(
                         decoration: BoxDecoration(
                           color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                           borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                           border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.2)),
                         ),
                         padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                         margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                         child: Row(children: [
                           Image.asset(Images.announcement, height: 20, width: 20),
                           const SizedBox(width: Dimensions.paddingSizeSmall),
                           Flexible(child: Text(store.announcementMessage??'', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall))),
                         ]),
                        ) : const SizedBox(),

                        const Padding(
                           padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                           child: ProPlanBannerWidget(),
                        ),

                        StoreBannerWidget(storeController: storeController),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                        (!ResponsiveHelper.isDesktop(context) && storeController.recommendedItemModel != null && storeController.recommendedItemModel!.items!.isNotEmpty) ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                              child: Text('most_requested'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyMedium!.color)),
                            ),
                            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                            SizedBox(
                              height: ResponsiveHelper.isDesktop(context) ? 150 : 125,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: storeController.recommendedItemModel!.items!.length,
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall), // Add initial padding for alignment
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.symmetric(vertical: 20) : const EdgeInsets.symmetric(vertical: 5) ,
                                    child: Container(
                                      width: ResponsiveHelper.isDesktop(context) ? 500 : 310,
                                      padding: const EdgeInsets.only(right: Dimensions.paddingSizeExtraSmall, left: Dimensions.paddingSizeExtraSmall),
                                      margin: const EdgeInsets.only(right: Dimensions.paddingSizeExtraSmall),
                                      child: RecommendedStoreItemWidget(
                                        item: storeController.recommendedItemModel!.items![index],
                                        index: index,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ) : const SizedBox(),
                        ]),
                      ),
                    ]),
                  ),

                  Positioned(
                    top: 0, left: 0, right: 0,
                    child: Container(
                      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall),
                      child: Row(children: [
                        // Back Button
                        InkWell(
                          onTap: () => Get.back(),
                          child: Container(
                            height: 40, width: 40,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusDefault), color: Theme.of(context).cardColor.withValues(alpha: 0.8), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 5)]),
                            alignment: Alignment.center,
                            child: Icon(Icons.arrow_back, color: Theme.of(context).textTheme.bodyMedium!.color),
                          ),
                        ),
                        const Spacer(),

                        // Favorite Button
                        GetBuilder<FavouriteController>(builder: (favouriteController) {
                          bool isWished = favouriteController.wishStoreIdList.contains(store!.id);
                          return InkWell(
                            onTap: () {
                              if(AuthHelper.isLoggedIn()) {
                                isWished ? favouriteController.removeFromFavouriteList(store!.id, true)
                                    : favouriteController.addToFavouriteList(null, store?.id, true);
                              }else {
                                showCustomSnackBar('you_are_not_logged_in'.tr);
                              }
                            },
                            child: Container(
                              height: 40, width: 40,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusDefault), color: Theme.of(context).cardColor.withValues(alpha: 0.8), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 5)]),
                              alignment: Alignment.center,
                              child: Icon(
                                isWished ? Icons.favorite : Icons.favorite_border,
                                color: isWished ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyMedium!.color,
                                size: 20,
                              ),
                            ),
                          );
                        }),
                        const SizedBox(width: Dimensions.paddingSizeSmall),

                        // Share Button
                        AppConstants.webHostedUrl.isNotEmpty ? InkWell(
                          onTap: () => storeController.shareStore(),
                          child: Container(
                            height: 40, width: 40,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusDefault), color: Theme.of(context).cardColor.withValues(alpha: 0.8), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 5)]),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.send_outlined, color: Theme.of(context).textTheme.bodyMedium!.color, size: 20,
                            ),
                          ),
                        ) : const SizedBox(),
                        const SizedBox(width: Dimensions.paddingSizeSmall),

                        // More Button
                        InkWell(
                          onTap: () {},
                          child: Container(
                            height: 40, width: 40,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusDefault), color: Theme.of(context).cardColor.withValues(alpha: 0.8), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 5)]),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.more_vert, color: Theme.of(context).textTheme.bodyMedium!.color, size: 20,
                            ),
                          ),
                        ),
                      ]),
                    )
                  )

                ]),
              ),



              (ResponsiveHelper.isDesktop(context)  && storeController.recommendedItemModel != null && storeController.recommendedItemModel!.items!.isNotEmpty)
              ? SliverToBoxAdapter(
                child: Container(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.10),
                  child: Center(
                    child: SizedBox(
                      width: Dimensions.webMaxWidth,
                      height: ResponsiveHelper.isDesktop(context) ? 325 : 125,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          Text('most_requested'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w700)),
                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                          Text('here_is_what_you_might_like'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                          SizedBox(
                            height: 250,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: storeController.recommendedItemModel!.items!.length,
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                              itemBuilder: (context, index) {
                                return Container(
                                  width:  225,
                                  padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeExtraSmall),
                                  margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                                  child: WebItemWidget(
                                    isStore: false, item: storeController.recommendedItemModel!.items![index],
                                    store: null, index: index, length: null, isCampaign: false, inStore: true,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ): const SliverToBoxAdapter(child: SizedBox()),
              const SliverToBoxAdapter(child: SizedBox(height: Dimensions.paddingSizeSmall)),

              ///web view..
              ResponsiveHelper.isDesktop(context) ? SliverToBoxAdapter(
                child: FooterView(
                  child: SizedBox(
                    width: Dimensions.webMaxWidth,
                    child: Padding(
                      padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 175,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.vertical,
                                    itemCount: storeController.categoryList!.length,
                                    padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: () {
                                          storeController.setCategoryIndex(index, itemSearching: storeController.isSearching);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.bottomRight,
                                                end: Alignment.topLeft,
                                                colors: <Color>[
                                                  index == storeController.categoryIndex ? Theme.of(context).primaryColor.withValues(alpha: 0.50) : Colors.transparent,
                                                  index == storeController.categoryIndex ? Theme.of(context).cardColor : Colors.transparent,
                                                ]
                                              )
                                            ),
                                            child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                                              Text(
                                                storeController.categoryList![index].name!,
                                                maxLines: 1, overflow: TextOverflow.ellipsis,
                                                style: index == storeController.categoryIndex
                                                    ? robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)
                                                    : robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                                              ),
                                            ]),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                Container(
                                  height: storeController.categoryList!.length * 50, width: 1,
                                  color: Theme.of(context).disabledColor.withValues(alpha: 0.5),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeLarge),

                          Expanded(child: Column (
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                    height: 45,
                                    width: 430,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                      color: Theme.of(context).cardColor,
                                      border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.40)),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: _searchController,
                                            textInputAction: TextInputAction.search,
                                            decoration: InputDecoration(
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                              hintText: 'search_for_items'.tr,
                                              hintStyle: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), borderSide: BorderSide.none),
                                              filled: true, fillColor:Theme.of(context).cardColor,
                                              isDense: true,
                                              prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor.withValues(alpha: 0.50)),
                                            ),
                                            onSubmitted: (String? value) {
                                              if(value!.isNotEmpty) {
                                                Get.find<StoreController>().getStoreSearchItemList(
                                                  _searchController.text.trim(), widget.store!.id.toString(), 1, storeController.type,
                                                );
                                              }
                                            } ,
                                            onChanged: (String? value) { } ,
                                          ),
                                        ),
                                        const SizedBox(width: Dimensions.paddingSizeSmall),

                                        !storeController.isSearching ? CustomButton(
                                          radius: Dimensions.radiusSmall,
                                          height: 40,
                                          width: 74,
                                          buttonText: 'search'.tr,
                                          isBold: false,
                                          fontSize: Dimensions.fontSizeSmall,
                                          onPressed: () {
                                            storeController.getStoreSearchItemList(
                                              _searchController.text.trim(), widget.store!.id.toString(), 1, storeController.type,
                                            );
                                          },
                                        ) : InkWell(onTap: () {
                                          _searchController.text = '';
                                          storeController.initSearchData();
                                          storeController.changeSearchStatus();
                                        },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).primaryColor,
                                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall)
                                            ),
                                            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: Dimensions.paddingSizeSmall),
                                            child: const Icon(Icons.clear, color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: Dimensions.paddingSizeDefault),

                                  InkWell(
                                    onTap: () {
                                      List<double?> prices = [];
                                      for (var product in Get.find<StoreController>().storeItemModel!.items!) {
                                        prices.add(product.price);
                                      }
                                      prices.sort();
                                      double? maxValue = prices.isNotEmpty ? prices[prices.length-1] : 1000;
                                      Get.dialog(FilterWidget(maxValue: maxValue));
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                        color: Theme.of(context).cardColor,
                                        border: Border.all(color: Theme.of(context).primaryColor, width: 1),
                                      ),
                                      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                      child: Icon(Icons.filter_list, size: 24, color: Theme.of(context).primaryColor),
                                    ),
                                  ),

                                  /*(Get.find<SplashController>().configModel!.moduleConfig!.module!.vegNonVeg! && Get.find<SplashController>().configModel!.toggleVegNonVeg!)
                                  ? SizedBox(
                                    width: 300,
                                    height:  30,
                                    child:  ListView.builder(
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      itemCount: Get.find<ItemController>().itemTypeList.length,
                                      padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                                          child:  CustomCheckBoxWidget(
                                            title: Get.find<ItemController>().itemTypeList[index].tr,
                                            value: storeController.type == Get.find<ItemController>().itemTypeList[index],
                                            onClick: () {
                                              if(storeController.isSearching){
                                                storeController.getStoreSearchItemList(
                                                  storeController.searchText, widget.store!.id.toString(), 1, Get.find<ItemController>().itemTypeList[index],
                                                );
                                              } else {
                                                storeController.getStoreItemList(storeController.store!.id, 1, Get.find<ItemController>().itemTypeList[index], true);
                                              }
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ) : const SizedBox(),*/
                                ],
                              ),
                              const SizedBox(height: Dimensions.paddingSizeSmall),

                              PaginatedListView(
                                scrollController: scrollController,
                                onPaginate: (int? offset) async {
                                  if(storeController.isSearching){
                                    await storeController.getStoreSearchItemList(
                                      storeController.searchText, widget.store!.id.toString(), offset!, storeController.type,
                                    );
                                  } else {
                                    await storeController.getStoreItemList(widget.store!.id ?? storeController.store!.id, offset!, storeController.type, false);
                                  }
                                },
                                totalSize: storeController.isSearching
                                    ? storeController.storeSearchItemModel?.totalSize
                                    : (storeController.categoryList!.isNotEmpty && storeController.categoryList![storeController.categoryIndex].id == -1)
                                        ? (Get.find<FavouriteController>().wishItemList?.where((item) => item != null && item.storeId == (widget.store?.id ?? storeController.store?.id)).length ?? 0)
                                        : storeController.storeItemModel?.totalSize,
                                offset: storeController.isSearching
                                    ? storeController.storeSearchItemModel?.offset
                                    : (storeController.categoryList!.isNotEmpty && storeController.categoryList![storeController.categoryIndex].id == -1)
                                        ? 1
                                        : storeController.storeItemModel?.offset,
                        itemView: GetBuilder<FavouriteController>(
                                    builder: (favouriteController) {
                                      List<Item>? items = storeController.isSearching
                                          ? storeController.storeSearchItemModel?.items
                                          : (storeController.categoryList!.isNotEmpty && storeController.storeItemModel != null)
                                          ? (storeController.categoryList![storeController.categoryIndex].id == -1
                                              ? (favouriteController.wishItemList != null
                                                  ? favouriteController.wishItemList!.where((item) => item != null && item.storeId == (widget.store?.id ?? storeController.store?.id)).map((item) => item!).toList()
                                                  : <Item>[])
                                              : storeController.storeItemModel!.items)
                                          : null;
                                      if (items == null) return const CustomLoaderWidget();
                                      if (items.isEmpty) return Center(child: Text('no_item_available'.tr));
                                      
                                      return GridView.builder(
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: ResponsiveHelper.isDesktop(context) ? 5 : ResponsiveHelper.isTab(context) ? 3 : 2,
                                          mainAxisSpacing: Dimensions.paddingSizeSmall,
                                          crossAxisSpacing: Dimensions.paddingSizeSmall,
                                          mainAxisExtent: (Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.food) ? 230 : 380,
                                        ),
                                        physics: const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: items.length,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: Dimensions.paddingSizeSmall,
                                            vertical: Dimensions.paddingSizeSmall
                                        ),
                                        itemBuilder: (context, index) {
                                          return ItemCard(
                                            item: items[index],
                                            isPopularItem: false,
                                            isFood: Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.food,
                                            isShop: Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.ecommerce,
                                          );
                                        },
                                      );
                                    }
                                  ),
                              ),
                            ],
                          ))

                        ],
                      ),
                    ),
                  ),
                ),
              ) : const SliverToBoxAdapter(child:SizedBox()),


              ///mobile view..
              const SliverToBoxAdapter(child: SizedBox()),

              ResponsiveHelper.isDesktop(context) ? const SliverToBoxAdapter(child:SizedBox()) :
              (storeController.categoryList!.isNotEmpty) ? SliverPersistentHeader(
                pinned: true,
                delegate: SliverDelegate(height: _selectedTab == 0 ? 125 : 70, child: Center(child: Container(
                  width: Dimensions.webMaxWidth,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeSmall),
                        child: Row(children: [
                          Expanded(child: InkWell(
                            onTap: () => setState(() => _selectedTab = 0),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _selectedTab == 0 ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                border: Border.all(color: _selectedTab == 0 ? Theme.of(context).primaryColor : Theme.of(context).disabledColor),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  Text(Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == 'food' ? 'all_meals'.tr : 'all_products'.tr, style: robotoMedium.copyWith(color: _selectedTab == 0 ? Colors.white : Theme.of(context).disabledColor)),
                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                Icon(Icons.storefront, size: 16, color: _selectedTab == 0 ? Colors.white : Theme.of(context).disabledColor),
                              ]),
                            ),
                          )),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          Expanded(child: InkWell(
                            onTap: () {
                              setState(() => _selectedTab = 1);
                              Get.find<ReviewController>().getStoreReviewList(storeController.store!.id.toString());
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _selectedTab == 1 ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                border: Border.all(color: _selectedTab == 1 ? Theme.of(context).primaryColor : Theme.of(context).disabledColor),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                 Text('reviews'.tr, style: robotoMedium.copyWith(color: _selectedTab == 1 ? Colors.white : Theme.of(context).disabledColor)),
                               const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                               Icon(Icons.star_border, size: 16, color: _selectedTab == 1 ? Colors.white : Theme.of(context).disabledColor),
                               ]),
                            ),
                          )),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          Expanded(child: InkWell(
                            onTap: () => setState(() => _selectedTab = 2),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _selectedTab == 2 ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                border: Border.all(color: _selectedTab == 2 ? Theme.of(context).primaryColor : Theme.of(context).disabledColor),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Text(Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.food ? 'about_restaurant'.tr : 'about_store'.tr, style: robotoMedium.copyWith(color: _selectedTab == 2 ? Colors.white : Theme.of(context).disabledColor)),
                                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                 Icon(Icons.info_outline, size: 16, color: _selectedTab == 2 ? Colors.white : Theme.of(context).disabledColor),
                             ]),
                            ),
                          )),
                        ]),
                      ),
                      if (_selectedTab == 0)
                        Container(
                          color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                          child: Column(
                            children: [
                              const SizedBox(height: Dimensions.paddingSizeSmall),
                              SizedBox(
                                height: 35,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                      itemCount: storeController.categoryList!.length,
                                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                                  physics: const BouncingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () {
                                        bool isFood = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == 'food';
                                        if (isFood) {
                                          if (storeController.isSearching) {
                                            storeController.setCategoryIndex(index, itemSearching: true);
                                          } else {
                                            _scrollToCategory(index);
                                          }
                                        } else {
                                          storeController.setCategoryIndex(index, itemSearching: storeController.isSearching);
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                                        margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                          color: index == storeController.categoryIndex ? Theme.of(context).textTheme.bodyLarge!.color : Colors.transparent,
                                          border: Border.all(color: index == storeController.categoryIndex ? Colors.transparent : Theme.of(context).disabledColor.withValues(alpha: 0.3)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              storeController.categoryList![index].name!,
                                              style: robotoMedium.copyWith(color: index == storeController.categoryIndex ? Theme.of(context).cardColor : Theme.of(context).textTheme.bodyLarge!.color, fontSize: Dimensions.fontSizeSmall),
                                            ),
                                            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                            storeController.categoryList![index].id == -1 ? Icon(
                                               Icons.favorite,
                                               color: index == storeController.categoryIndex ? Theme.of(context).cardColor : Theme.of(context).primaryColor,
                                               size: 20,
                                             ) : ClipOval(
                                               child: CustomImage(
                                                 image: storeController.categoryList![index].imageFullUrl ?? '',
                                                 height: 25, width: 25, fit: BoxFit.cover,
                                               ),
                                             ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: Dimensions.paddingSizeSmall),
                            ],
                          ),
                        ),
                    ],
                  ),
                ))),
              ) : const SliverToBoxAdapter(child: SizedBox()),

              ResponsiveHelper.isDesktop(context) ? const SliverToBoxAdapter(child:SizedBox()) :
              SliverToBoxAdapter(child: Container(
                width: Dimensions.webMaxWidth,
                decoration: BoxDecoration(
                  color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                ),
                child: _selectedTab == 0 ? Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                      child: Row(children: [
                        Text(
                          '${storeController.isSearching ? storeController.storeSearchItemModel?.totalSize ?? 0 : (Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == 'food' ? storeController.store?.itemCount ?? 0 : storeController.storeItemModel?.totalSize ?? 0)} ${Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == 'food' ? 'meals'.tr : 'items'.tr}',
                          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                        ),
                        const Expanded(child: SizedBox()),

                        InkWell(
                          onTap: () {
                            List<double?> prices = [];
                            if(storeController.storeItemModel != null && storeController.storeItemModel!.items != null) {
                              for (var product in storeController.storeItemModel!.items!) {
                                prices.add(product.price);
                              }
                            }
                            prices.sort();
                            double? maxValue = prices.isNotEmpty ? prices[prices.length-1] : 1000;
                            Get.dialog(FilterWidget(maxValue: maxValue));
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                            decoration: BoxDecoration(
                              border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.5)),
                              borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                            ),
                            child: Row(children: [
                              Text('filter'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                              Icon(Icons.filter_alt_outlined, size: 20, color: Theme.of(context).textTheme.bodyMedium!.color),
                            ]),
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                      child: SizedBox(
                        height: 48,
                        child: TextField(
                          controller: _searchController,
                          textInputAction: TextInputAction.search,
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
                          cursorColor: Theme.of(context).primaryColor,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            hintText: 'search_item_in_store'.tr,
                            hintStyle: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
                            filled: true,
                            fillColor: Theme.of(context).cardColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
                            ),
                            suffixIcon: _searchController.text.isNotEmpty ? IconButton(
                              icon: Icon(Icons.clear, color: Theme.of(context).hintColor, size: 20),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                                if(storeController.isSearching) {
                                  storeController.changeSearchStatus();
                                  storeController.initSearchData();
                                  storeController.getStoreItemList(widget.store!.id ?? storeController.store!.id, 1, storeController.type, false);
                                }
                              },
                            ) : Icon(Icons.search, color: Theme.of(context).primaryColor, size: 22),
                          ),
                          onChanged: (text) {
                            setState(() {});
                            if (_debounce?.isActive ?? false) _debounce!.cancel();
                            _debounce = Timer(const Duration(milliseconds: 500), () {
                              if (text.trim().length >= 2) {
                                storeController.getStoreSearchItemList(
                                  text.trim(),
                                  (widget.store!.id ?? storeController.store!.id).toString(),
                                  1,
                                  storeController.type,
                                );
                              } else if (text.trim().length < 2 && storeController.isSearching) {
                                storeController.changeSearchStatus();
                                storeController.initSearchData();
                                storeController.getStoreItemList(widget.store!.id ?? storeController.store!.id, 1, storeController.type, false);
                              }
                            });
                          },
                          onSubmitted: (text) {
                            if (text.trim().isNotEmpty) {
                              if (_debounce?.isActive ?? false) _debounce!.cancel();
                              storeController.getStoreSearchItemList(
                                text.trim(),
                                (widget.store!.id ?? storeController.store!.id).toString(),
                                1,
                                storeController.type,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    GestureDetector(
                      onHorizontalDragEnd: (DragEndDetails details) {
                        bool isLtr = Get.find<LocalizationController>().isLtr;
                        if (details.primaryVelocity! > 0) {
                          if (isLtr) {
                            if (storeController.categoryIndex > 0) {
                              storeController.setCategoryIndex(storeController.categoryIndex - 1, itemSearching: storeController.isSearching);
                            }
                          } else {
                            if (storeController.categoryIndex < storeController.categoryList!.length - 1) {
                              storeController.setCategoryIndex(storeController.categoryIndex + 1, itemSearching: storeController.isSearching);
                            }
                          }
                        } else if (details.primaryVelocity! < 0) {
                          if (isLtr) {
                            if (storeController.categoryIndex < storeController.categoryList!.length - 1) {
                              storeController.setCategoryIndex(storeController.categoryIndex + 1, itemSearching: storeController.isSearching);
                            }
                          } else {
                            if (storeController.categoryIndex > 0) {
                              storeController.setCategoryIndex(storeController.categoryIndex - 1, itemSearching: storeController.isSearching);
                            }
                          }
                        }
                      },
                  child: PaginatedListView(
                    scrollController: scrollController,
                    onPaginate: (int? offset) async {
                      bool isFood = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == 'food';
                      if (storeController.isSearching) {
                        await storeController.getStoreSearchItemList(
                          storeController.searchText,
                          (widget.store!.id ?? storeController.store!.id).toString(),
                          offset!,
                          storeController.type,
                        );
                      } else if (isFood) {
                        if (storeController.loadedCategoryIndexes.isNotEmpty) {
                          int lastIndex = storeController.loadedCategoryIndexes.last;
                          CategoryModel lastCategory = storeController.categoryList![lastIndex];
                          int lastCategoryId = lastCategory.id ?? 0;
                          
                          int loadedItemsCount = storeController.categoryItems[lastCategoryId]?.length ?? 0;
                          int totalSize = storeController.categoryTotalSizes[lastCategoryId] ?? 0;
                          
                          if (loadedItemsCount < totalSize) {
                            await storeController.loadCategoryItems(lastIndex, isPaginate: true);
                          } else {
                            if (lastIndex + 1 < storeController.categoryList!.length) {
                              await storeController.loadCategoryItems(lastIndex + 1);
                            }
                          }
                        }
                      } else {
                        await storeController.getStoreItemList(
                          widget.store!.id ?? storeController.store!.id,
                          offset!,
                          storeController.type,
                          false,
                        );
                      }
                    },
                    totalSize: storeController.isSearching
                        ? storeController.storeSearchItemModel?.totalSize
                        : (Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == 'food'
                            ? (storeController.loadedCategoryIndexes.isNotEmpty
                                ? (storeController.loadedCategoryIndexes.last + 1 < storeController.categoryList!.length
                                    ? 999999
                                    : (storeController.categoryTotalSizes[storeController.categoryList![storeController.loadedCategoryIndexes.last].id] ?? 0))
                                : 0)
                            : storeController.storeItemModel?.totalSize),
                    offset: storeController.isSearching
                        ? storeController.storeSearchItemModel?.offset
                        : (Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == 'food'
                            ? (storeController.loadedCategoryIndexes.isNotEmpty
                                ? (storeController.categoryOffsets[storeController.categoryList![storeController.loadedCategoryIndexes.last].id] ?? 1)
                                : 1)
                            : storeController.storeItemModel?.offset),
                    itemView: Builder(
                      builder: (context) {
                        bool isFood = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == 'food';
                        if (isFood && !storeController.isSearching) {
                          if (storeController.loadedCategoryIndexes.isEmpty) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (int i = 0; i < storeController.loadedCategoryIndexes.length; i++) ...[
                                Builder(
                                  builder: (context) {
                                    int categoryIndex = storeController.loadedCategoryIndexes[i];
                                    CategoryModel category = storeController.categoryList![categoryIndex];
                                    int categoryId = category.id ?? 0;
                                    List<Item> categoryItems = storeController.categoryItems[categoryId] ?? [];

                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          key: categoryKeys[categoryIndex] ??= GlobalKey(),
                                          width: double.infinity,
                                          margin: const EdgeInsets.only(
                                            top: Dimensions.paddingSizeDefault,
                                            bottom: Dimensions.paddingSizeSmall,
                                            left: Dimensions.paddingSizeSmall,
                                            right: Dimensions.paddingSizeSmall,
                                          ),
                                          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).cardColor,
                                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.05),
                                                blurRadius: 5,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              if (categoryId == -1)
                                                Icon(Icons.favorite, color: Theme.of(context).primaryColor, size: 24)
                                              else if (categoryId == -2)
                                                const Icon(Icons.local_fire_department, color: Colors.orange, size: 24)
                                              else
                                                ClipOval(
                                                  child: CustomImage(
                                                    image: category.imageFullUrl ?? '',
                                                    height: 30,
                                                    width: 30,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              const SizedBox(width: Dimensions.paddingSizeSmall),
                                              Expanded(
                                                child: Text(
                                                  category.name ?? '',
                                                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                                                ),
                                              ),
                                              Container(
                                                height: 4,
                                                width: 20,
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                                                  borderRadius: BorderRadius.circular(2),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        if (categoryItems.isNotEmpty)
                                          GridView.builder(
                                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: ResponsiveHelper.isDesktop(context) ? 5 : ResponsiveHelper.isTab(context) ? 3 : 2,
                                              mainAxisSpacing: Dimensions.paddingSizeSmall,
                                              crossAxisSpacing: Dimensions.paddingSizeSmall,
                                              mainAxisExtent: (Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.food) ? 220 : 360,
                                            ),
                                            physics: const NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: categoryItems.length,
                                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                            itemBuilder: (context, index) {
                                              return ItemCard(
                                                item: categoryItems[index],
                                                isPopularItem: false,
                                                isFood: Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.food,
                                                isShop: Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.ecommerce,
                                              );
                                            },
                                          )
                                        else
                                          Padding(
                                            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                                            child: Center(
                                              child: Text('no_item_available'.tr),
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ],
                          );
                        }

                        List<Item>? items = storeController.isSearching
                            ? (storeController.storeSearchItemModel?.items)
                            : (storeController.categoryList!.isNotEmpty && storeController.storeItemModel != null)
                            ? storeController.storeItemModel!.items : null;
                        
                        if (items == null) {
                          return GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: ResponsiveHelper.isDesktop(context) ? 5 : ResponsiveHelper.isTab(context) ? 3 : 2,
                              mainAxisSpacing: Dimensions.paddingSizeSmall,
                              crossAxisSpacing: Dimensions.paddingSizeSmall,
                              mainAxisExtent: (Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.food) ? 220 : 360,
                            ),
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: ResponsiveHelper.isDesktop(context) ? 10 : 6,
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
                            itemBuilder: (context, index) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                ),
                              );
                            },
                          );
                        }
                        if (items.isEmpty) {
                          return SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: Center(child: Text('no_item_available'.tr)),
                          );
                        }

                        return GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: ResponsiveHelper.isDesktop(context) ? 5 : ResponsiveHelper.isTab(context) ? 3 : 2,
                            mainAxisSpacing: Dimensions.paddingSizeSmall,
                            crossAxisSpacing: Dimensions.paddingSizeSmall,
                            mainAxisExtent: (Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.food) ? 220 : 360,
                          ),
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: items.length,
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeSmall,
                            vertical: Dimensions.paddingSizeSmall,
                          ),
                          itemBuilder: (context, index) {
                            return ItemCard(
                              item: items[index],
                              isPopularItem: false,
                              isFood: Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.food,
                              isShop: Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.ecommerce,
                            );
                          },
                        );
                      }
                    ),
                  ),
                ),
              ],
            ) : _selectedTab == 1 ? GetBuilder<ReviewController>(builder: (reviewController) {
              return reviewController.storeReviewList != null ? Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('${(reviewController.originalStoreReviewList != null && reviewController.originalStoreReviewList!.isNotEmpty) ? reviewController.originalStoreReviewList!.length : (store?.reviewsCommentsCount ?? 0)} ${'ratings_1'.tr}', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                    Row(children: [
                      InkWell(
                        onTap: () {
                          Get.dialog(Dialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                            child: Container(
                              width: 300,
                              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                              child: Column(mainAxisSize: MainAxisSize.min, children: [
                                Text('filter_by_rating'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                                const SizedBox(height: Dimensions.paddingSizeLarge),
                                ...[0, 5, 4, 3, 2, 1].map((rating) {
                                  return InkWell(
                                    onTap: () {
                                      reviewController.filterStoreReviewList(rating);
                                      Get.back();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                                      child: Row(children: [
                                        Icon(
                                          reviewController.ratingFilter == rating ? Icons.radio_button_checked : Icons.radio_button_off,
                                          color: reviewController.ratingFilter == rating ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                                          size: 20,
                                        ),
                                        const SizedBox(width: Dimensions.paddingSizeSmall),
                                        Text(rating == 0 ? 'all'.tr : '$rating ${'stars'.tr}', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault)),
                                      ]),
                                    ),
                                  );
                                }),
                              ]),
                            ),
                          ));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                          decoration: BoxDecoration(
                            border: Border.all(color: reviewController.ratingFilter != 0 ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withValues(alpha: 0.5)),
                            color: reviewController.ratingFilter != 0 ? Theme.of(context).primaryColor.withValues(alpha: 0.05) : Colors.transparent,
                            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                          ),
                          child: Row(children: [
                            Text(reviewController.ratingFilter == 0 ? 'filter'.tr : '${reviewController.ratingFilter} ${'stars'.tr}', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: reviewController.ratingFilter != 0 ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyMedium!.color)),
                            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                            Icon(Icons.filter_alt_outlined, size: 20, color: reviewController.ratingFilter != 0 ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyMedium!.color),
                          ]),
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      InkWell(
                        onTap: () => reviewController.sortStoreReviewList(),
                        child: Container(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                          decoration: BoxDecoration(
                            border: Border.all(color: reviewController.isAscendingSort ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withValues(alpha: 0.5)),
                            color: reviewController.isAscendingSort ? Theme.of(context).primaryColor.withValues(alpha: 0.05) : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.sort, size: 20, color: reviewController.isAscendingSort ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyMedium!.color),
                        ),
                      ),
                    ]),
                  ]),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  RatingWidget(
                    averageRating: store?.avgRating ?? 0,
                    ratingCount: store?.ratingCount ?? 0,
                    reviewCommentCount: (reviewController.originalStoreReviewList != null && reviewController.originalStoreReviewList!.isNotEmpty) ? reviewController.originalStoreReviewList!.length : (store?.reviewsCommentsCount ?? 0),
                    ratings: store?.ratings,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  reviewController.storeReviewList!.isNotEmpty ? ReviewListWidget(
                    reviewController: reviewController, storeName: store?.name, reviewList: reviewController.storeReviewList,
                  ) : Center(child: Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeDefault), child: Text('no_review_found'.tr))),
                ]),
              ) : const Center(child: Padding(padding: EdgeInsets.all(Dimensions.paddingSizeLarge), child: CircularProgressIndicator()));
            }) : Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // About Store
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusDefault), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.food ? 'about_restaurant'.tr : 'about_store'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        Text((store?.metaDescription != null && store!.metaDescription!.isNotEmpty) ? store.metaDescription! : (store?.address ?? ''), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                      ],
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  // Working Hours
                  if(store?.schedules != null && store!.schedules!.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusDefault), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('working_hours'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          Builder(
                            builder: (context) {
                              Map<int, List<dynamic>> groupedSchedules = {};
                              for (var schedule in store!.schedules!) {
                                if (!groupedSchedules.containsKey(schedule.day)) {
                                  groupedSchedules[schedule.day!] = [];
                                }
                                groupedSchedules[schedule.day!]!.add(schedule);
                              }
                              List<int> sortedDays = groupedSchedules.keys.toList();
                              sortedDays.sort((a, b) {
                                if (a == 6) return -1;
                                if (b == 6) return 1;
                                return a.compareTo(b);
                              });
                              
                              return Column(
                                children: [
                                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                    Expanded(child: Text('day'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall))),
                                    Expanded(child: Text('slot_1'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall), textAlign: TextAlign.center)),
                                    Expanded(child: Text('slot_2'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall), textAlign: TextAlign.right)),
                                  ]),
                                  const Divider(),
                                  ...sortedDays.map((day) {
                                    List<String> days = ['sunday'.tr, 'monday'.tr, 'tuesday'.tr, 'wednesday'.tr, 'thursday'.tr, 'friday'.tr, 'saturday'.tr];
                                    String dayName = days[day % 7];
                                    List<dynamic> slots = groupedSchedules[day]!;
                                    
                                    String slot1 = '';
                                    String slot2 = '';
                                    if (slots.isNotEmpty) {
                                      if (slots.length == 1) {
                                        slot1 = slots[0].openingTime ?? '';
                                        slot2 = slots[0].closingTime ?? '';
                                      } else {
                                        slot1 = '${slots[0].openingTime} - ${slots[0].closingTime}';
                                        slot2 = '${slots[1].openingTime} - ${slots[1].closingTime}';
                                      }
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                        Expanded(child: Text(dayName, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor))),
                                        Expanded(child: Text(slot1, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor), textAlign: TextAlign.center)),
                                        Expanded(child: Text(slot2, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor), textAlign: TextAlign.right)),
                                      ]),
                                    );
                                  }),
                                ],
                              );
                            }
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                  ],

                  // Location Map
                  if(store?.latitude != null && store?.longitude != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusDefault), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('location'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), border: Border.all(color: Theme.of(context).primaryColor, width: 0.5)),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              child: GoogleMap(
                                initialCameraPosition: CameraPosition(target: LatLng(double.parse(store!.latitude!), double.parse(store.longitude!)), zoom: 16),
                                markers: {
                                  Marker(markerId: const MarkerId('store'), position: LatLng(double.parse(store.latitude!), double.parse(store.longitude!))),
                                },
                                zoomControlsEnabled: false,
                                myLocationButtonEnabled: false,
                                compassEnabled: false,
                                mapToolbarEnabled: false,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
              )),
            ],
          ) : const StoreDetailsScreenShimmerWidget();
            });
          });
        }),

      floatingActionButton: GetBuilder<StoreController>(
        builder: (storeController) {
          return Visibility(
            visible: storeController.showFavButton && Get.find<SplashController>().configModel!.moduleConfig!.module!.orderAttachment!
                && (storeController.store != null && storeController.store!.prescriptionOrder!)
                && Get.find<SplashController>().configModel!.prescriptionStatus! && AuthHelper.isLoggedIn(),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.5), blurRadius: 10, offset: const Offset(2, 2))],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [

                AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  width: storeController.currentState == true ? 0 : ResponsiveHelper.isDesktop(context) ? 180 : 150,
                  height: 30,
                  curve: Curves.linear,
                  child:  Center(
                    child: Text(
                      'prescription_order'.tr, textAlign: TextAlign.center,
                      style: robotoMedium.copyWith(color: Theme.of(context).primaryColor), maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                InkWell(
                  onTap: () {
                    Get.find<CheckoutController>().updateFirstTime();
                    Get.find<CheckoutController>().updateFirstTimeCodActive();
                    Get.toNamed(
                      RouteHelper.getCheckoutRoute('prescription', storeId: storeController.store!.id),
                      arguments: CheckoutScreen(fromCart: false, cartList: null, storeId: storeController.store!.id),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    ),
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: Image.asset(Images.prescriptionIcon, height: 25, width: 25),
                  ),
                ),

              ]),
            ),
          );
        }
      ),

      bottomNavigationBar: GetBuilder<CartController>(builder: (cartController) {
        return cartController.cartList.isNotEmpty && !ResponsiveHelper.isDesktop(context) ? const BottomCartWidget() : const SizedBox();
      })
    );
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;
  double height;

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
    return oldDelegate.maxExtent != height || oldDelegate.minExtent != height || child != oldDelegate.child;
  }
}

class CategoryProduct {
  CategoryModel category;
  List<Item> products;
  CategoryProduct(this.category, this.products);
}

class _VerifiedChip extends StatelessWidget {
  const _VerifiedChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF4285F4), borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
        boxShadow: const [BoxShadow(color: Color(0x26000000), blurRadius: 6, offset: Offset(0, 2))]
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.verified, color: Colors.white, size: 16),
        const SizedBox(width: 4),
        Text(
          'Verified',
          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.white),
        ),
      ]),
    );
  }
}

