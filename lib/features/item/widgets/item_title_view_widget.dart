import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_asset_image_widget.dart';
import 'package:sixam_mart/common/widgets/custom_tool_tip_widget.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/favourite/controllers/favourite_controller.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/organic_tag.dart';
import 'package:sixam_mart/common/widgets/rating_bar.dart';
import 'package:sixam_mart/features/review/widgets/review_widget.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/features/contact_share/screens/contact_share_sheet.dart';

class ItemTitleViewWidget extends StatefulWidget {
  final Item? item;
  final bool inStorePage;
  final bool isCampaign;
  final bool inStock;
  final Function()? clickableRating;
  final double? price;
  const ItemTitleViewWidget({super.key, required this.item,  this.inStorePage = false, this.isCampaign = false, required this.inStock, this.clickableRating, this.price});

  @override
  State<ItemTitleViewWidget> createState() => _ItemTitleViewWidgetState();
}

class _ItemTitleViewWidgetState extends State<ItemTitleViewWidget> {
  final bool _showReviews = false;
  int _currentStatusIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _disposeTimer() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _disposeTimer();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _currentStatusIndex++;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print(widget.inStock ? 'out_of_stock'.tr : 'in_stock'.tr);
    }
    final bool isLoggedIn = AuthHelper.isLoggedIn();
    double? startingPrice;
    double? endingPrice;
    if(widget.item != null && widget.item!.variations != null && widget.item!.variations!.isNotEmpty) {
      List<double?> priceList = [];
      for (var variation in widget.item!.variations!) {
        priceList.add(variation.price);
      }
      priceList.sort((a, b) => a!.compareTo(b!));
      startingPrice = priceList[0];
      if(priceList[0]! < priceList[priceList.length-1]!) {
        endingPrice = priceList[priceList.length-1];
      }
    }else {
      startingPrice = widget.item!.price;
    }

    double? discount = widget.item?.discount;
    String? discountType = widget.item?.discountType;

    return ResponsiveHelper.isDesktop(context) ? GetBuilder<ItemController>(builder: (itemController){
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        InkWell(
          onTap: () {
            if(widget.inStorePage) {
              Get.back();
            }else {
              Get.offNamed(RouteHelper.getStoreRoute(id: widget.item!.storeId, page: 'item'));
            }
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 5, 5, 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.item?.storeName ?? '',
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                ),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                Container(
                  width: 20, height: 20,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).primaryColor),
                  padding: const EdgeInsets.all(2),
                  child: ClipRRect(borderRadius: BorderRadius.circular(100), child: const Icon(Icons.store, size: 16, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

        Row(children: [
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    widget.item?.name ?? '',
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeOverLarge),
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: (widget.item?.isStoreHalalActive ?? false) && (widget.item?.isHalalItem ?? false) ? Dimensions.paddingSizeSmall : 0),

                (widget.item?.isStoreHalalActive ?? false) && (widget.item?.isHalalItem ?? false) ? CustomToolTip(
                  message: 'this_is_a_halal_food'.tr,
                  preferredDirection: AxisDirection.up,
                  child: const CustomAssetImageWidget(Images.halalTag, height: 35, width: 35),
                ) : const SizedBox(),

                const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                ((Get.find<SplashController>().configModel!.moduleConfig!.module!.unit! && widget.item!.unitType != null)
                || (Get.find<SplashController>().configModel!.moduleConfig!.module!.vegNonVeg! && Get.find<SplashController>().configModel!.toggleVegNonVeg!)) ? Text(
                  Get.find<SplashController>().configModel!.moduleConfig!.module!.unit! ? '(${widget.item!.unitType})'
                      : widget.item!.veg == 0 ? '(${'non_veg'.tr})' : '(${'veg'.tr})',
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                ) : const SizedBox(),
              ],
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          widget.item!.availableTimeStarts != null ? const SizedBox() : Container(
            padding: const EdgeInsets.all(8), alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ),
            child: GetBuilder<FavouriteController>(
                builder: (favouriteController) {
                  return InkWell(
                    onTap: () {
                      if(AuthHelper.isLoggedIn()){
                        if(favouriteController.wishItemIdList.contains(widget.item?.id)) {
                          favouriteController.removeFromFavouriteList(widget.item?.id, false);
                        }else {
                          favouriteController.addToFavouriteList(widget.item, null, false);
                        }
                      }else {
                        showCustomSnackBar('you_are_not_logged_in'.tr);
                      }
                    },
                    child: Icon(
                      favouriteController.wishItemIdList.contains(widget.item?.id) ? Icons.favorite : Icons.favorite_border, size: 25,
                      color: Theme.of(context).primaryColor,
                    ),
                  );
                }
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Container(
            padding: const EdgeInsets.all(8), alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ),
            child: InkWell(
              onTap: () {
                String shareUrl = '${AppConstants.webHostedUrl}${RouteHelper.getItemDetailsRoute(widget.item?.id ?? 0, widget.inStorePage)}';
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (con) => ContactShareSheet(
                    shareableType: 'item',
                    shareableId: widget.item?.id ?? 0,
                    shareableName: widget.item?.name ?? '',
                    shareUrl: shareUrl,
                  ),
                );
              },
              child: Icon(Icons.share, size: 25, color: Theme.of(context).primaryColor),
            ),
          ),
        ]),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

        Builder(
          builder: (context) {
            List<Map<String, dynamic>> statusList = [];
            try {
              if (widget.item != null) {
                bool isStoreOpen = DateConverter.isAvailable(widget.item!.availableTimeStarts, widget.item!.availableTimeEnds);
                statusList.add({'text': isStoreOpen ? 'open'.tr : 'closed'.tr, 'icon': Icons.access_time});
                
                if (widget.item!.deliveryTime != null && widget.item!.deliveryTime!.isNotEmpty) {
                  statusList.add({'text': '${'delivery_time'.tr}: ${widget.item!.deliveryTime!.replaceAll('min', 'min'.tr).replaceAll('mins', 'mins'.tr)}', 'icon': Icons.delivery_dining});
                }
                if (widget.item!.organic == 1) {
                   statusList.add({'text': 'local_product'.tr, 'icon': Icons.local_florist});
                }
                if (widget.item!.discount != null && widget.item!.discount! > 0) {
                  statusList.add({'text': widget.item!.discountType == 'percent' ? '${widget.item!.discount!}% ${'off'.tr}' : '${PriceConverter.convertPrice(widget.item!.discount!)} ${'off'.tr}', 'icon': Icons.discount});
                }
                if (widget.item!.orderCount != null && widget.item!.orderCount! > 0) {
                  statusList.add({'text': '${widget.item!.orderCount} ${'orders'.tr}', 'icon': Icons.shopping_cart});
                }
                if (widget.item!.itemViewCount != null && widget.item!.itemViewCount! > 0) {
                  statusList.add({'text': '${widget.item!.itemViewCount} ${'views'.tr}', 'icon': Icons.remove_red_eye});
                }
                 if (widget.item!.wishlistCount != null && widget.item!.wishlistCount! > 0) {
                  statusList.add({'text': '${widget.item!.wishlistCount} ${'favorites'.tr}', 'icon': Icons.favorite});
                }
              }
            } catch (e) {
              print('Error preparing status list: $e');
            }
            
            if (statusList.isEmpty) statusList.add({'text': '', 'icon': Icons.error}); // Fallback to avoid hidden

            if (statusList.length == 1 && statusList[0]['text'] == '') return const SizedBox();

            return Align(
              alignment: Alignment.centerRight,
              child: Container(
                height: 24,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                margin: const EdgeInsets.symmetric(vertical: 1),
                decoration: BoxDecoration(
                  color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                     return FadeTransition(opacity: animation, child: child);
                  },
                  child: Row(
                    key: ValueKey<int>(_currentStatusIndex),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                       Icon(statusList[_currentStatusIndex % statusList.length]['icon'], color: Theme.of(context).primaryColor, size: 14),
                       const SizedBox(width: 4),
                       Flexible(child: Text(
                          statusList[_currentStatusIndex % statusList.length]['text'],
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                       )),
                    ],
                  ),
                ),
              ),
            );
          }
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        (itemController.item!.genericName != null && itemController.item!.genericName!.isNotEmpty) ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(children: List.generate(itemController.item!.genericName!.length, (index) {
              return Text(
                '${itemController.item!.genericName![index]}${itemController.item!.genericName!.length-1 == index ? '.' : ', '}',
                style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha: 0.5)),
              );
            })),
            const SizedBox(height: Dimensions.paddingSizeLarge),
          ],
        ) : const SizedBox(),
        SizedBox(height: (itemController.item!.genericName != null && itemController.item!.genericName!.isNotEmpty) ? Dimensions.paddingSizeSmall : 0),

        (widget.item?.moduleId == 1) ? const SizedBox() : Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall, vertical: 3),
            decoration: BoxDecoration(
              color: widget.inStock ? Colors.red.shade50 : Colors.green.shade50, borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ),
            child: Text(widget.inStock ? 'out_of_stock'.tr : 'in_stock'.tr, style: robotoRegular.copyWith(
              color: Theme.of(context).disabledColor,
              fontSize: Dimensions.fontSizeOverSmall,
            )),
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault),

          OrganicTag(item: widget.item!, fromDetails: true),
        ]),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        if((widget.item?.ratingCount ?? 0) > 0)
          RatingBar(rating: widget.item?.avgRating, ratingCount: widget.item?.ratingCount, size: 15),
        SizedBox(height: (widget.item?.ratingCount ?? 0) > 0 ? Dimensions.paddingSizeExtraSmall : 0),

        Row(children: [
          discount! > 0 ? Flexible(
            child: Text(
              '${PriceConverter.convertPrice(startingPrice)}'
                  '${endingPrice!= null ? ' - ${PriceConverter.convertPrice(endingPrice)}' : ''}',
              textDirection: TextDirection.ltr,
              style: robotoRegular.copyWith(
                color: Theme.of(context).disabledColor, decoration: TextDecoration.lineThrough,
                fontSize: Dimensions.fontSizeExtraSmall,
              ),
            ),
          ) : const SizedBox(),
          SizedBox(width: discount > 0 ? 10 : 0),

          Text(
            '${PriceConverter.convertPrice(startingPrice, discount: discount, discountType: discountType)}'
                '${endingPrice!= null ? ' - ${PriceConverter.convertPrice(endingPrice, discount: discount, discountType: discountType)}' : ''}',
            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge), textDirection: TextDirection.ltr,
          ),
        ]),

      ]);
    }) : Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      child: GetBuilder<ItemController>(
        builder: (itemController) {
          // Check if item has reviews if we are showing them
          // Note: item_model has been updated to include List<ReviewModel>? reviews
           
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            
            Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Start side (Name & Rating)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item?.name ?? '',
                          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                          maxLines: 2, overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                        if ((widget.item?.ratingCount ?? 0) > 0)
                          RatingBar(rating: widget.item?.avgRating, ratingCount: widget.item?.ratingCount, size: 12),
                        
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                        Row(children: [
                          if(widget.item?.unitType != null)
                            Text(
                              widget.item?.unitType ?? '',
                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                            ),
                          if(widget.item?.unitType != null) const SizedBox(width: 10),
                          Text(
                             widget.inStock ? 'out_of_stock'.tr : 'in_stock'.tr,
                             style: robotoRegular.copyWith(color: widget.inStock ? Theme.of(context).colorScheme.error : Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall),
                          ),
                        ]),
                      ],
                    ),
                  ),

                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  // End side (Price & Status)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        widget.price != null 
                            ? PriceConverter.convertPrice(widget.price)
                            : '${PriceConverter.convertPrice(startingPrice, discount: discount, discountType: discountType)}'
                                '${endingPrice!= null ? ' - ${PriceConverter.convertPrice(endingPrice, discount: discount, discountType: discountType)}' : ''}',
                        style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                        textDirection: TextDirection.rtl,
                      ),
                      
                      if (discount != null && discount > 0) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${PriceConverter.convertPrice(startingPrice)}'
                              '${endingPrice!= null ? ' - ${PriceConverter.convertPrice(endingPrice)}' : ''}',
                          style: robotoRegular.copyWith(
                            color: Theme.of(context).disabledColor, 
                            decoration: TextDecoration.lineThrough,
                            fontSize: Dimensions.fontSizeExtraSmall,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                      
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      Builder(
                        builder: (context) {
                          List<Map<String, dynamic>> statusList = [];
                          try {
                            if (widget.item != null) {
                              bool isStoreOpen = DateConverter.isAvailable(widget.item!.availableTimeStarts, widget.item!.availableTimeEnds);
                              statusList.add({'text': isStoreOpen ? 'open'.tr : 'closed'.tr, 'icon': Icons.access_time});
                              
                              if (widget.item!.deliveryTime != null && widget.item!.deliveryTime!.isNotEmpty) {
                                statusList.add({'text': '${'delivery_time'.tr}: ${widget.item!.deliveryTime!.replaceAll('min', 'min'.tr).replaceAll('mins', 'mins'.tr)}', 'icon': Icons.delivery_dining});
                              }
                              if (widget.item!.organic == 1) {
                                 statusList.add({'text': 'local_product'.tr, 'icon': Icons.local_florist});
                              }
                              if (widget.item!.discount != null && widget.item!.discount! > 0) {
                                statusList.add({'text': widget.item!.discountType == 'percent' ? '${widget.item!.discount!}% ${'off'.tr}' : '${PriceConverter.convertPrice(widget.item!.discount!)} ${'off'.tr}', 'icon': Icons.discount});
                              }
                              if (widget.item!.orderCount != null && widget.item!.orderCount! > 0) {
                                statusList.add({'text': '${widget.item!.orderCount} ${'orders'.tr}', 'icon': Icons.shopping_cart});
                              }
                              if (widget.item!.itemViewCount != null && widget.item!.itemViewCount! > 0) {
                                statusList.add({'text': '${widget.item!.itemViewCount} ${'views'.tr}', 'icon': Icons.remove_red_eye});
                              }
                               if (widget.item!.wishlistCount != null && widget.item!.wishlistCount! > 0) {
                                statusList.add({'text': '${widget.item!.wishlistCount} ${'favorites'.tr}', 'icon': Icons.favorite});
                              }
                            }
                          } catch (e) {
                            print('Error preparing status list: $e');
                          }
                          
                          if (statusList.isEmpty) statusList.add({'text': '', 'icon': Icons.error}); // Fallback to avoid hidden

                          if (statusList.length == 1 && statusList[0]['text'] == '') return const SizedBox();

                          return Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              height: 24,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(
                                color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                transitionBuilder: (Widget child, Animation<double> animation) {
                                   return FadeTransition(opacity: animation, child: child);
                                },
                                child: Row(
                                  key: ValueKey<int>(_currentStatusIndex),
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                     Icon(statusList[_currentStatusIndex % statusList.length]['icon'], color: Theme.of(context).primaryColor, size: 14),
                                     const SizedBox(width: 4),
                                     Flexible(child: Text(
                                        statusList[_currentStatusIndex % statusList.length]['text'],
                                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                                        maxLines: 1, overflow: TextOverflow.ellipsis,
                                     )),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                      ),
                    ],
                  ),
                ],
              ),

            const SizedBox(height: Dimensions.paddingSizeSmall),

            // Generic Name
            (widget.item?.genericName != null && widget.item!.genericName!.isNotEmpty) ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(children: List.generate(widget.item!.genericName!.length, (index) {
                  return Text(
                    '${widget.item!.genericName![index]}${widget.item!.genericName!.length-1 == index ? '.' : ', '}',
                    style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha: 0.5)),
                  );
                })),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              ],
            ) : const SizedBox(),



            // Expandable Reviews Section
            if(_showReviews && widget.item?.reviews != null) ...[
              const SizedBox(height: Dimensions.paddingSizeDefault),
              const Divider(),
              Text('reviews'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
               const SizedBox(height: Dimensions.paddingSizeSmall),
               ListView.builder(
                 shrinkWrap: true,
                 physics: const NeverScrollableScrollPhysics(),
                 itemCount: widget.item!.reviews!.length,
                 itemBuilder: (context, index) {
                   return ReviewWidget(review: widget.item!.reviews![index], hasDivider: index != widget.item!.reviews!.length - 1, item: widget.item);
                 }
               )
            ] else if (_showReviews) ...[
               const SizedBox(height: Dimensions.paddingSizeDefault),
               Center(child: Text('no_reviews_found'.tr, style: robotoRegular)),
            ]

          ]);
        },
      ),
    );
  }
}
