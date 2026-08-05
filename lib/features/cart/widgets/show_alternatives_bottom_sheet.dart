import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/item_widget.dart';
import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class ShowAlternativesBottomSheet extends StatefulWidget {
  final Item item;
  final int cartIndex;
  const ShowAlternativesBottomSheet({super.key, required this.item, required this.cartIndex});

  @override
  State<ShowAlternativesBottomSheet> createState() => _ShowAlternativesBottomSheetState();
}

class _ShowAlternativesBottomSheetState extends State<ShowAlternativesBottomSheet> {

  @override
  void initState() {
    super.initState();
    if(widget.item.categoryIds != null && widget.item.categoryIds!.isNotEmpty) {
      Get.find<CategoryController>().getCategoryItemList(
        widget.item.categoryIds![0].id.toString(), 1, 'all', false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, spreadRadius: 5)],
      ),
      child: GetBuilder<CategoryController>(builder: (categoryController) {
        List<Item>? alternatives = categoryController.categoryItemList?.where((element) => element.id != widget.item.id).toList();

        return Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            height: 5, width: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).disabledColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            child: Column(children: [
              Text(
                'suggested_alternatives'.tr == 'suggested_alternatives' ? 'بدائل مقترحة' : 'suggested_alternatives'.tr,
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Text(
                'find_something_similar'.tr == 'find_something_similar' ? 'ابحث عن شيء مشابه لما كنت تريده' : 'find_something_similar'.tr,
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
              ),
            ]),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            child: Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).disabledColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                border: Border.all(color: Theme.of(context).disabledColor.withOpacity(0.1)),
              ),
              child: Row(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  child: CustomImage(
                    image: '${widget.item.imageFullUrl}',
                    height: 40, width: 40, fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      widget.item.name!,
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'out_of_stock'.tr,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).colorScheme.error),
                    ),
                  ]),
                ),
              ]),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          categoryController.categoryItemList == null ? const Padding(
            padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
            child: CircularProgressIndicator(),
          ) : alternatives == null || alternatives.isEmpty ? Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Column(children: [
              Icon(Icons.search_off, size: 50, color: Theme.of(context).disabledColor),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Text(
                'no_alternatives_found'.tr == 'no_alternatives_found' ? 'لم يتم العلم العثور على بدائل حالياً' : 'no_alternatives_found'.tr,
                style: robotoMedium.copyWith(color: Theme.of(context).disabledColor),
              ),
            ]),
          ) : ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              itemCount: alternatives.length,
              itemBuilder: (context, index) {
                return SizedBox(
                  height: 110,
                  child: ItemWidget(
                    item: alternatives[index],
                    isStore: false,
                    store: null,
                    index: index,
                    length: alternatives.length,
                    fromCartSuggestion: true,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
        ]);
      }),
    );
  }
}
