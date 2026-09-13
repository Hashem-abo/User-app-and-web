import 'package:suliman/features/notification/controllers/notification_controller.dart';
import 'package:suliman/features/splash/controllers/splash_controller.dart';
import 'package:suliman/helper/auth_helper.dart';
import 'package:suliman/helper/route_helper.dart';
import 'package:suliman/common/widgets/custom_app_bar.dart';
import 'package:suliman/common/widgets/menu_drawer.dart';
import 'package:suliman/common/widgets/not_logged_in_screen.dart';
import 'package:suliman/features/notification/widgets/notification_content_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationScreen extends StatefulWidget {
  final bool fromNotification;
  const NotificationScreen({super.key, this.fromNotification = false});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {

  void _loadData() async {
    Get.find<NotificationController>().clearNotification();
    if(Get.find<SplashController>().configModel == null) {
      await Get.find<SplashController>().getConfigData();
    }
    if(AuthHelper.isLoggedIn()) {
      Get.find<NotificationController>().getNotificationList(true);
    }
  }

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if(widget.fromNotification) {
          Get.offAllNamed(RouteHelper.getInitialRoute());
        } else {
          return;
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(title: 'notification'.tr, onBackPressed: () {
          if(widget.fromNotification){
            Get.offAllNamed(RouteHelper.getInitialRoute());
          }else{
            Get.back();
          }
        }),
        endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
        body: AuthHelper.isLoggedIn() ? const NotificationContentView() :  NotLoggedInScreen(callBack: (value){
          _loadData();
          setState(() {});
        }),
      ),
    );
  }
}
