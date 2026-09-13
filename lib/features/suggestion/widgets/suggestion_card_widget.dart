import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:suliman/common/widgets/confirmation_dialog.dart';
import 'package:suliman/common/widgets/custom_image.dart';
import 'package:suliman/features/suggestion/controllers/suggestion_controller.dart';
import 'package:suliman/features/suggestion/domain/models/suggestion_model.dart';
import 'package:suliman/helper/date_converter.dart';
import 'package:suliman/util/app_constants.dart';
import 'package:suliman/util/dimensions.dart';
import 'package:suliman/util/images.dart';
import 'package:suliman/util/styles.dart';

class SuggestionCardWidget extends StatelessWidget {
  final CustomerSuggestion suggestion;
  const SuggestionCardWidget({super.key, required this.suggestion});

  Color _getStatusColor(BuildContext context, int? status) {
    switch (status) {
      case 0:
        return Colors.orange; // Pending
      case 1:
        return Colors.blue; // Under Review
      case 2:
        return Colors.green; // Applied
      case 3:
        return Colors.red; // Rejected
      default:
        return Theme.of(context).disabledColor;
    }
  }

  String _getStatusText(int? status) {
    switch (status) {
      case 0:
        return 'pending'.tr;
      case 1:
        return 'under_review'.tr;
      case 2:
        return 'applied'.tr;
      case 3:
        return 'rejected'.tr;
      default:
        return 'pending'.tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor = _getStatusColor(context, suggestion.status);

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header: Category/Title & Status Badge
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                suggestion.title ?? '',
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
              ),
              const SizedBox(height: 4),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                  ),
                  child: Text(
                    suggestion.category?.tr ?? 'general'.tr,
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                if (suggestion.isAnonymous == true)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).disabledColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                    ),
                    child: Text(
                      'anonymous'.tr,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                    ),
                  ),
              ]),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              _getStatusText(suggestion.status),
              style: robotoBold.copyWith(color: statusColor, fontSize: Dimensions.fontSizeExtraSmall),
            ),
          ),
        ]),

        const SizedBox(height: Dimensions.paddingSizeSmall),

        // Description
        Text(
          suggestion.description ?? '',
          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyMedium!.color),
        ),

        // Attachments
        if (suggestion.attachment != null && suggestion.attachment!.isNotEmpty) ...[
          const SizedBox(height: Dimensions.paddingSizeSmall),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: suggestion.attachment!.length,
              itemBuilder: (context, index) {
                String imgUrl = '${AppConstants.baseUrl}/storage/app/public/suggestion/${suggestion.attachment![index]}';
                return Padding(
                  padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    child: CustomImage(image: imgUrl, height: 60, width: 60, fit: BoxFit.cover),
                  ),
                );
              },
            ),
          ),
        ],

        // Admin Reply section
        if (suggestion.reply != null && suggestion.reply!.trim().isNotEmpty) ...[
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.2)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(Icons.admin_panel_settings, size: 16, color: Theme.of(context).primaryColor),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                Text('admin_reply'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor)),
                const Spacer(),
                if (suggestion.repliedAt != null)
                  Text(
                    DateConverter.containTAndZToUTCFormat(suggestion.repliedAt!),
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                  ),
              ]),
              const SizedBox(height: 4),
              Text(suggestion.reply!, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
            ]),
          ),
        ],

        const SizedBox(height: Dimensions.paddingSizeSmall),

        // Footer: Date & Delete Button
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
            suggestion.createdAt != null ? DateConverter.containTAndZToUTCFormat(suggestion.createdAt!) : '',
            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
          ),
          InkWell(
            onTap: () {
              Get.dialog(ConfirmationDialog(
                icon: Images.support,
                title: 'are_you_sure_to_delete_suggestion'.tr,
                description: 'it_will_remove_your_suggestion'.tr,
                isLogOut: true,
                onYesPressed: () {
                  Get.back();
                  Get.find<SuggestionController>().deleteSuggestion(suggestion.id!);
                },
              ));
            },
            child: Row(children: [
              Icon(Icons.delete_outline, size: 18, color: Colors.red.withValues(alpha: 0.8)),
              const SizedBox(width: 2),
              Text('delete'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Colors.red.withValues(alpha: 0.8))),
            ]),
          ),
        ]),
      ]),
    );
  }
}
