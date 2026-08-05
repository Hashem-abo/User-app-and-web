import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';

class ModuleSelector extends StatelessWidget {
  final double height;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final void Function(int)? onModuleSelected;

  const ModuleSelector({
    super.key,
    this.height = 80,
    this.backgroundColor,
    this.padding,
    this.onModuleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(builder: (splashCtrl) {
      final list = splashCtrl.moduleList;
      if (list == null || list.isEmpty) return const SizedBox.shrink();

      return Container(
        color: backgroundColor ?? Theme.of(context).cardColor,
        height: height,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 8),
          physics: const BouncingScrollPhysics(),
          itemCount: list.length,
          itemBuilder: (context, index) {
            bool isSelected = splashCtrl.module != null && splashCtrl.module!.id == list[index].id;
            return InkWell(
              onTap: () {
                splashCtrl.switchModule(index, true);
                onModuleSelected?.call(index);
              },
              child: Container(
                width: 60,
                margin: const EdgeInsets.only(right: Dimensions.paddingSizeDefault),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 44, width: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
                          width: isSelected ? 2.5 : 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: CustomImage(
                          image: '${list[index].iconFullUrl}',
                          height: 44, width: 44,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      list[index].moduleName ?? '',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall,
                        color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }
}