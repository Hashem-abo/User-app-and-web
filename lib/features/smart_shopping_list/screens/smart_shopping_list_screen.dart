import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/no_data_screen.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/cart/screens/cart_screen.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/smart_shopping_list/controllers/smart_shopping_list_controller.dart';
import 'package:sixam_mart/features/smart_shopping_list/widgets/smart_product_card.dart';
import 'package:sixam_mart/features/smart_shopping_list/widgets/smart_shopping_list_input_sheet.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class SmartShoppingListScreen extends StatelessWidget {
  const SmartShoppingListScreen({super.key});

  void _openEditSheet(BuildContext context) {
    if (ResponsiveHelper.isDesktop(context)) {
      Get.dialog(const Dialog(child: SmartShoppingListInputSheet()));
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (con) => const SmartShoppingListInputSheet(),
      );
    }
  }

  void _openStoreSelectorSheet(BuildContext context, SmartShoppingListController ctrl) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'choose_store_for_basket'.tr,
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Text(
                'stores_availability_hint'.tr,
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: ctrl.candidateStores.length,
                  itemBuilder: (context, index) {
                    final store = ctrl.candidateStores[index];
                    final bool isSelected = store.storeId == ctrl.selectedStoreId;

                    return Container(
                      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).primaryColor.withValues(alpha: 0.08)
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).disabledColor.withValues(alpha: 0.2),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: ListTile(
                        onTap: () {
                          ctrl.applyStoreFilter(store.storeId, store.storeName);
                          Get.back();
                        },
                        leading: CircleAvatar(
                          backgroundColor: isSelected
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).disabledColor.withValues(alpha: 0.15),
                          child: Icon(
                            Icons.storefront_rounded,
                            color: isSelected ? Colors.white : Theme.of(context).disabledColor,
                          ),
                        ),
                        title: Text(
                          store.storeName,
                          style: robotoBold.copyWith(
                            color: isSelected ? Theme.of(context).primaryColor : null,
                          ),
                        ),
                        subtitle: Text(
                          '${'provides'.tr} ${store.availableItemsCount} ${'of'.tr} ${ctrl.keywords.length} ${'items'.tr}',
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: store.availableItemsCount == ctrl.keywords.length
                                ? Colors.green
                                : Theme.of(context).hintColor,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check_circle_rounded, color: Theme.of(context).primaryColor)
                            : const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(
        title: 'smart_shopping_results'.tr,
        menuWidget: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.edit_note_rounded, color: Theme.of(context).primaryColor, size: 22),
          ),
          tooltip: 'edit_list'.tr,
          onPressed: () => _openEditSheet(context),
        ),
      ),
      body: GetBuilder<SmartShoppingListController>(
        builder: (ctrl) {
          if (ctrl.keywords.isEmpty) {
            return Center(
              child: NoDataScreen(
                text: 'no_shopping_list_items'.tr,
                showFooter: false,
              ),
            );
          }

          final String? currentStoreName = ctrl.selectedStoreName;

          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async {
                  if (ctrl.rawInput.isNotEmpty) {
                    await ctrl.searchList(ctrl.rawInput);
                  }
                },
                child: ListView.builder(
                  padding: const EdgeInsets.only(
                    top: Dimensions.paddingSizeSmall,
                    bottom: 100, // Space for bottom persistent cart bar
                  ),
                  itemCount: ctrl.keywords.length + 1, // +1 for store header
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // Top Single-Store Banner
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeDefault,
                          vertical: Dimensions.paddingSizeSmall,
                        ),
                        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).primaryColor,
                              Theme.of(context).primaryColor.withValues(alpha: 0.82),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.28),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 24),
                                ),
                                const SizedBox(width: Dimensions.paddingSizeSmall),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        currentStoreName ?? 'best_store_selected'.tr,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: robotoBold.copyWith(
                                          color: Colors.white,
                                          fontSize: Dimensions.fontSizeLarge,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${'all_items_from_one_store'.tr} (${ctrl.availableCount} ${'of'.tr} ${ctrl.keywords.length} ${'available'.tr})',
                                        style: robotoRegular.copyWith(
                                          color: Colors.white.withValues(alpha: 0.9),
                                          fontSize: Dimensions.fontSizeSmall,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (ctrl.candidateStores.length > 1)
                                  TextButton.icon(
                                    onPressed: () => _openStoreSelectorSheet(context, ctrl),
                                    icon: const Icon(Icons.swap_horiz_rounded, size: 16, color: Colors.white),
                                    label: Text(
                                      'change_store'.tr,
                                      style: robotoMedium.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeSmall),
                                    ),
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }

                    // Keyword Item Section
                    String keyword = ctrl.keywords[index - 1];
                    bool isLoading = ctrl.keywordLoading[keyword] ?? false;
                    List<Item> items = ctrl.results[keyword] ?? [];

                    return _KeywordSectionWidget(
                      keyword: keyword,
                      isLoading: isLoading,
                      items: items,
                      storeName: currentStoreName,
                      onRetry: () => ctrl.retryKeyword(keyword),
                    );
                  },
                ),
              ),

              // Bottom Persistent Cart Summary Bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: GetBuilder<CartController>(
                  builder: (cartController) {
                    if (cartController.cartList.isEmpty) {
                      return const SizedBox();
                    }

                    double totalCartAmount = 0;
                    int totalCount = 0;
                    for (var cart in cartController.cartList) {
                      totalCartAmount += (cart.price ?? 0) * (cart.quantity ?? 1);
                      totalCount += (cart.quantity ?? 1);
                    }

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault,
                        vertical: Dimensions.paddingSizeSmall,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                            blurRadius: 16,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        top: false,
                        child: Row(
                          children: [
                            // Cart count & price
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.shopping_cart_rounded, size: 18, color: Theme.of(context).primaryColor),
                                      const SizedBox(width: 6),
                                      Text(
                                        '$totalCount ${'items_in_cart'.tr}',
                                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    PriceConverter.convertPrice(totalCartAmount),
                                    style: robotoBold.copyWith(
                                      fontSize: Dimensions.fontSizeLarge,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Checkout / View Cart Button
                            CustomButton(
                              width: 150,
                              buttonText: 'view_cart'.tr,
                              icon: Icons.arrow_forward_rounded,
                              onPressed: () {
                                Get.to(() => const CartScreen(fromNav: false));
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _KeywordSectionWidget extends StatelessWidget {
  final String keyword;
  final bool isLoading;
  final List<Item> items;
  final String? storeName;
  final VoidCallback onRetry;

  const _KeywordSectionWidget({
    required this.keyword,
    required this.isLoading,
    required this.items,
    this.storeName,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    bool isAvailable = items.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        color: isAvailable
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).disabledColor.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      keyword,
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        color: isAvailable ? null : Theme.of(context).disabledColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isAvailable
                            ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isLoading
                            ? '...'
                            : isAvailable
                                ? '${items.length} ${'product'.tr}'
                                : 'not_available'.tr,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall,
                          color: isAvailable ? Theme.of(context).primaryColor : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
                if (!isLoading && items.isEmpty)
                  TextButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh, size: 14),
                    label: Text('retry'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall)),
                  ),
              ],
            ),
          ),

          const SizedBox(height: Dimensions.paddingSizeSmall),

          // Horizontal Products Carousel or Shimmer/Not Available state
          if (isLoading)
            SizedBox(
              height: 230,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                itemCount: 4,
                itemBuilder: (context, i) => _buildShimmerCard(context),
              ),
            )
          else if (items.isEmpty)
            Container(
              height: 90,
              margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.remove_shopping_cart_outlined, color: Colors.red, size: 20),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${'item_not_available_in'.tr} ${storeName ?? 'this_store'.tr}',
                          style: robotoMedium.copyWith(
                            color: Colors.red.shade700,
                            fontSize: Dimensions.fontSizeSmall,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'item_missing_from_store_desc'.tr,
                          style: robotoRegular.copyWith(
                            color: Theme.of(context).hintColor,
                            fontSize: Dimensions.fontSizeExtraSmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              height: 235,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                itemCount: items.length,
                itemBuilder: (context, i) {
                  return SmartProductCard(item: items[i]);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildShimmerCard(BuildContext context) {
    return Container(
      width: 170,
      margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 12,
            width: 100,
            decoration: BoxDecoration(
              color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 14,
            width: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
