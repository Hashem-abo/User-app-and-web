import 'package:flutter/material.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';

// This widget displays the modules/categories horizontally // + ahmed
class HorizontalModuleView extends StatelessWidget {
  final SplashController splashController;
  const HorizontalModuleView({super.key, required this.splashController});

  @override
  Widget build(BuildContext context) {
    // If no modules are available, return an empty box // + ahmed
    if (splashController.moduleList == null || splashController.moduleList!.isEmpty) {
      return const SizedBox();
    }

    return Container(
      height: 105, // Increased height for larger icons // + ahmed
      padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
        physics: const BouncingScrollPhysics(),
        itemCount: splashController.moduleList!.length,
        itemBuilder: (context, index) {
          
          // Check if this module is selected // + ahmed
          bool isSelected = splashController.module != null && 
                            splashController.module!.id == splashController.moduleList![index].id;

          return InkWell(
            onTap: () => splashController.switchModule(index, true), // Switch module on tap // + ahmed
            child: Padding(
              padding: const EdgeInsets.only(right: Dimensions.paddingSizeLarge),
              child: Column(
                children: [
                  Container(
                    height: 65, width: 65, // ahmed: Increased size to 65
                    padding: const EdgeInsets.all(2), 
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault), // ahmed: More pronounced square
                      border: Border.all(
                        color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withOpacity(0.3), 
                        width: isSelected ? 3 : 1
                      ), // Highlight selected module
                    ),
                    child: ClipRRect( // ahmed: ClipRRect for square
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      child: CustomImage(
                        image: '${splashController.moduleList![index].iconFullUrl}', // Module icon
                        height: 65, width: 65,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  Text(
                    splashController.moduleList![index].moduleName ?? '', // Module name // + ahmed
                    textAlign: TextAlign.center,
                    maxLines: 1, // Allow 2 lines // + ahmed
                    overflow: TextOverflow.ellipsis,
                    style: isSelected 
                        ? robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)
                        : robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
