import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
// import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart'; // + ahmed
import 'package:sixam_mart/features/location/widgets/zone_selection_bottom_sheet.dart';
import 'package:sixam_mart/helper/auth_helper.dart'; // + ahmed
import 'package:sixam_mart/helper/address_helper.dart'; // + ahmed
// import 'package:sixam_mart/util/images.dart';
// import 'package:sixam_mart/features/store/controllers/store_controller.dart';

// ahmed: Delegate for sticky module header with transition
// ahmed: Delegate for sticky module header with transition
class ModuleStickyDelegate extends SliverPersistentHeaderDelegate {
  final SplashController splashController;
  final double expandedHeight;
  final double collapsedHeight;
  final Widget? searchBar; // ahmed: Optional search bar content
  final double searchBarHeight;
  final ScrollController? expandedScrollController;
  final ScrollController? collapsedScrollController;

  final double paddingTop; // ahmed: padding top from media query

  bool get showLocationHeader =>
      splashController.module?.showLocationHeader ?? false;
  String? get locationHeaderFontColor =>
      splashController.module?.locationHeaderFontColor;

  ModuleStickyDelegate({
    required this.splashController,
    this.expandedHeight = 115,
    this.collapsedHeight = 60,
    this.searchBar,
    this.searchBarHeight = 120,
    this.paddingTop = 0, // ahmed: new parameter
    this.expandedScrollController,
    this.collapsedScrollController,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // Calculating offsets inside delegate build is no longer necessary as it is managed by persistent controllers.

    double shrinkableAmount = maxExtent - minExtent;
    double percent = (shrinkOffset / shrinkableAmount).clamp(0.0, 1.0);
    bool isCollapsed = percent > 0.5;

    return Container(
      color: Theme.of(context).colorScheme.surface, // Base color
      child: Stack(
        children: [
          // Unified Sky Background
          Positioned.fill(
            child: Opacity(
              opacity: 1, // ahmed: Increased visibility to 70% as requested
              child: ShaderMask(
                shaderCallback: (rect) {
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black, Colors.transparent],
                    stops: [0.5, 1.0],
                  ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
                },
                blendMode: BlendMode.dstIn,
                child: splashController.module?.skyHeaderFullUrl != null
                    ? CustomImage(
                        image: splashController.module!.skyHeaderFullUrl!,
                        fit: BoxFit.cover,
                        isUseMemCache: false,
                      )
                    : Image.asset(
                        "assets/image/sky_header.jpg",
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                            color: Colors.blue.withValues(alpha: 0.1)),
                      ),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(
                top: paddingTop), // ahmed: Apply top padding here
            child: Column(
              children: [
                // Module Area (Transitioning)
                Expanded(
                  child: Stack(
                    children: [
                      // Expanded View (Icons + Text)
                      IgnorePointer(
                        ignoring: isCollapsed,
                        child: Opacity(
                          opacity: (1 - percent).clamp(0.0, 1.0),
                          child: SingleChildScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            child: SizedBox(
                              height: expandedHeight,
                              child: ListView.builder(
                                controller: expandedScrollController,
                                scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.only(
                                        left: Dimensions.paddingSizeSmall,
                                        right: Dimensions.paddingSizeSmall,
                                        top: Dimensions.paddingSizeSmall),
                                    physics: const BouncingScrollPhysics(),
                                    itemCount:
                                        splashController.moduleList?.length ??
                                            0,
                                    itemBuilder: (context, index) {
                                      bool isSelected = splashController
                                                  .module !=
                                              null &&
                                          (splashController.module!.id ==
                                                  splashController
                                                      .moduleList![index].id ||
                                              (splashController
                                                          .module!.moduleType !=
                                                      null &&
                                                  splashController
                                                          .module!.moduleType ==
                                                      splashController
                                                          .moduleList![index]
                                                          .moduleType));
                                      return InkWell(
                                        onTap: () => splashController
                                            .switchModule(index, true),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              right:
                                                  Dimensions.paddingSizeSmall),
                                          child: Builder(
                                            builder: (context) {
                                              double buttonWidth =
                                                  splashController
                                                          .moduleList![index]
                                                          .moduleButtonWidth ??
                                                      65;
                                              double buttonHeight =
                                                  splashController
                                                          .moduleList![index]
                                                          .moduleButtonHeight ??
                                                      65;
                                              String textPosition = splashController
                                                      .moduleList![index]
                                                      .moduleViewTextPosition ??
                                                  'bottom';

                                              Widget imageContainer =
                                                  AnimatedScale(
                                                scale: isSelected ? 1.05 : 1.0,
                                                duration: const Duration(
                                                    milliseconds: 300),
                                                curve: Curves.easeOutBack,
                                                child: AnimatedContainer(
                                                  duration: const Duration(
                                                      milliseconds: 300),
                                                  curve: Curves.easeInOut,
                                                  height: buttonHeight,
                                                  width: buttonWidth,

                                                  // مساحة داخلية لإظهار الإطار دون تغطية الصورة له
                                                  padding: EdgeInsets.all(
                                                      isSelected ? 1 : 0),

                                                  decoration: BoxDecoration(
                                                    color: isSelected
                                                        ? Theme.of(context)
                                                            .primaryColor
                                                        : null,

                                                    // إطار بلون الثيم للعنصر المحدد فقط
                                                    border: isSelected
                                                        ? Border.all(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor,
                                                            width: 2,
                                                          )
                                                        : null,

                                                    borderRadius: splashController
                                                                .moduleList![
                                                                    index]
                                                                .moduleButtonShape ==
                                                            'square'
                                                        ? BorderRadius.circular(
                                                            (splashController
                                                                        .moduleList![
                                                                            index]
                                                                        .moduleButtonRadius ??
                                                                    15)
                                                                .toDouble(),
                                                          )
                                                        : BorderRadius.circular(
                                                            100),
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius: splashController
                                                                .moduleList![
                                                                    index]
                                                                .moduleButtonShape ==
                                                            'square'
                                                        ? BorderRadius.circular(
                                                            ((splashController.moduleList![index].moduleButtonRadius ??
                                                                            15)
                                                                        .toDouble() -
                                                                    2.5)
                                                                .clamp(
                                                                    0.0,
                                                                    double
                                                                        .infinity),
                                                          )
                                                        : BorderRadius.circular(
                                                            100),
                                                    child: CustomImage(
                                                      image:
                                                          '${splashController.moduleList![index].iconFullUrl}',
                                                      height: buttonHeight,
                                                      width: buttonWidth,
                                                      fit: BoxFit.contain,
                                                    )
                                                        .animate(
                                                          target: isSelected
                                                              ? 1
                                                              : 0,
                                                          onPlay: (controller) {
                                                            if (isSelected) {
                                                              controller.repeat(
                                                                  reverse:
                                                                      true);
                                                            }
                                                          },
                                                        )
                                                        .scaleXY(
                                                          end: 1.1,
                                                          duration: 800.ms,
                                                          curve:
                                                              Curves.easeInOut,
                                                        ),
                                                  ),
                                                ),
                                              );
                                              Widget textWidget = Container(
                                                padding: isSelected
                                                    ? const EdgeInsets
                                                        .symmetric(
                                                        horizontal: Dimensions
                                                            .paddingSizeSmall,
                                                        vertical: 2)
                                                    : null,
                                                decoration: isSelected
                                                    ? BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: BorderRadius
                                                            .circular(Dimensions
                                                                .radiusSmall))
                                                    : null,
                                                child: Text(
                                                  splashController
                                                          .moduleList![index]
                                                          .moduleName ??
                                                      '',
                                                  textAlign: TextAlign.center,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: isSelected
                                                      ? robotoBold.copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeDefault,
                                                          color: Theme.of(context)
                                                              .primaryColor)
                                                      : robotoRegular.copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeDefault,
                                                          color: splashController.moduleList![index].moduleButtonUnselectedColor != null
                                                              ? Color(int.parse(splashController
                                                                  .moduleList![
                                                                      index]
                                                                  .moduleButtonUnselectedColor!
                                                                  .replaceFirst(
                                                                      '#', '0xff')))
                                                              : Colors.white),
                                                ),
                                              );

                                              Widget moduleWidget;
                                              if (textPosition == 'top') {
                                                moduleWidget = Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    textWidget,
                                                    const SizedBox(
                                                        height: Dimensions
                                                            .paddingSizeExtraSmall),
                                                    imageContainer,
                                                  ],
                                                );
                                              } else if (textPosition ==
                                                  'left') {
                                                moduleWidget = Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    RotatedBox(
                                                      quarterTurns: 3,
                                                      child: textWidget,
                                                    ),
                                                    const SizedBox(
                                                        width: Dimensions
                                                            .paddingSizeExtraSmall),
                                                    imageContainer,
                                                  ],
                                                );
                                              } else if (textPosition ==
                                                  'right') {
                                                moduleWidget = Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    imageContainer,
                                                    const SizedBox(
                                                        width: Dimensions
                                                            .paddingSizeExtraSmall),
                                                    RotatedBox(
                                                      quarterTurns: 1,
                                                      child: textWidget,
                                                    ),
                                                  ],
                                                );
                                              } else if (textPosition ==
                                                  'hide') {
                                                moduleWidget = Padding(
                                                  padding: const EdgeInsets.only(
                                                      bottom: 2),
                                                  child: imageContainer,
                                                );
                                              } else {
                                                moduleWidget = Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    imageContainer,
                                                    const SizedBox(
                                                        height: Dimensions
                                                            .paddingSizeExtraSmall),
                                                    textWidget,
                                                  ],
                                                );
                                              }

                                              return Align(
                                                alignment: Alignment.topCenter,
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: moduleWidget,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),

                      // Collapsed View (Text Chips)
                       IgnorePointer(
                        ignoring: !isCollapsed,
                        child: Opacity(
                          opacity: percent.clamp(0.0, 1.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              height: collapsedHeight,
                              child: ListView.builder(
                                controller: collapsedScrollController,
                                scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.only(
                                        left: Dimensions.paddingSizeSmall,
                                        right: Dimensions.paddingSizeSmall,
                                        top: 6,
                                        bottom: 2),
                                    physics: const BouncingScrollPhysics(),
                                    itemCount:
                                        splashController.moduleList?.length ??
                                            0,
                                    itemBuilder: (context, index) {
                                      // bool isSelected = splashController.module != null &&
                                      //                   (splashController.module!.id == splashController.moduleList![index].id ||
                                      //                    (splashController.module!.moduleType != null &&
                                      //                     splashController.module!.moduleType == splashController.moduleList![index].moduleType));
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            right: Dimensions.paddingSizeSmall),
                                        child: InkWell(
                                          onTap: () => splashController
                                              .switchModule(index, true),
                                          child: Container(
                                            // padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall, vertical: 2),
                                            // decoration: BoxDecoration(
                                            //   color: isSelected ? Theme.of(context).secondaryHeaderColor : Theme.of(context).primaryColor,
                                            //   borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                                            //   boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, blurRadius: 5, spreadRadius: 1)],
                                            // ),
                                            alignment: Alignment.center,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Dimensions.radiusLarge),
                                              child: CustomImage(
                                                image:
                                                    '${splashController.moduleList![index].thumbnailFullUrl}',
                                                height: 60,
                                                width: 100,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                    ],
                  ),
                ),

                // Location Header (Dynamic) // + ahmed
                if (showLocationHeader)
                  Container(
                    height: 40 *
                        (1 - percent)
                            .clamp(0.0, 1.0), // Shrink height on collapse
                    width: Dimensions.webMaxWidth,
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeSmall),
                    child: Opacity(
                      opacity:
                          (1 - percent).clamp(0.0, 1.0), // Fade out on collapse
                      child: SingleChildScrollView(
                        // Avoid overflow errors
                        physics: const NeverScrollableScrollPhysics(),
                        child: GetBuilder<LocationController>(
                            builder: (locationController) {
                          Color? fontColor = locationHeaderFontColor != null
                              ? Color(int.parse(locationHeaderFontColor!
                                  .replaceFirst('#', '0xff')))
                              : Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .color;

                          String currentZoneName = locationController.zoneID == 0 ? 'all_zone'.tr : 'select_zone'.tr;
                          if (locationController.zoneID != 0 && locationController.zoneList != null && locationController.zoneList!.isNotEmpty) {
                            final currentZone = locationController.zoneList!.firstWhereOrNull((z) => z.id == locationController.zoneID);
                            if (currentZone != null && currentZone.name != null && currentZone.name!.isNotEmpty) {
                              currentZoneName = currentZone.name!;
                            }
                          }

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Right: Address & Location Picker (Expanded to fill available width)
                              Expanded(
                                child: InkWell(
                                  onTap: () => Get.find<LocationController>().navigateToLocationScreen('home'),
                                  child: Row(
                                    children: [
                                      Icon(Icons.location_on, size: 20, color: fontColor),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    (AddressHelper.getUserAddressFromSharedPref() != null && AddressHelper.getUserAddressFromSharedPref()!.addressType != null)
                                                        ? AddressHelper.getUserAddressFromSharedPref()!.addressType!.tr
                                                        : 'your_location'.tr,
                                                    style: robotoBold.copyWith(color: fontColor, fontSize: Dimensions.fontSizeDefault),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 2),
                                                Icon(Icons.keyboard_arrow_down, color: fontColor, size: 18),
                                              ],
                                            ),
                                            Text(
                                              AddressHelper.formatAddressWithZone(AddressHelper.getUserAddressFromSharedPref()),
                                              style: robotoRegular.copyWith(color: fontColor?.withValues(alpha: 0.85), fontSize: Dimensions.fontSizeSmall),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(width: 6),

                              // Left: City / Zone Selector Dropdown Pill
                              InkWell(
                                onTap: () {
                                  Get.bottomSheet(
                                    const ZoneSelectionBottomSheet(),
                                    isScrollControlled: true,
                                  );
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.3), width: 1),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.location_city_rounded, size: 14, color: Theme.of(context).primaryColor),
                                      const SizedBox(width: 4),
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(maxWidth: 95),
                                        child: Text(
                                          currentZoneName,
                                          style: robotoBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeExtraSmall),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Icon(Icons.arrow_drop_down_rounded, color: Theme.of(context).primaryColor, size: 18),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),

                if (searchBar != null)
                  Container(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: searchBar,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent {
    return expandedHeight +
        (searchBar != null ? searchBarHeight : 0) +
        (showLocationHeader ? 50 : 0) +
        paddingTop;
  }

  @override
  double get minExtent =>
      collapsedHeight + (searchBar != null ? searchBarHeight : 0) + paddingTop;

  @override
  bool shouldRebuild(ModuleStickyDelegate oldDelegate) {
    return oldDelegate.searchBar != searchBar ||
        oldDelegate.searchBarHeight != searchBarHeight ||
        oldDelegate.expandedHeight != expandedHeight ||
        oldDelegate.collapsedHeight != collapsedHeight ||
        oldDelegate.showLocationHeader !=
            showLocationHeader || // Check if module type changed
        oldDelegate.locationHeaderFontColor != locationHeaderFontColor ||
        oldDelegate.paddingTop != paddingTop ||
        oldDelegate.expandedScrollController != expandedScrollController ||
        oldDelegate.collapsedScrollController != collapsedScrollController ||
        oldDelegate.splashController != splashController;
  }
}

class ScrollControllerProvider extends StatefulWidget {
  final double initialScrollOffset;
  final Widget Function(BuildContext context, ScrollController controller)
      builder;

  const ScrollControllerProvider(
      {Key? key, required this.initialScrollOffset, required this.builder})
      : super(key: key);

  @override
  State<ScrollControllerProvider> createState() =>
      _ScrollControllerProviderState();
}

class _ScrollControllerProviderState extends State<ScrollControllerProvider> {
  late ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        ScrollController(initialScrollOffset: widget.initialScrollOffset);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _controller);
  }
}
