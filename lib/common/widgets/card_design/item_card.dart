import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';

import 'package:sixam_mart/common/widgets/hover/text_hover.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/add_favourite_view.dart';
import 'package:sixam_mart/common/widgets/cart_count_view.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/discount_tag.dart';
import 'package:sixam_mart/common/widgets/hover/on_hover.dart';
import 'package:sixam_mart/common/widgets/not_available_widget.dart';
import 'package:sixam_mart/common/widgets/organic_tag.dart';
import 'package:sixam_mart/common/widgets/store_verified_avatar.dart';
import 'package:sixam_mart/helper/module_icon_helper.dart';
import 'package:sixam_mart/helper/color_converter.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ItemCard extends StatefulWidget {
  final Item? item;
  final Store? store;
  final bool isPopularItem;
  final bool isFood;
  final bool isShop;
  final bool isPopularItemCart;
  final int? index;
  final double? width;
  final bool isCampaign;
  const ItemCard({super.key, this.item, this.store, this.isPopularItem = false, required this.isFood, required this.isShop, this.isPopularItemCart = false, this.index, this.width, this.isCampaign = false});

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  int _currentStatusIndex = 0;
  Timer? _timer;
  int _currentImageIndex = 0;
  final CarouselSliderController _carouselController = CarouselSliderController();
  final math.Random _random = math.Random();
  Duration _statusSwitchDuration = const Duration(milliseconds: 350);

  @override
  void initState() {
    super.initState();
    _scheduleNextStatusTimer();
  }

  void _scheduleNextStatusTimer() {
    final int baseMs = 2500;
    final int halfBaseMs = 1200;
    final Duration nextDelay = Duration(milliseconds: halfBaseMs + _random.nextInt(baseMs));
    _timer = Timer(nextDelay, () {
      if (!mounted) return;
      setState(() {
        _statusSwitchDuration = Duration(milliseconds: 300 + _random.nextInt(400));
        _currentStatusIndex++;
      });
      _scheduleNextStatusTimer();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double? discount = widget.item?.discount;
    String? discountType = widget.item?.discountType;
    double priceValue = widget.item != null ? (Get.find<ItemController>().getStartingPrice(widget.item!) ?? 0) : 0;
    double finalPrice = widget.item != null ? (PriceConverter.convertWithDiscount(priceValue, discount, discountType) ?? 0) : 0;
    bool isAvailable = false;
    bool hasRating = (widget.item != null && (widget.item?.ratingCount ?? 0) > 0) || (widget.store != null && (widget.store?.ratingCount ?? 0) > 0);
    String? badgeText;
    Color? badgeColor;
    IconData? badgeIcon;

    if (widget.item != null) {
      if ((widget.item?.orderCount ?? 0) > 5) {
        badgeText = 'best_seller'.tr;
        badgeColor = Colors.amber.shade800;
        badgeIcon = Icons.stars_rounded;
      } else if ((widget.item?.avgRating ?? 0) >= 4.5 && (widget.item?.ratingCount ?? 0) > 2) {
        badgeText = 'most_loved'.tr;
        badgeColor = Colors.orange;
        badgeIcon = Icons.favorite_rounded;
      } else if ((widget.item?.wishlistCount ?? 0) > 3) {
        badgeText = 'most_liked'.tr;
        badgeColor = Colors.pink;
        badgeIcon = Icons.thumb_up_alt_rounded;
      } else if ((widget.item?.itemViewCount ?? 0) > 10) {
        badgeText = 'most_viewed'.tr;
        badgeColor = Colors.teal;
        badgeIcon = Icons.visibility_rounded;
      }
    }

    if(widget.item != null) {
      isAvailable = Get.find<ItemController>().isAvailable(widget.item!);
    } else if(widget.store != null) {
       isAvailable = widget.store!.open == 1 && (widget.store!.active ?? false);
    }

    return OnHover(
      isItem: true,
      child: Stack(children: [
        Container(
          width: widget.isFood ? 220 : (widget.width ?? 200),
          height: widget.isFood ? 220 : null,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            color: Theme.of(context).cardColor,
          ),
          child: CustomInkWell(
            onTap: () {
               if(widget.item != null) {
                 Get.find<ItemController>().navigateToItemPage(widget.item, context, isCampaign: widget.isCampaign);
               } else if(widget.store != null) {
                  if(widget.isShop) {
                    Get.toNamed(RouteHelper.getStoreRoute(id: widget.store!.id, page: 'store'));
                  } else {
                    Get.toNamed(RouteHelper.getStoreRoute(id: widget.store!.id, page: 'restaurant'));
                  }
               }
            },
            radius: Dimensions.radiusLarge,
            child: TextHover(
              builder: (isHovered) {
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                    flex: widget.isFood ? 6 : 7,
                    child: Stack(children: [
                      Padding(
                        padding: EdgeInsets.only(top: widget.isPopularItem ? Dimensions.paddingSizeExtraSmall : 0, left: widget.isPopularItem ? Dimensions.paddingSizeExtraSmall : 0, right: widget.isPopularItem ? Dimensions.paddingSizeExtraSmall : 0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(Dimensions.radiusLarge),
                            topRight: const Radius.circular(Dimensions.radiusLarge),
                            bottomLeft: Radius.circular(widget.isPopularItem ? Dimensions.radiusLarge : 0),
                            bottomRight: Radius.circular(widget.isPopularItem ? Dimensions.radiusLarge : 0),
                          ),
                          child: (widget.item != null && widget.item!.imagesFullUrl != null && widget.item!.imagesFullUrl!.length > 1) ? Stack(
                            children: [
                              CarouselSlider.builder(
                                carouselController: _carouselController,
                                itemCount: widget.item!.imagesFullUrl!.length,
                                options: CarouselOptions(
                                  viewportFraction: 1,
                                  autoPlay: false,
                                  enlargeCenterPage: false,
                                  height: double.infinity,
                                  onPageChanged: (index, reason) {
                                    setState(() {
                                      _currentImageIndex = index;
                                    });
                                  },
                                ),
                                itemBuilder: (context, index, realIndex) {
                                  return CustomImage(
                                    isHovered: isHovered,
                                    placeholder: Images.defultImage,
                                    image: widget.item!.imagesFullUrl![index],
                                    fit: BoxFit.cover, width: double.infinity, height: double.infinity,
                                  );
                                },
                              ),

                              Positioned(
                                bottom: 5, left: 0, right: 0,
                                child: Center(
                                  child: AnimatedSmoothIndicator(
                                    activeIndex: _currentImageIndex,
                                    count: widget.item!.imagesFullUrl!.length,
                                    effect: ExpandingDotsEffect(
                                      dotHeight: 5, dotWidth: 5,
                                      activeDotColor: Theme.of(context).primaryColor,
                                      dotColor: Theme.of(context).disabledColor.withOpacity(0.5),
                                    ),
                                    onDotClicked: (index) {
                                      _carouselController.animateToPage(index);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ) : CustomImage(
                            isHovered: isHovered,
                            placeholder: Images.defultImage,
                            image: widget.item != null ? '${widget.item!.imageFullUrl}' : '${widget.store!.coverPhotoFullUrl}',
                            fit: BoxFit.cover, width: double.infinity, height: double.infinity,
                          ),
                        ),
                      ),

                      widget.item != null ? AddFavouriteView(
                        item: widget.item!,
                        left: widget.isPopularItem ? Dimensions.paddingSizeExtraSmall : 0,
                        top: widget.isPopularItem ? Dimensions.paddingSizeExtraSmall : 0,
                        right: null,
                        isCorner: true,
                      ) : const SizedBox(), // TODO: Add Favourite view for Store if needed (requires Store wrapper)
                      Positioned(
                        top: 25, right: 0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (badgeText != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                margin: const EdgeInsets.only(bottom: 4),
                                decoration: BoxDecoration(
                                  color: badgeColor,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(badgeIcon, color: Colors.white, size: 10),
                                    const SizedBox(width: 3),
                                    Text(
                                      badgeText,
                                      style: robotoBold.copyWith(color: Colors.white, fontSize: 8),
                                    ),
                                  ],
                                ),
                              ),
                            if (widget.item != null && widget.item!.flashSale == 1)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.flash_on, color: Colors.white, size: 10),
                                    const SizedBox(width: 3),
                                    Text(
                                      'flash_sale'.tr,
                                      style: robotoBold.copyWith(color: Colors.white, fontSize: 8),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      // (widget.item != null && widget.item!.isStoreHalalActive! && widget.item!.isHalalItem!) ? const Positioned(
                      //   top: 40, right: 15,
                      //   child: CustomAssetImageWidget(
                      //     Images.halalTag,
                      //     height: 20, width: 20,
                      //   ),
                   // )
                 //    : const SizedBox(),
                      widget.item != null ? DiscountTag(
                        discount: discount,
                        discountType: discountType,
                        freeDelivery: false,
                        inLeft: false,
                        fromTop: widget.isPopularItem ? Dimensions.paddingSizeExtraSmall : 0,
                        isFloating: false,
                      ) : const SizedBox(),

                      widget.item != null ? OrganicTag(item: widget.item!, placeInImage: true) : const SizedBox(),

                      (widget.item != null && widget.item!.stock != null && widget.item!.stock! < 0) ? Positioned(
                        bottom: 10, left : 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(Dimensions.radiusLarge),
                              bottomRight: Radius.circular(Dimensions.radiusLarge),
                            ),
                          ),
                          child: Text('out_of_stock'.tr, style: robotoRegular.copyWith(color: Theme.of(context).cardColor, fontSize: Dimensions.fontSizeSmall)),
                        ),
                      ) : const SizedBox(),

                     widget.item != null ? Positioned(
                  bottom: 0, 
                  left: 0,
                  child: CartCountView(
                    item: widget.item!,
                    index: widget.index,
                    isCampaign: widget.isCampaign,
                    child: Container(
                      height: 45, 
                      width: 45,
                      decoration: BoxDecoration(
                        // 1. Change shape to circle
                        shape: BoxShape.circle, 
                        color: Theme.of(context).primaryColor,
                        // 2. Remove borderRadius (it will cause an error if shape is circle)
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).cardColor.withValues(alpha: 0.4), 
                            blurRadius: 6, 
                            spreadRadius: 1, 
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(color: Theme.of(context).cardColor),
                      ),
                      child: Icon(
                        ModuleIconHelper.getIcon(Get.find<SplashController>().module?.iconAddToCart, Icons.add), 
                        size: 30, 
                        color: Theme.of(context).cardColor,
                      ),
                    ),
                  ),
                )  : const SizedBox(),

                      isAvailable ? const SizedBox() : NotAvailableWidget(radius: Dimensions.radiusLarge, isAllSideRound: widget.isPopularItem),

                      Builder(builder: (context) {
                        List<Color> colorList = [];
                        int colorOptionCount = 0;
                        if(widget.item != null && widget.item!.choiceOptions != null) {
                          for(var option in widget.item!.choiceOptions!) {
                            if(option.title != null && (option.title!.toLowerCase().contains('color') || option.title!.contains('لون'))) {
                              colorOptionCount = option.options?.length ?? 0;
                              if(option.options != null) {
                                for(var colorStr in option.options!) {
                                  Color? color = ColorConverter.getColorFromOption(colorStr);
                                  if(color != null) {
                                    colorList.add(color);
                                  }
                                }
                              }
                              break;
                            }
                          }
                        }

                        return (colorList.isNotEmpty) ? Positioned(
                          top: 40, left: 10,
                          child: Column(children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              ),
                              child: Column(children: List.generate(colorList.length > 3 ? 3 : colorList.length, (index) {
                                return Container(
                                  height: 12, width: 12,
                                  margin: EdgeInsets.only(bottom: index == (colorList.length > 3 ? 2 : colorList.length - 1) ? 0 : 2),
                                  decoration: BoxDecoration(
                                    color: colorList[index],
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.3), width: 0.5),
                                  ),
                                );
                              })),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              colorOptionCount.toString(),
                              style: robotoRegular.copyWith(fontSize: 10, color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.7)),
                            ),
                          ]),
                        ) : const SizedBox();
                      }),

                    ]),
                  ),

                  Expanded(
                    flex: widget.isFood ? 4 : 4,
                    child: Padding(
                      padding: EdgeInsets.only(left: Dimensions.paddingSizeSmall, right: widget.isShop ? 0 : Dimensions.paddingSizeSmall, top: Dimensions.paddingSizeExtraSmall, bottom: widget.isShop ? 0 : Dimensions.paddingSizeExtraSmall),
                      child: Stack(clipBehavior: Clip.none, children: [

                        Align(
                          alignment: widget.isPopularItem ? Alignment.center : Alignment.centerLeft,
                              child: widget.isFood ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(

                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Icon(Icons.check_circle, color: Colors.blue, size: 16),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                widget.item != null ? widget.item!.name ?? '' : widget.store!.name ?? '',
                                                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall),
                                                maxLines: 1, overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: Dimensions.paddingSizeSmall),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isAvailable ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                          border: Border.all(color: isAvailable ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5)),
                                        ),
                                        child: Text(
                                          isAvailable ? 'available'.tr : 'closed'.tr,
                                          style: robotoMedium.copyWith(color: isAvailable ? Colors.green : Colors.red, fontSize: 10),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                  Row(
                                    children: [
                                      StoreVerifiedAvatar(
                                         imageUrl: widget.item?.storeLogoFullUrl ?? widget.store?.logoFullUrl ?? (widget.item?.storeDetails != null ? widget.item?.storeDetails!['logo_full_url'] : null),
                                         isVerified: (widget.item?.verifiedSeller == 1) || (widget.store?.verifiedSeller == 1) || (widget.item?.storeDetails?['verified_seller'] == 1) || (widget.item?.storeDetails?['verified_seller'] == '1') || (widget.item?.storeDetails?['verified_seller'] == true),
                                         size: 14,
                                       ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          widget.item != null ? widget.item!.storeName ?? '' : widget.store!.name ?? '',
                                          style: robotoRegular.copyWith(fontSize: 10, color: Theme.of(context).disabledColor),
                                          textAlign: TextAlign.right,
                                          maxLines: 1, overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (hasRating) ...[
                                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                        Container(height: 10, width: 1, color: Theme.of(context).disabledColor.withOpacity(0.3)),
                                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                        Container(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                '(${widget.item != null ? widget.item!.ratingCount : widget.store!.ratingCount}) ${widget.item != null ? widget.item!.avgRating!.toStringAsFixed(1) : widget.store!.avgRating!.toStringAsFixed(1)}',
                                                style: robotoRegular.copyWith(fontSize: 10, color: Theme.of(context).disabledColor),
                                              ),
                                              const SizedBox(width: 2),
                                              Icon(Icons.star, color: Colors.amber, size: 12),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                        Container(height: 10, width: 1, color: Theme.of(context).disabledColor.withOpacity(0.3)),
                                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                      ],
                                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                      Text(
                                        PriceConverter.convertPrice(finalPrice),
                                        style: robotoBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall),
                                      ),
                                    ],
                                  ),
                                ],
                              ) : Column(
                                  crossAxisAlignment:  CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    StoreVerifiedAvatar(
                                       imageUrl: widget.item?.storeLogoFullUrl ?? widget.store?.logoFullUrl ?? (widget.item?.storeDetails != null ? widget.item?.storeDetails!['logo_full_url'] : null),
                                       isVerified: (widget.item?.verifiedSeller == 1) || (widget.store?.verifiedSeller == 1) || (widget.item?.storeDetails?['verified_seller'] == 1) || (widget.item?.storeDetails?['verified_seller'] == '1') || (widget.item?.storeDetails?['verified_seller'] == true),
                                       size: 16,
                                     ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        widget.item != null ? (widget.item!.storeName ?? '') : (widget.store!.name ?? ''),
                                        style: robotoBold.copyWith(fontSize: 12, color: Theme.of(context).secondaryHeaderColor),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(), // Optional spacing between rows
                                Padding(
                                  padding: const EdgeInsets.only(right: Dimensions.paddingSizeExtraSmall),
                                  child: Directionality(textDirection: TextDirection.rtl, child: Text(widget.item != null ? widget.item!.name ?? '' : widget.store!.name ?? '', style: robotoBold, maxLines: 1, overflow: TextOverflow.ellipsis)),
                                ),

                                // (widget.isFood || widget.isShop) ? Flexible(
                                //   child: Directionality(
                                //     textDirection: TextDirection.rtl,
                                //     child: Text(
                                //       widget.item != null ? widget.item!.name ?? '' : widget.store!.name ?? '',
                                //       style: robotoBold, maxLines: 1, overflow: TextOverflow.ellipsis,
                                //     ),
                                //   ),
                                // ) : Row(
                                //   textDirection: TextDirection.rtl,
                                //   mainAxisAlignment: widget.isPopularItem ? MainAxisAlignment.center : MainAxisAlignment.start,
                                //   children: [
                                //     (widget.item != null && widget.item!.ratingCount! > 0) || (widget.store != null && widget.store!.ratingCount! > 0) ? Row(
                                //         textDirection: TextDirection.rtl,
                                //         mainAxisAlignment: widget.isPopularItem ? MainAxisAlignment.center : MainAxisAlignment.start,
                                //         children: [
                                //           Icon(ModuleIconHelper.getIcon(Get.find<SplashController>().module?.iconRating, Icons.star), size: 14, color: Theme.of(context).primaryColor),
                                //           const SizedBox(width: Dimensions.paddingSizeExtraSmall),
          
                                //           Text(widget.item != null ? widget.item!.avgRating!.toStringAsFixed(1) : widget.store!.avgRating!.toStringAsFixed(1), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                                //           const SizedBox(width: Dimensions.paddingSizeExtraSmall),
          
                                //           Text("(${widget.item != null ? widget.item!.ratingCount : widget.store!.ratingCount})", style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                                //         ],
                                //     ) : const SizedBox(),

                                //     SizedBox(width: (widget.item != null && widget.item!.ratingCount! > 0 && widget.item!.unitType != null) ? Dimensions.paddingSizeExtraSmall : 0),

                                //     (Get.find<SplashController>().configModel!.moduleConfig!.module!.unit! && widget.item != null && widget.item!.unitType != null) ? Text(
                                //       '(${ widget.item!.unitType ?? ''})',
                                //       style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                                //     ) : const SizedBox(),
                                //   ],
                                // ),
    
                                // showUnitOrRattings(context);
                                /*Row(
                                  textDirection: TextDirection.rtl,
                                  mainAxisAlignment: widget.isPopularItem ? MainAxisAlignment.center : MainAxisAlignment.start,
                                  children: [
                                    (widget.isFood || widget.isShop) ? (widget.item != null && widget.item!.ratingCount! > 0) || (widget.store != null && widget.store!.ratingCount! > 0) ? Row(
                                      textDirection: TextDirection.rtl,
                                      mainAxisAlignment: widget.isPopularItem ? MainAxisAlignment.center : MainAxisAlignment.start,
                                      children: [
                                        Icon(ModuleIconHelper.getIcon(Get.find<SplashController>().module?.iconRating, Icons.star), size: 14, color: Theme.of(context).primaryColor),
                                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
        
                                        Text(widget.item != null ? widget.item!.avgRating!.toStringAsFixed(1) : widget.store!.avgRating!.toStringAsFixed(1), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
        
                                        Text("(${widget.item != null ? widget.item!.ratingCount : widget.store!.ratingCount})", style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
        
                                      ],
                                    ) : const SizedBox() : const SizedBox(),
                                  ],
                                ),*/
                                if(!widget.isFood)
                                Builder(
                                    builder: (context) {
                                      List<Map<String, dynamic>> statusList = [];

                                      // Ratings
                                      int ratingCount = widget.item != null ? (widget.item?.ratingCount ?? 0) : (widget.store?.ratingCount ?? 0);
                                      double avgRating = widget.item != null ? (widget.item?.avgRating ?? 0.0) : (widget.store?.avgRating ?? 0.0);

                                      if (ratingCount > 0) {
                                        statusList.add({
                                          'text': '${avgRating.toStringAsFixed(1)} ($ratingCount)',
                                          'icon': Icons.star,
                                          'color': Colors.amber,
                                        });
                                      }

                                      // Store Name
                                      if (widget.item?.storeName?.isNotEmpty ?? false) {
                                        statusList.add({'text': widget.item!.storeName!, 'icon': Icons.store, 'color': Colors.blue});
                                      }

                                      bool isStoreOpen = widget.item != null 
                                          ? DateConverter.isAvailable(widget.item!.availableTimeStarts, widget.item!.availableTimeEnds) 
                                          : (widget.store?.open == 1 && widget.store?.active == true);
                                      
                                       statusList.add({
                                        'text': isStoreOpen ? 'open'.tr : 'closed'.tr,
                                         'icon': Icons.circle,
                                        'color': isStoreOpen ? Colors.green : Colors.red
                                       });

                                      if (widget.item?.deliveryTime?.isNotEmpty ?? false) {
                                        statusList.add({'text': widget.item!.deliveryTime!.replaceAll('min', 'min'.tr), 'icon': Icons.bolt, 'color': Colors.orange});
                                      }

                                      if (widget.item?.discount != null && (widget.item?.discount ?? 0) > 0) {
                                        bool isLtr = Get.find<LocalizationController>().isLtr;
                                        double disc = widget.item!.discount!;
                                        String percentStr = '${disc == disc.truncate() ? disc.truncate() : disc}%';
                                        
                                        statusList.add({
                                          'text': widget.item!.discountType == 'percent' 
                                              ? (!isLtr ? '${'off'.tr} $percentStr' : '$percentStr ${'off'.tr}') 
                                              : (!isLtr ? '${'off'.tr} ${PriceConverter.convertPrice(disc)}' : '${PriceConverter.convertPrice(disc)} ${'off'.tr}'), 
                                          'icon': Icons.local_offer, 
                                          'color': Colors.pinkAccent
                                        });
                                        statusList.add({
                                          'text': 'special_offer'.tr, 
                                          'icon': Icons.stars_rounded,
                                          'color': Colors.amber,
                                        });
                                      }
                                            

                                      // Order Count
                                      if(widget.item != null && (widget.item?.orderCount ?? 0) > 0) {
                                        statusList.add({
                                          'text': '${widget.item!.orderCount} ${'orders'.tr}', 
                                          'icon': Icons.shopping_bag_outlined, 
                                          'color': Colors.deepPurpleAccent,
                                        });
                                      }

                                    // View Count
                                    if(widget.item != null && widget.item!.itemViewCount != null && widget.item!.itemViewCount! > 0) {
                                      statusList.add({
                                        'text': '${widget.item!.itemViewCount} ${'views'.tr}', 
                                        'icon': Icons.visibility_outlined, 
                                        'color': Colors.teal, // Modern Teal
                                      });
                                    }

                                    // Wishlist Count
                                  if(widget.item != null && widget.item!.wishlistCount != null && widget.item!.wishlistCount! > 0) {
                                    statusList.add({
                                      'text': '${widget.item!.wishlistCount} ${'favorites'.tr}', 
                                      'icon': Icons.favorite_border, 
                                      'color': Colors.redAccent, // Classic Love Red
                                    });
                                  }

                                      if (widget.item != null) {
                                        if (widget.item!.orderCount != null && widget.item!.orderCount! > 10) {
                                          statusList.add({
                                            'text': 'best_seller'.tr,
                                            'icon': Icons.stars_rounded,
                                            'color': Colors.amber.shade800,
                                          });
                                        } else if (widget.item!.avgRating != null && widget.item!.avgRating! >= 4.5 && (widget.item!.ratingCount ?? 0) > 2) {
                                          statusList.add({
                                            'text': 'most_loved'.tr,
                                            'icon': Icons.favorite_rounded,
                                            'color': Colors.orange,
                                          });
                                        } else if (widget.item!.wishlistCount != null && widget.item!.wishlistCount! > 5) {
                                          statusList.add({
                                            'text': 'most_liked'.tr,
                                            'icon': Icons.thumb_up_alt_rounded,
                                            'color': Colors.pink,
                                          });
                                        } else if (widget.item!.itemViewCount != null && widget.item!.itemViewCount! > 3) {
                                          statusList.add({
                                            'text': 'most_viewed'.tr,
                                            'icon': Icons.visibility_rounded,
                                            'color': Colors.teal,
                                          });
                                        }
                                      }

                                      if (statusList.isEmpty) return const SizedBox();

                           // The Modern Animated Container
                          return Padding(
                            padding: const EdgeInsets.only(right: Dimensions.paddingSizeExtraSmall),
                            child: Container(
                              height: 30,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              alignment: AlignmentDirectional.centerStart,
                              child: AnimatedSize(
                                duration: const Duration(milliseconds: 350),
                                alignment: AlignmentDirectional.centerStart,
                                curve: Curves.easeInOutCubic,
                                child: AnimatedSwitcher(
                                  duration: _statusSwitchDuration, 
                                  switchInCurve: Curves.easeInOutCubic,        
                                  switchOutCurve: Curves.easeInOutCubic,  
                                  layoutBuilder: (
                                    Widget? currentChild,
                                    List<Widget> previousChildren,
                                  ) {
                                    return Stack(
                                      alignment: AlignmentDirectional.centerStart,
                                      children: [
                                        ...previousChildren,
                                        if (currentChild != null) currentChild,
                                      ],
                                    );
                                  },     
                                  transitionBuilder: (Widget child, Animation<double> animation) {
                                    return SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0, 0.2),            
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: FadeTransition(
                                        opacity: animation, 
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: Container(
                                    key: ValueKey<int>(_currentStatusIndex),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: (statusList[_currentStatusIndex % statusList.length]['color'] as Color).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: (statusList[_currentStatusIndex % statusList.length]['color'] as Color).withOpacity(0.3),
                                        width: 1,
                                      ),
                                      // Multi-layered shadows create a 3D "extruded" look
                                      boxShadow: [
                                        // Outer soft ambient shadow
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                        // Inner light highlight for a 3D glass edge
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.5),
                                          blurRadius: 4,
                                          offset: const Offset(-1, -1),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // 3D Styled Icon Effect using stacked shadows
                                        Stack(
                                          children: [
                                            // The 3D Dark Shadow Layer behind the icon
                                            Positioned(
                                              top: 1.5,
                                              left: 0.5,
                                              child: Icon(
                                                statusList[_currentStatusIndex % statusList.length]['icon'],
                                                color: (statusList[_currentStatusIndex % statusList.length]['color'] as Color).withOpacity(0.4),
                                                size: 14,
                                              ),
                                            ),
                                            // The Main Front Icon Layer
                                            Icon(
                                              statusList[_currentStatusIndex % statusList.length]['icon'],
                                              color: statusList[_currentStatusIndex % statusList.length]['color'],
                                              size: 14,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 6),
                                        Flexible( 
                                          child: Text(
                                            statusList[_currentStatusIndex % statusList.length]['text'],
                                            style: robotoMedium.copyWith(
                                              fontSize: Dimensions.fontSizeSmall,
                                              color: Theme.of(context).textTheme.bodyLarge?.color,
                                              fontWeight: FontWeight.w700, // Slightly bolder text holds up better against 3D elements
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
             
                                    },
                                  ),
                             if(!widget.isFood)
                                Padding(
                                  padding: const EdgeInsets.only(right: Dimensions.paddingSizeExtraSmall),
                                  child: Align(
                            alignment:Alignment.centerRight ,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end, // Aligns bottoms of text perfectly
                              children: [
                                // --- Original Price (Discounted) ---
                                if (discount != null && discount > 0)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 2), // Lift it slightly for better baseline
                                    child: Text(
                                      PriceConverter.convertPrice(Get.find<ItemController>().getStartingPrice(widget.item!)),
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        color: Theme.of(context).disabledColor.withOpacity(0.6),
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ),

                                if (discount != null && discount > 0) const SizedBox(width: 6),

                                // --- Main Price ---
                                widget.item != null ? Builder(
                                  builder: (context) {
                                    double priceValue = Get.find<ItemController>().getStartingPrice(widget.item!) ?? 0;
                                    double finalPrice = PriceConverter.convertWithDiscount(priceValue, discount, discountType) ?? 0;
                                    bool isRightSide = Get.find<SplashController>().configModel!.currencySymbolDirection == 'right';
                                    String currencySymbol = Get.find<SplashController>().configModel!.currencySymbol!;

                                    String formattedPrice = PriceConverter.toFixed(finalPrice)
                                        .toStringAsFixed(Get.find<SplashController>().configModel!.digitAfterDecimalPoint!)
                                        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');

                                    return Text.rich(
                                      TextSpan(
                                        children: [
                                          if (!isRightSide)
                                            TextSpan(
                                              text: currencySymbol,
                                              style: robotoMedium.copyWith(
                                                fontSize: Dimensions.fontSizeSmall, 
                                                color: Theme.of(context).primaryColor,
                                              ),
                                            ),
                                          
                                          TextSpan(
                                            text: formattedPrice,
                                            style: robotoBlack.copyWith(
                                              fontSize: 16, // Slightly larger for that "Modern Bold" look
                                              color: Theme.of(context).primaryColor,
                                              letterSpacing: -0.5, // Tighter letters look more modern
                                            ),
                                          ),

                                          if (isRightSide)
                                            TextSpan(
                                              text: ' $currencySymbol',
                                              style: robotoMedium.copyWith(
                                                fontSize: Dimensions.fontSizeSmall, 
                                                color: Theme.of(context).primaryColor,
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                ) : const SizedBox(),
                              ],
                            ),
                          ),
                                ),
                                
                              ]),
                        ),

                         const SizedBox(),
                      ]),
                    ),
                  ),
                ]);
              },
            ),
          ),
        ),
      ]),
    );
  }
}