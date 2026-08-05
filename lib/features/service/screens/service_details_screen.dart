import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/service/controllers/service_controller.dart';
import 'package:sixam_mart/features/service/domain/models/service_model.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';

class ServiceDetailsScreen extends StatefulWidget {
  final int id;
  const ServiceDetailsScreen({super.key, required this.id});

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Get.find<ServiceController>().getServiceDetails(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'service_details'.tr),
      body: GetBuilder<ServiceController>(builder: (serviceController) {
        Service? service = serviceController.serviceDetails;

        return serviceController.isLoading || service == null ? const CustomLoaderWidget() : Column(children: [
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            physics: const BouncingScrollPhysics(),
            child: Center(child: SizedBox(width: Dimensions.webMaxWidth, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                child: CustomImage(
                  image: '${service.imageFullUrl}',
                  height: 250, width: double.infinity, fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(service.name ?? '', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  Text(service.categoryName ?? '', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  InkWell(
                    onTap: () => Get.toNamed(RouteHelper.getReviewRoute(null, serviceID: service.id.toString(), storeName: service.name, service: service)),
                    child: Row(children: [
                      Icon(Icons.star, color: Theme.of(context).primaryColor, size: 15),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      Text(
                        service.avgRating?.toStringAsFixed(1) ?? '0.0',
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      Text(
                        '(${service.reviewsCount ?? 0})',
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                      ),
                    ]),
                  ),
                ])),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                  child: Text(
                    service.serviceMode?.tr ?? '',
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                  ),
                ),
              ]),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Text('description'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Text(service.description ?? '', style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.7))),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              if (service.provider != null) ...[
                Text('provider'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                InkWell(
                  onTap: () => Get.toNamed(RouteHelper.getServiceProviderRoute(service.provider!)),
                  child: Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.2)),
                    ),
                    child: Row(children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        child: CustomImage(image: '${service.provider!.logoFullUrl}', height: 50, width: 50, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(service.provider!.companyName ?? '', style: robotoMedium),
                        Text(service.provider!.companyAddress ?? '', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                        Row(children: [
                          Icon(Icons.star, color: Theme.of(context).primaryColor, size: 15),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                          Text(
                            service.provider!.avgRating?.toStringAsFixed(1) ?? '0.0',
                            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                          Text(
                            '(${service.provider!.reviewsCount ?? 0})',
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                          ),
                        ]),
                      ])),
                    ]),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),
              ],

            ]))),
          )),

          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, -1))],
            ),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text(
                  '${PriceConverter.convertPrice(service.price)}${service.serviceMode == 'rental' ? ' / ${(service.rentalUnit ?? 'day').tr}' : ''}',
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).primaryColor),
                ),
                Text(
                  '(${service.priceType == 'starting_price' ? 'starting_from'.tr : 'fixed'.tr})',
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                ),
              ])),

              CustomButton(
                width: 150,
                buttonText: service.serviceMode == 'quotation' ? 'get_quotation'.tr : 'book_now'.tr,
                onPressed: () {
                  if (!AuthHelper.isLoggedIn()) {
                    showCustomSnackBar('you_are_not_logged_in'.tr);
                    Get.toNamed(RouteHelper.getSignInRoute(Get.currentRoute));
                    return;
                  }
                  if (service.serviceMode == 'quotation') {
                    Get.toNamed(RouteHelper.getServiceQuotationRoute(service.id));
                  } else {
                    Get.toNamed(RouteHelper.getServiceBookingRoute(service.id));
                  }
                },
              ),
            ]),
          ),
        ]);
      }),
    );
  }
}
