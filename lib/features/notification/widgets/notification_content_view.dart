import 'package:sixam_mart/common/widgets/custom_asset_image_widget.dart';
import 'package:sixam_mart/common/widgets/web_page_title_widget.dart';
import 'package:sixam_mart/features/notification/controllers/notification_controller.dart';
import 'package:sixam_mart/features/notification/domain/models/notification_model.dart';
import 'package:sixam_mart/features/notification/widgets/notification_bottom_sheet.dart';
import 'package:sixam_mart/features/notification/widgets/notification_dialog_widget.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/no_data_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationContentView extends StatefulWidget {
  const NotificationContentView({super.key});

  @override
  State<NotificationContentView> createState() => _NotificationContentViewState();
}

class _NotificationContentViewState extends State<NotificationContentView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _searchText = '';

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NotificationController>(builder: (notificationController) {
      if(notificationController.notificationList != null) {
        notificationController.saveSeenNotificationCount(notificationController.notificationList!.length);
      }
      List<DateTime> dateTimeList = [];
      List<NotificationModel>? notificationList;
      if(notificationController.notificationList != null) {
        notificationList = [];
        if(_searchText.isEmpty) {
          notificationList = notificationController.notificationList;
        }else {
          for (var notification in notificationController.notificationList!) {
            if(notification.data!.title!.toLowerCase().contains(_searchText.toLowerCase()) || notification.data!.description!.toLowerCase().contains(_searchText.toLowerCase())) {
              notificationList.add(notification);
            }
          }
        }
      }

      return notificationList != null ? notificationList.isNotEmpty ? RefreshIndicator(
        onRefresh: () async {
          await notificationController.getNotificationList(true);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: FooterView(
            child: Column(children: [
              WebScreenTitleWidget(title: 'notification'.tr),

              SizedBox(
                width: Dimensions.webMaxWidth,
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocus,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
                      decoration: InputDecoration(
                        hintText: 'search'.tr,
                        hintStyle: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault), borderSide: BorderSide.none),
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        isDense: true,
                        prefixIcon: Icon(Icons.search, color: Theme.of(context).disabledColor, size: 24),
                        suffixIcon: _searchText.isNotEmpty ? IconButton(
                          icon: Icon(Icons.clear, color: Theme.of(context).disabledColor, size: 24),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchText = '';
                            });
                            FocusScope.of(context).unfocus();
                          },
                        ) : null,
                      ),
                      onChanged: (String query) {
                        setState(() {
                          _searchText = query;
                        });
                      },
                    ),
                  ),
                ),
              ),

              Center(
                child: SizedBox(width: Dimensions.webMaxWidth, child: ListView.builder(
                  itemCount: notificationList.length,
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    DateTime originalDateTime = DateConverter.dateTimeStringToDate(notificationList![index].createdAt!);
                    DateTime convertedDate = DateTime(originalDateTime.year, originalDateTime.month, originalDateTime.day);
                    bool addTitle = false;
                    if(!dateTimeList.contains(convertedDate)) {
                      addTitle = true;
                      dateTimeList.add(convertedDate);
                    }

                    bool isSeen = notificationController.getSeenNotificationIdList()!.contains(notificationList[index].id);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                        addTitle ? Padding(
                          padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                          child: Text(
                            DateConverter.convertTodayYesterdayDate(notificationList[index].createdAt!),
                            style: robotoMedium.copyWith(color: Theme.of(context).hintColor),
                          ),
                        ) : const SizedBox(),

                        InkWell(
                          onTap: () {
                            notificationController.addSeenNotificationId(notificationList![index].id!);

                            ResponsiveHelper.isDesktop(context) ? showDialog(context: context, builder: (BuildContext context) {
                              return NotificationDialogWidget(notificationModel: notificationList![index]);
                            }) : showModalBottomSheet(
                              isScrollControlled: true, useRootNavigator: true, context: Get.context!,
                              backgroundColor: Colors.white,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusExtraLarge), topRight: Radius.circular(Dimensions.radiusExtraLarge)),
                              ),
                              builder: (context) {
                                return ConstrainedBox(
                                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
                                  child: NotificationBottomSheet(notificationModel: notificationList![index]),
                                );
                              },
                            );

                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                              boxShadow: isSeen ? [] : [const BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
                            ),
                            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

                              Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                ),
                                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall + 1),
                                child: CustomAssetImageWidget(
                                  notificationList[index].data!.type == 'push_notification' ? Images.pushNotificationIcon
                                      : notificationList[index].data!.type == 'order_status' ? Images.orderConfirmIcon : Images.referEarnIcon,
                                  height: 30, width: 30, fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: Dimensions.paddingSizeSmall),

                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

                                  Expanded(
                                    child: Text(
                                      notificationList[index].data!.title ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                                      style: robotoBold.copyWith(color: isSeen ? Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.5) : Theme.of(context).textTheme.bodyLarge?.color,
                                        fontWeight: isSeen ? FontWeight.w500 : FontWeight.w700,
                                      ),
                                    ),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                                    child: Text(
                                      DateConverter.dateTimeStringToFormattedTime(notificationList[index].createdAt!),
                                      style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: Dimensions.fontSizeSmall),
                                    ),
                                  ),

                                ]),
                                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Expanded(
                                    child: Text(
                                      notificationList[index].data!.description ?? '', maxLines: 2, overflow: TextOverflow.ellipsis,
                                      style: robotoRegular.copyWith(color: isSeen ? Theme.of(context).disabledColor : Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.7)),
                                    ),
                                  ),
                                  const SizedBox(width: Dimensions.paddingSizeSmall),

                                  notificationList[index].data!.type == 'push_notification' ? ClipRRect(
                                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                    child: notificationList[index].imageFullUrl!=null ? CustomImage(
                                      image: '${notificationList[index].imageFullUrl}',
                                      height: 45, width: 75, fit: BoxFit.cover,
                                    ): const SizedBox(),
                                  ) : const SizedBox.shrink(),

                                ]),

                              ])),

                            ]),
                          ),
                        ),

                      ]),
                    );
                  },
                )),
              ),
            ]),
          ),
        ),
      ) : NoDataScreen(text: 'no_notification_found'.tr, showFooter: true) : const Center(child: CircularProgressIndicator());
    });
  }
}
