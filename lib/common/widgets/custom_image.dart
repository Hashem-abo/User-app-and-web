import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:flutter_avif/flutter_avif.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomImage extends StatelessWidget {
  final String image;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final bool isNotification;
  final String placeholder;
  final bool isHovered;
  final Color? color;
  final bool isUseMemCache;
  const CustomImage({super.key, required this.image, this.height, this.width, this.fit = BoxFit.cover, this.isNotification = false, this.placeholder = '', this.isHovered = false, this.color, this.isUseMemCache = true});

  static ImageProvider targetProvider(String? image) {
    if(image == null || image.isEmpty) {
      return const AssetImage(Images.defultImage);
    }
    String imageUrl = kIsWeb ? '${AppConstants.baseUrl}/image-proxy?url=$image' : image;
    if (image.toLowerCase().endsWith('.avif')) {
      return NetworkAvifImage(imageUrl);
    } else {
      return NetworkImage(imageUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    if(image.toLowerCase().endsWith('.svg')) {
      return SvgPicture.network(
        image, height: height, width: width, fit: fit ?? BoxFit.contain,
        colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
        placeholderBuilder: (BuildContext context) => Image.asset(
          placeholder.isNotEmpty ? placeholder : (isNotification ? Images.notificationPlaceholder : Images.defultImage),
          height: height, width: width, fit: fit, color: color,
        ),
        errorBuilder: (context, error, stackTrace) => Image.asset(
          placeholder.isNotEmpty ? placeholder : (isNotification ? Images.notificationPlaceholder : Images.defultImage),
          height: height, width: width, fit: fit, color: color,
        ),
      );
    }
    if(image.toLowerCase().endsWith('.avif')) {
      return AvifImage.network(
        image, height: height, width: width, fit: fit,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          placeholder.isNotEmpty ? placeholder : (isNotification ? Images.notificationPlaceholder : Images.defultImage),
          height: height, width: width, fit: fit, color: color,
        ),
      );
    }

    final double dpr = MediaQuery.maybeOf(context)?.devicePixelRatio.clamp(1.0, 2.5) ?? 2.0;
    final int memW = isUseMemCache
        ? ((width != null && width!.isFinite && width! > 0) ? (width! * dpr).round() : 600).clamp(50, 800)
        : 800;
    final int memH = isUseMemCache
        ? ((height != null && height!.isFinite && height! > 0) ? (height! * dpr).round() : 600).clamp(50, 800)
        : 800;

    Widget imageWidget = CachedNetworkImage(
      color: color,
      imageUrl: kIsWeb ? '${AppConstants.baseUrl}/image-proxy?url=$image' : image,
      height: height, width: width, fit: fit,
      memCacheHeight: memH,
      memCacheWidth: memW,
      maxHeightDiskCache: 1000,
      maxWidthDiskCache: 1000,
      placeholder: (context, url) => _ShimmerPlaceholder(height: height, width: width),
      errorWidget: (context, url, error) => Image.asset(
        placeholder.isNotEmpty ? placeholder : (isNotification ? Images.notificationPlaceholder : Images.defultImage),
        height: height, width: width, fit: fit, color: color,
      ),
    );

    // Only wrap in AnimatedScale when hover is actually active (desktop/web)
    if (isHovered) {
      return AnimatedScale(
        scale: 1.1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: imageWidget,
      );
    }
    return imageWidget;
  }
}

/// Lightweight static placeholder — zero tickers, zero rebuild overhead during list scrolling
class _ShimmerPlaceholder extends StatelessWidget {
  final double? height;
  final double? width;
  const _ShimmerPlaceholder({this.height, this.width});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: height,
      width: width,
      color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEFEFEF),
    );
  }
}
