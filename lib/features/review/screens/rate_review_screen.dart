import 'dart:ui' as ui;
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/features/order/domain/models/order_details_model.dart';
import 'package:sixam_mart/features/order/domain/models/order_model.dart';
import 'package:sixam_mart/features/review/controllers/review_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/features/review/widgets/deliver_man_review_widget.dart';
import 'package:sixam_mart/features/review/widgets/item_review_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RateReviewScreen extends StatefulWidget {
  final List<OrderDetailsModel> orderDetailsList;
  final DeliveryMan? deliveryMan;
  final int? orderID;
  final List<Reviews>? reviews;
  const RateReviewScreen({super.key, required this.orderDetailsList, required this.deliveryMan, required this.orderID, this.reviews});

  @override
  RateReviewScreenState createState() => RateReviewScreenState();
}

class RateReviewScreenState extends State<RateReviewScreen> with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: (widget.deliveryMan == null || widget.orderDetailsList.isEmpty) ? 1 : 2, initialIndex: 0, vsync: this);
    Get.find<ReviewController>().initRatingData(widget.orderDetailsList);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(title: 'rate_review'.tr, backgroundColor: Colors.transparent),
      endDrawer: const MenuDrawer(), endDrawerEnableOpenDragGesture: false,
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              Images.onboard_3,
              fit: BoxFit.cover,
            ),
          ),
          // Blur
          Positioned.fill(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: Theme.of(context).cardColor.withOpacity(0.1),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(children: [
              Center(
                child: Container(
                  width: Dimensions.webMaxWidth,
                  margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Theme.of(context).primaryColor,
                    unselectedLabelColor: Theme.of(context).disabledColor,
                    indicatorColor: Colors.transparent,
                    indicator: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                    unselectedLabelStyle: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                    tabs: widget.orderDetailsList.isNotEmpty ? widget.deliveryMan != null ? [
                      Tab(text: widget.orderDetailsList.length > 1 ? 'items'.tr : 'item'.tr),
                      Tab(text: (widget.orderDetailsList.isNotEmpty && widget.orderDetailsList[0].itemDetails!.moduleId == 1) ? 'Vendor' : 'delivery_man'.tr),
                    ] : [
                      Tab(text: widget.orderDetailsList.length > 1 ? 'items'.tr : 'item'.tr),
                    ] : [
                      Tab(text: (widget.orderDetailsList.isNotEmpty && widget.orderDetailsList[0].itemDetails!.moduleId == 1) ? 'Vendor' : 'delivery_man'.tr),
                    ],
                  ),
                ),
              ),

              Expanded(child: TabBarView(
                controller: _tabController,
                children: widget.orderDetailsList.isNotEmpty ? widget.deliveryMan != null ? [
                  ItemReviewWidget(orderDetailsList: widget.orderDetailsList, reviews: widget.reviews),
                  DeliveryManReviewWidget(deliveryMan: widget.deliveryMan, orderID: widget.orderID.toString(), moduleId: widget.orderDetailsList[0].itemDetails!.moduleId),
                ] : [
                  ItemReviewWidget(orderDetailsList: widget.orderDetailsList, reviews: widget.reviews),
                ] : [
                  DeliveryManReviewWidget(
                    deliveryMan: widget.deliveryMan, 
                    orderID: widget.orderID.toString(), 
                    moduleId: widget.orderDetailsList.isNotEmpty ? widget.orderDetailsList[0].itemDetails!.moduleId : null
                  ),
                ],
              )),

            ]),
          ),
        ],
      ),
    );
  }
}
