import 'package:suliman/features/order/domain/models/order_model.dart';
import 'package:suliman/util/dimensions.dart';
import 'package:suliman/util/styles.dart';
import 'package:suliman/common/widgets/custom_image.dart';
import 'package:suliman/common/widgets/rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:suliman/helper/module_helper.dart';

class DeliveryManWidget extends StatelessWidget {
  final DeliveryMan? deliveryMan;
  final int? moduleId;
  const DeliveryManWidget({super.key, required this.deliveryMan, this.moduleId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 5, spreadRadius: 1,
        )],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(ModuleHelper.isGrocery(moduleId: moduleId) ? 'Vendor' : 'delivery_man'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall)),
        ListTile(
          leading: ClipOval(
            child: CustomImage(
              image: '${deliveryMan!.imageFullUrl}',
              height: 40, width: 40, fit: BoxFit.cover,
            ),
          ),
          title: Text(
            '${deliveryMan!.fName} ${deliveryMan!.lName}',
            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
          ),
          subtitle: RatingBar(rating: deliveryMan!.avgRating, size: 15, ratingCount: deliveryMan!.ratingCount ?? 0),
        ),
      ]),
    );
  }
}
