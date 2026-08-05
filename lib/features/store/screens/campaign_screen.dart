import 'package:sixam_mart/features/item/controllers/campaign_controller.dart';
import 'package:sixam_mart/features/item/domain/models/basic_campaign_model.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/item_view.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/common/widgets/web_menu_bar.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CampaignScreen extends StatefulWidget {
  final BasicCampaignModel campaign;
  const CampaignScreen({super.key, required this.campaign});

  @override
  State<CampaignScreen> createState() => _CampaignScreenState();
}

class _CampaignScreenState extends State<CampaignScreen> {
  bool _isStore = true;

  @override
  void initState() {
    super.initState();

    Get.find<CampaignController>().getBasicCampaignDetails(widget.campaign.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      backgroundColor: Theme.of(context).cardColor,
      body: GetBuilder<CampaignController>(builder: (campaignController) {
        return CustomScrollView(
          slivers: [

            ResponsiveHelper.isDesktop(context) ? SliverToBoxAdapter(
              child: Container(
                color: const Color(0xFF171A29),
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeExtraLarge),
                alignment: Alignment.center,
                child: Center(
                  child: SizedBox(
                    width: 1150,
                    child: Row(children: [
                      Expanded(
                        flex: 3,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          child: CustomImage(
                            fit: BoxFit.cover, height: 200, width: 1150,
                            image: '${widget.campaign.imageFullUrl}',
                          ),
                        ),
                      ),

                      Expanded(flex: 2, child: Container(
                        // color: Colors.green,
                        padding: const EdgeInsets.only(left: Dimensions.paddingSizeExtraLarge),
                        child: campaignController.basicCampaign != null ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              campaignController.basicCampaign!.title!,
                              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeOverLarge, color: Colors.white),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: Dimensions.paddingSizeDefault),

                            Text(
                              campaignController.basicCampaign!.description ?? '', maxLines: 2, overflow: TextOverflow.ellipsis,
                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).disabledColor),
                            ),
                            const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                            campaignController.basicCampaign!.startTime != null ? Row(children: [
                              Image.asset(Images.announcement, height: 15, width: 15, color: Colors.white),
                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                              Text('${'campaign_schedule'.tr}:', style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeExtraSmall, color: Colors.white,
                              )),
                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                              Text(
                                '${DateConverter.stringToLocalDateOnly(campaignController.basicCampaign!.availableDateStarts!)}'
                                    ' - ${DateConverter.stringToLocalDateOnly(campaignController.basicCampaign!.availableDateEnds!)}',
                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor),
                                textDirection: TextDirection.ltr,
                              ),
                            ]) : const SizedBox(),
                            const SizedBox(height: Dimensions.paddingSizeDefault),

                            campaignController.basicCampaign!.startTime != null ? Row(children: [
                              const Icon(Icons.access_time_filled, size: 16, color: Colors.white),
                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                              Text('${'daily_time'.tr}:', style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeExtraSmall, color: Colors.white,
                              )),
                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                              Text(
                                '${DateConverter.convertTimeToTime(campaignController.basicCampaign!.startTime!)}'
                                    ' - ${DateConverter.convertTimeToTime(campaignController.basicCampaign!.endTime!)}',
                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor),
                                textDirection: Get.find<LocalizationController>().isLtr ? TextDirection.ltr : TextDirection.rtl,
                              ),
                            ]) : const SizedBox(),
                            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                          ],
                        ) : const SizedBox(),
                      ))
                    ]),
                  ),
                ),
              ),
            ) : SliverAppBar(
              expandedHeight: 140,
              toolbarHeight: 50,
              pinned: true,
              floating: false,
              backgroundColor: Colors.white,
              leading: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle, color: Theme.of(context).primaryColor,
                ),
                child: IconButton(icon: const Icon(Icons.chevron_left, color: Colors.white), onPressed: () => Get.back()),
              ),
              flexibleSpace: FlexibleSpaceBar(
                // title: Text(
                //   widget.campaign.title!,
                //   style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Colors.black),
                // ),
                background: CustomImage(
                  fit: BoxFit.cover,
                  image: '${widget.campaign.imageFullUrl}',
                ),
              ),
              actions: const [
                SizedBox(),
              ],
            ),

            SliverToBoxAdapter(child: FooterView(child: Container(
              width: Dimensions.webMaxWidth,
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
              ),
              child: Column(children: [

                campaignController.basicCampaign != null && !ResponsiveHelper.isDesktop(context) ? Column(
                  children: [

                    Container(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 1, blurRadius: 5)],
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            child: CustomImage(
                              image: '${campaignController.basicCampaign!.imageFullUrl}',
                              height: 50, width: 60, fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(
                              campaignController.basicCampaign!.title!, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                            if (campaignController.basicCampaign!.description != null && campaignController.basicCampaign!.description!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                                child: Text(
                                  campaignController.basicCampaign!.description!, maxLines: 2, overflow: TextOverflow.ellipsis,
                                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                                ),
                              ),
                          ])),
                        ]),
                        const SizedBox(height: Dimensions.paddingSizeDefault),

                        if (campaignController.basicCampaign!.startTime != null)
                          Row(children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                ),
                                child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                                  Icon(Icons.date_range, color: Theme.of(context).primaryColor, size: 20),
                                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                  Text('campaign_schedule'.tr, style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor,
                                  )),
                                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                  Text(
                                    '${DateConverter.stringToLocalDateOnly(campaignController.basicCampaign!.availableDateStarts!)} - ${DateConverter.stringToLocalDateOnly(campaignController.basicCampaign!.availableDateEnds!)}',
                                    textAlign: TextAlign.center,
                                    textDirection: TextDirection.ltr,
                                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                                  ),
                                ]),
                              ),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeSmall),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                ),
                                child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                                  Icon(Icons.access_time, color: Theme.of(context).primaryColor, size: 20),
                                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                  Text('daily_time'.tr, style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor,
                                  )),
                                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                  Text(
                                    '${DateConverter.convertTimeToTime(campaignController.basicCampaign!.startTime!)} - ${DateConverter.convertTimeToTime(campaignController.basicCampaign!.endTime!)}',
                                    textAlign: TextAlign.center,
                                    textDirection: Get.find<LocalizationController>().isLtr ? TextDirection.ltr : TextDirection.rtl,
                                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                                  ),
                                ]),
                              ),
                            ),
                          ]),
                      ]),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                  ],
                ) : ResponsiveHelper.isDesktop(context) ? SizedBox(
                  width: 1150,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                    child: Text('store_list'.tr, style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                    )),
                  ),
                ) : const SizedBox(),

                Container(
                  height: 40,
                  width: 300,
                  margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _isStore = true),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _isStore ? Theme.of(context).primaryColor : Colors.transparent,
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            ),
                            child: Text(
                              'stores'.tr,
                              style: robotoMedium.copyWith(
                                color: _isStore ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                                fontSize: Dimensions.fontSizeSmall,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _isStore = false),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: !_isStore ? Theme.of(context).primaryColor : Colors.transparent,
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            ),
                            child: Text(
                              'items'.tr,
                              style: robotoMedium.copyWith(
                                color: !_isStore ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                                fontSize: Dimensions.fontSizeSmall,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                ItemsView(
                  isStore: _isStore,
                  items: _isStore ? null : campaignController.basicCampaign?.items,
                  padding: EdgeInsets.zero,
                  stores: _isStore ? campaignController.basicCampaign?.store : null,
                  isCampaign: !_isStore,
                  mobileItemCrossAxisCount: _isStore ? null : 2,
                ),

              ]),
            ))),
          ],
        );
      }),
    );
  }
}