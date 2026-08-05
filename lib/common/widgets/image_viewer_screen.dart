import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/helper/color_converter.dart';
import 'package:sixam_mart/helper/price_converter.dart';

class ImageViewerScreen extends StatefulWidget {
  final Item item;
  final bool isCampaign;
  const ImageViewerScreen({super.key, required this.item, this.isCampaign = false});

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  late final PageController _pageController;
  int _selectedColorIndex = 0;
  final List<String?> _imageList = [];
  ChoiceOptions? _colorOption;
  int _colorOptionIndex = -1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    Get.find<ItemController>().setImageIndex(0, false);

    // Build the image list dynamically and safely, incorporating variation-specific images
    final Set<String> uniqueImages = {};

    if (widget.item.imageFullUrl != null && widget.item.imageFullUrl!.isNotEmpty) {
      uniqueImages.add(widget.item.imageFullUrl!);
    }
    if (widget.item.imagesFullUrl != null) {
      for (var image in widget.item.imagesFullUrl!) {
        if (image.isNotEmpty) {
          uniqueImages.add(image);
        }
      }
    }
    if (widget.item.variations != null) {
      for (var variation in widget.item.variations!) {
        if (variation.imagesFullUrl != null) {
          for (var image in variation.imagesFullUrl!) {
            if (image.isNotEmpty) {
              uniqueImages.add(image);
            }
          }
        }
      }
    }

    _imageList.addAll(uniqueImages);

    if (_imageList.isEmpty && widget.item.imageFullUrl != null) {
      _imageList.add(widget.item.imageFullUrl);
    }

    // Find the color choice option if available
    if (widget.item.choiceOptions != null) {
      for (int index = 0; index < widget.item.choiceOptions!.length; index++) {
        String title = widget.item.choiceOptions![index].title ?? '';
        if (title.toLowerCase().contains('color') || title.contains('لون')) {
          _colorOption = widget.item.choiceOptions![index];
          _colorOptionIndex = index;
          break;
        }
      }
    }

    // Sync the initial active color selection dot based on the active image index
    _syncColorIndexForImage(0);
  }

  bool _isSameImage(String? url1, String? url2) {
    if (url1 == null || url2 == null) return false;
    
    String cleanUrl(String url) {
      String path = url.split('?').first;
      int lastSlash = path.lastIndexOf('/');
      if (lastSlash != -1) {
        return path.substring(lastSlash + 1).toLowerCase();
      }
      return path.toLowerCase();
    }
    
    return cleanUrl(url1) == cleanUrl(url2);
  }

  void _syncColorIndexForImage(int index) {
    bool hasColors = _colorOption != null && _colorOption!.options != null && _colorOption!.options!.isNotEmpty;
    if (hasColors && widget.item.variations != null && index >= 0 && index < _imageList.length) {
      String? visibleImageUrl = _imageList[index];
      if (visibleImageUrl != null) {
        for (int i = 0; i < _colorOption!.options!.length; i++) {
          String colorName = _colorOption!.options![i].trim().toLowerCase();
          
          // Find matching variation that matches this color name
          Variation? matchingVar = widget.item.variations!.firstWhereOrNull((v) {
            String type = (v.type ?? '').trim().toLowerCase();
            return type == colorName || type.contains(colorName);
          });
          
          if (matchingVar != null && matchingVar.imagesFullUrl != null) {
            bool hasMatchingImage = false;
            for (var img in matchingVar.imagesFullUrl!) {
              if (_isSameImage(img, visibleImageUrl)) {
                hasMatchingImage = true;
                break;
              }
            }
            if (hasMatchingImage) {
              setState(() {
                _selectedColorIndex = i;
              });
              break;
            }
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool hasColors = _colorOption != null && _colorOption!.options != null && _colorOption!.options!.isNotEmpty;
    double bottomPadding = MediaQuery.of(context).padding.bottom;
    double bottomBarHeight = 60 + bottomPadding;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        top: false,
        bottom: false,
        child: GetBuilder<ItemController>(builder: (itemController) {
          return Stack(
            children: [
              // 1. Photo View Gallery (Main Immersive Viewer Area)
              Positioned.fill(
                child: PhotoViewGallery.builder(
                  scrollPhysics: const BouncingScrollPhysics(),
                  backgroundDecoration: const BoxDecoration(color: Colors.black),
                  itemCount: _imageList.length,
                  pageController: _pageController,
                  builder: (BuildContext context, int index) {
                    return PhotoViewGalleryPageOptions(
                      imageProvider: kIsWeb
                          ? NetworkImage('${AppConstants.baseUrl}/image-proxy?url=${_imageList[index]}')
                          : NetworkImage('${_imageList[index]}'),
                      initialScale: PhotoViewComputedScale.contained,
                      heroAttributes: PhotoViewHeroAttributes(tag: index.toString()),
                    );
                  },
                  loadingBuilder: (context, event) => Center(
                    child: SizedBox(
                      width: 24.0,
                      height: 24.0,
                      child: CircularProgressIndicator(
                        value: event == null
                            ? 0
                            : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                      ),
                    ),
                  ),
                  onPageChanged: (int index) {
                    itemController.setImageIndex(index, true);
                    _syncColorIndexForImage(index);
                  },
                ),
              ),

              // 2. Custom High-End Top Overlay Bar (Mockup Layout with top-right icon removed)
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 10,
                right: 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Left Close/Back Button
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white, size: 30),
                      onPressed: () => Get.back(),
                    ),

                    // Center Dynamic Page Indicator
                    Text(
                      '${itemController.imageIndex + 1}/${_imageList.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // Top Right Balanced Spacer (Ensures the text in the center remains perfectly centered)
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // 3. Floating Left/Right Navigation Chevron Arrows
              if (itemController.imageIndex != 0)
                Positioned(
                  left: 10,
                  top: 0,
                  bottom: bottomBarHeight,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.chevron_left_outlined, size: 36, color: Colors.white),
                        onPressed: () {
                          if (itemController.imageIndex > 0) {
                            _pageController.animateToPage(
                              itemController.imageIndex - 1,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),

              if (itemController.imageIndex != _imageList.length - 1)
                Positioned(
                  right: 10,
                  top: 0,
                  bottom: bottomBarHeight,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.chevron_right_outlined, size: 36, color: Colors.white),
                        onPressed: () {
                          if (itemController.imageIndex < _imageList.length - 1) {
                            _pageController.animateToPage(
                              itemController.imageIndex + 1,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),

              // 4. Color Variation Option Panels (Floating above the bottom CTA)
              if (hasColors)
                Positioned(
                  bottom: bottomBarHeight + 15,
                  left: 20,
                  right: 20,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Elegant active color name chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          _colorOption!.options![_selectedColorIndex],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Interactive color dots row
                      SizedBox(
                        height: 48,
                        child: Center(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: _colorOption!.options!.length,
                            itemBuilder: (context, i) {
                              String colorName = _colorOption!.options![i].trim();
                              bool isSelected = _selectedColorIndex == i;
                              Color? color = ColorConverter.getColorFromOption(colorName);

                              // Find matching variation to check for specific variant images
                              Variation? matchingVariation;
                              if (widget.item.variations != null) {
                                matchingVariation = widget.item.variations!.firstWhereOrNull((v) {
                                  String type = (v.type ?? '').trim().toLowerCase();
                                  return type == colorName.toLowerCase() || type.contains(colorName.toLowerCase());
                                });
                              }

                              String? variantImageUrl;
                              if (matchingVariation != null &&
                                  matchingVariation.imagesFullUrl != null &&
                                  matchingVariation.imagesFullUrl!.isNotEmpty) {
                                variantImageUrl = matchingVariation.imagesFullUrl!.first;
                              }

                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedColorIndex = i;
                                    });

                                    // Transition directly to the variant image if available
                                    if (matchingVariation != null &&
                                        matchingVariation.imagesFullUrl != null &&
                                        matchingVariation.imagesFullUrl!.isNotEmpty) {
                                      int imgIndex = _imageList.indexWhere((img) {
                                        return matchingVariation!.imagesFullUrl!.any((varImg) => _isSameImage(varImg, img));
                                      });
                                      if (imgIndex != -1) {
                                        _pageController.animateToPage(
                                          imgIndex,
                                          duration: const Duration(milliseconds: 500),
                                          curve: Curves.easeInOut,
                                        );
                                        itemController.setImageIndex(imgIndex, true);
                                      }
                                    }

                                    // Synchronize variation selection in details controller
                                    itemController.setCartVariationIndex(_colorOptionIndex, i, widget.item);
                                  },
                                  child: Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected ? Colors.white : Colors.transparent,
                                        width: 1.5,
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(3),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: color ?? Colors.grey.shade800,
                                        border: color == Colors.white
                                            ? Border.all(color: Colors.grey.shade800, width: 0.5)
                                            : null,
                                        image: variantImageUrl != null
                                            ? DecorationImage(
                                                image: NetworkImage(variantImageUrl),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Positioned(
              //   bottom: 0,
              //   left: 0,
              //   right: 0,
              //   child: Container(
              //     height: bottomBarHeight,
              //     width: double.infinity,
              //     padding: EdgeInsets.only(bottom: bottomPadding),
              //     decoration: const BoxDecoration(
              //       color: Colors.black,
              //       border: Border(
              //         top: BorderSide(color: Colors.white, width: 3.0),
              //       ),
              //     ),
              //     child: Material(
              //       color: Colors.transparent,
              //       child: InkWell(
              //         onTap: () {
              //           itemController.itemDirectlyAddToCart(widget.item, context);
              //         },
              //         splashColor: Colors.white.withOpacity(0.1),
              //         highlightColor: Colors.white.withOpacity(0.05),
              //         child: Center(
              //           child: Row(
              //             mainAxisAlignment: MainAxisAlignment.center,
              //             children: [
              //               Icon(
              //                 widget.item.discount != null && widget.item.discount! > 0
              //                     ? Icons.trending_down_rounded
              //                     : Icons.shopping_cart_outlined,
              //                 color: Colors.white,
              //                 size: 22,
              //               ),
              //               const SizedBox(width: 8),
              //               Builder(
              //                 builder: (context) {
              //                   String buttonText = 'add_to_cart'.tr;
              //                   if (widget.item.discount != null && widget.item.discount! > 0) {
              //                     if (widget.item.discountType == 'percent') {
              //                       buttonText = '$buttonText - ${widget.item.discount!.toInt()}% OFF';
              //                     } else {
              //                       buttonText = '$buttonText - ${PriceConverter.convertPrice(widget.item.discount)} OFF';
              //                     }
              //                   }
              //                   return Text(
              //                     buttonText,
              //                     style: const TextStyle(
              //                       fontSize: 16,
              //                       fontWeight: FontWeight.bold,
              //                       color: Colors.white,
              //                       letterSpacing: 0.5,
              //                     ),
              //                   );
              //                 }
              //               ),
              //             ],
              //           ),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          );
        }),
      ),
    );
  }
}