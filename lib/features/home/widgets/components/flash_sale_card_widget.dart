import 'package:flutter/material.dart';
import 'dart:async'; // + ahmed
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/flash_sale/controllers/flash_sale_controller.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/flash_sale/domain/models/flash_sale_model.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/features/favourite/controllers/favourite_controller.dart';

import 'package:share_plus/share_plus.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';

class FlashSaleCard extends StatefulWidget {
  final List<ActiveProducts> activeProducts;
  const FlashSaleCard({super.key, required this.activeProducts});

  @override
  State<FlashSaleCard> createState() => _FlashSaleCardState();
}

class _FlashSaleCardState extends State<FlashSaleCard> {

  late PageController _pageController;
  int _currentPage = 1 ;
  bool isFirstTime = false;
  
  // Dynamic Status Animation
  int _currentStatusIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentPage = 0;
    _pageController = PageController(initialPage: _currentPage, viewportFraction: 0.5);

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _currentStatusIndex++;
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {});
      }
    });

  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      AspectRatio(
        // Increased height by reducing aspect ratio from 1.6 to 1.3
        aspectRatio: ResponsiveHelper.isTab(context) ? 1.0 : ResponsiveHelper.isDesktop(context) ? 0.9 : 1.3, 
        child: PageView.builder(
            itemCount: widget.activeProducts.length,
            allowImplicitScrolling: true,
            physics: const ClampingScrollPhysics(),
            padEnds: false,
            controller: _pageController,
            onPageChanged: (int pageIndex) {
              Get.find<FlashSaleController>().setPageIndex(pageIndex);
            },
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.zero,
                child: AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double value = 0.0;
                    if(_pageController.position.haveDimensions){
                      value = index.toDouble() - (_pageController.page ?? 0);
                      value = (value * 0.038).clamp(-1, 1);
                    }
                    return Transform.scale(
                        scale: 1 - (value.abs() * 0.2), // Subtle scale effect
                        child: carouselCard(index, widget.activeProducts[index])
                    );
                  },
                ),
              );
            }),
      ),
    ]);
  }

  Widget carouselCard(int index, ActiveProducts activeProduct) {
    double? discount = activeProduct.item!.discount;
    String? discountType = activeProduct.item!.discountType;
    int sold = activeProduct.sold ?? 0;
    // int stock = activeProduct.stock ?? 0;

    return Container(

      margin: const EdgeInsets.symmetric(horizontal: 1.5, vertical: Dimensions.paddingSizeExtraSmall), // ahmed: Reduced horizontal margin to 1.5
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5)],
        // border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.1)), // ahmed: Removed border to fix "line" issue
      ),
      child: Column(children: [
        // Top Section: Image and Overlays
        Expanded(
          flex: 5, // ahmed: Reduced flex for image to give space but balanced
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusDefault)),
                child: CustomImage(
                  image: '${activeProduct.item!.imageFullUrl}',
                  fit: BoxFit.cover, width: double.infinity, height: double.infinity,
                ),
              ),

              // Top Left: Favorite Icon
              Positioned(
                top: 0, left: 0, // Flush to corner
                child: GetBuilder<FavouriteController>(builder: (favouriteController) {
                  bool isWished = favouriteController.wishItemIdList.contains(activeProduct.item!.id);
                  return InkWell(
                    onTap: () {
                      if(AuthHelper.isLoggedIn()) {
                        isWished ? favouriteController.removeFromFavouriteList(activeProduct.item!.id, false)
                            : favouriteController.addToFavouriteList(activeProduct.item, null, false);
                      }else {
                        showCustomSnackBar('you_are_not_logged_in'.tr);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6), // Increased padding for touch target
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(Dimensions.radiusDefault),
                          topLeft: Radius.circular(Dimensions.radiusDefault), // Match card corner
                        ),
                      ),
                      child: Icon(
                        isWished ? Icons.favorite : Icons.favorite_border,
                        color: Colors.white, size: 18,
                      ),
                    ),
                  );
                }),
              ),

              // Top Right: Share/Link Icon
              Positioned(
                top: 0, right: 0, // Flush to corner
                child: InkWell(
                  onTap: () {
                    String shareUrl = '${AppConstants.webHostedUrl}${RouteHelper.getItemDetailsRoute(activeProduct.item!.id, false)}';
                    if (AuthHelper.isLoggedIn()) {
                      String refCode = Get.find<ProfileController>().userInfoModel?.refCode ?? '';
                      if (refCode.isNotEmpty) {
                        shareUrl = shareUrl.contains('?') ? '$shareUrl&ref=$refCode' : '$shareUrl?ref=$refCode';
                      }
                    }
                    Share.share('${activeProduct.item!.name} \n$shareUrl', subject: activeProduct.item!.name ?? '');
                  }, 
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(Dimensions.radiusDefault),
                        topRight: Radius.circular(Dimensions.radiusDefault), // Match card corner
                      ),
                    ),
                    child: const Icon(Icons.share, color: Colors.white, size: 18),
                  ),
                ),
              ),

              // Bottom: Dynamic Status Bar
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Increased vertical padding
                  color: Theme.of(context).primaryColor,
                  alignment: Alignment.center,
                  height: 30, // Fixed height for animation stability
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                       final inTween = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(animation);
                       final outTween = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(animation);
                       if (child.key == ValueKey<int>(_currentStatusIndex)) {
                         return SlideTransition(position: inTween, child: FadeTransition(opacity: animation, child: child));
                       } else {
                         return SlideTransition(position: outTween, child: FadeTransition(opacity: animation, child: child));
                       }
                    },
                    child: Builder(
                      key: ValueKey<int>(_currentStatusIndex),
                      builder: (context) {
                        // Dynamic Status List
                        List<String> statusList = [];
                        
                        // 1. Store Name
                        if(activeProduct.item?.storeName != null) {
                           statusList.add(activeProduct.item!.storeName!);
                        }
                        
                        // 2. Discount
                        if(activeProduct.item!.discount != null && activeProduct.item!.discount! > 0) {
                          String discount = activeProduct.item!.discountType == 'percent' 
                              ? '${activeProduct.item!.discount}% -' 
                              : '${PriceConverter.convertPrice(activeProduct.item!.discount)} -';
                           statusList.add(discount);
                        }

                        // 3. Selling Fast / Limited Time
                        if(activeProduct.item!.organic == 1) {
                           statusList.add('local_product'.tr);
                        }
                        statusList.add('selling_fast'.tr);
                        statusList.add('limited_time_offer'.tr);

                         String currentText = statusList.isNotEmpty 
                            ? statusList[_currentStatusIndex % statusList.length] 
                            : 'flash_sale'.tr;
                        
                        // Check if theme is Blue-ish
                        Color primary = Theme.of(context).primaryColor;
                        bool isBlueish = primary.blue > primary.red && primary.blue > primary.green;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Builder(
                              builder: (context) {
                                Color primary = Theme.of(context).primaryColor;
                                bool isBlueish = primary.blue > 100 && primary.blue > primary.red && primary.blue > primary.green;
                                
                                return Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: isBlueish ? Colors.transparent : Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check, 
                                    color: isBlueish ? Colors.white : Colors.blue, 
                                    size: 11 // Slightly larger
                                  ), 
                                );
                              }
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                currentText,
                                style: robotoMedium.copyWith(color: Colors.white, fontSize: 11),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        );
                      }
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Bottom Section: Details
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                // Details Column (First in RTL -> Right Side)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activeProduct.item!.name ?? '',
                        style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Rating Row: Sold (Right) --- Divider --- Rating (Left)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${'sold'.tr} $sold', style: robotoRegular.copyWith(fontSize: 12, color: Theme.of(context).primaryColor)),
                          Container(height: 10, width: 1, color: Colors.grey),
                          Row(
                            children: [
                              Text('${activeProduct.item!.avgRating} (${activeProduct.item!.ratingCount})', style: robotoRegular.copyWith(fontSize: 12, color: Colors.grey)),
                              const SizedBox(width: 2),
                              const Icon(Icons.star, color: Colors.amber, size: 14),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                       // Price Row: Old (Right) --- Current --- Discount (Left)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            PriceConverter.convertPrice(
                              Get.find<ItemController>().getStartingPrice(activeProduct.item!), discount: discount,
                              discountType: discountType,
                            ),
                            style: robotoBold.copyWith(fontSize: 16, color: Theme.of(context).primaryColor),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              if(discount != null && discount > 0)
                                Text(
                                  PriceConverter.convertPrice(Get.find<ItemController>().getStartingPrice(activeProduct.item!)),
                                  style: robotoRegular.copyWith(
                                    fontSize: 12, color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              const SizedBox(width: 5),
                              if(discount != null && discount > 0)
                                Text(
                                  discountType == 'percent' ? '-${discount.toInt()}%' : '-${PriceConverter.convertPrice(discount)}',
                                  style: robotoBold.copyWith(color: Colors.red, fontSize: 12),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: Dimensions.paddingSizeSmall), // Increased spacing lightly

                // Cart Icon
                InkWell(
                  onTap: () => Get.find<ItemController>().navigateToItemPage(activeProduct.item, context),
                  child: Container(
                    padding: const EdgeInsets.all(8), // Padding instead of hardcoded size for better touch area
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
