import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:suliman/features/splash/controllers/splash_controller.dart';
import 'package:suliman/features/order/controllers/order_controller.dart';
import 'package:suliman/features/order/domain/models/order_model.dart';
import 'package:suliman/features/location/domain/models/zone_response_model.dart';
import 'package:suliman/helper/address_helper.dart';
import 'package:suliman/util/app_constants.dart';
import 'package:suliman/common/widgets/custom_app_bar.dart';
import 'package:suliman/features/checkout/widgets/payment_failed_dialog.dart';
import 'package:suliman/features/wallet/widgets/fund_payment_dialog_widget.dart';
import 'package:suliman/helper/auth_helper.dart';
import 'package:suliman/features/profile/controllers/profile_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final OrderModel orderModel;
  final bool isCashOnDelivery;
  final String? addFundUrl;
  final String paymentMethod;
  final String guestId;
  final String contactNumber;
  final String? subscriptionUrl;
  final int? storeId;
  final bool? createAccount;
  final dynamic createUserId;
  const PaymentWebViewScreen({super.key, required this.orderModel, required this.isCashOnDelivery, this.addFundUrl, required this.paymentMethod,
    required this.guestId, required this.contactNumber, this.subscriptionUrl, this.storeId, this.createAccount = false, this.createUserId});

  @override
  PaymentScreenState createState() => PaymentScreenState();
}

class PaymentScreenState extends State<PaymentWebViewScreen> {
  late String selectedUrl;
  bool _isLoading = true;
  final bool _canRedirect = true;
  double? _maximumCodOrderAmount;
  PullToRefreshController? pullToRefreshController;
  InAppWebViewController? webViewController;
  final GlobalKey webViewKey = GlobalKey();

  static bool isAllowedPaymentDomain(Uri uri) {
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return false;
    }
    final host = uri.host.toLowerCase();
    if (host.isEmpty) return false;

    final baseHost = Uri.tryParse(AppConstants.baseUrl)?.host.toLowerCase() ?? '';
    if (baseHost.isNotEmpty && (host == baseHost || host.endsWith('.$baseHost'))) {
      return true;
    }

    const allowedPaymentDomains = [
      'stripe.com',
      'paypal.com',
      'sslcommerz.com',
      'paymob.com',
      'paytabs.com',
      'razorpay.com',
      'flutterwave.com',
      'paystack.com',
      'bkash.com',
      'nagad.com.bd',
      'mercadopago.com',
      'senangpay.my',
      'hyperpay.com',
      'thawani.om',
      'tap.company',
      'floosak.com',
      'kuraimi.com',
      'jawali.com',
      'easywallet.com',
      'directplace.store',
      'reg_directplace.store',
    ];

    for (final domain in allowedPaymentDomains) {
      if (host == domain || host.endsWith('.$domain')) {
        return true;
      }
    }
    return false;
  }

  @override
  void initState() {
    super.initState();

    if(widget.addFundUrl == '' && widget.addFundUrl!.isEmpty && widget.subscriptionUrl == '' && widget.subscriptionUrl!.isEmpty){
      dynamic customerId = (widget.createAccount ?? false)
          ? widget.createUserId
          : (widget.orderModel.userId == 0 || widget.orderModel.userId == null || widget.orderModel.userId == '0')
              ? (AuthHelper.isLoggedIn() ? (Get.find<ProfileController>().userInfoModel?.id ?? widget.guestId) : widget.guestId)
              : widget.orderModel.userId;
      selectedUrl = '${AppConstants.baseUrl}/payment-mobile?customer_id=$customerId&order_id=${widget.orderModel.id}&payment_method=${widget.paymentMethod}';
    } else if(widget.subscriptionUrl != '' && widget.subscriptionUrl!.isNotEmpty){
      selectedUrl = widget.subscriptionUrl!;
    } else{
      selectedUrl = widget.addFundUrl!;
    }


    _initData();
  }

  void _initData() async {
    if(widget.addFundUrl == null  || (widget.addFundUrl != null && widget.addFundUrl!.isEmpty)){
      for(ZoneData zData in AddressHelper.getUserAddressFromSharedPref()!.zoneData!) {
        for(Modules m in zData.modules!) {
          if(m.id == Get.find<SplashController>().module!.id) {
            _maximumCodOrderAmount = m.pivot!.maximumCodOrderAmount;
            break;
          }
        }
      }
    }

    pullToRefreshController = GetPlatform.isWeb || ![TargetPlatform.iOS, TargetPlatform.android].contains(defaultTargetPlatform) ? null : PullToRefreshController(
      onRefresh: () async {
        if (defaultTargetPlatform == TargetPlatform.android) {
          webViewController?.reload();
        } else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
          webViewController?.loadUrl(urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        _exitApp();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).cardColor,
        appBar: CustomAppBar(title: '', onBackPressed: () => _exitApp(), backButton: true),
        body: Stack(
          children: [
            InAppWebView(
              key: webViewKey,
              initialUrlRequest: URLRequest(url: WebUri(selectedUrl)),
              initialUserScripts: UnmodifiableListView<UserScript>([]),
              pullToRefreshController: pullToRefreshController,
              initialSettings: InAppWebViewSettings(
                isInspectable: kDebugMode,
                mediaPlaybackRequiresUserGesture: false,
                allowsInlineMediaPlayback: true,
                iframeAllow: "camera; microphone",
                iframeAllowFullscreen: true,
              ),
              onWebViewCreated: (controller) async {
                webViewController = controller;
              },
              onLoadStart: (controller, url) async {
                Get.find<OrderController>().paymentRedirect(
                  url: url.toString(), canRedirect: _canRedirect, onClose: (){} ,
                  addFundUrl: widget.addFundUrl, orderID: widget.orderModel.id.toString(), contactNumber: widget.contactNumber,
                  subscriptionUrl: widget.subscriptionUrl, storeId: widget.storeId, createAccount: widget.createAccount!,
                  guestId: widget.guestId,
                );
                setState(() {
                  _isLoading = true;
                });
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                Uri uri = navigationAction.request.url!;
                if (!["http", "https"].contains(uri.scheme)) {
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                    return NavigationActionPolicy.CANCEL;
                  }
                  return NavigationActionPolicy.CANCEL;
                }
                if (!isAllowedPaymentDomain(uri)) {
                  if (kDebugMode) {
                    print('Blocked untrusted navigation in payment webview: ${uri.toString()}');
                  }
                  return NavigationActionPolicy.CANCEL;
                }
                return NavigationActionPolicy.ALLOW;
              },
              onLoadStop: (controller, url) async {
                pullToRefreshController?.endRefreshing();
                setState(() {
                  _isLoading = false;
                });
                Get.find<OrderController>().paymentRedirect(
                  url: url.toString(), canRedirect: _canRedirect, onClose: (){} ,
                  addFundUrl: widget.addFundUrl, orderID: widget.orderModel.id.toString(), contactNumber: widget.contactNumber,
                  subscriptionUrl: widget.subscriptionUrl, storeId: widget.storeId, createAccount: widget.createAccount!,
                  guestId: widget.guestId,
                );
                // _redirect(url.toString());
              },
              onProgressChanged: (controller, progress) {
                if (progress == 100) {
                  pullToRefreshController?.endRefreshing();
                }
                // setState(() {
                //   _value = progress / 100;
                // });
              },
              onConsoleMessage: (controller, consoleMessage) {
                debugPrint(consoleMessage.message);
              },
            ),
            _isLoading ? Center(
              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
            ) : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Future<bool?> _exitApp() async {
    if((widget.addFundUrl == null  || (widget.addFundUrl != null && widget.addFundUrl!.isEmpty)) || !Get.find<SplashController>().configModel!.digitalPaymentInfo!.pluginPaymentGateways!){
      return Get.dialog(PaymentFailedDialog(
        orderID: widget.orderModel.id.toString(),
        orderAmount: widget.orderModel.orderAmount,
        maxCodOrderAmount: _maximumCodOrderAmount,
        orderType: widget.orderModel.orderType,
        isCashOnDelivery: widget.isCashOnDelivery,
        guestId: widget.guestId,
      ));
    }else{
      return Get.dialog(FundPaymentDialogWidget(isSubscription: widget.subscriptionUrl != null && widget.subscriptionUrl!.isNotEmpty));
    }

  }

}