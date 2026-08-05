import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/report/controllers/report_controller.dart';
import 'package:sixam_mart/features/report/domain/models/report_model.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';

class ReportBottomSheet extends StatefulWidget {
  final int reportableId;
  final String reportableType;
  const ReportBottomSheet({super.key, required this.reportableId, required this.reportableType});

  @override
  State<ReportBottomSheet> createState() => _ReportBottomSheetState();
}

class _ReportBottomSheetState extends State<ReportBottomSheet> {
  final List<String> _reasons = [
    'spam',
    'inappropriate_content',
    'harassment',
    'other',
  ];
  String _selectedReason = 'inappropriate_content';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimensions.radiusExtraLarge),
          topRight: Radius.circular(Dimensions.radiusExtraLarge),
        ),
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: GetBuilder<ReportController>(builder: (reportController) {
        return Column(mainAxisSize: MainAxisSize.min, children: [
          
          Container(
            height: 5, width: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).disabledColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          Text('report_this_content'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          Text(
            'select_a_reason_for_reporting'.tr, 
             style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
             textAlign: TextAlign.center,
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          ..._reasons.map((reason) => RadioListTile<String>(
            title: Text(reason.tr, style: robotoMedium),
            value: reason,
            groupValue: _selectedReason,
            activeColor: Theme.of(context).primaryColor,
            onChanged: (value) {
              setState(() {
                _selectedReason = value!;
              });
            },
            dense: true,
            contentPadding: EdgeInsets.zero,
          )),

          const SizedBox(height: Dimensions.paddingSizeLarge),

          !reportController.isLoading ? Row(children: [
            Expanded(child: CustomButton(
              buttonText: 'cancel'.tr,
              transparent: true,
              onPressed: () => Get.back(),
              color: Theme.of(context).disabledColor,
            )),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            
            Expanded(child: CustomButton(
              buttonText: 'report'.tr,
              onPressed: () {
                ReportModel report = ReportModel(
                  reportableId: widget.reportableId,
                  reportableType: widget.reportableType,
                  reason: _selectedReason,
                );
                reportController.submitReport(report);
              },
            )),
          ]) : const Center(child: CircularProgressIndicator()),
          
        ]);
      }),
    );
  }
}
