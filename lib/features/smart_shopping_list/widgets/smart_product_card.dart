import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/discount_tag.dart';
import 'package:sixam_mart/common/widgets/item_bottom_sheet.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class SmartProductCard extends StatelessWidget {
  final Item item;
  const SmartProductCard({super.key, required this.item});

  void _openItemSheet(BuildContext context) {
    if (item.id == null) return;
    if (ResponsiveHelper.isDesktop(context)) {
      Get.dialog(Dialog(child: ItemBottomSheet(itemId: item.id!, item: item, inStorePage: false)));
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (con) => ItemBottomSheet(itemId: item.id!, item: item, inStorePage: false),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    double? discount = item.discount;
    String? discountType = item.discountType;

    return GetBuilder<CartController>(builder: (cartController) {
      int cartQty = 0;
      for (var c in cartController.cartList) {
        if (c.item?.id == item.id) {
          cartQty += (c.quantity ?? 1);
        }
      }

      return Container(
        width: 170,
        margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall, bottom: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: cartQty > 0
                ? Theme.of(context).primaryColor
                : (isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.06)),
            width: cartQty > 0 ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: cartQty > 0
                  ? Theme.of(context).primaryColor.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Get.toNamed(RouteHelper.getItemDetailsRoute(item.id, false));
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image with Discount and Store Badge
                  Expanded(
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CustomImage(
                            image: item.imageFullUrl ?? '',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                        if (discount != null && discount > 0)
                          Positioned(
                            top: 6,
                            left: 6,
                            child: DiscountTag(
                              discount: discount,
                              discountType: discountType,
                              freeDelivery: false,
                            ),
                          ),
                        if (item.storeName != null && item.storeName!.isNotEmpty)
                          Positioned(
                            bottom: 6,
                            right: 6,
                            left: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item.storeName!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: robotoRegular.copyWith(
                                  color: Colors.white,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Item Name
                  Text(
                    item.name ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                  ),

                  if (item.unitType != null && item.unitType!.isNotEmpty)
                    Text(
                      '(${item.unitType})',
                      maxLines: 1,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall - 1,
                        color: Theme.of(context).disabledColor,
                      ),
                    ),

                  const SizedBox(height: 6),

                  // Price & Add to Cart Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              PriceConverter.convertPrice(item.price, discount: discount, discountType: discountType),
                              style: robotoBold.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            if (discount != null && discount > 0)
                              Text(
                                PriceConverter.convertPrice(item.price),
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeExtraSmall - 1,
                                  color: Theme.of(context).disabledColor,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Add to Cart Button
                      InkWell(
                        onTap: () => _openItemSheet(context),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: cartQty > 0
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                cartQty > 0 ? Icons.check : Icons.add_shopping_cart_rounded,
                                size: 16,
                                color: cartQty > 0 ? Colors.white : Theme.of(context).primaryColor,
                              ),
                              if (cartQty > 0) ...[
                                const SizedBox(width: 4),
                                Text(
                                  '$cartQty',
                                  style: robotoBold.copyWith(
                                    color: Colors.white,
                                    fontSize: Dimensions.fontSizeExtraSmall,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
