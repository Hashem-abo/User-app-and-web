import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/features/shelf/controllers/shelf_controller.dart';
import 'package:sixam_mart/features/shelf/widgets/dynamic_shelf_view.dart';
import 'package:sixam_mart/features/shelf/widgets/dynamic_mother_shelf_view.dart';
import 'package:sixam_mart/features/shelf/widgets/dynamic_category_shelf_view.dart';
import 'package:sixam_mart/features/shelf/widgets/dynamic_store_shelf_view.dart';
import 'package:sixam_mart/features/flash_sale/widgets/flash_sale_view_widget.dart';
import 'package:sixam_mart/features/banner/controllers/banner_controller.dart';
import 'package:sixam_mart/features/home/widgets/banner_view.dart';
import 'package:sixam_mart/features/home/widgets/ads_banner_widget.dart';
import 'package:sixam_mart/features/home/widgets/brands_view_widget.dart';
import 'package:sixam_mart/features/home/widgets/highlight_widget.dart';
import 'package:sixam_mart/features/home/widgets/views/best_reviewed_item_view.dart';
import 'package:sixam_mart/features/home/widgets/views/best_store_nearby_view.dart';
import 'package:sixam_mart/features/home/widgets/views/category_view.dart';
import 'package:sixam_mart/features/home/widgets/views/common_condition_view.dart';
import 'package:sixam_mart/features/home/widgets/views/featured_categories_view.dart';
import 'package:sixam_mart/features/home/widgets/views/item_that_you_love_view.dart';
import 'package:sixam_mart/features/home/widgets/views/just_for_you_view.dart';
import 'package:sixam_mart/features/home/widgets/views/middle_section_banner_view.dart';
import 'package:sixam_mart/features/home/widgets/views/most_popular_item_view.dart';
import 'package:sixam_mart/features/home/widgets/views/new_on_mart_view.dart';
import 'package:sixam_mart/features/home/widgets/views/popular_store_view.dart';
import 'package:sixam_mart/features/home/widgets/views/product_with_categories_view.dart';
import 'package:sixam_mart/features/home/widgets/views/promo_code_banner_view.dart';
import 'package:sixam_mart/features/home/widgets/views/promotional_banner_view.dart';
import 'package:sixam_mart/features/home/widgets/views/recommended_store_view.dart';
import 'package:sixam_mart/features/home/widgets/views/special_offer_view.dart';
import 'package:sixam_mart/features/home/widgets/views/top_offers_near_me.dart';
import 'package:sixam_mart/features/home/widgets/views/visit_again_view.dart';

import 'package:sixam_mart/features/home/controllers/store_corner_controller.dart';
import 'package:sixam_mart/features/home/widgets/views/store_corner_view.dart';
import 'package:sixam_mart/features/home/widgets/views/browse_by_category_view.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/features/home/widgets/views/super_banner_view.dart';
import 'package:sixam_mart/features/home/widgets/views/service_categories_view.dart';
import 'package:sixam_mart/features/home/widgets/views/service_list_view.dart';
import 'package:sixam_mart/features/home/widgets/views/service_provider_view.dart';
import 'package:sixam_mart/features/reels/widgets/reels_section_widget.dart';

class ModuleHomeLayoutBuilder extends StatelessWidget {
  final ModuleModel module;
  final bool isLoggedIn;
  final bool wrapInSliver;
  
  const ModuleHomeLayoutBuilder({super.key, required this.module, required this.isLoggedIn, this.wrapInSliver = true});

  @override
  Widget build(BuildContext context) {
    if (module.layoutConfig == null || module.layoutConfig!.isEmpty) {
        return wrapInSliver ? SliverToBoxAdapter(child: _buildDefaultLayout(context)) : _buildDefaultLayout(context);
    }

    Color? adsBgColor;
    if (module.layoutConfig != null) {
      var bannerConfig = module.layoutConfig!.firstWhereOrNull((config) => config.name == 'BannerView');
      if (bannerConfig != null && bannerConfig.backgroundColor != null && bannerConfig.backgroundColor!.startsWith('#') && bannerConfig.backgroundColor!.length == 7) {
        adsBgColor = Color(int.parse(bannerConfig.backgroundColor!.replaceFirst('#', '0xff')));
      }
    }

    if (wrapInSliver) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == 0) {
              return Container(
                color: adsBgColor,
                child: AdsBannerWidget(module: module),
              );
            }

            var config = module.layoutConfig![index - 1];
            if (config.active == false) return const SizedBox();
            
            Widget widget = _buildWidget(context, config);

            Color? bgColor = (config.backgroundColor != null && config.backgroundColor!.startsWith('#') && config.backgroundColor!.length == 7) 
                ? Color(int.parse(config.backgroundColor!.replaceFirst('#', '0xff'))) 
                : null;

            return Container(
              color: bgColor,
              child: widget,
            );
          },
          childCount: (module.layoutConfig?.length ?? 0) + 1,
        ),
      );
    } else {
      List<Widget> children = [];
      children.add(Container(
        color: adsBgColor,
        child: AdsBannerWidget(module: module),
      ));

      for (var config in module.layoutConfig!) {
        if (config.active == false) continue;
        Widget widget = _buildWidget(context, config);
        Color? bgColor = (config.backgroundColor != null && config.backgroundColor!.startsWith('#') && config.backgroundColor!.length == 7) 
            ? Color(int.parse(config.backgroundColor!.replaceFirst('#', '0xff'))) 
            : null;
        children.add(Container(
          color: bgColor,
          child: widget,
        ));
      }
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
    }
  }

  Widget _buildWidget(BuildContext context, ModuleLayoutConfig config) {
    bool isShop = module.moduleType == 'ecommerce';
    bool isGrocery = module.moduleType == 'grocery';
    bool isPharmacy = module.moduleType == 'pharmacy';
    bool isFood = module.moduleType == 'food';
    String? title = config.titles?[Get.locale?.languageCode];
    title ??= config.titles?['default'];
    double? height = config.height != null && config.height!.isNotEmpty ? double.tryParse(config.height!) : null;

    switch (config.name) {
      case 'BannerView':
        bool isFeatured = config.params?['is_featured'] == true;
        return GetBuilder<BannerController>(builder: (bannerController) {
          return BannerView(isFeatured: isFeatured, height: height);
        });
      case 'SuperBannerView':
        int? superBannerId = config.params?['super_banner_id'] != null ? int.tryParse(config.params!['super_banner_id'].toString()) : null;
        return superBannerId != null ? SuperBannerView(superBannerId: superBannerId, height: height) : const SizedBox();
      case 'CategoryView':
        return const CategoryView();
      case 'MostPopularItemView':
        int? categoryId = config.params?['category_id'] != null ? int.tryParse(config.params!['category_id'].toString()) : null;
        return MostPopularItemView(isFood: isFood, isShop: isShop, title: title, categoryId: categoryId, height: height);
      case 'HighlightWidget':
        return HighlightWidget(title: title);
      case 'CommonConditionView':
        return CommonConditionView();
      case 'FlashSaleViewWidget':
        return FlashSaleViewWidget(title: title);
      case 'BestStoreNearbyView':
        return const BestStoreNearbyView();
      case 'SpecialOfferView':
        return SpecialOfferView(isFood: isFood, isShop: isShop, title: title, height: height);
      case 'MiddleSectionBannerView':
        return const MiddleSectionBannerView();
      case 'BestReviewItemView':
        return BestReviewItemView(title: title, height: height);
      case 'JustForYouView':
        return JustForYouView(title: title, height: height);
      case 'TopOffersNearMe':
        return TopOffersNearMe(title: title);
      case 'ItemThatYouLoveView':
        return ItemThatYouLoveView(forShop: isShop, isFood: isFood, isShop: isShop, title: title, height: height);
      case 'PromoCodeBannerView':
        return isLoggedIn ? const PromoCodeBannerView() : const SizedBox();
      case 'NewOnMartView':
        return NewOnMartView(isPharmacy: isPharmacy, isShop: isShop);
      case 'PromotionalBannerView':
        return const PromotionalBannerView();
      case 'VisitAgainView':
        return isLoggedIn ? const VisitAgainView() : const SizedBox();
      case 'BrandsViewWidget':
        return const BrandsViewWidget();
      case 'ProductWithCategoriesView':
        return ProductWithCategoriesView(fromShop: true, height: height);
      case 'FeaturedCategoriesView':
        return const FeaturedCategoriesView();
      case 'PopularStoreView':
        return const PopularStoreView();
      case 'RecommendedStoreView':
        return const RecommendedStoreView();
      case 'reelsList':
      case 'ReelsList':
      case 'ReelsSectionWidget':
        return ReelsSectionWidget(title: title);

      case 'DynamicMotherShelfView':
        int? shelfId = config.params?['shelf_id'] != null ? int.tryParse(config.params!['shelf_id'].toString()) : null;
        return GetBuilder<ShelfController>(builder: (shelfController) {
          if (shelfController.shelfList == null) return const SizedBox();
          if (shelfId != null) {
            var shelf = shelfController.shelfList!.firstWhereOrNull((s) => s.id == shelfId);
            return shelf != null ? DynamicMotherShelfView(shelf: shelf, isFood: isFood, isShop: isShop, height: height) : const SizedBox();
          }
          return Column(children: shelfController.shelfList!.where((s) => s.children != null && s.children!.isNotEmpty).map((shelf) => DynamicMotherShelfView(shelf: shelf, isFood: isFood, isShop: isShop, height: height)).toList());
        });
      case 'DynamicShelfView':
        int? shelfId = config.params?['shelf_id'] != null ? int.tryParse(config.params!['shelf_id'].toString()) : null;
        return GetBuilder<ShelfController>(builder: (shelfController) {
          if (shelfController.shelfList == null) return const SizedBox();
          if (shelfId != null) {
            var shelf = shelfController.shelfList!.firstWhereOrNull((s) => s.id == shelfId);
            return shelf != null ? DynamicShelfView(shelf: shelf, isFood: isFood, isShop: isShop, height: height) : const SizedBox();
          }
          return Column(children: shelfController.shelfList!.where((s) => s.type == 'product' || s.type == 'service' || s.type == null).map((shelf) => DynamicShelfView(shelf: shelf, isFood: isFood, isShop: isShop, height: height)).toList());
        });
      case 'DynamicCategoryShelfView':
        int? shelfId = config.params?['shelf_id'] != null ? int.tryParse(config.params!['shelf_id'].toString()) : null;
        return GetBuilder<ShelfController>(builder: (shelfController) {
          if (shelfController.shelfList == null) return const SizedBox();
          if (shelfId != null) {
            var shelf = shelfController.shelfList!.firstWhereOrNull((s) => s.id == shelfId);
            return shelf != null ? DynamicCategoryShelfView(shelf: shelf, height: height) : const SizedBox();
          }
          return Column(children: shelfController.shelfList!.where((s) => s.type == 'category' || s.type == 'service_category').map((shelf) => DynamicCategoryShelfView(shelf: shelf, height: height)).toList());
        });
      case 'DynamicStoreShelfView':
        int? shelfId = config.params?['shelf_id'] != null ? int.tryParse(config.params!['shelf_id'].toString()) : null;
        return GetBuilder<ShelfController>(builder: (shelfController) {
          if (shelfController.shelfList == null) return const SizedBox();
          if (shelfId != null) {
            var shelf = shelfController.shelfList!.firstWhereOrNull((s) => s.id == shelfId);
            return shelf != null ? DynamicStoreShelfView(shelf: shelf, height: height) : const SizedBox();
          }
          return Column(children: shelfController.shelfList!.where((s) => s.type == 'store' || s.type == 'service_provider').map((shelf) => DynamicStoreShelfView(shelf: shelf, height: height)).toList());
        });
      case 'BrowseByCategoryView':
        Color? backgroundColor = config.backgroundColor != null && config.backgroundColor!.isNotEmpty 
            ? Color(int.parse(config.backgroundColor!.replaceFirst('#', '0xff'))) 
            : null;
        return BrowseByCategoryView(isFood: isFood, isShop: isShop, title: title, height: height, backgroundColor: backgroundColor);
      case 'StoreCornerView':
        int? cornerId = config.params?['corner_id'] != null ? int.tryParse(config.params!['corner_id'].toString()) : null;
        return GetBuilder<StoreCornerController>(builder: (storeCornerController) {
          if (storeCornerController.storeCornerList == null) {
              return const SizedBox();
          }
          if (cornerId != null) {
            var corner = storeCornerController.storeCornerList!.firstWhereOrNull((c) => c.id == cornerId);
            return corner != null ? StoreCornerView(storeCorner: corner, isFood: isFood, isShop: isShop, isGrocery: isGrocery) : const SizedBox();
          }
          return Column(children: storeCornerController.storeCornerList!.map<Widget>((corner) => StoreCornerView(storeCorner: corner, isFood: isFood, isShop: isShop, isGrocery: isGrocery)).toList());
        });
      case 'ServiceCategoriesView':
        return const ServiceCategoriesView();
      case 'ServiceListView':
        return const ServiceListView();
      case 'ServiceProviderView':
        return const ServiceProviderView();
      default:
        return const SizedBox();
    }
  }

  Widget _buildDefaultLayout(BuildContext context) {
    // Fallback to original Grocery/Shop Layout if config is missing
    bool isShop = module.moduleType == 'ecommerce';
    // bool isGrocery = module.moduleType == 'grocery';
    // bool isPharmacy = module.moduleType == 'pharmacy';
    bool isFood = module.moduleType == 'food';

    if (isShop) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GetBuilder<SplashController>(builder: (splashController) {
          // ... Shop Banner Logic (Keep it simpler for fallback or copy full logic if needed)
          return const SizedBox(); // For simplicity, rely on the fact that if config is null we might want to just show nothing or assume migration is done
        }),
      ]);
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        color: Theme.of(context).cardColor,
        child: AdsBannerWidget(module: module),
      ),
      SizedBox(
        width: MediaQuery.of(context).size.width,
        child: const Column(children: [BannerView(isFeatured: false), SizedBox(height: 12)]),
      ),
      const CategoryView(),

      isLoggedIn ? const VisitAgainView() : const SizedBox(),
      const MostPopularItemView(isFood: false, isShop: false),
      const HighlightWidget(),
      const FlashSaleViewWidget(),
      const SpecialOfferView(isFood: false, isShop: false),
      const BestReviewItemView(),
      const JustForYouView(),
      const TopOffersNearMe(),
      const ItemThatYouLoveView(forShop: false, isFood: false, isShop: false),
      isLoggedIn ? const PromoCodeBannerView() : const SizedBox(),
      const PromotionalBannerView(),
    ]);
  }
}
