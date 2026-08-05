import 'package:flutter/material.dart';
import 'package:sixam_mart/features/home/widgets/highlight_widget.dart';
import 'package:sixam_mart/features/home/widgets/views/product_with_categories_view.dart';
import 'package:sixam_mart/features/home/widgets/views/best_store_nearby_view.dart';
import 'package:sixam_mart/features/home/widgets/views/common_condition_view.dart';
import 'package:sixam_mart/features/home/widgets/views/just_for_you_view.dart';
import 'package:sixam_mart/features/home/widgets/views/middle_section_banner_view.dart';
import 'package:sixam_mart/features/home/widgets/views/new_on_mart_view.dart';
import 'package:sixam_mart/features/home/widgets/views/promotional_banner_view.dart';
import 'package:sixam_mart/features/home/widgets/views/recommended_store_view.dart';
import 'package:sixam_mart/features/home/widgets/views/top_offers_near_me.dart';
import 'package:sixam_mart/features/home/widgets/views/visit_again_view.dart';
import 'package:sixam_mart/features/shelf/controllers/shelf_controller.dart';
import 'package:sixam_mart/features/shelf/widgets/dynamic_shelf_view.dart';

import 'package:sixam_mart/features/home/widgets/banner_view.dart';
import 'package:sixam_mart/features/home/widgets/views/category_view.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/features/home/widgets/module_home_layout_builder.dart';
import 'package:sixam_mart/features/home/widgets/ads_banner_widget.dart';

class PharmacyHomeScreen extends StatelessWidget {
  const PharmacyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = AuthHelper.isLoggedIn();
    return GetBuilder<SplashController>(builder: (splashController) {
      if (splashController.module != null &&
          splashController.module!.layoutConfig != null &&
          splashController.module!.layoutConfig!.isNotEmpty) {
        return ModuleHomeLayoutBuilder(module: splashController.module!, isLoggedIn: isLoggedIn);
      }

      return SliverToBoxAdapter(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AdsBannerWidget(module: splashController.module!),


        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: const Column(
            children: [
              BannerView(isFeatured: false),
              SizedBox(height: 12),
            ],
          ),
        ),

        const CategoryView(),

      GetBuilder<ShelfController>(builder: (shelfController) {
          return shelfController.shelfList != null ? Column(children: shelfController.shelfList!.map((shelf) => DynamicShelfView(shelf: shelf, isFood: false, isShop: false)).toList()) : const SizedBox();
      }),
      isLoggedIn ? const VisitAgainView() : const SizedBox(),
        //const RecommendedStoreView(),
        const ProductWithCategoriesView(),
        const HighlightWidget(),
        const MiddleSectionBannerView(),
        const BestStoreNearbyView(),
        const JustForYouView(),
        const TopOffersNearMe(),
        const NewOnMartView(isShop: false, isPharmacy: true, isNewStore: true),
        const CommonConditionView(),
        const PromotionalBannerView(),

      ]));
    });
  }
}
