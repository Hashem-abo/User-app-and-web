import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/service/controllers/service_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class ServiceCategoriesView extends StatelessWidget {
  const ServiceCategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServiceController>(builder: (serviceController) {
      if (serviceController.categories == null) {
        return const Center(child: CircularProgressIndicator());
      }
      return Container(
        height: 110,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: serviceController.categories!.length + 1,
          padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
          itemBuilder: (context, index) {
            bool isAll = index == 0;
            bool isSelected = isAll ? serviceController.selectedCategory == -1 : serviceController.selectedCategory == index - 1;
            return InkWell(
              onTap: () {
                serviceController.setCategory(isAll ? -1 : index - 1);
              },
              child: Container(
                width: 80,
                margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                child: Column(children: [
                  Container(
                    height: 60, width: 60,
                    decoration: BoxDecoration(
                      color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withOpacity(0.3)),
                    ),
                    child: Center(
                      child: isAll ? Icon(Icons.grid_view_rounded, color: isSelected ? Colors.white : Theme.of(context).primaryColor) : ClipRRect(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        child: CustomImage(
                          image: '${serviceController.categories![index - 1].imageFullUrl}',
                          height: 55, width: 55, fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  Text(
                    isAll ? 'all'.tr : serviceController.categories![index - 1].name ?? '',
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyMedium!.color),
                    maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                  ),
                ]),
              ),
            );
          },
        ),
      );
    });
  }
}
