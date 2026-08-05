import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/features/favourite/controllers/favourite_controller.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';

import 'package:sixam_mart/features/contact_share/screens/contact_share_sheet.dart';

class DetailsAppBarWidget extends StatefulWidget implements PreferredSizeWidget {
  final String? title;
  final bool isScrolled;
  final Item? item;
  const DetailsAppBarWidget({super.key, this.title, this.isScrolled = false, this.item});

  @override
  DetailsAppBarWidgetState createState() => DetailsAppBarWidgetState();

  @override
  Size get preferredSize => const Size(double.maxFinite, 50);
}

class DetailsAppBarWidgetState extends State<DetailsAppBarWidget> with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
  }
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void shake() {
    controller.forward(from: 0.0);
  }

  Widget _glassButton(BuildContext context, {required Widget child, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: widget.isScrolled ? Colors.transparent : Theme.of(context).cardColor.withOpacity(0.85),
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      ),
    );
  }

  void _showShareBottomSheet(BuildContext context, String rawLink, String shareText) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (con) => Container(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeLarge),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            height: 4, width: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).disabledColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          Text(
            'share_product'.tr == 'share_product' ? 'مشاركة المنتج' : 'share_product'.tr,
            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
          ),
          Text(
            'share_this_product_with_others'.tr == 'share_this_product_with_others' ? 'شارك هذا المنتج مع الآخرين' : 'share_this_product_with_others'.tr,
            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          _buildShareOption(
            context,
            'copy_product_link'.tr == 'copy_product_link' ? 'نسخ رابط المنتج' : 'copy_product_link'.tr,
            Icons.copy,
            () {
              Clipboard.setData(ClipboardData(text: rawLink));
              showCustomSnackBar('link_copied'.tr == 'link_copied' ? 'تم نسخ الرابط' : 'link_copied'.tr, isError: false);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          _buildShareOption(
            context,
            'share_via_apps'.tr == 'share_via_apps' ? 'مشاركة عبر التطبيقات' : 'share_via_apps'.tr,
            Icons.send,
            () {
              Share.share(shareText);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
        ]),
      ),
    );
  }

  Widget _buildShareOption(BuildContext context, String title, IconData icon, Function onTap) {
    return InkWell(
      onTap: onTap as void Function()?,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).disabledColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          border: Border.all(color: Theme.of(context).disabledColor.withOpacity(0.1)),
        ),
        child: Row(children: [
          Expanded(child: Text(title, style: robotoMedium)),
          Icon(icon, size: 20),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Animation<double> offsetAnimation = Tween(begin: 0.0, end: 15.0).chain(CurveTween(curve: Curves.elasticIn)).animate(controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.reverse();
        }
      });

    return AppBar(
      leading: Center(
        child: _glassButton(
          context,
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios_new, size: 24, color: Theme.of(context).textTheme.bodyLarge!.color),
        ),
      ),
      backgroundColor: widget.isScrolled ? Theme.of(context).cardColor : Colors.transparent,
      elevation: 0,
      title: AnimatedOpacity(
        opacity: widget.isScrolled ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Text(
          widget.title ?? 'item_details'.tr,
          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge!.color),
        ),
      ),
      centerTitle: true,
      actions: [
        if (widget.item != null)
          _glassButton(
            context,
            onTap: () {
              String rawLink = '${AppConstants.webHostedUrl}${RouteHelper.getItemDetailsRoute(widget.item!.id, false)}';
              if (AuthHelper.isLoggedIn()) {
                String refCode = Get.find<ProfileController>().userInfoModel?.refCode ?? '';
                if (refCode.isNotEmpty) {
                  rawLink = rawLink.contains('?') ? '$rawLink&ref=$refCode' : '$rawLink?ref=$refCode';
                }
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (con) => ContactShareSheet(
                    shareableType: 'item',
                    shareableId: widget.item!.id!,
                    shareableName: widget.item!.name!,
                    shareUrl: rawLink,
                  ),
                );
              } else {
                Share.share('${widget.item!.name} \n$rawLink');
              }
            },
            child: Icon(Icons.send_outlined, size: 24, color: Theme.of(context).textTheme.bodyLarge!.color),
          ),
        
        if (widget.item != null)
          GetBuilder<FavouriteController>(builder: (favouriteController) {
            bool isFav = favouriteController.wishItemIdList.contains(widget.item!.id);
            return _glassButton(
              context,
              onTap: () {
                if(AuthHelper.isLoggedIn()){
                  if(isFav) {
                    favouriteController.removeFromFavouriteList(widget.item!.id, false);
                  } else {
                    favouriteController.addToFavouriteList(widget.item, null, false);
                  }
                } else {
                  showCustomSnackBar('you_are_not_logged_in'.tr);
                }
              },
              child: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                size: 24,
                color: isFav ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge!.color,
              ),
            );
          }),

        AnimatedBuilder(
          animation: offsetAnimation,
          builder: (buildContext, child) {
            return Transform.translate(
              offset: Offset(offsetAnimation.value, 0),
              child: Center(
                child: _glassButton(
                  context,
                  onTap: () => Navigator.pushNamed(context, RouteHelper.getCartRoute()),
                  child: Stack(clipBehavior: Clip.none, children: [
                    Icon(Icons.shopping_cart_outlined, size: 24, color: Theme.of(context).textTheme.bodyLarge!.color),
                    Positioned(
                      top: -4, right: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                        child: GetBuilder<CartController>(builder: (cartController) {
                          return Text(
                            cartController.cartList.length.toString(),
                            style: robotoMedium.copyWith(color: Colors.white, fontSize: 10),
                          );
                        }),
                      ),
                    ),
                  ]),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
