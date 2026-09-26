import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:suliman/util/app_constants.dart';
import 'package:suliman/util/images.dart';
import 'package:flutter_avif/flutter_avif.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

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
    String cleanUrl = image.split('?').first.toLowerCase();
    if(cleanUrl.endsWith('.svg')) {
      Widget placeholderWidget = Image.asset(
        placeholder.isNotEmpty ? placeholder : (isNotification ? Images.notificationPlaceholder : Images.defultImage),
        height: height, width: width, fit: fit, color: color,
      );

      return NetworkSvgWithStyleFix(
        url: kIsWeb ? '${AppConstants.baseUrl}/image-proxy?url=$image' : image,
        height: height,
        width: width,
        fit: fit ?? BoxFit.contain,
        color: color,
        placeholder: placeholderWidget,
      );
    }
    if(cleanUrl.endsWith('.avif')) {
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

class NetworkSvgWithStyleFix extends StatefulWidget {
  final String url;
  final double? height;
  final double? width;
  final BoxFit fit;
  final Color? color;
  final Widget placeholder;

  const NetworkSvgWithStyleFix({
    super.key,
    required this.url,
    this.height,
    this.width,
    this.fit = BoxFit.contain,
    this.color,
    required this.placeholder,
  });

  @override
  State<NetworkSvgWithStyleFix> createState() => _NetworkSvgWithStyleFixState();
}

class _NetworkSvgWithStyleFixState extends State<NetworkSvgWithStyleFix> {
  static final Map<String, String> _svgCache = {};
  String? _svgString;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadSvg();
  }

  @override
  void didUpdateWidget(covariant NetworkSvgWithStyleFix oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _loadSvg();
    }
  }

  Future<void> _loadSvg() async {
    if (_svgCache.containsKey(widget.url)) {
      if (mounted) {
        setState(() {
          _svgString = _svgCache[widget.url];
          _hasError = false;
        });
      }
      return;
    }

    try {
      final response = await http.get(Uri.parse(widget.url));
      if (response.statusCode == 200) {
        String svg = response.body;
        svg = _inlineSvgStyles(svg);
        _svgCache[widget.url] = svg;
        if (mounted) {
          setState(() {
            _svgString = svg;
            _hasError = false;
          });
        }
      } else {
        if (mounted) setState(() => _hasError = true);
      }
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  static String _inlineSvgStyles(String svg) {
    final styleRegex = RegExp(r'<style[^>]*>([\s\S]*?)<\/style>', caseSensitive: false);
    final styleMatches = styleRegex.allMatches(svg);

    Map<String, Map<String, String>> classStyles = {};
    for (var m in styleMatches) {
      String styleContent = m.group(1) ?? '';
      final ruleRegex = RegExp(r'([^{]+)\{([^}]+)\}');
      for (var ruleMatch in ruleRegex.allMatches(styleContent)) {
        List<String> selectors = ruleMatch.group(1)!.split(',');
        String declarations = ruleMatch.group(2)!.trim();
        Map<String, String> declMap = {};
        for (var decl in declarations.split(';')) {
          var parts = decl.split(':');
          if (parts.length == 2) {
            declMap[parts[0].trim().toLowerCase()] = parts[1].trim();
          }
        }
        for (var sel in selectors) {
          String cleanSel = sel.trim().replaceAll('.', '');
          if (cleanSel.isNotEmpty) {
            classStyles.putIfAbsent(cleanSel, () => {}).addAll(declMap);
          }
        }
      }
    }

    if (classStyles.isEmpty) return svg;

    String processed = svg;
    classStyles.forEach((className, styles) {
      String styleAttributes = '';
      if (styles.containsKey('fill')) {
        styleAttributes += ' fill="${styles['fill']}"';
      }
      if (styles.containsKey('stroke')) {
        styleAttributes += ' stroke="${styles['stroke']}"';
      }
      if (styles.containsKey('stroke-width')) {
        styleAttributes += ' stroke-width="${styles['stroke-width']}"';
      }
      if (styles.containsKey('font-size')) {
        styleAttributes += ' font-size="${styles['font-size']}"';
      }
      if (styles.containsKey('font-weight')) {
        styleAttributes += ' font-weight="${styles['font-weight']}"';
      }
      if (styleAttributes.isNotEmpty) {
        final elemRegex = RegExp('class=["\'][^"\']*\\b$className\\b[^"\']*["\']');
        processed = processed.replaceAllMapped(elemRegex, (match) => '${match.group(0)}$styleAttributes');
      }
    });

    return processed;
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) return widget.placeholder;
    if (_svgString != null) {
      return SvgPicture.string(
        _svgString!,
        height: widget.height,
        width: widget.width,
        fit: widget.fit,
        colorFilter: widget.color != null ? ColorFilter.mode(widget.color!, BlendMode.srcIn) : null,
      );
    }
    return widget.placeholder;
  }
}

/// Lightweight static placeholder — zero tickers, zero rebuild overhead during list scrolling
class _ShimmerPlaceholder extends StatelessWidget {
  final double? height;
  final double? width;
  const _ShimmerPlaceholder({this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      color: Theme.of(context).disabledColor.withValues(alpha: 0.08),
    );
  }
}
