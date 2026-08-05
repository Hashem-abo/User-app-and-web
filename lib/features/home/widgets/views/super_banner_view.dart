import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/home/controllers/super_banner_controller.dart';
import 'package:sixam_mart/features/home/domain/models/super_banner_model.dart';
import 'package:sixam_mart/features/store/screens/store_screen.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/common/widgets/item_bottom_sheet.dart';
import 'package:sixam_mart/features/item/screens/item_details_screen.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';

class SuperBannerView extends StatefulWidget {
  final int superBannerId;
  final double? height;
  const SuperBannerView({super.key, required this.superBannerId, this.height});

  @override
  State<SuperBannerView> createState() => _SuperBannerViewState();
}

class _SuperBannerViewState extends State<SuperBannerView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var controller = Get.find<SuperBannerController>();
      if (!controller.superBanners.containsKey(widget.superBannerId) && !controller.isLoading(widget.superBannerId)) {
        controller.getSuperBanner(widget.superBannerId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SuperBannerController>(builder: (superBannerController) {
      bool isLoading = superBannerController.isLoading(widget.superBannerId);
      SuperBanner? superBanner = superBannerController.superBanners[widget.superBannerId];
      List<SuperBannerItem>? items = superBanner?.items;

      if (isLoading) {
        return Shimmer(
          duration: const Duration(seconds: 2),
          enabled: true,
          child: Container(
            height: widget.height ?? 150,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              color: Colors.grey[300],
            ),
          ),
        );
      }

      if (items == null || items.isEmpty) {
        return const SizedBox();
      }

      bool isBig = superBanner?.type == 'big';

      return Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
        child: Column(
          children: [

            CarouselSlider.builder(
              options: CarouselOptions(
                height: widget.height,
                autoPlay: true,
                enlargeCenterPage: isBig,
                padEnds: isBig,
                viewportFraction: isBig ? 0.9 : 0.5,
                aspectRatio: widget.height != null ? 16/9 : (isBig ? 4.66 : 3.2),
                autoPlayInterval: const Duration(seconds: 5),
              ),
              itemCount: items.length,
              itemBuilder: (context, index, realIndex) {
               SuperBannerItem item = items[index];
                return InkWell(
                  onTap: () async {
                    if (item.type == 'item' && item.linkId != null) {
                      if(Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText! || Get.find<SplashController>().module!.moduleType == 'food') {
                        ResponsiveHelper.isMobile(context) ? Get.bottomSheet(
                          ItemBottomSheet(itemId: item.linkId!, inStorePage: false, isCampaign: false),
                          backgroundColor: Colors.transparent, isScrollControlled: true,
                        ) : Get.dialog(
                          Dialog(child: ItemBottomSheet(itemId: item.linkId!, inStorePage: false, isCampaign: false)),
                        );
                      } else {
                        Get.toNamed(RouteHelper.getItemDetailsRoute(item.linkId, false), arguments: ItemDetailsScreen(itemId: item.linkId!, inStorePage: false, isCampaign: false));
                      }
                    } else if (item.type == 'store') {
                       Get.toNamed(
                        RouteHelper.getStoreRoute(id: item.linkId, page: 'banner'),
                        arguments: StoreScreen(store: null, fromModule: false),
                      );
                    } else if (item.type == 'shelf' && item.linkId != null) {
                      Get.toNamed(RouteHelper.getDynamicShelfItemsRoute(item.linkId));
                    } else if (item.type == 'module' && item.linkId != null) {
                      int moduleListIndex = Get.find<SplashController>().moduleList!.indexWhere((module) => module.id == item.linkId);
                      if (moduleListIndex != -1) {
                        Get.find<SplashController>().switchModule(moduleListIndex, true);
                      }
                    } else if (item.type == 'web_url' || item.type == 'website') {
                      String url = item.url ?? '';
                      if (await canLaunchUrlString(url)) {
                        await launchUrlString(url, mode: LaunchMode.externalApplication);
                      } else {
                        showCustomSnackBar('unable_to_found_url'.tr);
                      }
                    }
                  },
                  child: Container(
                   // margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      color: Theme.of(context).cardColor,
                      boxShadow: [BoxShadow(color: isBig ? Colors.black12 : Colors.grey.withOpacity(0.3), blurRadius: 5, spreadRadius: 1)],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      child: CustomImage(
                        image: item.imageFullUrl ?? '',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    });
  }
}
