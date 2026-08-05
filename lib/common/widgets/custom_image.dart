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
    return AnimatedScale(
      scale: isHovered ? 1.1 : 1.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: CachedNetworkImage(
        color: color,
        imageUrl: kIsWeb ? '${AppConstants.baseUrl}/image-proxy?url=$image' : image, height: height, width: width, fit: fit,
        memCacheHeight: isUseMemCache && height != null ? (height!.isFinite ? (height! * MediaQuery.of(context).devicePixelRatio).toInt() : 600) : null,
        memCacheWidth: isUseMemCache && width != null ? (width!.isFinite ? (width! * MediaQuery.of(context).devicePixelRatio).toInt() : 600) : null,
        placeholder: (context, url) => Image.asset(
          placeholder.isNotEmpty ? placeholder : (isNotification ? Images.notificationPlaceholder : Images.defultImage),
          height: height, width: width, fit: fit, color: color,
        ),
        errorWidget: (context, url, error) => Image.asset(
          placeholder.isNotEmpty ? placeholder : (isNotification ? Images.notificationPlaceholder : Images.defultImage),
          height: height, width: width, fit: fit, color: color,
        ),
      ),
    );
  }
}
