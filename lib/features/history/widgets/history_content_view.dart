import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/card_design/item_card.dart';
import 'package:sixam_mart/common/widgets/card_design/store_card_with_distance.dart';
import 'package:sixam_mart/common/widgets/no_data_screen.dart';
import 'package:sixam_mart/features/history/controllers/item_history_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';

import 'package:sixam_mart/common/widgets/item_view.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/web_page_title_widget.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';

class HistoryContentView extends StatefulWidget {
  const HistoryContentView({super.key});

  @override
  State<HistoryContentView> createState() => _HistoryContentViewState();
}

class _HistoryContentViewState extends State<HistoryContentView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _searchText = '';
  String _searchType = 'items';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      WebScreenTitleWidget(title: 'history'.tr),

      // ── Toggle banner ──────────────────────────────────────────────────────
      GetBuilder<ItemHistoryController>(builder: (ctrl) {
        return _HistoryToggleBanner(
          isEnabled: ctrl.isHistoryEnabled,
          onToggle: () => ctrl.toggleHistory(),
          onClearAll: ctrl.isHistoryEnabled
              ? null
              : null, // clear is implicit when disabled
        );
      }),

      SizedBox(
        width: Dimensions.webMaxWidth,
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
            ),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
                  decoration: InputDecoration(
                    hintText: 'search'.tr,
                    hintStyle: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    isDense: true,
                    prefixIcon: Icon(Icons.search, color: Theme.of(context).disabledColor, size: 24),
                    suffixIcon: _searchText.isNotEmpty ? IconButton(
                      icon: Icon(Icons.clear, color: Theme.of(context).disabledColor, size: 24),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchText = '';
                        });
                        FocusScope.of(context).unfocus();
                      },
                    ) : null,
                  ),
                  onChanged: (String query) {
                    setState(() {
                      _searchText = query;
                    });
                  },
                ),
              ),
                Container(
                margin: const EdgeInsets.all(5),
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.3)),
                ),
                child: DropdownButton<String>(
                  value: _searchType,
                  items: [
                    DropdownMenuItem(value: 'items', child: Text(Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == 'food' ? 'meals'.tr : 'items'.tr)),
                    DropdownMenuItem(value: 'stores', child: Text(Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText! ? 'restaurants'.tr : 'stores'.tr)),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _searchType = value!;
                    });
                  },
                  underline: const SizedBox(),
                  icon: Icon(Icons.keyboard_arrow_down, color: Theme.of(context).disabledColor),
                ),
              ),
            ]),
          ),
        ),
      ),

      Expanded(
        child: _searchType == 'items'
            ? _HistoryItemView(searchText: _searchText, isStore: false)
            : _HistoryItemView(searchText: _searchText, isStore: true),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Toggle banner
// ─────────────────────────────────────────────────────────────────────────────
class _HistoryToggleBanner extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback onToggle;
  final VoidCallback? onClearAll;

  const _HistoryToggleBanner({
    required this.isEnabled,
    required this.onToggle,
    this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent = Theme.of(context).primaryColor;
    return Container(
      width: Dimensions.webMaxWidth,
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeSmall,
        vertical: Dimensions.paddingSizeExtraSmall,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeSmall,
      ),
      decoration: BoxDecoration(
        color: isEnabled
            ? accent.withValues(alpha: 0.06)
            : Theme.of(context).disabledColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(
          color: isEnabled
              ? accent.withValues(alpha: 0.3)
              : Theme.of(context).disabledColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          // icon
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isEnabled
                  ? accent.withValues(alpha: 0.12)
                  : Theme.of(context).disabledColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isEnabled ? Icons.history : Icons.history_toggle_off,
              size: 18,
              color: isEnabled ? accent : Theme.of(context).disabledColor,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          // label
          Expanded(
            child: Text(
              'enable_disable'.tr,
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: isEnabled
                    ? accent
                    : Theme.of(context).disabledColor,
              ),
            ),
          ),

          // toggle switch
          Switch.adaptive(
            value: isEnabled,
            onChanged: (_) => _confirmToggle(context),
            activeColor: accent,
          ),
        ]),

        // hint text
        Padding(
          padding: const EdgeInsets.only(
              top: 4, left: 4, bottom: 2),
          child: Text(
            isEnabled
                ? 'history_saving_on_hint'.tr
                : 'history_saving_off_hint'.tr,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeExtraSmall,
              color: Theme.of(context).disabledColor,
            ),
          ),
        ),
      ]),
    );
  }

  void _confirmToggle(BuildContext context) {
    if (isEnabled) {
      // Warn user that disabling will clear the list
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
          title: Text('disable_history'.tr,
              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
          content: Text(
            'disable_history_warning'.tr,
            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr,
                  style: robotoMedium.copyWith(
                      color: Theme.of(context).disabledColor)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onToggle();
              },
              child: Text('disable'.tr,
                  style: robotoMedium.copyWith(
                      color: Theme.of(context).colorScheme.error)),
            ),
          ],
        ),
      );
    } else {
      onToggle();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Items / Stores list
// ─────────────────────────────────────────────────────────────────────────────
class _HistoryItemView extends StatelessWidget {
  final bool isStore;
  final String searchText;
  const _HistoryItemView(
      {required this.isStore, required this.searchText});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<ItemHistoryController>(
          builder: (itemHistoryController) {
        bool isFood = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == 'food';
        bool isShop = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == 'ecommerce';
        
        List<Item?>? historyItemList;
        List<Store?>? historyStoreList;

        int? currentModuleId = Get.find<SplashController>().module?.id;

        if (!isStore) {
          historyItemList = [];
          for (var item in itemHistoryController.recentlyViewedList) {
            if (item.moduleId == currentModuleId && (searchText.isEmpty || item.name!.toLowerCase().contains(searchText.toLowerCase()))) {
              historyItemList.add(item);
            }
          }
                } else {
          historyStoreList = [];
          for (var store in itemHistoryController.recentlyViewedStoreList) {
            if (store.moduleId == currentModuleId && (searchText.isEmpty || store.name!.toLowerCase().contains(searchText.toLowerCase()))) {
              historyStoreList.add(store);
            }
          }
                }

        final bool hasData = isStore
            ? (historyStoreList != null && historyStoreList.isNotEmpty)
            : (historyItemList != null && historyItemList.isNotEmpty);

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: FooterView(
            child: SizedBox(
              width: Dimensions.webMaxWidth,
              child: Padding(
                padding: EdgeInsets.only(
                    bottom:
                        ResponsiveHelper.isDesktop(context) ? 0 : 80.0),
                child: hasData
                    ? GridView.builder(
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              ResponsiveHelper.isMobile(context)
                                  ? (isStore ? 1 : 2)
                                  : ResponsiveHelper.isDesktop(context)
                                      ? 3
                                      : 3,
                          crossAxisSpacing:
                              ResponsiveHelper.isDesktop(context)
                                  ? Dimensions.paddingSizeExtremeLarge
                                  : Dimensions.paddingSizeSmall,
                          mainAxisSpacing:
                              ResponsiveHelper.isDesktop(context)
                                  ? Dimensions.paddingSizeExtremeLarge
                                  : Dimensions.paddingSizeSmall,
                          mainAxisExtent:
                              ResponsiveHelper.isDesktop(context) &&
                                      isStore
                                  ? 220
                                  : ResponsiveHelper.isMobile(context) &&
                                          isStore
                                      ? (isFood ? 250 : 200)
                                      : (isFood ? 220 :320),
                        ),
                        itemCount: isStore
                            ? historyStoreList!.length
                            : historyItemList!.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(
                            Dimensions.paddingSizeSmall),
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              isStore
                                  ? StoreCardWithDistance(
                                      store: historyStoreList![index]!,
                                      fromAllStore: true,
                                      isNewStore: false,
                                    )
                                  : ItemCard(
                                      item: historyItemList![index],
                                      isShop: isShop,
                                      isFood: isFood,
                                    ),

                              // ── Delete button (SharedPreferences only) ──
                              Positioned(
                                top: 4,
                                right: 4,
                                child: _DeleteBadge(
                                  onDelete: () {
                                    if (isStore) {
                                      final storeId =
                                          historyStoreList![index]!.id;
                                      if (storeId != null) {
                                        itemHistoryController
                                            .removeStoreFromHistory(
                                                storeId);
                                      }
                                    } else {
                                      final itemId =
                                          historyItemList![index]?.id;
                                      if (itemId != null) {
                                        itemHistoryController
                                            .removeItemFromHistory(
                                                itemId);
                                      }
                                    }
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      )
                    : Center(
                        child: Text('no_history_found'.tr)),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small delete badge shown over each card
// ─────────────────────────────────────────────────────────────────────────────
class _DeleteBadge extends StatelessWidget {
  final VoidCallback onDelete;
  const _DeleteBadge({required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDelete,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 6,
              spreadRadius: 1,
            )
          ],
        ),
        child: Icon(
          Icons.delete_outline,
          size: 17,
          color: Theme.of(context).colorScheme.error,
        ),
      ),
    );
  }
}
