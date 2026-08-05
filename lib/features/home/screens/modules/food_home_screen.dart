import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/features/home/widgets/highlight_widget.dart';
import 'package:sixam_mart/features/home/widgets/views/category_view.dart';
import 'package:sixam_mart/features/home/widgets/views/browse_by_category_view.dart';
import 'package:sixam_mart/features/home/widgets/views/store_corner_view.dart';
import 'package:sixam_mart/features/home/widgets/views/recommended_store_view.dart';
import 'package:sixam_mart/features/home/widgets/views/top_offers_near_me.dart';
import 'package:sixam_mart/features/shelf/controllers/shelf_controller.dart';
import 'package:sixam_mart/features/shelf/widgets/dynamic_shelf_view.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/features/home/widgets/views/best_reviewed_item_view.dart';
import 'package:sixam_mart/features/home/widgets/views/best_store_nearby_view.dart';
import 'package:sixam_mart/features/home/widgets/views/item_that_you_love_view.dart';
import 'package:sixam_mart/features/home/widgets/views/just_for_you_view.dart';
import 'package:sixam_mart/features/home/widgets/views/most_popular_item_view.dart';
import 'package:sixam_mart/features/home/widgets/views/new_on_mart_view.dart';
import 'package:sixam_mart/features/home/widgets/views/special_offer_view.dart';
import 'package:sixam_mart/features/home/widgets/views/visit_again_view.dart';
import 'package:sixam_mart/features/home/widgets/banner_view.dart';
import 'package:sixam_mart/features/home/widgets/module_home_layout_builder.dart';

import 'package:sixam_mart/features/home/widgets/ads_banner_widget.dart';

class FoodHomeScreen extends StatelessWidget {
  const FoodHomeScreen({super.key});

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
        const BrowseByCategoryView(isFood: true, isShop: false),

        GetBuilder<ShelfController>(builder: (shelfController) {
            return shelfController.shelfList != null ? Column(children: shelfController.shelfList!.map((shelf) => DynamicShelfView(shelf: shelf, isFood: true, isShop: false)).toList()) : const SizedBox();
        }),
        isLoggedIn ? const VisitAgainView(fromFood: true) : const SizedBox(),
        const StoreCornerView(isShop: false, isFood: true, isGrocery: false), // Added Store Corner View
       // const RecommendedStoreView(),
        const SpecialOfferView(isFood: true, isShop: false),
        const HighlightWidget(),
        const TopOffersNearMe(),
        const BestReviewItemView(),
        const BestStoreNearbyView(),
        const ItemThatYouLoveView(forShop: false, isFood: true, isShop: false),
        const MostPopularItemView(isFood: true, isShop: false),
        const JustForYouView(),
        const NewOnMartView(isNewStore: true, isPharmacy: false, isShop: false),
      ]));
    });
  }
}
