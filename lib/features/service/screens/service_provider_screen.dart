import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';
import 'package:sixam_mart/features/service/controllers/service_controller.dart';
import 'package:sixam_mart/features/service/domain/models/service_provider_model.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/features/service/domain/models/service_model.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/route_helper.dart';

class ServiceProviderScreen extends StatefulWidget {
  final ServiceProviderModel? provider;
  final int? providerId;
  const ServiceProviderScreen({super.key, this.provider, this.providerId});

  @override
  State<ServiceProviderScreen> createState() => _ServiceProviderScreenState();
}

class _ServiceProviderScreenState extends State<ServiceProviderScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    int? id = widget.provider?.id ?? widget.providerId;
    if (id != null) {
      if (widget.provider == null) {
        await Get.find<ServiceController>().getProviders();
      }
      Get.find<ServiceController>().getServices(1, providerId: id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServiceController>(builder: (serviceController) {
      ServiceProviderModel? provider = widget.provider;
      if (provider == null && widget.providerId != null && serviceController.providers != null) {
        provider = serviceController.providers!.firstWhereOrNull((p) => p.id == widget.providerId);
      }

      return Scaffold(
        appBar: CustomAppBar(title: 'provider_details'.tr),
        body: provider == null ? const CustomLoaderWidget() : CustomScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Stack(children: [
              Column(children: [
                Container(
                  height: 250, width: double.infinity,
                  alignment: Alignment.topCenter,
                  child: CustomImage(
                     fit: BoxFit.cover, height: 250, width: double.infinity,
                     image: '${provider.coverImageFullUrl}',
                  ),
                ),
              ]),

              Padding(
                padding: const EdgeInsets.only(top: 180),
                child: Column(children: [
                  SizedBox(
                    width: Dimensions.webMaxWidth,
                    child: Column(children: [
                       Container(
                          margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Theme.of(context).primaryColor, width: 1.5),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5))],
                          ),
                          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          child: Row(children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              child: CustomImage(
                                image: '${provider.logoFullUrl}',
                                height: 60, width: 60, fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeSmall),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                                Row(children: [
                                  Flexible(
                                    child: Text(
                                       provider.companyName ?? '', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyMedium!.color),
                                      maxLines: 1, overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (provider.verified == 1) ...[
                                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                    Icon(Icons.verified, color: Theme.of(context).primaryColor, size: 18),
                                  ]
                                ]),
                                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                Row(children: [
                                  Expanded(
                                   child: Text(
                                      provider.companyAddress ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                                    ),
                                  ),
                                ]),
                                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                Row(children: [
                                  Icon(Icons.star, color: Theme.of(context).primaryColor, size: 15),
                                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                  Text(
                                     provider.rating?.toStringAsFixed(1) ?? '0.0', 
                                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)
                                  ),
                                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                  Text(
                                     '(${provider.reviewsCount})', 
                                    style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeExtraSmall)
                                  ),
                                ]),
                              ]),
                            ),
                          ]),
                       ),
                    ]),
                  ),
                ]),
              ),
            ]),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Text('services'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
            ),
          ),

          GetBuilder<ServiceController>(builder: (serviceController) {
            List<Service>? services = serviceController.services;
            
            if (serviceController.isLoading || services == null) {
              return const SliverToBoxAdapter(child: CustomLoaderWidget());
            }
            
            if (services.isEmpty) {
              return SliverToBoxAdapter(child: Center(child: Padding(
                padding: const EdgeInsets.all(50),
                child: Text('no_services_found'.tr),
              )));
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return InkWell(
                    onTap: () => Get.toNamed(RouteHelper.getServiceDetailsRoute(services[index].id!)),
                    child: Container(
                      margin: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeSmall),
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 5, spreadRadius: 1)],
                      ),
                      child: Row(children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          child: CustomImage(
                            image: '${services[index].imageFullUrl}',
                            height: 70, width: 70, fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(services[index].name ?? '', style: robotoMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                          Text(
                            services[index].categoryName ?? '', 
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                          Text(
                            PriceConverter.convertPrice(services[index].price),
                            style: robotoBold.copyWith(color: Theme.of(context).primaryColor),
                          ),
                        ])),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          ),
                          child: Text(
                            services[index].serviceMode?.tr ?? '',
                            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor),
                          ),
                        ),
                      ]),
                    ),
                  );
                },
                childCount: services.length,
              ),
            );
          }),
        ],
      ),
    );
    });
  }
}
