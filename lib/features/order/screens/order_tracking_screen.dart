import 'dart:async';
import 'dart:collection';

import 'package:geolocator/geolocator.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/call/screens/zego_call_screen.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/location/widgets/permission_dialog_widget.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/chat/domain/models/conversation_model.dart';
import 'package:sixam_mart/features/order/controllers/order_controller.dart';
import 'package:sixam_mart/features/order/domain/models/order_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/marker_helper.dart';
import 'package:sixam_mart/helper/pusher_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/confirmation_dialog.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:sixam_mart/features/order/widgets/track_details_view_widget.dart';
import 'package:sixam_mart/features/order/widgets/tracking_stepper_widget.dart';
import 'package:sixam_mart/features/order/widgets/cancellation_dialogue_widget.dart';
import 'package:sixam_mart/features/order/widgets/parcel_cancelation/cancellation_reason_bottom_sheet.dart';
import 'package:sixam_mart/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixam_mart/util/styles.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String? orderID;
  final String? contactNumber;
  const OrderTrackingScreen({super.key, required this.orderID, this.contactNumber});

  @override
  OrderTrackingScreenState createState() => OrderTrackingScreenState();
}

class OrderTrackingScreenState extends State<OrderTrackingScreen> with WidgetsBindingObserver {
  GoogleMapController? _controller;
  final bool _isLoading = true;
  Set<Marker> _markers = HashSet<Marker>();
  Timer? _timer;
  bool showChatPermission = true;
  bool isHovered = false;

  void _loadData() async {
    await Get.find<LocationController>().getCurrentLocation(true, notify: false, defaultLatLng: LatLng(
      double.parse(AddressHelper.getUserAddressFromSharedPref()!.latitude!),
      double.parse(AddressHelper.getUserAddressFromSharedPref()!.longitude!),
    ));
    await Get.find<OrderController>().trackOrder(widget.orderID, null, true, contactNumber: widget.contactNumber);
    await Get.find<OrderController>().getOrderDetails(widget.orderID.toString());

    if(Get.find<SplashController>().configModel!.websocketEnabled!) {
      print('====pusher entered-------------');
      _trackWithPusher();
    }
    
    _timerTrackOrder();
  }

  void _trackWithPusher() {
    bool canTrackDeliveryman = Get.find<OrderController>().trackModel?.orderStatus != 'delivered' && Get.find<OrderController>().trackModel?.orderStatus != 'failed' && Get.find<OrderController>().trackModel?.orderStatus != 'canceled';
    if(Get.find<OrderController>().trackModel != null && Get.find<OrderController>().trackModel!.deliveryMan != null && canTrackDeliveryman) {
      Get.find<OrderController>().timerTrackOrder(widget.orderID.toString(), contactNumber: widget.contactNumber);

      PusherHelper().pusherDriverStatus(
        deliverymanId: Get.find<OrderController>().trackModel!.deliveryMan!.id.toString(),
        onLocationReceived: (RecordLocationBodyModel dmLocation) {
          print('======from view call: $dmLocation');
          updateDeliverymanMarker(dmLocation);
        },
      );


    }
  }

  void _timerTrackOrder(){
    if(Get.find<OrderController>().trackModel?.orderStatus != 'delivered' && Get.find<OrderController>().trackModel?.orderStatus != 'failed' && Get.find<OrderController>().trackModel?.orderStatus != 'canceled') {
      Get.find<OrderController>().timerTrackOrder(widget.orderID.toString(), contactNumber: widget.contactNumber);
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if(Get.currentRoute.contains(RouteHelper.orderDetails) || Get.currentRoute.contains(RouteHelper.orderTracking)){
          Get.find<OrderController>().timerTrackOrder(widget.orderID.toString(), contactNumber: widget.contactNumber);

          updateMarker(
            Get.find<OrderController>().trackModel?.store, Get.find<OrderController>().trackModel!.deliveryMan,
            Get.find<OrderController>().trackModel?.orderType == 'take_away' ? Get.find<LocationController>().position.latitude == 0 ? Get.find<OrderController>().trackModel?.deliveryAddress : AddressModel(
              latitude: Get.find<LocationController>().position.latitude.toString(),
              longitude: Get.find<LocationController>().position.longitude.toString(),
              address: Get.find<LocationController>().address,
            ) : Get.find<OrderController>().trackModel?.deliveryAddress,
            Get.find<OrderController>().trackModel?.orderType == 'take_away', Get.find<OrderController>().trackModel?.orderType == 'parcel', Get.find<OrderController>().trackModel?.moduleType == 'food',
          );

        } else {
          _timer?.cancel();
        }
      });
    }else{
      Get.find<OrderController>().timerTrackOrder(widget.orderID.toString(), contactNumber: widget.contactNumber);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    PusherHelper.initializePusher();
    _loadData();
  }

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // _timerTrackOrder();
    }else if(state == AppLifecycleState.paused){
      _timer?.cancel();
      _controller?.dispose();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
    _timer?.cancel();
    PusherHelper().pusherDisconnectPusher();
    WidgetsBinding.instance.removeObserver(this);
  }

  void onEntered(bool isHovered) {
    setState(() {
      this.isHovered = isHovered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'order_tracking'.tr, 
        menuWidget: IconButton(
          icon: Icon(Icons.refresh, color: Theme.of(context).primaryColor),
          onPressed: () {
            if(Get.find<OrderController>().trackModel != null){
              Get.find<OrderController>().timerTrackOrder(widget.orderID.toString(), contactNumber: widget.contactNumber);
            }
          },
        ),
      ),
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      body: GetBuilder<OrderController>(builder: (orderController) {
        OrderModel? track;
        if(orderController.trackModel != null) {
          track = orderController.trackModel;

          if(track!.orderType != 'parcel') {
            if (track.store!.storeBusinessModel == 'commission') {
              showChatPermission = true;
            } else if (track.store!.storeSubscription != null && track.store!.storeBusinessModel == 'subscription') {
              showChatPermission = track.store!.storeSubscription!.chat == 1;
            } else {
              showChatPermission = false;
            }
          } else {
            showChatPermission = AuthHelper.isLoggedIn();
          }
        }

        /*
        return track != null ? SingleChildScrollView(
          physics: isHovered || !ResponsiveHelper.isDesktop(context) ? const NeverScrollableScrollPhysics() : const AlwaysScrollableScrollPhysics(),
          child: FooterView(
            child: Center(child: SizedBox(width: Dimensions.webMaxWidth, height: ResponsiveHelper.isDesktop(context) ? 700 : MediaQuery.of(context).size.height * 0.85, child: Stack(children: [

              (track.store != null && track.store!.moduleId == 1) ? const SizedBox() : MouseRegion(
                onEnter: (event) => onEntered(true),
                onExit: (event) => onEntered(false),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(target: LatLng(
                    double.parse(track.deliveryAddress!.latitude!), double.parse(track.deliveryAddress!.longitude!),
                  ), zoom: 16),
                  minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
                  zoomControlsEnabled: false,
                  markers: _markers,
                  onMapCreated: (GoogleMapController controller) {
                    _controller = controller;
                    _isLoading = false;
                    setMarker(
                      track!.orderType == 'parcel' ? Store(latitude: track.receiverDetails!.latitude, longitude: track.receiverDetails!.longitude,
                          address: track.receiverDetails!.address, name: track.receiverDetails!.contactPersonName) : track.store, track.deliveryMan,
                      track.orderType == 'take_away' ? Get.find<LocationController>().position.latitude == 0 ? track.deliveryAddress : AddressModel(
                        latitude: Get.find<LocationController>().position.latitude.toString(),
                        longitude: Get.find<LocationController>().position.longitude.toString(),
                        address: Get.find<LocationController>().address,
                      ) : track.deliveryAddress, track.orderType == 'take_away', track.orderType == 'parcel', track.moduleType == 'food',
                    );
                  },
                  style: Get.isDarkMode ? Get.find<ThemeController>().darkMap : Get.find<ThemeController>().lightMap,
                ),
              ),

              _isLoading && (track.store == null || track.store!.moduleId != 1) ? const CustomLoaderWidget() : const SizedBox(),

              Positioned(
                top: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall,
                child: TrackingStepperWidget(status: track.orderStatus, takeAway: track.orderType == 'take_away', isPickupCenter: track.orderType == 'pickup_center'),
              ),

              (track.store != null && track.store!.moduleId == 1) ? const SizedBox() : Positioned(
                right: 15, bottom: track.orderType != 'take_away' && track.deliveryMan == null ? 150 : 220,
                child: InkWell(
                  onTap: () => _checkPermission(() async {
                    AddressModel address = await Get.find<LocationController>().getCurrentLocation(false, mapController: _controller);
                    setMarker(
                      track!.orderType == 'parcel' ? Store(latitude: track.receiverDetails!.latitude, longitude: track.receiverDetails!.longitude,
                          address: track.receiverDetails!.address, name: track.receiverDetails!.contactPersonName) : track.store, track.deliveryMan,
                      track.orderType == 'take_away' ? Get.find<LocationController>().position.latitude == 0 ? track.deliveryAddress : AddressModel(
                        latitude: Get.find<LocationController>().position.latitude.toString(),
                        longitude: Get.find<LocationController>().position.longitude.toString(),
                        address: Get.find<LocationController>().address,
                      ) : track.deliveryAddress, track.orderType == 'take_away', track.orderType == 'parcel', track.moduleType == 'food',
                      currentAddress: address, fromCurrentLocation: true,
                    );
                  }),
                  child: Container(
                    padding: const EdgeInsets.all( Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: Colors.white),
                    child: Icon(Icons.my_location_outlined, color: Theme.of(context).primaryColor, size: 25),
                  ),
                ),
              ),

              Positioned(
                bottom: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall,
                child: TrackDetailsViewWidget(status: track.orderStatus, track: track, showChatPermission: showChatPermission, callback: () async{
                  bool takeAway = track?.orderType == 'take_away';
                  _timer?.cancel();
                  await Get.toNamed(RouteHelper.getChatRoute(
                    notificationBody: takeAway ? NotificationBodyModel(restaurantId: track!.store!.id, orderId: int.parse(widget.orderID!))
                        : NotificationBodyModel(deliverymanId: track!.deliveryMan!.id, orderId: int.parse(widget.orderID!)),
                    user: User(
                      id: takeAway ? track.store!.id : track.deliveryMan!.id,
                      fName: takeAway ? track.store!.name : track.deliveryMan!.fName,
                      lName: takeAway ? '' : track.deliveryMan!.lName,
                      imageFullUrl: takeAway ? track.store!.logoFullUrl : track.deliveryMan!.imageFullUrl,
                    ),
                  ));
                  _timerTrackOrder();
                }),
              ),

            ]))),
          ),
        ) : const CustomLoaderWidget();
        */

        return track != null ? (track.orderType == 'parcel'
            ? _buildParcelTracking(orderController, track)
            : SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // Order Info Card
            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                color: Theme.of(context).disabledColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                    ),
                    child: Row(children: [
                      Icon(Icons.access_time_rounded, size: 16, color: Colors.white),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      Text((track.orderType != 'pickup_center' && track.orderStatus == 'arrived_at_pickup_center' ? 'delivery_on_the_way' : track.orderStatus!).tr, style: robotoBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeSmall)),
                    ]),
                  ),
                  Text('ORD-${track.id}', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor)),
                ]),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  track.orderStatus != 'canceled' && Get.find<SplashController>().configModel!.orderDeliveryVerification! ? Row(children: [
                    Text('${'delivery_verification_code'.tr}: ', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.6))),
                    InkWell(
                      onTap: () {
                        if (track!.otp != null && track.otp!.isNotEmpty) {
                          Clipboard.setData(ClipboardData(text: track.otp!));
                          showCustomSnackBar('code_copied'.tr, isError: false);
                        }
                      },
                      child: Row(children: [
                        Text(track.otp ?? '', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Icon(Icons.copy, size: 14, color: Theme.of(context).primaryColor),
                      ]),
                    ),
                  ]) : const SizedBox(),

                  Text(
                    DateConverter.dateTimeStringToDateTime(track.createdAt!),
                    style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
                  ),
                ]),
              ]),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            /*// Estimated Time
            Center(
              child: Text(
                '${'estimated_delivery_time'.tr}: ${track.processingTime ?? 30} ${'min'.tr}',
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),*/

            // Timeline Card
            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.1)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('order_status'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                _buildTimelineStep(context, 'order_placed'.tr, track.createdAt, true),
                _buildTimelineStep(context, 'order_confirmed'.tr, track.confirmed, track.confirmed != null || track.orderStatus == 'processing' || track.orderStatus == 'handover' || track.orderStatus == 'picked_up' || track.orderStatus == 'arrived_at_pickup_center' || track.orderStatus == 'delivered'),
                _buildTimelineStep(context, 'preparing_item'.tr, track.processing, track.processing != null || track.handover != null || track.orderStatus == 'processing' || track.orderStatus == 'handover' || track.orderStatus == 'picked_up' || track.orderStatus == 'arrived_at_pickup_center' || track.orderStatus == 'delivered'),
                _buildTimelineStep(context, track.orderType == 'take_away' ? 'ready_for_handover'.tr : 'delivery_on_the_way'.tr, track.orderType == 'take_away' ? (track.handover ?? track.pickedUp) : track.pickedUp, track.handover != null || track.pickedUp != null || track.orderStatus == 'handover' || track.orderStatus == 'picked_up' || track.orderStatus == 'arrived_at_pickup_center' || track.orderStatus == 'delivered'),
                if (track.orderType == 'pickup_center')
                  _buildTimelineStep(context, 'arrived_at_pickup_center'.tr, track.orderStatus == 'arrived_at_pickup_center' ? track.updatedAt : null, track.orderStatus == 'arrived_at_pickup_center' || track.orderStatus == 'delivered'),
                _buildTimelineStep(context, 'delivered'.tr, track.delivered, track.orderStatus == 'delivered', isLast: true),

                const SizedBox(height: Dimensions.paddingSizeDefault),
                if(track.deliveryMan != null && track.orderStatus != 'delivered' && track.orderStatus != 'failed' && track.orderStatus != 'canceled' && track.orderStatus != 'refunded')
                  Padding(
                    padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
                    child: Row(children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            if(AuthHelper.isGuestLoggedIn()) {
                              if(await canLaunchUrlString('tel:${track!.deliveryMan!.phone}')) {
                                launchUrlString('tel:${track.deliveryMan!.phone}', mode: LaunchMode.externalApplication);
                              }
                            } else {
                              Get.bottomSheet(
                                Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                  ),
                                  padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                                    Container(
                                      height: 4, width: 40,
                                      decoration: BoxDecoration(color: Theme.of(context).disabledColor.withOpacity(0.3), borderRadius: BorderRadius.circular(2)),
                                    ),
                                    const SizedBox(height: Dimensions.paddingSizeLarge),
                                    Text('choose_call_option'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                                    const SizedBox(height: Dimensions.paddingSizeLarge),
                                    ListTile(
                                      leading: Icon(Icons.ring_volume, color: Theme.of(context).primaryColor),
                                      title: Text('online_call'.tr, style: robotoMedium),
                                      subtitle: Text('call_via_internet'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor)),
                                      onTap: () {
                                        Get.back();
                                        ZegoUIKitPrebuiltCallInvitationService().send(
                                          invitees: [
                                            ZegoCallUser(
                                              'delivery_${track!.deliveryMan!.id}',
                                              '${track.deliveryMan!.fName} ${track.deliveryMan!.lName}',
                                            )
                                          ],
                                          isVideoCall: false,
                                        );
                                      },
                                    ),
                                    const Divider(),
                                    ListTile(
                                      leading: Icon(Icons.phone, color: Theme.of(context).primaryColor),
                                      title: Text('cellular_call'.tr, style: robotoMedium),
                                      subtitle: Text('call_via_sim_card'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor)),
                                      onTap: () async {
                                        Get.back();
                                        if (await canLaunchUrlString('tel:${track!.deliveryMan!.phone}')) {
                                          launchUrlString('tel:${track.deliveryMan!.phone}', mode: LaunchMode.externalApplication);
                                        } else {
                                          showCustomSnackBar('${'can_not_launch'.tr} ${track.deliveryMan!.phone}');
                                        }
                                      },
                                    ),
                                  ]),
                                ),
                              );
                            }
                          },
                          icon: Icon(Icons.call, size: 18, color: Theme.of(context).primaryColor),
                          label: Text('call'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Theme.of(context).primaryColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                            minimumSize: const Size(0, 45),
                          ),
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Get.toNamed(RouteHelper.getChatRoute(
                              notificationBody: NotificationBodyModel(deliverymanId: track!.deliveryMan!.id, orderId: int.parse(widget.orderID!)),
                              user: User(
                                id: track.deliveryMan!.id,
                                fName: track.deliveryMan!.fName,
                                lName: track.deliveryMan!.lName,
                                imageFullUrl: track.deliveryMan!.imageFullUrl,
                              ),
                            ));
                          },
                          icon: Icon(Icons.chat_bubble_outline, size: 18, color: Theme.of(context).primaryColor),
                          label: Text('chat'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Theme.of(context).primaryColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                            minimumSize: const Size(0, 45),
                          ),
                        ),
                      ),
                    ]),
                  ),
              ]),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            // Address Section
            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.1)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('address'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Row(children: [
                  Icon(Icons.location_on, color: Theme.of(context).primaryColor),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(child: Text(track.deliveryAddress?.address ?? '', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall))),
                ]),
              ]),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            // Products Summary
            if(orderController.orderDetails != null)
              Builder(
                builder: (context) {
                  bool hasUnit = orderController.orderDetails!.any((detail) => detail.itemDetails?.unitType != null && detail.itemDetails?.unitType?.isNotEmpty == true);
                  
                  return Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.1)),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == 'food' ? 'meals_summary'.tr : 'products_summary'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      Table(
                        columnWidths: hasUnit ? const {
                          0: FlexColumnWidth(3),
                          1: FlexColumnWidth(1.5),
                          2: FlexColumnWidth(2),
                          3: FlexColumnWidth(1),
                          4: FlexColumnWidth(2),
                        } : const {
                          0: FlexColumnWidth(3),
                          1: FlexColumnWidth(2),
                          2: FlexColumnWidth(1),
                          3: FlexColumnWidth(2),
                        },
                        children: [
                          TableRow(children: [
                            _buildTableHeader(Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == 'food' ? 'meal'.tr : 'product'.tr),
                            if (hasUnit) _buildTableHeader('unit'.tr),
                            _buildTableHeader('price'.tr),
                            _buildTableHeader('quantity'.tr),
                            _buildTableHeader('total'.tr),
                          ]),
                          ...orderController.orderDetails!.map((detail) => TableRow(children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(detail.itemDetails?.name ?? '', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall)),
                                  if (detail.variant != null && detail.variant!.isNotEmpty && detail.variant != 'null') ...[
                                    const SizedBox(height: 2),
                                    Text(detail.variant!, style: robotoRegular.copyWith(fontSize: 10, color: Theme.of(context).disabledColor)),
                                  ],
                                ],
                              ),
                            ),
                            if (hasUnit) Padding(
                              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                              child: Text(detail.itemDetails?.unitType ?? '-', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall), textAlign: TextAlign.center),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                              child: Text(PriceConverter.convertPrice(detail.price), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall)),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                              child: Text(detail.quantity.toString(), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall)),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                              child: Text(PriceConverter.convertPrice(detail.price! * detail.quantity!), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall)),
                            ),
                          ])),
                        ],
                      ),
                    ]),
                  );
                }
              ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            // Order Summary
            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.1)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('order_summary'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                _buildSummaryRow('item_price'.tr, PriceConverter.convertPrice(track.orderAmount! - track.deliveryCharge! - track.totalTaxAmount! + track.couponDiscountAmount! + track.storeDiscountAmount!)),
                if (track.dmTips != null && track.dmTips! > 0)
                  _buildSummaryRow('delivery_man_tips'.tr, PriceConverter.convertPrice(track.dmTips)),
                _buildSummaryRow('delivery_fee'.tr, PriceConverter.convertPrice(track.deliveryCharge)),
                if (track.totalTaxAmount != null && track.totalTaxAmount! > 0)
                  _buildSummaryRow('tax'.tr, PriceConverter.convertPrice(track.totalTaxAmount)),
                if ((track.couponDiscountAmount! + track.storeDiscountAmount!) > 0)
                  _buildSummaryRow('discount'.tr, '-${PriceConverter.convertPrice(track.couponDiscountAmount! + track.storeDiscountAmount!)}'),
                const Divider(),
                _buildSummaryRow('total_amount'.tr, PriceConverter.convertPrice(track.orderAmount), isBold: true),
              ]),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraLarge),

            // Footer Buttons
            /*ElevatedButton(
              onPressed: () {
                Get.toNamed(RouteHelper.getChatRoute(
                  notificationBody: NotificationBodyModel(restaurantId: track!.store!.id, orderId: int.parse(widget.orderID!)),
                  user: User(
                    id: track.store!.id,
                    fName: track.store!.name,
                    lName: '',
                    imageFullUrl: track.store!.logoFullUrl,
                  ),
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
              ),
              child: Text('contact_seller'.tr, style: robotoBold.copyWith(color: Colors.white)),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),*/

            // Show route on map button if order is in a trackable status
            Builder(
              builder: (context) {
                if (track == null) return const SizedBox();
                bool isParcel = track.orderType == 'parcel';
                final trackableStatuses = ['pending', 'accepted', 'confirmed', 'processing', 'handover', 'picked_up'];
                final isPendingWithoutDigitalPayment = track.orderStatus == 'pending' && track.paymentMethod != 'digital_payment';

                bool showTrackDeliveryButton = isParcel
                    ? trackableStatuses.contains(track.orderStatus)
                    : (isPendingWithoutDigitalPayment || trackableStatuses.contains(track.orderStatus));

                if (!showTrackDeliveryButton) return const SizedBox();

                return Padding(
                  padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                  child: CustomButton(
                    buttonText: 'track_on_map'.tr,
                    onPressed: () {
                      Get.toNamed(RouteHelper.getOrderTrackingMapRoute(track!.id, widget.contactNumber));
                    },
                  ),
                );
              },
            ),

            ElevatedButton(
              onPressed: () {
                Get.toNamed(RouteHelper.getChatRoute(
                  notificationBody: NotificationBodyModel(adminId: 0, orderId: int.parse(widget.orderID!)),
                  user: User(id: 0, fName: Get.find<SplashController>().configModel!.businessName, lName: '', imageFullUrl: Get.find<SplashController>().configModel!.logoFullUrl),
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
              ),
              child: Text('contact_customer_service'.tr, style: robotoBold.copyWith(color: Colors.white)),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            Builder(
              builder: (context) {
                if (track == null) return const SizedBox();
                final currentOrder = track;
                bool isParcel = currentOrder.orderType == 'parcel';
                bool showCancelButton = false;
                
                final isUserLoggedIn = Get.find<AuthController>().isLoggedIn();
                final isGuestLoggedIn = Get.find<AuthController>().isGuestLoggedIn();
                final hasGuestOrderDetails = orderController.orderDetails != null && orderController.orderDetails!.isNotEmpty && orderController.orderDetails![0].isGuest == 1;
                final canCancel = isUserLoggedIn || hasGuestOrderDetails;

                if (isParcel) {
                  final cancellableStatuses = ['pending', 'accepted', 'confirmed', 'processing', 'handover', 'picked_up'];
                  if(isGuestLoggedIn){
                    showCancelButton = currentOrder.orderStatus == 'pending' && canCancel;
                  }else{
                    showCancelButton = cancellableStatuses.contains(currentOrder.orderStatus) && canCancel;
                  }
                } else {
                  showCancelButton = currentOrder.orderStatus == 'pending' && canCancel;
                }

                return showCancelButton ? OutlinedButton(
                  onPressed: () {
                    if (isParcel) {
                      _handleParcelCancel(orderController, currentOrder, ResponsiveHelper.isDesktop(context));
                    } else {
                      _handleCancelOrder(orderController, currentOrder);
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                  ),
                  child: Text(isParcel ? 'cancel_delivery'.tr : 'cancel_order'.tr, style: robotoBold.copyWith(color: Theme.of(context).disabledColor)),
                ) : const SizedBox();
              }
            ),

          ]),
        )) : const CustomLoaderWidget();
      }),
    );
  }

  Widget _buildParcelTracking(OrderController orderController, OrderModel track) {
    final bool isFinished = ['delivered', 'canceled', 'failed', 'refunded'].contains(track.orderStatus);
    final bool canCancel = Get.find<AuthController>().isLoggedIn()
        || (orderController.orderDetails?.isNotEmpty == true && orderController.orderDetails!.first.isGuest == 1);
    final bool guest = Get.find<AuthController>().isGuestLoggedIn();
    final statuses = guest
        ? ['pending']
        : ['pending', 'accepted', 'confirmed', 'processing', 'handover', 'picked_up'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Center(child: SizedBox(width: Dimensions.webMaxWidth, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withValues(alpha: .72)]),
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('parcel_delivery'.tr, style: robotoBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeLarge)),
              Text('#${track.id}', style: robotoBold.copyWith(color: Colors.white)),
            ]),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Text((track.parcelCategory?.name ?? 'parcel'.tr), style: robotoRegular.copyWith(color: Colors.white70)),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge)),
              child: Text((track.orderStatus ?? '').tr, style: robotoBold.copyWith(color: Theme.of(context).primaryColor)),
            ),
          ]),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        _parcelCard(
          title: 'delivery_route'.tr,
          child: Column(children: [
            _parcelAddress('sender'.tr, track.deliveryAddress, Icons.my_location),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 19),
              child: Align(alignment: AlignmentDirectional.centerStart, child: Container(width: 2, height: 28, color: Theme.of(context).dividerColor)),
            ),
            _parcelAddress('receiver'.tr, track.receiverDetails, Icons.location_on),
          ]),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        _parcelCard(
          title: 'delivery_status'.tr,
          child: Column(children: [
            _buildTimelineStep(context, 'parcel_requested'.tr, track.createdAt, true),
            _buildTimelineStep(context, 'order_confirmed'.tr, track.confirmed, track.confirmed != null),
            _buildTimelineStep(context, 'parcel_picked_up'.tr, track.pickedUp, track.pickedUp != null),
            _buildTimelineStep(context, 'delivery_on_the_way'.tr, track.pickedUp, track.pickedUp != null),
            _buildTimelineStep(context, 'delivered'.tr, track.delivered, track.delivered != null, isLast: true),
          ]),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        _parcelCard(
          title: 'payment_summary'.tr,
          child: Column(children: [
            _buildSummaryRow('parcel_delivery_charge'.tr, PriceConverter.convertPrice(track.deliveryCharge)),
            if ((track.dmTips ?? 0) > 0) _buildSummaryRow('delivery_man_tips'.tr, PriceConverter.convertPrice(track.dmTips)),
            if ((track.totalTaxAmount ?? 0) > 0) _buildSummaryRow('tax'.tr, PriceConverter.convertPrice(track.totalTaxAmount)),
            if (track.chargePayer != null) _buildSummaryRow('charge_payer'.tr,
                (track.chargePayer == 'receiver' ? 'receiver_will_pay' : 'sender_will_pay').tr),
            const Divider(),
            _buildSummaryRow('total_amount'.tr, PriceConverter.convertPrice(track.orderAmount), isBold: true),
          ]),
        ),
        if (track.deliveryMan != null && !isFinished) ...[
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: () => launchUrlString('tel:${track.deliveryMan!.phone}', mode: LaunchMode.externalApplication),
              icon: const Icon(Icons.call_outlined), label: Text('call_delivery_man'.tr),
            )),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(child: OutlinedButton.icon(
              onPressed: () => Get.toNamed(RouteHelper.getChatRoute(
                notificationBody: NotificationBodyModel(deliverymanId: track.deliveryMan!.id, orderId: track.id),
                user: User(id: track.deliveryMan!.id, fName: track.deliveryMan!.fName, lName: track.deliveryMan!.lName, imageFullUrl: track.deliveryMan!.imageFullUrl),
              )),
              icon: const Icon(Icons.chat_bubble_outline), label: Text('chat'.tr),
            )),
          ]),
        ],
        if (canCancel && statuses.contains(track.orderStatus)) ...[
          const SizedBox(height: Dimensions.paddingSizeDefault),
          SizedBox(width: double.infinity, child: OutlinedButton(
            onPressed: () => _handleParcelCancel(orderController, track, ResponsiveHelper.isDesktop(context)),
            child: Text('cancel_delivery'.tr),
          )),
        ],
      ]))),
    );
  }

  Widget _parcelCard({required String title, required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      border: Border.all(color: Theme.of(context).dividerColor),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
      const SizedBox(height: Dimensions.paddingSizeDefault),
      child,
    ]),
  );

  Widget _parcelAddress(String title, AddressModel? address, IconData icon) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    CircleAvatar(
      radius: 20,
      backgroundColor: Theme.of(context).primaryColor.withValues(alpha: .12),
      child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
    ),
    const SizedBox(width: Dimensions.paddingSizeSmall),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: robotoBold),
      if ((address?.contactPersonName ?? '').isNotEmpty) Text(address!.contactPersonName!, style: robotoMedium),
      if ((address?.contactPersonNumber ?? '').isNotEmpty) Text(address!.contactPersonNumber!, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor)),
      Text(address?.address ?? '-', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
    ])),
  ]);

  Widget _buildTimelineStep(BuildContext context, String title, String? time, bool isActive, {bool isLast = false}) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(children: [
        Container(
          width: 20, height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withValues(alpha: 0.3),
          ),
          child: isActive ? Icon(Icons.check, size: 12, color: Colors.white) : null,
        ),
        if(!isLast)
          Container(
            width: 2, height: 40,
            color: isActive ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withValues(alpha: 0.3),
          ),
      ]),
      const SizedBox(width: Dimensions.paddingSizeSmall),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: isActive ? null : Theme.of(context).disabledColor)),
          if(time != null)
            Text(
              DateConverter.dateTimeStringToDateTime(time),
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
            ),
        ]),
      ),
    ]);
  }

  Widget _buildTableHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
      child: Text(title, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraSmall)),
    );
  }

  Widget _buildSummaryRow(String title, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title, style: isBold ? robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall) : robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
        Text(value, style: isBold ? robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall) : robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
      ]),
    );
  }

  void setMarker(Store? store, DeliveryMan? deliveryMan, AddressModel? addressModel, bool takeAway, bool parcel, bool isRestaurant, {AddressModel? currentAddress, bool fromCurrentLocation = false}) async {
    try {

      BitmapDescriptor restaurantImageData = await MarkerHelper.convertAssetToBitmapDescriptor(
        width: 30, imagePath: parcel ? Images.userMarker : isRestaurant ? Images.restaurantMarker : Images.markerStore,
      );

      BitmapDescriptor deliveryBoyImageData = await MarkerHelper.convertAssetToBitmapDescriptor(
        width: 30, imagePath: Images.deliveryManMarker,
      );
      BitmapDescriptor destinationImageData = await MarkerHelper.convertAssetToBitmapDescriptor(
        width: 30, imagePath: Images.userMarker,
      );

      /// Animate to coordinate
      LatLngBounds? bounds;
      double rotation = 0;
      if(_controller != null) {
        if (double.parse(addressModel!.latitude!) < double.parse(store!.latitude!)) {
          bounds = LatLngBounds(
            southwest: LatLng(double.parse(addressModel.latitude!), double.parse(addressModel.longitude!)),
            northeast: LatLng(double.parse(store.latitude!), double.parse(store.longitude!)),
          );
          rotation = 0;
        }else {
          bounds = LatLngBounds(
            southwest: LatLng(double.parse(store.latitude!), double.parse(store.longitude!)),
            northeast: LatLng(double.parse(addressModel.latitude!), double.parse(addressModel.longitude!)),
          );
          rotation = 180;
        }
      }
      LatLng centerBounds = LatLng(
        (bounds!.northeast.latitude + bounds.southwest.latitude)/2,
        (bounds.northeast.longitude + bounds.southwest.longitude)/2,
      );

      if(fromCurrentLocation && currentAddress != null) {
        LatLng currentLocation = LatLng(
          double.parse(currentAddress.latitude!),
          double.parse(currentAddress.longitude!),
        );
        _controller!.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(target: currentLocation, zoom: GetPlatform.isWeb ? 7 : 15)));
      }

      if(!fromCurrentLocation) {
        _controller!.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(target: centerBounds, zoom: GetPlatform.isWeb ? 10 : 17)));
        if(!ResponsiveHelper.isWeb()) {
          zoomToFit(_controller, bounds, centerBounds, padding: GetPlatform.isWeb ? 15 : 3);
        }
      }

      /// user for normal order , but sender for parcel order
      _markers = HashSet<Marker>();

      ///current location marker set
      if(currentAddress != null) {
        _markers.add(Marker(
          markerId: const MarkerId('current_location'),
          visible: true,
          draggable: false,
          zIndexInt: 2,
          flat: true,
          anchor: const Offset(0.5, 0.5),
          position: LatLng(
            double.parse(currentAddress.latitude!),
            double.parse(currentAddress.longitude!),
          ),
          icon: destinationImageData,
        ));
        setState(() {});
      }

      if(currentAddress == null){
        addressModel != null ? _markers.add(Marker(
          markerId: const MarkerId('destination'),
          position: LatLng(double.parse(addressModel.latitude!), double.parse(addressModel.longitude!)),
          infoWindow: InfoWindow(
            title: parcel ? 'sender'.tr : 'Destination'.tr,
            snippet: addressModel.address,
          ),
          icon: destinationImageData,
        )) : const SizedBox();
      }

      ///store for normal order , but receiver for parcel order
      store != null ? _markers.add(Marker(
        markerId: const MarkerId('store'),
        position: LatLng(double.parse(store.latitude!), double.parse(store.longitude!)),
        infoWindow: InfoWindow(
          title: parcel ? 'receiver'.tr : Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText! ? 'store'.tr : 'store'.tr,
          snippet: store.address,
        ),
        icon: restaurantImageData,
      )) : const SizedBox();

      deliveryMan != null ? _markers.add(Marker(
        markerId: const MarkerId('delivery_boy'),
        position: LatLng(double.parse(deliveryMan.lat ?? '0'), double.parse(deliveryMan.lng ?? '0')),
        infoWindow: InfoWindow(
          title: 'delivery_man'.tr,
          snippet: deliveryMan.location,
        ),
        rotation: rotation,
        icon: deliveryBoyImageData,
      )) : const SizedBox();

    }catch(_) {}
    setState(() {});
  }

  Future<void> updateDeliverymanMarker(RecordLocationBodyModel dmLocation) async {
    BitmapDescriptor deliveryBoyImageData = await MarkerHelper.convertAssetToBitmapDescriptor(
      width: 30, imagePath: Images.deliveryManMarker,
    );

    if(dmLocation.latitude != null && dmLocation.latitude!.isNotEmpty) {
      print('=========here=========> ${dmLocation.location} // ${dmLocation.latitude}, ${dmLocation.longitude}');
      _markers.removeWhere((m) => m.markerId.value == 'delivery_boy');
      _markers.add(Marker(
        markerId: const MarkerId('delivery_boy'),
        position: LatLng(double.parse(dmLocation.latitude ?? '0'), double.parse(dmLocation.longitude ?? '0')),
        infoWindow: InfoWindow(
          title: 'delivery_man'.tr,
          snippet: dmLocation.location,
        ),
        // rotation: rotation,
        icon: deliveryBoyImageData,
      ));

      setState(() { });
    }
  }

  void updateMarker(Store? store, DeliveryMan? deliveryMan, AddressModel? addressModel, bool takeAway, bool parcel, bool isRestaurant, {AddressModel? currentAddress, bool fromCurrentLocation = false}) async {
    try {

      BitmapDescriptor restaurantImageData = await MarkerHelper.convertAssetToBitmapDescriptor(
        width: 30, imagePath: parcel ? Images.userMarker : isRestaurant ? Images.restaurantMarker : Images.markerStore,
      );

      BitmapDescriptor deliveryBoyImageData = await MarkerHelper.convertAssetToBitmapDescriptor(
        width: 30, imagePath: Images.deliveryManMarker,
      );
      BitmapDescriptor destinationImageData = await MarkerHelper.convertAssetToBitmapDescriptor(
        width: 30, imagePath: Images.userMarker,
      );

      LatLngBounds? bounds;
      debugPrint(bounds.toString());
      double rotation = 0;
      if(_controller != null) {
        if (double.parse(addressModel!.latitude!) < double.parse(store!.latitude!)) {
          bounds = LatLngBounds(
            southwest: LatLng(double.parse(addressModel.latitude!), double.parse(addressModel.longitude!)),
            northeast: LatLng(double.parse(store.latitude!), double.parse(store.longitude!)),
          );
          rotation = 0;
        }else {
          bounds = LatLngBounds(
            southwest: LatLng(double.parse(store.latitude!), double.parse(store.longitude!)),
            northeast: LatLng(double.parse(addressModel.latitude!), double.parse(addressModel.longitude!)),
          );
          rotation = 180;
        }
      }

      /// user for normal order , but sender for parcel order
      _markers = HashSet<Marker>();

      ///current location marker set
      if(currentAddress != null) {
        _markers.add(Marker(
          markerId: const MarkerId('current_location'),
          visible: true,
          draggable: false,
          zIndexInt: 2,
          flat: true,
          anchor: const Offset(0.5, 0.5),
          position: LatLng(
            double.parse(currentAddress.latitude!),
            double.parse(currentAddress.longitude!),
          ),
          icon: destinationImageData,
        ));
        setState(() {});
      }

      if(currentAddress == null){
        addressModel != null ? _markers.add(Marker(
          markerId: const MarkerId('destination'),
          position: LatLng(double.parse(addressModel.latitude!), double.parse(addressModel.longitude!)),
          infoWindow: InfoWindow(
            title: parcel ? 'sender'.tr : 'Destination'.tr,
            snippet: addressModel.address,
          ),
          icon: destinationImageData,
        )) : const SizedBox();
      }

      ///store for normal order , but receiver for parcel order
      store != null ? _markers.add(Marker(
        markerId: const MarkerId('store'),
        position: LatLng(double.parse(store.latitude!), double.parse(store.longitude!)),
        infoWindow: InfoWindow(
          title: parcel ? 'receiver'.tr : Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText! ? 'store'.tr : 'store'.tr,
          snippet: store.address,
        ),
        icon: restaurantImageData,
      )) : const SizedBox();

      deliveryMan != null ? _markers.add(Marker(
        markerId: const MarkerId('delivery_boy'),
        position: LatLng(double.parse(deliveryMan.lat ?? '0'), double.parse(deliveryMan.lng ?? '0')),
        infoWindow: InfoWindow(
          title: 'delivery_man'.tr,
          snippet: deliveryMan.location,
        ),
        rotation: rotation,
        icon: deliveryBoyImageData,
      )) : const SizedBox();

    }catch(_) {}
    setState(() {});
  }

  Future<void> zoomToFit(GoogleMapController? controller, LatLngBounds? bounds, LatLng centerBounds, {double padding = 0.5}) async {
    bool keepZoomingOut = true;

    while(keepZoomingOut) {
      final LatLngBounds screenBounds = await controller!.getVisibleRegion();
      if(fits(bounds!, screenBounds)){
        keepZoomingOut = false;
        final double zoomLevel = await controller.getZoomLevel() - padding;
        controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: centerBounds,
          zoom: zoomLevel,
        )));
        break;
      }
      else {
        // Zooming out by 0.1 zoom level per iteration
        final double zoomLevel = await controller.getZoomLevel() - 0.1;
        controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: centerBounds,
          zoom: zoomLevel,
        )));
      }
    }
  }

  bool fits(LatLngBounds fitBounds, LatLngBounds screenBounds) {
    final bool northEastLatitudeCheck = screenBounds.northeast.latitude >= fitBounds.northeast.latitude;
    final bool northEastLongitudeCheck = screenBounds.northeast.longitude >= fitBounds.northeast.longitude;

    final bool southWestLatitudeCheck = screenBounds.southwest.latitude <= fitBounds.southwest.latitude;
    final bool southWestLongitudeCheck = screenBounds.southwest.longitude <= fitBounds.southwest.longitude;

    return northEastLatitudeCheck && northEastLongitudeCheck && southWestLatitudeCheck && southWestLongitudeCheck;
  }

  void _checkPermission(Function onTap) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if(permission == LocationPermission.denied) {
      showCustomSnackBar('you_have_to_allow'.tr);
    }else if(permission == LocationPermission.deniedForever) {
      Get.dialog(const PermissionDialogWidget());
    }else {
      onTap();
    }
  }

  void _handleCancelOrder(OrderController orderController, OrderModel order) {
    orderController.setOrderCancelReason('');
    Get.dialog(CancellationDialogueWidget(
      orderId: order.id,
      contactNumber: widget.contactNumber,
    ));
  }

  void _handleParcelCancel(OrderController orderController, OrderModel order, bool isDesktop) {
    final isBeforePickup = ['pending', 'accepted', 'confirmed'].contains(order.orderStatus);
    final cancellationSheet = CancellationReasonBottomSheet(
      isBeforePickup: isBeforePickup,
      orderId: order.id,
      contactNumber: widget.contactNumber,
      chargePayerSender: order.chargePayer == 'sender',
      orderAmount: order.orderAmount ?? 0,
      dmTips: order.dmTips ?? 0,
    );

    if (isDesktop) {
      Get.dialog(Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
        insetPadding: const EdgeInsets.all(20),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: cancellationSheet,
      ));
    } else {
      showCustomBottomSheet(child: cancellationSheet);
    }
  }

}
