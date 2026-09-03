import 'package:flutter/material.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

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
    final String type = (vendorType != null && vendorType!.isNotEmpty)
        ? vendorType!
        : (store != null ? store!.vendorType : '');

    if (type.isEmpty) {
      return const SizedBox();
    }

    final Color primaryColor = Theme.of(context).primaryColor;

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
              Icons.storefront_outlined,
              size: (fontSize ?? Dimensions.fontSizeExtraSmall) + 2,
              color: primaryColor,
            ),
            const SizedBox(width: 3),
          ],
          Text(
            type,
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
