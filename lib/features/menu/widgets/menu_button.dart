import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class MenuButton extends StatelessWidget {
  final String icon;
  final String title;
  final String? route;
  final Function()? onTap;
  
  const MenuButton({
    super.key, 
    required this.icon, 
    required this.title, 
    this.route, 
    this.onTap
  });

  @override
  Widget build(BuildContext context) {
    // bool isRtl = Directionality.of(context) == TextDirection.rtl;
    return Material(
      color: Theme.of(context).cardColor,
      child: ListTile(
        leading:  SvgPicture.asset(
          icon,
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(Theme.of(context).primaryColor, BlendMode.srcIn),
        ),
        title: Text(
          title,
          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge,),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Theme.of(context).disabledColor,
        ),
        onTap: onTap ?? () => Get.toNamed(route!),
      ),
    );
  }
}
