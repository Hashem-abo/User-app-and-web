import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/service/controllers/service_controller.dart';
import 'package:sixam_mart/features/service/domain/models/service_quotation_model.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/helper/route_helper.dart';

class ServiceQuotationDetailsScreen extends StatelessWidget {
  final ServiceQuotation quotation;
  const ServiceQuotationDetailsScreen({super.key, required this.quotation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'quotation_details'.tr, backButton: true),
      body: GetBuilder<ServiceController>(builder: (serviceController) {
        return Column(children: [
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Row(children: [
                Text('${'quotation_id'.tr}: #${quotation.id}', style: robotoMedium),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                  child: Text(quotation.status?.tr ?? '', style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeExtraSmall)),
                ),
              ]),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Text('service_info'.tr, style: robotoMedium),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 1, blurRadius: 5)],
                ),
                child: Row(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    child: CustomImage(
                      image: quotation.service?.imageFullUrl ?? '',
                      height: 60, width: 60, fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(quotation.service?.name ?? '', style: robotoMedium),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    Text(
                      quotation.provider?.companyName ?? '',
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                    ),
                  ])),
                ]),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              Text('description'.tr, style: robotoMedium),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Text(quotation.description ?? '', style: robotoRegular),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              if (quotation.images != null && quotation.images!.isNotEmpty) ...[
                Text('images'.tr, style: robotoMedium),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: quotation.images!.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          child: CustomImage(
                            image: '${AppConstants.baseUrl}/storage/app/public/quotation/${quotation.images![index]}',
                            height: 100, width: 100, fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
              ],

              if (quotation.status == 'offered') ...[
                const Divider(),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Text('offer_details'.tr, style: robotoBold.copyWith(color: Theme.of(context).primaryColor)),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.2)),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('offered_price'.tr, style: robotoMedium),
                      Text(PriceConverter.convertPrice(quotation.offeredPrice), style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor)),
                    ]),
                    if (quotation.providerNote != null && quotation.providerNote!.isNotEmpty) ...[
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      Text('provider_note'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                      Text(quotation.providerNote!, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                    ],
                  ]),
                ),
              ],

              if (quotation.status == 'accepted' && quotation.bookingId != null) ...[
                const SizedBox(height: Dimensions.paddingSizeDefault),
                Text('booking_info'.tr, style: robotoMedium),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                InkWell(
                  onTap: () => Get.toNamed(RouteHelper.getServiceBookingDetailsRoute(quotation.bookingId)),
                  child: Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      border: Border.all(color: Theme.of(context).primaryColor),
                    ),
                    child: Row(children: [
                      Expanded(child: Text('${'booking_id'.tr}: #${quotation.bookingId}', style: robotoMedium)),
                      Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).primaryColor),
                    ]),
                  ),
                ),
              ],

            ]),
          )),

          if(quotation.status == 'offered')
            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: CustomButton(
                buttonText: 'accept_offer'.tr,
                isLoading: serviceController.isLoading,
                onPressed: () {
                  serviceController.acceptQuotation(quotation.id!).then((response) {
                    if(response.isSuccess) {
                      Get.back();
                      showCustomSnackBar(response.message, isError: false);
                    }else {
                      showCustomSnackBar(response.message);
                    }
                  });
                },
              ),
            ),
        ]);
      }),
    );
  }
}
