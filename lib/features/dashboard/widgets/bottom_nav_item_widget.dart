import 'package:flutter/material.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class BottomNavItemWidget extends StatelessWidget {
  final String? selectedIcon;
  final String? unSelectedIcon;
  final String? iconUrl;
  final IconData? iconData;
  final IconData? selectedIconData;
  final String title;
  final Function? onTap;
  final bool isSelected;
  final int cartCount;
  const BottomNavItemWidget({super.key, this.onTap, this.isSelected = false, required this.title, this.selectedIcon, this.unSelectedIcon, this.iconUrl, this.iconData, this.selectedIconData, this.cartCount = 0});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap as void Function()?,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: isSelected ? BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(Dimensions.radiusDefault)),
          ) : null,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            
            Stack(clipBehavior: Clip.none, children: [
              iconUrl != null ? CustomImage(
                image: iconUrl!,
                height: 24, width: 24,
                color: isSelected ? Colors.white : null,
              ) : iconData != null ? Icon(
                isSelected ? (selectedIconData ?? iconData) : iconData,
                color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium!.color!,
                size: 24,
              ) : Image.asset(
                isSelected ? selectedIcon! : unSelectedIcon!, height: 25, width: 25,
                color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium!.color!,
              ),

              cartCount > 0 ? Positioned(
                top: -5, right: -5,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor, shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).cardColor, width: 1.5),
                  ),
                  child: Text(
                    cartCount.toString(),
                    style: robotoMedium.copyWith(color: Theme.of(context).cardColor, fontSize: 8),
                  ),
                ),
              ) : const SizedBox(),
            ]),

            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            Text(
              title,
              style: robotoRegular.copyWith(color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium!.color!, fontSize: 12),
            ),

          ]),
        ),
      ),
    );
  }
}
