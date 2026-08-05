import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/product_question/domain/models/product_question_model.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/features/product_question/controllers/product_question_controller.dart';

import 'package:sixam_mart/features/report/widgets/report_bottom_sheet.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';

class ProductQuestionWidget extends StatelessWidget {
  final ProductQuestion question;
  final bool hasDivider;
  final EdgeInsetsGeometry? margin;
  final double? width;
  const ProductQuestionWidget({super.key, required this.question, this.hasDivider = true, this.width = 280, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: margin ?? const EdgeInsets.only(right: Dimensions.paddingSizeSmall, bottom: 5),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.05), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text(
            question.user?.fName != null ? '${question.user!.fName} ${question.user!.lName}' : 'User',
            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
            maxLines: 1, overflow: TextOverflow.ellipsis,
          )),
          Text(
            DateConverter.isoStringToLocalDateOnly(question.createdAt ?? ''),
            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
          ),
        ]),
        const SizedBox(height: 2),

        Text(
          question.question ?? '',
          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
          maxLines: 2, overflow: TextOverflow.ellipsis,
        ),
        
        if(question.reply != null) ...[
          Divider(color: Theme.of(context).disabledColor.withOpacity(0.1), thickness: 1),
          
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('reply'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall)),
                const SizedBox(height: 2),
                Text(
                  question.reply!,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                ),
              ]),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              ),
              child: Icon(Icons.storefront, size: 20, color: Theme.of(context).primaryColor),
            ),
          ]),
        ],

        const SizedBox(height: 5),

        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          InkWell(
            onTap: () {
              if(Get.find<AuthController>().isLoggedIn()) {
                Get.find<ProductQuestionController>().toggleQuestionLike(question.id!, -1);
              } else {
                showCustomSnackBar('you_must_login_to_like_question'.tr);
              }
            },
            child: Row(children: [
              Icon(
                question.isLikedByUser == true ? Icons.thumb_up : Icons.thumb_up_off_alt,
                size: 16,
                color: question.isLikedByUser == true ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
              ),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              Text(
                '${question.likeCount ?? 0}',
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
              ),
            ]),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          
          InkWell(
            onTap: () {
              if(Get.find<AuthController>().isLoggedIn()) {
                if(question.id != null) {
                  Get.bottomSheet(ReportBottomSheet(reportableId: question.id!, reportableType: 'question'));
                }
              } else {
                showCustomSnackBar('you_must_login_to_report'.tr);
              }
            },
            child: Icon(Icons.report_gmailerrorred, size: 18, color: Theme.of(context).disabledColor),
          ),
        ]),
      ]),
    );
  }
}
