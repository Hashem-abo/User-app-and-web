import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:suliman/common/widgets/custom_app_bar.dart';
import 'package:suliman/common/widgets/custom_button.dart';
import 'package:suliman/common/widgets/custom_snackbar.dart';
import 'package:suliman/common/widgets/footer_view.dart';
import 'package:suliman/common/widgets/menu_drawer.dart';
import 'package:suliman/features/suggestion/controllers/suggestion_controller.dart';
import 'package:suliman/features/profile/controllers/profile_controller.dart';
import 'package:suliman/util/dimensions.dart';
import 'package:suliman/util/styles.dart';

class AddSuggestionScreen extends StatefulWidget {
  const AddSuggestionScreen({super.key});

  @override
  State<AddSuggestionScreen> createState() => _AddSuggestionScreenState();
}

class _AddSuggestionScreenState extends State<AddSuggestionScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedCategory = 'general';
  bool _isAnonymous = false;

  final List<Map<String, String>> _categories = [
    {'key': 'general', 'label': 'general'.tr},
    {'key': 'app', 'label': 'app_feedback'.tr},
    {'key': 'delivery', 'label': 'delivery_service'.tr},
    {'key': 'store', 'label': 'stores_service'.tr},
    {'key': 'other', 'label': 'other'.tr},
  ];

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<ProfileController>() && Get.find<ProfileController>().userInfoModel != null) {
      _isAnonymous = Get.find<ProfileController>().userInfoModel!.isAnonymous ?? false;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'add_suggestion'.tr),
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: FooterView(
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: Dimensions.webMaxWidth,
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('suggestion_title'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'type_suggestion_title_here'.tr,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).primaryColor),
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    Text('category'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        border: Border.all(color: Theme.of(context).disabledColor.withOpacity(0.4)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          isExpanded: true,
                          items: _categories.map((cat) {
                            return DropdownMenuItem<String>(
                              value: cat['key'],
                              child: Text(cat['label'] ?? cat['key']!, style: robotoRegular),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedCategory = value;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    Text('suggestion_details'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'type_suggestion_details_here'.tr,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).primaryColor),
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _isAnonymous,
                            onChanged: (value) {
                              setState(() {
                                _isAnonymous = value ?? false;
                              });
                            },
                            activeColor: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Text('hide_my_name'.tr, style: robotoRegular),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    GetBuilder<SuggestionController>(builder: (suggestionController) {
                      return !suggestionController.isSubmitLoading
                          ? CustomButton(
                              buttonText: 'submit'.tr,
                              onPressed: () async {
                                if (_titleController.text.trim().isEmpty) {
                                  showCustomSnackBar('please_enter_suggestion_title'.tr);
                                } else if (_descriptionController.text.trim().isEmpty) {
                                  showCustomSnackBar('please_enter_suggestion_details'.tr);
                                } else {
                                  bool success = await suggestionController.submitSuggestion(
                                    title: _titleController.text.trim(),
                                    description: _descriptionController.text.trim(),
                                    category: _selectedCategory,
                                    isAnonymous: _isAnonymous,
                                  );
                                  if (success) {
                                    Get.back();
                                  }
                                }
                              },
                            )
                          : const Center(child: CircularProgressIndicator());
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
