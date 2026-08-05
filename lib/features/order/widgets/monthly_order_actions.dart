import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sixam_mart/common/widgets/confirmation_dialog.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/order/controllers/order_controller.dart';
import 'package:sixam_mart/features/order/domain/models/monthly_order_model.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/images.dart';

class MonthlyOrderActions {
  MonthlyOrderActions._();

  static String? refillDate(MonthlyOrder order) {
    final raw = order.remindAt;
    if(raw == null || raw.isEmpty) return null;
    final parsed = DateTime.tryParse(raw);
    if(parsed == null) return raw;
    return DateFormat('dd MMM, yyyy').format(parsed.toLocal());
  }

  static double totalAmount(MonthlyOrder order) {
    double sum = 0;
    for(final MonthlyOrderItemPreview item in order.itemsPreview) {
      sum += (item.price ?? 0) * (item.quantity ?? 1);
    }
    return sum;
  }

  static void addToCart(MonthlyOrder order) {
    final int? orderId = order.orderId;
    if(orderId == null) {
      showCustomSnackBar('sorry_something_went_wrong'.tr);
      return;
    }
    Get.find<OrderController>().reorder(orderId);
    Get.toNamed(RouteHelper.getCartRoute());
  }

  static void confirmRemove(MonthlyOrder order, {VoidCallback? onRemoved}) {
    final int? id = order.id;
    if(id == null) return;

    Get.dialog(ConfirmationDialog(
      icon: Images.warning,
      description: 'are_you_sure_to_remove_this_item'.tr,
      onYesPressed: () async {
        Get.back();
        final bool isSuccess = await Get.find<OrderController>().removeMonthlyOrder(id);
        if(isSuccess) {
          showCustomSnackBar('removed_successfully'.tr, isError: false);
          onRemoved?.call();
        }
      },
    ));
  }
}

