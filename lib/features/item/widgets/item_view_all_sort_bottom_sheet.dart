import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

// ... existing imports

class ItemViewAllSortBottomSheet extends StatelessWidget {
  final bool isPopular;
  final bool isSpecial;
  final bool fromDialog;
  const ItemViewAllSortBottomSheet({super.key, required this.isPopular, required this.isSpecial, this.fromDialog = false});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ItemController>(builder: (itemController) {
      return Container(
        constraints: BoxConstraints(
          // Set a max height instead of a fixed height to avoid overflow
          maxHeight: fromDialog ? 450 : context.height * 0.8,
        ),
        width: fromDialog ? 475 : context.width > 700 ? 700 : context.width,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.vertical(
            top: const Radius.circular(Dimensions.radiusExtraLarge),
            bottom: Radius.circular(fromDialog ? Dimensions.radiusExtraLarge : 0),
          ),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [

          // --- Handle/Close Button ---
          SizedBox(height: fromDialog ? 0 : Dimensions.paddingSizeLarge),
          _buildHandle(context),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          Text('sort_by'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),

          // --- Scrollable Options Area ---
          // This Expanded + SingleChildScrollView prevents the overflow!
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: Dimensions.paddingSizeDefault),

                ...itemController.sortOptions.map((option) {
                  return FilterButton(
                    title: option.tr,
                    isSelected: itemController.selectedSortOption == option,
                    onTap: () => itemController.setSelectedSortOption(option),
                  );
                }),
              ]),
            ),
          ),

          // --- Action Buttons ---
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Row(children: [
              Expanded(
                child: CustomButton(
                  buttonText: 'reset'.tr,
                  transparent: true, // Modern transparent style
                  color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                  textColor: Theme.of(context).textTheme.bodyLarge!.color,
                  onPressed: () {
                    itemController.resetFilters(isPopular: isPopular, isSpecial: isSpecial);
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeDefault),
              Expanded(
                child: CustomButton(
                  buttonText: 'apply'.tr, // Changed 'sort_by' to 'apply' for better UX
                  onPressed: () {
                    itemController.applyFilters(isPopular: isPopular, isSpecial: isSpecial);
                    Navigator.pop(context);
                  },
                ),
              ),
            ]),
          ),
        ]),
      );
    });
  }

  Widget _buildHandle(BuildContext context) {
    return ResponsiveHelper.isDesktop(context)
        ? Align(
      alignment: Alignment.topRight,
      child: IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close)),
    )
        : Container(
      height: 5, width: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).hintColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
    );
  }
}
class FilterButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final Function onTap;
  const FilterButton({super.key, required this.title, this.isSelected = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title, style: robotoRegular),

        RadioGroup(
          groupValue: true,
          onChanged: (bool? value) {
            onTap();
          },
          child: Radio(
            value: isSelected,
            activeColor: Theme.of(context).primaryColor,
            fillColor: WidgetStateProperty.all(isSelected ? Theme.of(context).primaryColor :Theme.of(context).disabledColor),
          ),
        ),

      ]),
    );
  }
}