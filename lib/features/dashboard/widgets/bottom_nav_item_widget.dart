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
  const BottomNavItemWidget(
      {super.key,
      this.onTap,
      this.isSelected = false,
      required this.title,
      this.selectedIcon,
      this.unSelectedIcon,
      this.iconUrl,
      this.iconData,
      this.selectedIconData,
      this.cartCount = 0});

  @override
  Widget build(BuildContext context) {
    final Color selectedColor = Theme.of(context).primaryColor;
    final Color unselectedColor =
        Theme.of(context).textTheme.bodyMedium!.color!.withAlpha(150);

    return Expanded(
      child: InkWell(
        onTap: onTap as void Function()?,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            if (isSelected)
              Positioned(
                top: 0,
                child: Container(
                  width: 12,
                  height: 8,
                  decoration: BoxDecoration(
                    color: selectedColor,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: selectedColor.withOpacity(0.20),
                        blurRadius: 6,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                ),
              ),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      if (iconUrl != null)
                        CustomImage(
                          image: iconUrl!,
                          height: 24,
                          width: 24,
                          color: isSelected ? selectedColor : unselectedColor,
                        )
                      else if (iconData != null)
                        Icon(
                          isSelected
                              ? (selectedIconData ?? iconData)
                              : iconData,
                          color: isSelected ? selectedColor : unselectedColor,
                          size: 24,
                        )
                      else
                        Image.asset(
                          isSelected ? selectedIcon! : unSelectedIcon!,
                          height: 25,
                          width: 25,
                          color: isSelected ? selectedColor : unselectedColor,
                        ),
                      if (cartCount > 0)
                        PositionedDirectional(
                          top: -5,
                          end: -7,
                          child: Container(
                            constraints: const BoxConstraints(
                              minWidth: 17,
                              minHeight: 17,
                            ),
                            padding: const EdgeInsets.all(3),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: selectedColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).cardColor,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              cartCount > 99 ? '99+' : cartCount.toString(),
                              style: robotoMedium.copyWith(
                                color: Theme.of(context).cardColor,
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(
                    height: Dimensions.paddingSizeExtraSmall,
                  ),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: robotoRegular.copyWith(
                      color: isSelected ? selectedColor : unselectedColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
