import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:suliman/features/suggestion/controllers/suggestion_controller.dart';
import 'package:suliman/features/suggestion/domain/models/suggestion_model.dart';
import 'package:suliman/helper/date_converter.dart';
import 'package:suliman/util/dimensions.dart';
import 'package:suliman/util/styles.dart';

class SuggestionWidget extends StatelessWidget {
  final CustomerSuggestion suggestion;
  final SuggestionController controller;

  const SuggestionWidget({
    super.key,
    required this.suggestion,
    required this.controller,
  });

  String _getCategoryText(String? category) {
    switch (category) {
      case 'app':
        return 'app_feedback'.tr;
      case 'delivery':
        return 'delivery_service'.tr;
      case 'store':
        return 'stores_service'.tr;
      case 'other':
        return 'other'.tr;
      case 'general':
      default:
        return 'general'.tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      margin: const EdgeInsets.only(
        bottom: Dimensions.paddingSizeSmall,
        left: Dimensions.paddingSizeSmall,
        right: Dimensions.paddingSizeSmall,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Category badge & Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
                child: Text(
                  _getCategoryText(suggestion.category),
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              if (suggestion.createdAt != null)
                Text(
                  DateConverter.containTAndZToUTCFormat(suggestion.createdAt!),
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: Theme.of(context).disabledColor,
                  ),
                ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          // Title
          Text(
            suggestion.title ?? '',
            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          // Description
          Text(
            suggestion.description ?? '',
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.85),
            ),
          ),

          // Admin Reply Section if present
          if (suggestion.reply != null && suggestion.reply!.isNotEmpty) ...[
            const SizedBox(height: Dimensions.paddingSizeSmall),
            const Divider(),
            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.support_agent, size: 18, color: Theme.of(context).primaryColor),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      Text(
                        'admin_reply'.tr,
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const Spacer(),
                      if (suggestion.repliedAt != null)
                        Text(
                          DateConverter.containTAndZToUTCFormat(suggestion.repliedAt!),
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall,
                            color: Theme.of(context).disabledColor,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  Text(
                    suggestion.reply!,
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                  ),
                ],
              ),
            ),
          ],

          // Footer: Delete button
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                Get.dialog(
                  AlertDialog(
                    title: Text('delete_suggestion'.tr),
                    content: Text('are_you_sure_to_delete_suggestion'.tr),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text('cancel'.tr),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.back();
                          controller.deleteSuggestion(suggestion.id!);
                        },
                        child: Text('delete'.tr, style: const TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
              label: Text(
                'delete'.tr,
                style: robotoMedium.copyWith(color: Colors.red, fontSize: Dimensions.fontSizeExtraSmall),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
