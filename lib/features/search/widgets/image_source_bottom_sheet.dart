import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class ImageSourceBottomSheet extends StatelessWidget {
  final Function(ImageSource) onImageSelected;
  const ImageSourceBottomSheet({super.key, required this.onImageSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          height: 4, width: 40,
          margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          ),
        ),
        Text('select_image_source'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
        const SizedBox(height: Dimensions.paddingSizeLarge),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _buildSourceItem(
            context,
            icon: Icons.camera_alt_rounded,
            label: 'from_camera'.tr,
            onTap: () {
              Get.back();
              onImageSelected(ImageSource.camera);
            },
          ),
          _buildSourceItem(
            context,
            icon: Icons.image_rounded,
            label: 'from_gallery'.tr,
            onTap: () {
              Get.back();
              onImageSelected(ImageSource.gallery);
            },
          ),
        ]),
        const SizedBox(height: Dimensions.paddingSizeLarge),
      ]),
    );
  }

  Widget _buildSourceItem(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor, size: 30),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        Text(label, style: robotoMedium),
      ]),
    );
  }
}
