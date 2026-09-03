import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/order/domain/models/order_model.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class TrackDetailsViewWidget extends StatelessWidget {
  final String? status;
  final OrderModel track;
  final Function? callback;
  final bool showChatPermission;
  const TrackDetailsViewWidget({super.key, required this.track, required this.status, this.callback, required this.showChatPermission});

  @override
  Widget build(BuildContext context) {
    bool takeAway = track.orderType == 'take_away';

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        color: Theme.of(context).cardColor,
      ),
      alignment: Alignment.center,
      child: (!takeAway && track.deliveryMan == null) ? Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        child: Text(
          'delivery_man_not_assigned'.tr, style: robotoMedium, textAlign: TextAlign.center,
        ),
      ) : Column(children: [


        Align(alignment: Alignment.centerLeft, child: Text(
          takeAway ? Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText!
              ? 'store'.tr : 'store'.tr : (track.store != null && track.store!.moduleId == 1) ? 'grocery_track'.tr : 'delivery_man'.tr,
          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
        )),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

        Row(children: [
          ClipOval(child: CustomImage(
            image: '${takeAway ? (track.store != null ? track.store!.logoFullUrl : '') : track.deliveryMan!.imageFullUrl}',
            height: 35, width: 35, fit: BoxFit.cover,
          )),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              takeAway ? track.store != null ? track.store!.name! : '' : '${track.deliveryMan!.fName} ${track.deliveryMan!.lName}',
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall),
            ),
            RatingBar(
              rating: takeAway ? track.store != null ? track.store!.avgRating : '' as double? : track.deliveryMan!.avgRating, size: 10,
              ratingCount: takeAway ? track.store != null ? track.store!.ratingCount : '' as int? : track.deliveryMan!.ratingCount,
            ),
          ])),
          !takeAway ? InkWell(
            onTap: () async {
              if(await canLaunchUrlString('tel:${track.deliveryMan?.phone ?? ''}')) {
                launchUrlString('tel:${track.deliveryMan?.phone ?? ''}', mode: LaunchMode.externalApplication);
              }else {
                showCustomSnackBar('${'can_not_launch'.tr} ${track.deliveryMan?.phone ?? ''}');
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                color: Colors.green,
              ),
              child: Text(
                'call'.tr,
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).cardColor),
              ),
            ),
          ) : const SizedBox(),
          SizedBox(width: !takeAway ? Dimensions.paddingSizeSmall : 0),

          (showChatPermission && !takeAway) ? InkWell(
            onTap: callback as void Function()?,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: Get.context!.width >= 1300 ? 7 : Dimensions.paddingSizeExtraSmall, horizontal: Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                color: Colors.green,
              ),
              child: Icon(Icons.chat, size: 12, color: Theme.of(context).cardColor),
            ),
          ) : const SizedBox(),
        ]),

      ]),
    );
  }
}
