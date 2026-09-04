import 'package:flutter/material.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/helper/vendor_type_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

export 'package:sixam_mart/helper/vendor_type_helper.dart';

class VendorTypeBadgeWidget extends StatelessWidget {
  final Store? store;
  final String? vendorType;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;
  final bool showIcon;

  const VendorTypeBadgeWidget({
    super.key,
    this.store,
    this.vendorType,
    this.fontSize,
    this.padding,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    String raw = '';
    if (vendorType != null && vendorType!.trim().isNotEmpty) {
      raw = vendorType!;
    } else if (store != null) {
      if (store!.rawVendorType != null && store!.rawVendorType!.trim().isNotEmpty) {
        raw = store!.rawVendorType!;
      } else if (store!.storeBusinessModel != null && store!.storeBusinessModel!.trim().isNotEmpty) {
        raw = store!.storeBusinessModel!;
      } else if (!store!.isZad && store!.vendorType.isNotEmpty) {
        raw = store!.vendorType;
      }
    }

    // Hide if empty or retailer
    if (VendorTypeHelper.isEmpty(raw) || VendorTypeHelper.isRetailer(raw)) {
      return const SizedBox();
    }

    final String displayType = VendorTypeHelper.resolveVendorType(raw);
    if (displayType.trim().isEmpty) {
      return const SizedBox();
    }

    final Color primaryColor = Theme.of(context).primaryColor;
    final IconData badgeIcon = VendorTypeHelper.isFactory(raw)
        ? Icons.precision_manufacturing_outlined
        : Icons.storefront_outlined;

    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        border: Border.all(color: primaryColor.withValues(alpha: 0.2), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showIcon) ...[
            Icon(
              badgeIcon,
              size: (fontSize ?? Dimensions.fontSizeExtraSmall) + 2,
              color: primaryColor,
            ),
            const SizedBox(width: 3),
          ],
          Text(
            displayType,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: robotoMedium.copyWith(
              fontSize: fontSize ?? Dimensions.fontSizeExtraSmall,
              color: primaryColor,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
