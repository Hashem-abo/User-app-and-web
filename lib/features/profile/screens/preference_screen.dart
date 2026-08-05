import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/profile/domain/models/size_info_model.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/category/domain/models/category_model.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/common/enums/data_source_enum.dart';

class PreferenceScreen extends StatefulWidget {
  const PreferenceScreen({super.key});

  @override
  State<PreferenceScreen> createState() => _PreferenceScreenState();
}

class _PreferenceScreenState extends State<PreferenceScreen> {
  List<CategoryModel> categories = [];
  bool isLoadingCategories = true;
  final List<String> fallbackCategories = [
    'Kids', 'Plus Size', 'Men', 'Women', 'Pets Supplies', 'Home'
  ];

  final List<String> buyFor = [
    'Parents', 'Partner', 'Myself', 'Girls 7-14 Yrs',
    'Toddler Girls 1-6 Yrs', 'Boys 7-14 Yrs', 'Toddler Boys 1-6 Yrs',
    'Baby 0-24 Months'
  ];

  final List<String> styles = [
    'Sexy', 'Elegant', 'Casual', 'Basics'
  ];

  final List<String> selectedCategories = [];
  final List<String> selectedBuyFor = [];
  final List<String> selectedStyles = [];

  bool isDirty = false;

  @override
  void initState() {
    super.initState();
    final profileController = Get.find<ProfileController>();
    profileController.loadSizeAndPreferences();
    selectedCategories.addAll(profileController.shoppingPreference.favoriteCategories);
    selectedBuyFor.addAll(profileController.shoppingPreference.targetAudience);
    selectedStyles.addAll(profileController.shoppingPreference.favoriteStyles);
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final splashController = Get.find<SplashController>();
      if (splashController.moduleList == null || splashController.moduleList!.isEmpty) {
        await splashController.getModules(dataSource: DataSourceEnum.client);
      }
      final ecommerceModule = splashController.moduleList?.firstWhereOrNull((m) => m.moduleType == 'ecommerce');
      if (ecommerceModule != null) {
        Map<String, String> headers = Map<String, String>.from(Get.find<ApiClient>().getHeader());
        headers[AppConstants.moduleId] = '${ecommerceModule.id}';
        
        Response response = await Get.find<ApiClient>().getData(AppConstants.categoryUri, headers: headers);
        if (response.statusCode == 200 && response.body != null) {
          List<CategoryModel> fetchedCategories = [];
          response.body.forEach((category) {
            fetchedCategories.add(CategoryModel.fromJson(category));
          });
          if (fetchedCategories.length > 6) {
            fetchedCategories = fetchedCategories.sublist(0, 6);
          }
          if (mounted) {
            setState(() {
              categories = fetchedCategories;
              isLoadingCategories = false;
            });
          }
          return;
        }
      }
    } catch (e) {
      debugPrint('Error loading ecommerce categories: $e');
    }
    if (mounted) {
      setState(() {
        isLoadingCategories = false;
      });
    }
  }

  void toggleCategory(String value) {
    setState(() {
      isDirty = true;
      if (selectedCategories.contains(value)) {
        selectedCategories.remove(value);
      } else {
        selectedCategories.add(value);
      }
    });
  }

  void toggleBuyFor(String value) {
    setState(() {
      isDirty = true;
      if (selectedBuyFor.contains(value)) {
        selectedBuyFor.remove(value);
      } else {
        selectedBuyFor.add(value);
      }
    });
  }

  void toggleStyle(String value) {
    setState(() {
      isDirty = true;
      if (selectedStyles.contains(value)) {
        selectedStyles.remove(value);
      } else {
        selectedStyles.add(value);
      }
    });
  }

  void showUnsavedChangesDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'are_you_sure_to_go_back'.tr,
                style: robotoBold.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 10),
              Text(
                'unsaved_changes_will_be_lost'.tr,
                textAlign: TextAlign.center,
                style: robotoRegular.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      onPressed: () {
                        Get.back(); // Close dialog
                        Get.back(); // Close screen
                      },
                      child: Text('discard'.tr, style: robotoMedium.copyWith(color: Colors.black)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Get.back();
                      },
                      child: Text('cancel'.tr, style: robotoMedium.copyWith(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileController = Get.find<ProfileController>();

    return PopScope(
      canPop: !isDirty,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        showUnsavedChangesDialog();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              if (isDirty) {
                showUnsavedChangesDialog();
              } else {
                Get.back();
              }
            },
          ),
          title: Text(
            'preference'.tr,
            style: robotoBold.copyWith(fontSize: 18, color: Colors.black),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Categories Question
                    questionHeader('fav_categories'.tr),
                    const SizedBox(height: 12),
                    isLoadingCategories
                        ? const Center(child: CircularProgressIndicator())
                        : Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: (categories.isNotEmpty
                                ? categories.map((cat) => cat.name ?? '')
                                : fallbackCategories).map((name) {
                              final isSelected = selectedCategories.contains(name);
                              return choiceChip(name, isSelected, () => toggleCategory(name));
                            }).toList(),
                          ),

                    const SizedBox(height: 30),

                    // Who do you buy clothes for Question
                    questionHeader('buy_clothes_for'.tr),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: buyFor.map((target) {
                        final isSelected = selectedBuyFor.contains(target);
                        return choiceChip(target, isSelected, () => toggleBuyFor(target));
                      }).toList(),
                    ),

                    const SizedBox(height: 30),

                    // Favorite styles Question
                    questionHeader('fav_styles'.tr),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: styles.map((style) {
                        final isSelected = selectedStyles.contains(style);
                        return choiceChip(style, isSelected, () => toggleStyle(style));
                      }).toList(),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Save Button
            SafeArea(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                  ),
                  onPressed: () async {
                    final pref = ShoppingPreference(
                      favoriteCategories: selectedCategories,
                      targetAudience: selectedBuyFor,
                      favoriteStyles: selectedStyles,
                      isCompleted: true,
                    );
                    await profileController.savePreferences(pref);
                    Get.back();
                    showCustomSnackBar('preferences_saved_successfully'.tr, isError: false);
                  },
                  child: Text(
                    'save'.tr,
                    style: robotoBold.copyWith(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget questionHeader(String title) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        title,
        style: robotoBold.copyWith(fontSize: 15, color: Colors.black),
      ),
    );
  }

  Widget choiceChip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          border: Border.all(color: isSelected ? Colors.black : Colors.grey[300]!),
        ),
        child: Text(
          label.tr,
          style: robotoMedium.copyWith(
            color: isSelected ? Colors.white : Colors.black87,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
