import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/smart_shopping_list/controllers/smart_shopping_list_controller.dart';
import 'package:sixam_mart/features/smart_shopping_list/screens/smart_shopping_list_screen.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class SmartShoppingListInputSheet extends StatefulWidget {
  const SmartShoppingListInputSheet({super.key});

  @override
  State<SmartShoppingListInputSheet> createState() => _SmartShoppingListInputSheetState();
}

class _SmartShoppingListInputSheetState extends State<SmartShoppingListInputSheet> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final ctrl = Get.find<SmartShoppingListController>();
    if (ctrl.rawInput.isNotEmpty) {
      _textController.text = ctrl.rawInput;
    }
    ctrl.loadNearestStoreSuggestions();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addSuggestion(String item) {
    String current = _textController.text.trim();
    if (current.isEmpty) {
      _textController.text = item;
    } else {
      List<String> items = current.split('\n');
      if (!items.contains(item)) {
        _textController.text = '$current\n$item';
      }
    }
    _textController.selection = TextSelection.fromPosition(
      TextPosition(offset: _textController.text.length),
    );
    setState(() {});
  }

  void _submit() {
    String text = _textController.text.trim();
    if (text.isEmpty) {
      showCustomSnackBar('please_enter_shopping_items'.tr);
      return;
    }

    final ctrl = Get.find<SmartShoppingListController>();
    ctrl.searchList(text);
    Get.back(); // close bottom sheet
    Get.to(() => const SmartShoppingListScreen());
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        left: Dimensions.paddingSizeDefault,
        right: Dimensions.paddingSizeDefault,
        top: Dimensions.paddingSizeDefault,
        bottom: MediaQuery.of(context).viewInsets.bottom + Dimensions.paddingSizeDefault,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            // Header Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withValues(alpha: 0.7),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'smart_shopping_list'.tr,
                        style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                      ),
                      Text(
                        'write_items_line_by_line'.tr,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close, color: Theme.of(context).disabledColor),
                ),
              ],
            ),

            const SizedBox(height: Dimensions.paddingSizeDefault),

            // Text Input Box
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Theme.of(context).disabledColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                  width: 1.2,
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                maxLines: 5,
                minLines: 4,
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                decoration: InputDecoration(
                  hintText: 'shopping_list_hint'.tr,
                  hintStyle: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).hintColor.withValues(alpha: 0.7),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),

            const SizedBox(height: Dimensions.paddingSizeSmall),

            // Quick Suggestions Section (Dynamically loaded from closest store)
            GetBuilder<SmartShoppingListController>(
              builder: (ctrl) {
                final List<String> suggestions = ctrl.quickSuggestions.isNotEmpty
                    ? ctrl.quickSuggestions
                    : SmartShoppingListController.defaultFallbackSuggestions;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'quick_suggestions'.tr,
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        if (ctrl.isSuggestionsLoading) ...[
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: suggestions.map((item) {
                        return ActionChip(
                          label: Text(
                            '+ $item',
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeExtraSmall,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                          side: BorderSide(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                            width: 0.8,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                          onPressed: () => _addSuggestion(item),
                        );
                      }).toList(),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: Dimensions.paddingSizeLarge),

            // Submit Button
            CustomButton(
              buttonText: 'search_and_shop'.tr,
              icon: Icons.search_rounded,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
