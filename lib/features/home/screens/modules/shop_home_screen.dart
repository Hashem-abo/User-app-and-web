import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/home/widgets/brands_view_widget.dart';
import 'package:sixam_mart/features/home/widgets/highlight_widget.dart';
import 'package:sixam_mart/features/home/widgets/views/recommended_store_view.dart';
import 'package:sixam_mart/features/home/widgets/views/top_offers_near_me.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/features/flash_sale/widgets/flash_sale_view_widget.dart';
import 'package:sixam_mart/features/home/widgets/views/product_with_categories_view.dart';
import 'package:sixam_mart/features/home/widgets/views/featured_categories_view.dart';
import 'package:sixam_mart/features/home/widgets/views/popular_store_view.dart';
import 'package:sixam_mart/features/home/widgets/views/item_that_you_love_view.dart';
import 'package:sixam_mart/features/home/widgets/views/just_for_you_view.dart';
import 'package:sixam_mart/features/home/widgets/views/most_popular_item_view.dart';
import 'package:sixam_mart/features/home/widgets/views/new_on_mart_view.dart';
import 'package:sixam_mart/features/home/widgets/views/middle_section_banner_view.dart';
import 'package:sixam_mart/features/home/widgets/views/browse_by_category_view.dart';
import 'package:sixam_mart/features/home/widgets/views/special_offer_view.dart';
import 'package:sixam_mart/features/home/widgets/views/promotional_banner_view.dart';
import 'package:sixam_mart/features/home/widgets/views/visit_again_view.dart';
import 'package:sixam_mart/features/home/widgets/banner_view.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/features/home/widgets/views/category_view.dart';
import 'package:sixam_mart/features/home/widgets/views/store_corner_view.dart';

import 'package:sixam_mart/features/home/widgets/module_home_layout_builder.dart';
import 'package:sixam_mart/helper/route_helper.dart';

import 'package:sixam_mart/features/home/widgets/ads_banner_widget.dart';
import 'package:sixam_mart/features/shelf/controllers/shelf_controller.dart';
import 'package:sixam_mart/features/shelf/widgets/dynamic_shelf_view.dart';

class ShopHomeScreen extends StatelessWidget {
  const ShopHomeScreen({super.key});

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
          height: GetPlatform.isDesktop ? 500 : MediaQuery.of(context).size.width * 0.429, // 1400x600 ratio
          child: const Column(
            children: [
              BannerView(isFeatured: false),
            ],
          ),
        ),

      const CategoryView(),

      GetBuilder<ShelfController>(builder: (shelfController) {
          return shelfController.shelfList != null ? Column(children: shelfController.shelfList!.map((shelf) => DynamicShelfView(shelf: shelf, isFood: false, isShop: true)).toList()) : const SizedBox();
      }),
      isLoggedIn ? const VisitAgainView() : const SizedBox(),
    //  const RecommendedStoreView(),
       const SpecialOfferView(isFood: false, isShop: true),
     const FlashSaleViewWidget(),
      const MiddleSectionBannerView(),
      const BrowseByCategoryView(isShop: true, isFood: false),
      const StoreCornerView(isShop: true, isFood: false, isGrocery: false), // Added Store Corner View
      const HighlightWidget(),
      const PopularStoreView(),
     const MostPopularItemView(isFood: false, isShop: true),
     const BrandsViewWidget(),
     const ProductWithCategoriesView(fromShop: true),
      const JustForYouView(),
      const TopOffersNearMe(),
      const FeaturedCategoriesView(),
      const ItemThatYouLoveView(forShop: true, isFood: false, isShop: true),
      const NewOnMartView(isShop: true,isPharmacy: false),
      const PromotionalBannerView(),
      const SizedBox(height: Dimensions.paddingSizeDefault),
      const TrendsChannelEntry(),
    ]));
    });
  }
}

class TrendsChannelEntry extends StatelessWidget {
  const TrendsChannelEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      child: GestureDetector(
        onTap: () => Get.toNamed(RouteHelper.getTrendsRoute()),
        child: Container(
          height: 100,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: Dimensions.paddingSizeDefault),
              Icon(Icons.trending_up, color: Colors.white, size: 40),
              const SizedBox(width: Dimensions.paddingSizeDefault),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'trends'.tr,
                      style: robotoBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeLarge),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'trends_channel'.tr,
                      style: robotoRegular.copyWith(color: Colors.white.withOpacity(0.8), fontSize: Dimensions.fontSizeSmall),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
              const SizedBox(width: Dimensions.paddingSizeDefault),
            ],
          ),
        ),
      ),
    );
  }
}
