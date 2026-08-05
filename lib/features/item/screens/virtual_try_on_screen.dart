import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/item/domain/services/fashn_service.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'dart:io';
import 'dart:convert';

import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/item/widgets/virtual_try_on_points_dialog.dart';

class VirtualTryOnScreen extends StatefulWidget {
  final String imageUrl;
  final List<String>? imageList;
  final String category;

  const VirtualTryOnScreen({super.key, required this.imageUrl, this.imageList, required this.category});

  @override
  State<VirtualTryOnScreen> createState() => _VirtualTryOnScreenState();
}

class _VirtualTryOnScreenState extends State<VirtualTryOnScreen> {
  final FashnService _fashnService = FashnService();
  XFile? _pickedImage;
  String? _resultImageUrl;
  bool _isLoading = false;
  bool _isSaving = false;

  String _selectedCategory = 'auto'; // Default category
  late String _selectedGarmentImage;

  @override
  void initState() {
    super.initState();
    _selectedGarmentImage = widget.imageUrl;
    // Initialize category based on widget.category if possible, or default to auto
    if (['tops', 'bottoms', 'one-pieces'].contains(widget.category)) {
      _selectedCategory = widget.category;
    } else if (widget.category == 'clothing') {
        _selectedCategory = 'tops'; // Default for clothing
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImage = image;
        _resultImageUrl = null; // Reset result on new upload
      });
    }
  }

  Future<void> _generateTryOn() async {
    if (!Get.find<AuthController>().isLoggedIn()) {
      showCustomSnackBar('you_are_not_logged_in'.tr);
      return;
    }

    final int cost = Get.find<SplashController>().configModel!.virtualTryOnLoyaltyPointCost ?? 10;
    final double currentPoints = (Get.find<ProfileController>().userInfoModel?.loyaltyPoint ?? 0).toDouble();

    if (currentPoints < cost) {
      showDialog(
        context: context,
        builder: (context) => VirtualTryOnPointsDialog(cost: cost, currentPoints: currentPoints),
      );
      return;
    }

    if (_pickedImage == null) {
      showCustomSnackBar('please_select_an_image'.tr);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final bytes = await File(_pickedImage!.path).readAsBytes();
      final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';

      final result = await _fashnService.generateTryOn(
        modelImageBase64: base64Image,
        garmentImageUrl: _selectedGarmentImage,
        category: _selectedCategory,
      );

      if (result != null) {
        setState(() {
          _resultImageUrl = result;
        });
        Get.find<ProfileController>().getUserInfo(); // Refresh points
      } else {
        showCustomSnackBar('failed_to_generate_try_on_image'.tr);
      }
    } catch (e) {
      showCustomSnackBar('${'error'.tr}: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveImage() async {
    if (_resultImageUrl == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final response = await http.get(Uri.parse(_resultImageUrl!));
      if (response.statusCode == 200) {
        final directory = await getTemporaryDirectory();
        final path = '${directory.path}/try_on_result.png';
        final file = File(path);
        await file.writeAsBytes(response.bodyBytes);

        await Share.shareXFiles([XFile(path)], text: 'virtual_try_on_result'.tr);
      } else {
        showCustomSnackBar('failed_to_save_image'.tr);
      }
    } catch (e) {
      showCustomSnackBar('failed_to_save_image'.tr);
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'virtual_try_on'.tr),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(
          children: [
            // Instructions
            Text(
              'upload_your_photo_to_try_on'.tr,
              style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            // Category Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                border: Border.all(color: Theme.of(context).disabledColor),
              ),
              child: Row(
                children: [
                  Text('category'.tr, style: robotoMedium),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        isExpanded: true,
                        items: ['auto', 'tops', 'bottoms', 'one-pieces'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value.tr, style: robotoRegular),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedCategory = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            // Image Display Area
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text('your_photo'.tr, style: robotoMedium),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      InkWell(
                        onTap: _pickImage,
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).primaryColor),
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          ),
                          child: _pickedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                  child: Image.file(
                                    File(_pickedImage!.path),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                )
                              : Center(
                                  child: Icon(Icons.add_a_photo,
                                      size: 40, color: Theme.of(context).primaryColor),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  child: Column(
                    children: [
                      Text('product'.tr, style: robotoMedium),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).disabledColor),
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          child: CustomImage(
                            image: _selectedGarmentImage,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (widget.imageList != null && widget.imageList!.length > 1) ...[
              const SizedBox(height: Dimensions.paddingSizeSmall),
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.imageList!.length,
                  itemBuilder: (context, index) {
                    final image = widget.imageList![index];
                    final isSelected = image == _selectedGarmentImage;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedGarmentImage = image;
                        });
                      },
                      child: Container(
                        width: 60,
                        margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          child: CustomImage(
                            image: image,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: Dimensions.paddingSizeExtraLarge),

            // Action Button
            CustomButton(
              buttonText: _isLoading ? 'processing'.tr : 'try_on_now'.tr,
              isLoading: _isLoading,
              onPressed: _pickedImage == null ? null : _generateTryOn,
              icon: Icons.auto_fix_high,
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraLarge),

            // Result Area
            if (_resultImageUrl != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('result'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                  IconButton(
                    onPressed: _isSaving ? null : _saveImage,
                    icon: _isSaving 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Icon(Icons.download, color: Theme.of(context).primaryColor),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).primaryColor, width: 2),
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  child: CustomImage(
                    image: _resultImageUrl!,
                    height: 400,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
