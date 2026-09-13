import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:suliman/common/widgets/custom_asset_image_widget.dart';
import 'package:suliman/common/widgets/custom_image.dart';
import 'package:suliman/features/item/domain/models/item_model.dart';
import 'package:suliman/features/order/domain/models/order_details_model.dart';
import 'package:suliman/features/order/domain/models/order_model.dart';
import 'package:suliman/features/splash/controllers/splash_controller.dart';
import 'package:suliman/helper/price_converter.dart';
import 'package:suliman/util/dimensions.dart';
import 'package:suliman/util/images.dart';
import 'package:suliman/util/styles.dart';

class OrderItemWidget extends StatelessWidget {
  final OrderModel order;
  final OrderDetailsModel orderDetails;
  const OrderItemWidget({super.key, required this.order, required this.orderDetails});

  @override
  Widget build(BuildContext context) {
    String addOnText = '';
    if (orderDetails.addOns != null) {
      for (var addOn in orderDetails.addOns!) {
        addOnText = '$addOnText${(addOnText.isEmpty) ? '' : ',  '}${addOn.name} (${addOn.quantity})';
      }
    }

    String? variationText = '';
    if (orderDetails.variation != null && orderDetails.variation!.isNotEmpty) {
      List<String> variationTypes = orderDetails.variation![0].type?.split('-') ?? [];
      if (orderDetails.itemDetails?.choiceOptions != null && variationTypes.length == orderDetails.itemDetails!.choiceOptions!.length) {
        int index = 0;
        for (var choice in orderDetails.itemDetails!.choiceOptions!) {
          variationText = '${variationText!}${(index == 0) ? '' : ',  '}${choice.title} - ${variationTypes[index]}';
          index = index + 1;
        }
      } else if (orderDetails.itemDetails?.variations != null && orderDetails.itemDetails!.variations!.isNotEmpty) {
        variationText = orderDetails.itemDetails!.variations![0].type;
      }
    } else if (orderDetails.foodVariation != null && orderDetails.foodVariation!.isNotEmpty) {
      for (FoodVariation variation in orderDetails.foodVariation!) {
        variationText = '${variationText!}${variationText.isNotEmpty ? ', ' : ''}${variation.name} (';
        if (variation.variationValues != null) {
          for (VariationValue value in variation.variationValues!) {
            variationText = '${variationText!}${variationText.endsWith('(') ? '' : ', '}${value.level}';
          }
        }
        variationText = '${variationText!})';
      }
    }

    final double effectivePrice = (orderDetails.price ?? 0) - (orderDetails.discountOnItem ?? 0);
    final double totalPrice = effectivePrice * (orderDetails.quantity ?? 1);

    // Determine unit name
    String unitName = '-';
    final moduleConfig = Get.find<SplashController>().getModuleConfig(order.moduleType);
    if ((moduleConfig.unit ?? false) && orderDetails.itemDetails?.unitType != null && orderDetails.itemDetails!.unitType!.isNotEmpty) {
      unitName = orderDetails.itemDetails!.unitType!;
    } else if ((Get.find<SplashController>().configModel?.toggleVegNonVeg ?? false) && (moduleConfig.vegNonVeg ?? false)) {
      unitName = orderDetails.itemDetails?.veg == 0 ? 'non_veg'.tr : 'veg'.tr;
    }

    final String? imageUrl = (orderDetails.imageFullUrl != null && orderDetails.imageFullUrl!.isNotEmpty)
        ? orderDetails.imageFullUrl
        : orderDetails.itemDetails?.imageFullUrl;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeSmall,
        vertical: Dimensions.paddingSizeSmall,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Item Column (Image + Name + Variations + Addons + Note) (flex: 4) ──
          Expanded(
            flex: 4,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageUrl != null && imageUrl.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    child: CustomImage(
                      height: 40,
                      width: 40,
                      fit: BoxFit.cover,
                      image: imageUrl,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall + 2),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              orderDetails.itemDetails?.name ?? '',
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (orderDetails.itemDetails?.isStoreHalalActive == true && orderDetails.itemDetails?.isHalalItem == true) ...[
                            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                            const CustomAssetImageWidget(Images.halalTag, height: 13, width: 13),
                          ],
                        ],
                      ),

                      // Variation under item name
                      if (variationText != null && variationText.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            variationText,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeExtraSmall,
                              color: Theme.of(context).disabledColor,
                            ),
                          ),
                        ),

                      // Addons under item
                      if ((moduleConfig.addOn ?? false) && addOnText.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            '${'addons'.tr}: $addOnText',
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeExtraSmall,
                              color: Theme.of(context).disabledColor,
                            ),
                          ),
                        ),

                      // Note under item
                      if (orderDetails.note != null && orderDetails.note!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            '${'note'.tr}: ${orderDetails.note}',
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeExtraSmall,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Unit Column (flex: 2) ──
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                unitName,
                textAlign: TextAlign.center,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                ),
              ),
            ),
          ),

          // ── Quantity Column (flex: 2) ──
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${orderDetails.quantity ?? 1}',
                textAlign: TextAlign.center,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),

          // ── Price Column (flex: 2) ──
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    PriceConverter.convertPrice(totalPrice),
                    textAlign: TextAlign.end,
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  if ((orderDetails.discountOnItem ?? 0) > 0)
                    Text(
                      PriceConverter.convertPrice((orderDetails.price ?? 0) * (orderDetails.quantity ?? 1)),
                      textAlign: TextAlign.end,
                      style: robotoRegular.copyWith(
                        decoration: TextDecoration.lineThrough,
                        fontSize: Dimensions.fontSizeExtraSmall,
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
