import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/order/controllers/order_controller.dart';
import 'package:sixam_mart/features/order/domain/models/order_details_model.dart';
import 'package:sixam_mart/features/order/domain/models/order_model.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart'; // Ensure logo image path import
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';


class InvoiceScreen extends StatefulWidget {
  final String orderId;
  const InvoiceScreen({super.key, required this.orderId});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  final GlobalKey _invoiceKey = GlobalKey();
  bool _downloading = false;
  bool _loading = true;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    _loadInvoice();
  }

  Future<void> _loadInvoice() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _loadFailed = false;
      });
    }

    final controller = Get.find<OrderController>();
    await controller.trackOrder(widget.orderId, null, false);
    if (controller.trackModel != null) {
      await controller.getOrderDetails(widget.orderId);
    }

    if (!mounted) return;
    setState(() {
      _loading = false;
      _loadFailed = controller.trackModel == null || controller.orderDetails == null;
    });
  }

  Future<void> _downloadInvoice() async {
    if (_downloading) return;
    setState(() => _downloading = true);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final boundary = _invoiceKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) throw StateError('Invoice is not ready');
      final ui.Image image = await boundary.toImage(pixelRatio: 2);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) throw StateError('Could not create invoice');
      final box = context.findRenderObject() as RenderBox?;
      await SharePlus.instance.share(ShareParams(
        files: [XFile.fromData(data.buffer.asUint8List(), mimeType: 'image/png', name: 'invoice_${widget.orderId}.png')],
        subject: '${'invoice'.tr} #${widget.orderId}',
        sharePositionOrigin: box == null ? null : box.localToGlobal(Offset.zero) & box.size,
      ));
    } catch (_) {
      Get.snackbar('invoice'.tr, 'invoice_download_failed'.tr);
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('invoice'.tr), centerTitle: true),
      body: GetBuilder<OrderController>(builder: (controller) {
        if (_loading) {
          return const CustomLoaderWidget();
        }
        if (_loadFailed || controller.orderDetails == null || controller.trackModel == null) {
          return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.receipt_long_outlined, size: 56, color: Theme.of(context).disabledColor),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Text('failed_to_load_invoice'.tr, style: robotoMedium),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            ElevatedButton.icon(
              onPressed: _loadInvoice,
              icon: const Icon(Icons.refresh),
              label: Text('retry'.tr),
            ),
          ]));
        }
        final order = controller.trackModel!;
        final details = controller.orderDetails!;
        return Column(children: [
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: RepaintBoundary(key: _invoiceKey, child: ColoredBox(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: _invoice(order, details),
              ),
            )),
          )),
          SafeArea(top: false, child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: SizedBox(width: double.infinity, child: ElevatedButton.icon(
              onPressed: _downloading ? null : _downloadInvoice,
              icon: _downloading
                  ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.download_outlined),
              label: Text('download_invoice'.tr),
            )),
          )),
        ]);
      }),
    );
  }

  Widget _invoice(OrderModel order, List<OrderDetailsModel> details) {
    final isParcel = order.orderType == 'parcel';
    final storeDiscount = (order.storeDiscountAmount ?? 0) + (order.flashAdminDiscountAmount ?? 0) + (order.flashStoreDiscountAmount ?? 0);
    final proDiscount = order.proDiscount ?? 0;
    final proDeliveryDiscount = order.proDeliveryDiscount ?? 0;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // App Logo Header
      Center(
        child: Image.asset(
          Images.logo,
          height: 50,
          fit: BoxFit.contain,
        ),
      ),
      const SizedBox(height: Dimensions.paddingSizeSmall),
      Center(child: Text((isParcel ? 'parcel_invoice'.tr : 'invoice'.tr).toUpperCase(), style: robotoBold.copyWith(fontSize: 22))),
      const SizedBox(height: Dimensions.paddingSizeLarge),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        _labelValue(isParcel ? 'delivery_id'.tr : 'order_id'.tr, '#${order.id}'),
        _labelValue('date'.tr, order.createdAt ?? '', end: true),
      ]),
      const Divider(height: 30),
      if (isParcel) ..._parcelDetails(order) else ..._itemDetails(details),
      const Divider(height: 30),
      if (!isParcel) _row('item_price'.tr, PriceConverter.convertPrice(_itemsTotal(details))),
      if (storeDiscount > 0) _row('discount'.tr, '- ${PriceConverter.convertPrice(storeDiscount)}'),
      if (proDiscount > 0) _row('coupon_discount_pro'.tr, '- ${PriceConverter.convertPrice(proDiscount)}'),
      if ((order.couponDiscountAmount ?? 0) > 0) _row('coupon_discount'.tr, '- ${PriceConverter.convertPrice(order.couponDiscountAmount)}'),
      if ((order.totalTaxAmount ?? 0) > 0) _row('tax'.tr, PriceConverter.convertPrice(order.totalTaxAmount)),
      if ((order.additionalCharge ?? 0) > 0) _row('additional_charge'.tr, PriceConverter.convertPrice(order.additionalCharge)),
      if ((order.extraPackagingAmount ?? 0) > 0) _row('extra_packaging_charge'.tr, PriceConverter.convertPrice(order.extraPackagingAmount)),
      if ((order.dmTips ?? 0) > 0) _row('delivery_man_tips'.tr, PriceConverter.convertPrice(order.dmTips)),
      _row(isParcel ? 'parcel_delivery_charge'.tr : 'delivery_fee'.tr,
          PriceConverter.convertPrice((order.deliveryCharge ?? 0) + proDeliveryDiscount)),
      if (proDeliveryDiscount > 0) _row('delivery_fee_discount_pro'.tr, '- ${PriceConverter.convertPrice(proDeliveryDiscount)}'),
      if ((order.referrerBonusAmount ?? 0) > 0) _row('referral_discount'.tr, '- ${PriceConverter.convertPrice(order.referrerBonusAmount)}'),
      const Divider(height: 20),
      _row('payment_method'.tr, (order.paymentMethod ?? '').tr),
      _row('payment_status'.tr, (order.paymentStatus ?? '').tr),
      if (isParcel && order.chargePayer != null)
        _row('charge_payer'.tr, (order.chargePayer == 'receiver' ? 'receiver_will_pay' : 'sender_will_pay').tr),
      const Divider(height: 20),
      _row('total_amount'.tr, PriceConverter.convertPrice(order.orderAmount), bold: true),
      const SizedBox(height: 40),
      Center(child: Text('thank_you_for_your_order'.tr, style: robotoMedium.copyWith(color: Theme.of(context).disabledColor))),
    ]);
  }

  List<Widget> _itemDetails(List<OrderDetailsModel> details) => [
     Text(Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == 'food' ? ('meals_summary'.tr == 'meals_summary' ? 'ملخص الوجبات' : 'meals_summary'.tr) : ('products_summary'.tr == 'products_summary' ? 'ملخص المنتجات' : 'products_summary'.tr), style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
    const SizedBox(height: Dimensions.paddingSizeSmall),
    ...details.map((detail) => _row(
      '${detail.quantity ?? 0} x ${detail.itemDetails?.name ?? 'item'.tr}',
      PriceConverter.convertPrice((detail.price ?? 0) * (detail.quantity ?? 0)),
    )),
  ];

  List<Widget> _parcelDetails(OrderModel order) => [
    Text('parcel_details'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
    const SizedBox(height: Dimensions.paddingSizeSmall),
    _row('parcel_category'.tr, order.parcelCategory?.name ?? '-'),
    const SizedBox(height: Dimensions.paddingSizeDefault),
    _address('sender'.tr, order.deliveryAddress),
    const SizedBox(height: Dimensions.paddingSizeDefault),
    _address('receiver'.tr, order.receiverDetails),
  ];

  Widget _address(String title, AddressModel? address) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
    decoration: BoxDecoration(border: Border.all(color: Theme.of(context).dividerColor), borderRadius: BorderRadius.circular(8)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: robotoBold),
      if ((address?.contactPersonName ?? '').isNotEmpty) Text(address!.contactPersonName!, style: robotoRegular),
      if ((address?.contactPersonNumber ?? '').isNotEmpty) Text(address!.contactPersonNumber!, style: robotoRegular),
      if ((address?.address ?? '').isNotEmpty) Text(address!.address!, style: robotoRegular),
    ]),
  );

  double _itemsTotal(List<OrderDetailsModel> details) => details.fold(0, (sum, detail) => sum + (detail.price ?? 0) * (detail.quantity ?? 0));

  Widget _labelValue(String label, String value, {bool end = false}) => Column(
    crossAxisAlignment: end ? CrossAxisAlignment.end : CrossAxisAlignment.start,
    children: [Text(label, style: robotoMedium), Text(value, style: robotoRegular)],
  );

  Widget _row(String title, String value, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Expanded(child: Text(title, style: bold ? robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge) : robotoRegular)),
      const SizedBox(width: 12),
      Text(value, textAlign: TextAlign.end, style: bold
          ? robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).primaryColor)
          : robotoRegular),
    ]),
  );
}
