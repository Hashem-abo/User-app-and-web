import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/search/controllers/search_controller.dart' as search;
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';

class NoonVisionScreen extends StatelessWidget {
  final bool fromHome;
  const NoonVisionScreen({super.key, required this.fromHome});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<search.SearchController>(builder: (searchController) {
      final aiResult = searchController.aiResult;
      final imageFile = searchController.searchImage;
      
      if (aiResult == null || imageFile == null) {
        return const Scaffold(body: CustomLoaderWidget());
      }

      String item = aiResult['identified_item'] ?? 'unknown';
      String details = aiResult['more_details'] ?? '';
      String query = aiResult['optimized_query'] ?? item;

      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
               searchController.clearSearchImage();
               Get.back();
            },
          ),
          title: Text('noon VISION', style: robotoBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeExtraLarge)),
          actions: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                searchController.clearSearchImage();
                Get.back();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            const SizedBox(height: Dimensions.paddingSizeLarge),
            
            // "Product Images" label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              ),
              child: Text(
                'product_images'.tr,
                style: robotoMedium.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeSmall),
              ),
            ),
            
            const SizedBox(height: Dimensions.paddingSizeLarge),
            
            // Image Display
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.file(
                      File(imageFile.path),
                      fit: BoxFit.contain,
                      width: double.infinity,
                    ),
                  ),
                  
                  // Arrows
                  Positioned(
                    left: 0,
                    child: _buildArrow(Icons.arrow_back_ios_new),
                  ),
                  Positioned(
                    right: 0,
                    child: _buildArrow(Icons.arrow_forward_ios),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: Dimensions.paddingSizeLarge),
            
            // Results Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item,
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeOverLarge),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  if (details.isNotEmpty)
                    Text(
                      details,
                      style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  
                  ElevatedButton(
                    onPressed: () {
                      searchController.searchByAiData(query, fromHome);
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                    ),
                    child: Text('view_results'.tr, style: robotoBold.copyWith(color: Colors.white)),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildArrow(IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}
