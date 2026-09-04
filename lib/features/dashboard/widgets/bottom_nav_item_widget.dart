import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (!isSelected) {
              HapticFeedback.lightImpact();
            }
            onTap?.call();
          },
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Animated indicator pill at top
              Positioned(
                top: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeInOut,
                  width: isSelected ? 24 : 0,
                  height: isSelected ? 3 : 0,
                  decoration: BoxDecoration(
                    color: isSelected ? selectedColor : Colors.transparent,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(24),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: selectedColor.withValues(alpha: 0.35),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                ),
              ),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          transitionBuilder: (child, anim) => FadeTransition(
                            opacity: anim,
                            child: ScaleTransition(
                              scale: Tween<double>(begin: 0.85, end: 1.0).animate(CurvedAnimation(
                                parent: anim,
                                curve: Curves.easeOutBack,
                              )),
                              child: child,
                            ),
                          ),
                          child: iconUrl != null
                              ? CustomImage(
                                  key: ValueKey(isSelected),
                                  image: iconUrl!,
                                  height: 24,
                                  width: 24,
                                  color: isSelected ? selectedColor : unselectedColor,
                                )
                              : iconData != null
                                  ? Icon(
                                      key: ValueKey(isSelected),
                                      isSelected
                                          ? (selectedIconData ?? iconData)
                                          : iconData,
                                      color: isSelected ? selectedColor : unselectedColor,
                                      size: 24,
                                    )
                                  : Image.asset(
                                      key: ValueKey(isSelected),
                                      isSelected ? selectedIcon! : unSelectedIcon!,
                                      height: 24,
                                      width: 24,
                                      color: isSelected ? selectedColor : unselectedColor,
                                    ),
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
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: robotoRegular.copyWith(
                        color: isSelected ? selectedColor : unselectedColor,
                        fontSize: Dimensions.fontSizeSmall,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

