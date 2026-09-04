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
        color: color,
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

    Widget imageWidget = CachedNetworkImage(
      color: color,
      imageUrl: kIsWeb ? '${AppConstants.baseUrl}/image-proxy?url=$image' : image,
      height: height, width: width, fit: fit,
      memCacheHeight: isUseMemCache && height != null ? (height!.isFinite ? (height! * MediaQuery.of(context).devicePixelRatio).toInt() : 600) : null,
      memCacheWidth: isUseMemCache && width != null ? (width!.isFinite ? (width! * MediaQuery.of(context).devicePixelRatio).toInt() : 600) : null,
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

/// Lightweight shimmer/skeleton placeholder — no heavy third-party dependency needed
class _ShimmerPlaceholder extends StatefulWidget {
  final double? height;
  final double? width;
  const _ShimmerPlaceholder({this.height, this.width});

  @override
  State<_ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<_ShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2A2A2A)
        : const Color(0xFFE8E8E8);
    final highlight = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF3A3A3A)
        : const Color(0xFFF5F5F5);
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) => Container(
        height: widget.height,
        width: widget.width,
        color: Color.lerp(base, highlight, _anim.value),
      ),
    );
  }
}
