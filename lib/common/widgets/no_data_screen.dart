import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';

class NoDataScreen extends StatelessWidget {
  final bool isCart;
  final bool showFooter;
  final String? text;
  final bool fromAddress;
  const NoDataScreen({super.key, required this.text, this.isCart = false, this.showFooter = false, this.fromAddress = false});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: FooterView(
        visibility: showFooter,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [

          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.scale(
                    scale: 0.85 + (value * 0.15),
                    child: child,
                  ),
                );
              },
              child: Image.asset(
                fromAddress ? Images.address : isCart ? Images.emptyCart : Images.noDataFound,
                width: (MediaQuery.of(context).size.height * 0.18).clamp(90.0, 160.0),
                height: (MediaQuery.of(context).size.height * 0.18).clamp(90.0, 160.0),
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height*0.03),

          Text(
            isCart ? 'cart_is_empty'.tr : (text ?? ''),
            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: fromAddress ? Theme.of(context).textTheme.bodyMedium!.color : Theme.of(context).disabledColor),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: MediaQuery.of(context).size.height*0.02),

          fromAddress ? Text(
            'please_add_your_address_for_your_better_experience'.tr,
            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
            textAlign: TextAlign.center,
          ) : const SizedBox(),
          SizedBox(height: fromAddress ? MediaQuery.of(context).size.height*0.04 : 0),

          fromAddress ? InkWell(
            onTap: () => Get.toNamed(RouteHelper.getAddAddressRoute(false, false, 0)),
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                color: Theme.of(context).primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_circle_outline_sharp, size: 20.0, color: Theme.of(context).cardColor),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  Text('add_address'.tr, style: robotoMedium.copyWith(color: Theme.of(context).cardColor)),
                ],
              ),
            ),
          ) : const SizedBox(),

        ]),
      ),
    );
  }
}
