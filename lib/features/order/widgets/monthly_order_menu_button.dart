import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

enum MonthlyOrderMenuAction { addToCart, view, remove }

class MonthlyOrderMenuButton extends StatelessWidget {
  final bool showAddToCart;
  final bool showView;
  final void Function(MonthlyOrderMenuAction action) onSelected;
  const MonthlyOrderMenuButton({super.key, this.showAddToCart = true, this.showView = true, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<MonthlyOrderMenuAction>(
      onSelected: onSelected,
      icon: Icon(Icons.more_vert, color: Theme.of(context).disabledColor),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
      itemBuilder: (context) => <PopupMenuEntry<MonthlyOrderMenuAction>>[
        if(showAddToCart) PopupMenuItem<MonthlyOrderMenuAction>(
          value: MonthlyOrderMenuAction.addToCart,
          child: Text('add_to_cart'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
        ),
        if(showView) PopupMenuItem<MonthlyOrderMenuAction>(
          value: MonthlyOrderMenuAction.view,
          child: Text('view_details'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
        ),
        PopupMenuItem<MonthlyOrderMenuAction>(
          value: MonthlyOrderMenuAction.remove,
          child: Text('remove'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).colorScheme.error)),
        ),
      ],
    );
  }
}
