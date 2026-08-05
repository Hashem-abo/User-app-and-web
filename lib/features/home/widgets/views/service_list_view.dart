import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/service/controllers/service_controller.dart';
import 'package:sixam_mart/features/service/widgets/service_widget.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class ServiceListView extends StatelessWidget {
  const ServiceListView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServiceController>(builder: (serviceController) {
      if (serviceController.services == null) {
        return const Center(child: CircularProgressIndicator());
      }
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
          child: Text('all_services'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
        ),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: serviceController.services!.length,
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
          itemBuilder: (context, index) {
            return ServiceWidget(service: serviceController.services![index], index: index);
          },
        ),
      ]);
    });
  }
}
