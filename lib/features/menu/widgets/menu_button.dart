import 'package:flutter/material.dart';
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
    bool isRtl = Directionality.of(context) == TextDirection.rtl;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
      ),
      child: ListTile(
        leading: Image.asset(icon, height: 24, width: 24, color: Theme.of(context).primaryColor),
        title: Text(
          title,
          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).secondaryHeaderColor),
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
