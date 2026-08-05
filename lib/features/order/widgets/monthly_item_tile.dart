import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/order/domain/models/monthly_order_model.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class MonthlyItemTile extends StatelessWidget {
  final MonthlyOrderItemPreview item;
  final double imageHeight;
  const MonthlyItemTile({super.key, required this.item, this.imageHeight = 100});

  @override
  Widget build(BuildContext context) {
    final double currentPrice = item.price ?? 0;
    final double? oldPrice = item.oldPrice;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Stack(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          child: CustomImage(
            image: item.imageFullUrl ?? '',
            height: imageHeight,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),

        if(!item.isAvailable) Positioned(
          left: 4, top: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ),
            child: Text(
              'out_of_stock'.tr,
              style: robotoMedium.copyWith(fontSize: 10, color: Colors.white),
            ),
          ),
        ),
      ]),
      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

      Text(
        item.name ?? '',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
      ),
      const SizedBox(height: 2),

      if(item.quantity != null) Text(
        '${'qty'.tr}: ${item.quantity}',
        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
      ),
      const SizedBox(height: 2),

      Row(children: [
        Text(
          PriceConverter.convertPrice(currentPrice),
          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
        ),
        if(oldPrice != null && oldPrice > currentPrice) ...[
          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
          Text(
            PriceConverter.convertPrice(oldPrice),
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeExtraSmall,
              color: Theme.of(context).disabledColor,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      ]),
    ]);
  }
}
