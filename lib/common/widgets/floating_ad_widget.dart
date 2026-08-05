import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/features/shelf/screens/dynamic_shelf_view_all_screen.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:sixam_mart/features/service/screens/service_provider_screen.dart';

class FloatingAdWidget extends StatefulWidget {
  /// When true the ad fades out; when false it fades back in.
  final bool isScrolling;

  const FloatingAdWidget({super.key, this.isScrolling = false});

  @override
  State<FloatingAdWidget> createState() => _FloatingAdWidgetState();
}

class _FloatingAdWidgetState extends State<FloatingAdWidget>
    with SingleTickerProviderStateMixin {
  double _bottom = 110;
  double _left = Dimensions.paddingSizeDefault;

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: 1.0,
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
  }

  @override
  void didUpdateWidget(FloatingAdWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isScrolling != oldWidget.isScrolling) {
      if (widget.isScrolling) {
        _animCtrl.reverse(); // fade + shrink out while scrolling
      } else {
        _animCtrl.forward(); // fade + grow back in after scroll stops
      }
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  /// Snap to the left edge, keeping the current vertical position.
  void _snapLeft() {
    setState(() {
      _left = Dimensions.paddingSizeDefault;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(builder: (splashController) {
      if (splashController.module == null ||
          !(splashController.module!.floatingAdStatus ?? false) ||
          splashController.isFloatingAdClosed ||
          splashController.module!.floatingAdImageFullUrl == null) {
        return const SizedBox();
      }

      return Positioned(
        left: _left,
        bottom: _bottom,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _fadeAnim,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _bottom -= details.delta.dy;
                  _left += details.delta.dx;
                });
              },
              onPanEnd: (_) => _snapLeft(), // snap to left on release
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  InkWell(
                    onTap: () {
                      String? type =
                          splashController.module!.floatingAdLinkType;
                      dynamic id = splashController.module!.floatingAdLinkId;
                      bool isServices =
                          splashController.module?.moduleType == 'services';

                      if (type == 'store') {
                        if (isServices) {
                          Get.to(() => ServiceProviderScreen(
                              providerId: int.parse(id.toString())));
                        } else {
                          Get.toNamed(RouteHelper.getStoreRoute(
                              id: int.parse(id.toString()), page: 'module'));
                        }
                      } else if (type == 'item') {
                        if (isServices) {
                          Get.toNamed(RouteHelper.getServiceDetailsRoute(
                              int.parse(id.toString())));
                        } else {
                          Get.toNamed(RouteHelper.getItemDetailsRoute(
                              int.parse(id.toString()), false));
                        }
                      } else if (type == 'shelf') {
                        Get.to(() => DynamicShelfViewAllScreen(
                            shelfId: int.parse(id.toString())));
                      } else if (type == 'page') {
                        if (id == 'special_offers' || id == 'popular_items') {
                          Get.toNamed(
                              RouteHelper.getPopularItemRoute(true, false));
                        } else if (id == 'all_stores') {
                          Get.toNamed(RouteHelper.getAllStoreRoute('all'));
                        } else if (id == 'categories' || id == 'category') {
                          Get.toNamed(RouteHelper.getCategoryRoute());
                        } else if (id == 'favourite') {
                          Get.toNamed(RouteHelper.getMainRoute('favourite'));
                        } else if (id == 'campaign' || id == 'item_campaign') {
                          Get.toNamed(RouteHelper.getItemCampaignRoute());
                        } else if (id == 'coupon') {
                          Get.toNamed(RouteHelper.getCouponRoute());
                        }
                      } else if (type == 'url') {
                        _launchUrl(id.toString());
                      }
                    },
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: CustomImage(
                          image: splashController
                                  .module!.floatingAdImageFullUrl ??
                              '',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -8,
                    right: -8,
                    child: InkWell(
                      onTap: () => splashController.closeFloatingAd(),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 5),
                          ],
                        ),
                        child: const Icon(Icons.close,
                            size: 14, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  void _launchUrl(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    }
  }
}
