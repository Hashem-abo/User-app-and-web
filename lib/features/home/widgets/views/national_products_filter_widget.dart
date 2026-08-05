import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class NationalProductsFilterWidget extends StatefulWidget {
  const NationalProductsFilterWidget({super.key});

  @override
  State<NationalProductsFilterWidget> createState() => _NationalProductsFilterWidgetState();
}

class _NationalProductsFilterWidgetState extends State<NationalProductsFilterWidget> {
  final ScrollController _scrollController = ScrollController();
  String _lastFilterType = 'latest';

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ItemController>(builder: (itemController) {
      if (_lastFilterType != itemController.nationalFilterType) {
        _lastFilterType = itemController.nationalFilterType;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          List<String> tabs = ['latest', 'popular', 'recommended', 'discounted', 'most-reviewed'];
          int index = tabs.indexOf(_lastFilterType);
          if (index != -1 && _scrollController.hasClients) {
            double offset = index * 100.0; // Approx width of each tab
            if (offset > _scrollController.position.maxScrollExtent) {
              offset = _scrollController.position.maxScrollExtent;
            }
            _scrollController.animateTo(offset, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
          }
        });
      }
      return Container(
        height: 90,
        width: Dimensions.webMaxWidth,
        color: Theme.of(context).colorScheme.surface,
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
              child: Text(
                'explore_more'.tr,
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge ,  color:Theme.of(context).textTheme.bodyLarge!.color),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Expanded(
              child: ListView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                children: [
                  _buildTab(context, itemController, 'latest'.tr, 'latest', Icons.local_fire_department_outlined),
                  _buildTab(context, itemController, 'popular'.tr, 'popular', Icons.trending_up),
                  _buildTab(context, itemController, 'recommended'.tr, 'recommended', Icons.recommend_outlined),
                  _buildTab(context, itemController, 'discounted'.tr, 'discounted', Icons.local_offer_outlined),
                  _buildTab(context, itemController, 'most_reviewed'.tr, 'most-reviewed', Icons.star_outline),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTab(BuildContext context, ItemController itemController, String title, String type, IconData icon) {
    bool isSelected = itemController.nationalFilterType == type;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: Dimensions.paddingSizeSmall),
      child: Center(
        child: InkWell(
          onTap: () => itemController.setNationalFilterType(type),
          borderRadius: BorderRadius.circular(50),
          child: Container(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withOpacity(0.3)),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 28,
                width: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      spreadRadius: 1,
                    )
                  ],
                ),
                alignment: Alignment.center,
                child: type == 'latest'
                    ? const Text('🔥', style: TextStyle(fontSize: 16))
                    : Icon(
                        icon,
                        size: 16,
                        color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).primaryColor,
                      ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Text(
                title,
                style: robotoBold.copyWith(
                  color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge!.color,
                  fontSize: Dimensions.fontSizeDefault,
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
