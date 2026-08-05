import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/features/shelf/screens/dynamic_shelf_view_all_screen.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/service/screens/service_provider_screen.dart';


class AdsBannerWidget extends StatelessWidget {
  final ModuleModel module;
  const AdsBannerWidget({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    if (module.adsBannerImageFullUrl == null || module.adsBannerImageFullUrl!.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeExtraSmall, 
        horizontal: Dimensions.paddingSizeExtraSmall
      ),
      child: InkWell(
        onTap: () async {
          bool isServices = Get.find<SplashController>().module?.moduleType == 'services';

          if (module.adsBannerLinkType == 'store' && module.adsBannerLinkId != null) {
            if (isServices) {
                Get.to(() => ServiceProviderScreen(providerId: int.tryParse(module.adsBannerLinkId.toString())));
            } else {
                Get.toNamed(
                  RouteHelper.getStoreRoute(id: int.tryParse(module.adsBannerLinkId.toString()), page: 'store'),
                  preventDuplicates: false,
                );
            }
          } else if (module.adsBannerLinkType == 'item' && module.adsBannerLinkId != null) {
            if (isServices) {
                Get.toNamed(RouteHelper.getServiceDetailsRoute(int.tryParse(module.adsBannerLinkId.toString())!));
            } else {
                Get.toNamed(RouteHelper.getItemDetailsRoute(int.tryParse(module.adsBannerLinkId.toString())!, false));
            }
          } else if (module.adsBannerLinkType == 'shelf' && module.adsBannerLinkId != null) {
            Get.to(() => DynamicShelfViewAllScreen(shelfId: int.tryParse(module.adsBannerLinkId.toString())!));
          } else if (module.adsBannerLinkType == 'url' && module.adsBannerLinkId != null) {
            String link = module.adsBannerLinkId.toString();
            if (!link.startsWith('http')) {
              link = 'https://$link';
            }
            if (await canLaunchUrlString(link)) {
              launchUrlString(link, mode: LaunchMode.externalApplication);
            }
          } else if (module.adsBannerLinkType == 'page' && module.adsBannerLinkId != null) {
            String page = module.adsBannerLinkId.toString();
            switch (page) {
              case 'item_campaign':
                Get.toNamed(RouteHelper.getItemCampaignRoute());
                break;
              case 'popular_items':
                Get.toNamed(RouteHelper.getPopularItemRoute(false, true));
                break;
              case 'all_stores':
                Get.toNamed(RouteHelper.getAllStoreRoute('all', isNearbyStore: true));
                break;
              case 'category':
                Get.toNamed(RouteHelper.getCategoryRoute());
                break;
              case 'favourite':
                Get.toNamed(RouteHelper.getFavouriteScreen());
                break;
              case 'coupon':
                Get.toNamed(RouteHelper.getCouponRoute());
                break;
              default:
                Get.toNamed(RouteHelper.getAllStoreRoute('all'));
            }
          }
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          child: module.adsBannerHeight != null && module.adsBannerHeight! > 0
              ? CustomImage(
                  image: module.adsBannerImageFullUrl!,
                  height: module.adsBannerHeight!.toDouble(),
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                )
              : AspectRatio(
                  aspectRatio: 9.33,
                  child: CustomImage(
                    image: module.adsBannerImageFullUrl!,
                    fit: BoxFit.cover,
                  ),
                ),
        ),
      ),
    );
  }
}
