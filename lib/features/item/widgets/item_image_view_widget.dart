import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/helper/color_converter.dart';
class ItemImageViewWidget extends StatelessWidget {
  final Item? item;
  final bool isCampaign;
  ItemImageViewWidget({super.key, required this.item, this.isCampaign = false});

  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {

    return GetBuilder<ItemController>(builder: (itemController) {
      if (item == null) {
        return const SizedBox();
      }

      List<String?> imageList = [];
      List<String?> imageListForCampaign = [];
      bool isVariantImage = false;

      if(isCampaign){
        imageListForCampaign.add(item!.imageFullUrl);
      }else{
        Variation? selectedVariation;
        if (item!.variations != null && item!.choiceOptions != null && itemController.variationIndex != null && itemController.variationIndex!.length >= item!.choiceOptions!.length) {
          List<String> variationList = [];
          for (int index = 0; index < item!.choiceOptions!.length; index++) {
            if (item!.choiceOptions![index].options != null && item!.choiceOptions![index].options!.length > itemController.variationIndex![index]) {
              variationList.add(item!.choiceOptions![index].options![itemController.variationIndex![index]].replaceAll(' ', ''));
            }
          }
          String variationType = '';
          bool isFirst = true;
          for (var variation in variationList) {
            if (isFirst) {
              variationType = '$variationType$variation';
              isFirst = false;
            } else {
              variationType = '$variationType-$variation';
            }
          }
          for (Variation v in item!.variations!) {
            if (v.type == variationType) {
              selectedVariation = v;
              break;
            }
          }
        }

        if (selectedVariation != null && selectedVariation.imagesFullUrl != null && selectedVariation.imagesFullUrl!.isNotEmpty) {
          imageList.addAll(selectedVariation.imagesFullUrl!);
          isVariantImage = true;
        } else {
          imageList.add(item!.imageFullUrl);
          if(item!.imagesFullUrl != null){
            imageList.addAll(item!.imagesFullUrl!);
          }
        }
      }

      Color? selectedColor;
      if (item!.choiceOptions != null && itemController.variationIndex != null) {
        for (int i = 0; i < item!.choiceOptions!.length; i++) {
          String? title = item!.choiceOptions![i].title;
          if (title != null && (title.toLowerCase().contains('color') || title.contains('لون'))) {
            if (itemController.variationIndex!.length > i) {
              int selectedIndex = itemController.variationIndex![i];
              if (item!.choiceOptions![i].options != null && item!.choiceOptions![i].options!.length > selectedIndex) {
                String optionName = item!.choiceOptions![i].options![selectedIndex];
                selectedColor = ColorConverter.getColorFromOption(optionName);
              }
            }
            break;
          }
        }
      }

      return Column(mainAxisSize: MainAxisSize.min, children: [

          InkWell(
            onTap: isCampaign ? null : () {
              if(!isCampaign) {
                Get.toNamed(RouteHelper.getItemImagesRoute(item!));
              }
            },
            child: Stack(children: [
              SizedBox(
                height: ResponsiveHelper.isDesktop(context)? 400: MediaQuery.of(context).size.width,
                child: PageView.builder(
                  controller: _controller,
                  itemCount: isCampaign ? imageListForCampaign.length : imageList.length,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.zero,
                      child: (selectedColor != null && !isVariantImage) 
                        ? ColorFiltered(
                            colorFilter: ColorFilter.mode(selectedColor, BlendMode.overlay),
                            child: ColorFiltered(
                              colorFilter: const ColorFilter.matrix(<double>[
                                0.5, 0.5, 0.5, 0, -0.4,
                                0.5, 0.5, 0.5, 0, -0.4,
                                0.5, 0.5, 0.5, 0, -0.4,
                                0,   0,   0,   1, 0,
                              ]),
                              child: CustomImage(
                                image: '${isCampaign ? imageListForCampaign[index] : imageList[index]}',
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : CustomImage(
                            image: '${isCampaign ? imageListForCampaign[index] : imageList[index]}',
                            fit: BoxFit.cover,
                          ),
                    );
                  },
                  onPageChanged: (index) {
                    itemController.setImageSliderIndex(index);
                  },
                ),
              ),
              Positioned(
                left: 0, right: 0, bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _indicators(context, itemController, isCampaign ? imageListForCampaign : imageList),
                  ),
                ),
              ),

              // Overlay Icons moved to app bar

              // Removed video button from here as it will be floating on the entire page


            ]),
          ),

      ]);
    });
  }

  List<Widget> _indicators(BuildContext context, ItemController itemController, List<String?> imageList) {
    List<Widget> indicators = [];
    for (int index = 0; index < imageList.length; index++) {
      indicators.add(TabPageSelectorIndicator(
        backgroundColor: index == itemController.imageSliderIndex ? Theme.of(context).primaryColor : Colors.white,
        borderColor: Colors.white,
        size: 10,
      ));
    }
    return indicators;
  }

}
