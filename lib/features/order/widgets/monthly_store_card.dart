import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/order/domain/models/monthly_order_model.dart';
import 'package:sixam_mart/features/order/widgets/monthly_item_tile.dart';
import 'package:sixam_mart/features/order/widgets/monthly_order_actions.dart';
import 'package:sixam_mart/features/order/widgets/monthly_order_menu_button.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class MonthlyStoreCard extends StatelessWidget {
  final MonthlyOrder order;
  const MonthlyStoreCard({super.key, required this.order});

  void _onMenuSelected(MonthlyOrderMenuAction action) {
    switch (action) {
      case MonthlyOrderMenuAction.addToCart:
        MonthlyOrderActions.addToCart(order);
        break;
      case MonthlyOrderMenuAction.view:
        Get.toNamed(RouteHelper.getMyItemsDetailRoute(order.id ?? 0), arguments: order);
        break;
      case MonthlyOrderMenuAction.remove:
        MonthlyOrderActions.confirmRemove(order);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<MonthlyOrderItemPreview> items = order.itemsPreview;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [BoxShadow(color: Theme.of(context).disabledColor.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(children: [
        _CardHeader(order: order, onMenuSelected: _onMenuSelected),

        if (items.isNotEmpty) ...[
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Column(children: [
              SizedBox(
                height: 185,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(width: Dimensions.paddingSizeSmall),
                  itemBuilder: (context, index) => SizedBox(
                    width: 110,
                    child: MonthlyItemTile(item: items[index]),
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(
                  '${'total'.tr} (${order.itemsCount ?? items.length} ${'items'.tr})',
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                ),
                Text(
                  PriceConverter.convertPrice(MonthlyOrderActions.totalAmount(order)),
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor),
                ),
              ]),
            ]),
          ),
        ],
      ]),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final MonthlyOrder order;
  final void Function(MonthlyOrderMenuAction action) onMenuSelected;

  const _CardHeader({required this.order, required this.onMenuSelected});

  String? _moduleName(MonthlyOrder order) {
    final List<ModuleModel> modules = Get.find<SplashController>().moduleList ?? <ModuleModel>[];
    final ModuleModel match = modules.firstWhere(
      (ModuleModel m) => m.id == order.moduleId,
      orElse: () => ModuleModel(moduleName: order.moduleType),
    );
    return match.moduleName;
  }

  @override
  Widget build(BuildContext context) {
    final String? module = _moduleName(order);
    return Padding(
      padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeSmall, Dimensions.paddingSizeSmall, Dimensions.paddingSizeExtraSmall, Dimensions.paddingSizeSmall),
      child: Row(children: [
        ClipOval(child: CustomImage(image: order.store?.logoFullUrl ?? '', height: 40, width: 40)),
        const SizedBox(width: Dimensions.paddingSizeSmall),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [
                Flexible(
                  child: Text(
                    order.store?.name ?? '',
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                  ),
                ),
                if (module != null && module.isNotEmpty) Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    '($module)',
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                  ),
                ),
              ]),
              if (MonthlyOrderActions.refillDate(order) != null) Text(
                '${'next_refill_date_is'.tr} ${MonthlyOrderActions.refillDate(order)}',
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
              ),
            ],
          ),
        ),

        MonthlyOrderMenuButton(onSelected: onMenuSelected),
      ]),
    );
  }
}
