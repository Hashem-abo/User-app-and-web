import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/favourite/controllers/favourite_controller.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/common/widgets/not_logged_in_screen.dart';
import 'package:sixam_mart/features/notification/widgets/notification_content_view.dart';
import 'package:sixam_mart/features/history/widgets/history_content_view.dart';
import 'package:sixam_mart/features/favourite/widgets/favourite_content_view.dart';
import 'package:sixam_mart/features/favourite/widgets/buy_again_content_view.dart';
import 'package:sixam_mart/features/favourite/widgets/wish_list_content_view.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  FavouriteScreenState createState() => FavouriteScreenState();
}

class FavouriteScreenState extends State<FavouriteScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();

    final bool isLtr = Get.find<LocalizationController>().isLtr;
    int initialIdx = isLtr ? 4 : 0;
    if (Get.parameters['tab'] == 'history') {
      initialIdx = isLtr ? 1 : 3;
    }
    _tabController = TabController(length: 5, initialIndex: initialIdx, vsync: this);
    _tabController!.addListener(() {
      setState(() {});
    });

    initCall();
  }

  void initCall(){
    if(AuthHelper.isLoggedIn()) {
      Get.find<FavouriteController>().getFavouriteList();
    }
  }

  void _showModuleBottomSheet(BuildContext context) {
    List<ModuleModel>? moduleList = Get.find<SplashController>().moduleList;
    ModuleModel? currentModule = Get.find<SplashController>().module;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (con) => Container(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeLarge),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            height: 4, width: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          Text(
            'select_module'.tr,
            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: moduleList?.length ?? 0,
            itemBuilder: (context, index) {
              ModuleModel module = moduleList![index];
              bool isActive = module.id == currentModule?.id;

              return InkWell(
                onTap: () async {
                  if(!isActive) {
                    await Get.find<SplashController>().switchModule(index, true);
                    initCall();
                    Get.find<ItemController>().getBuyAgainItemList(reload: true);
                    setState(() {});
                  }
                  if(Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                  margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    color: isActive ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Theme.of(context).disabledColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    border: Border.all(color: isActive ? Theme.of(context).primaryColor : Colors.transparent, width: 1),
                  ),
                  child: Row(children: [
                    Expanded(child: Text(
                      module.moduleName ?? '',
                      style: robotoMedium.copyWith(color: isActive ? Theme.of(context).primaryColor : null),
                    )),
                  ]),
                ),
              );
            },
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isLtr = Get.find<LocalizationController>().isLtr;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'favourite'.tr,
        backButton: false,
        titleWidget: GetBuilder<SplashController>(builder: (splashController) {
          List<ModuleModel>? moduleList = splashController.moduleList;
          String title = splashController.module?.moduleName ?? 'favourite'.tr;
          return (moduleList != null && moduleList.length > 1) ? InkWell(
            onTap: () => _showModuleBottomSheet(context),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(
                title,
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge!.color),
              ),
              Icon(Icons.keyboard_arrow_down, color: Theme.of(context).textTheme.bodyLarge!.color),
            ]),
          ) : Text(
            title,
            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge!.color),
          );
        }),
      ),
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      body: AuthHelper.isLoggedIn() ? SafeArea(child: Column(children: [

        Expanded(child: Column(children: [
          
           const SizedBox(height: Dimensions.paddingSizeSmall),

           SizedBox(
             width: Dimensions.webMaxWidth,
             child: Padding(
               padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
               child: Row(children: _getTabs(context, isLtr)),
             ),
           ),

           Expanded(child: TabBarView(
             controller: _tabController,
             physics: const NeverScrollableScrollPhysics(),
             children: isLtr ? [
               const NotificationContentView(),
               const HistoryContentView(),
               const BuyAgainContentView(),
               const WishListContentView(),
               const FavouriteContentView(),
             ] : [
               const FavouriteContentView(),
               const WishListContentView(),
               const BuyAgainContentView(),
               const HistoryContentView(),
               const NotificationContentView(),
             ],
           )),

        ]))

      ])) : NotLoggedInScreen(callBack: (value){
        initCall();
        setState(() {});
      }),
    );
  }

  List<Widget> _getTabs(BuildContext context, bool isLtr) {
    if (isLtr) {
      return [
        _tabItem(context, 0, 'notification'.tr, Icons.notifications_active),
        _tabItem(context, 1, 'view_log'.tr, Icons.watch_later),
        _tabItem(context, 2, 'buy_again'.tr, Icons.shopping_cart),
        _tabItem(context, 3, 'wish_list'.tr == 'wish_list' ? 'قائمة الامنيات' : 'wish_list'.tr, Icons.playlist_add),
        _tabItem(context, 4, 'favourite'.tr, Icons.favorite),
      ];
    } else {
      return [
        _tabItem(context, 0, 'favourite'.tr, Icons.favorite),
        _tabItem(context, 1, 'wish_list'.tr == 'wish_list' ? 'قائمة الامنيات' : 'wish_list'.tr, Icons.playlist_add),
        _tabItem(context, 2, 'buy_again'.tr, Icons.shopping_cart),
        _tabItem(context, 3, 'view_log'.tr, Icons.watch_later),
        _tabItem(context, 4, 'notification'.tr, Icons.notifications_active),
      ];
    }
  }

  Widget _tabItem(BuildContext context, int index, String title, IconData icon) {
    bool isSelected = _tabController!.index == index;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: InkWell(
          onTap: () => _tabController!.animateTo(index),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, spreadRadius: 1)],
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withOpacity(0.2) : Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: isSelected ? Colors.white : Theme.of(context).primaryColor, size: 20),
              ),
              const SizedBox(height: 5),
              Text(
                title,
                textAlign: TextAlign.center,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeExtraSmall,
                  color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
