import 'package:suliman/common/widgets/custom_snackbar.dart';
import 'package:suliman/helper/network_info.dart';
import 'package:suliman/helper/route_helper.dart';
import 'package:suliman/util/dimensions.dart';
import 'package:suliman/util/images.dart';
import 'package:suliman/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NoInternetScreen extends StatefulWidget {
  final Widget? child;
  final Function()? onRetry;
  final bool isScaffold;
  final bool showBackButton;
  const NoInternetScreen({super.key, this.child, this.onRetry, this.isScaffold = false, this.showBackButton = true});

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen> {
  bool _isChecking = false;

  void _handleRetry() async {
    if (_isChecking) return;
    setState(() => _isChecking = true);

    bool hasInternet = await NetworkInfo.hasConnection(forceCheck: true);

    if (mounted) {
      setState(() => _isChecking = false);
    }

    if (hasInternet) {
      if (widget.onRetry != null) {
        widget.onRetry!();
      } else if (widget.child != null) {
        try {
          Get.off(() => widget.child!);
        } catch (e) {
          Get.offAllNamed(RouteHelper.getInitialRoute());
        }
      } else if (Navigator.canPop(context)) {
        Get.back();
      } else {
        Get.offAllNamed(RouteHelper.getInitialRoute());
      }
    } else {
      showCustomSnackBar('no_internet_connection'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Stack(
      children: [
        if (widget.showBackButton && !widget.isScaffold && Navigator.canPop(context))
          PositionedDirectional(
            top: MediaQuery.of(context).padding.top + 8,
            start: 10,
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).textTheme.bodyLarge?.color),
              onPressed: () => Get.back(),
            ),
          ),
        Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.025),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            Image.asset(Images.noInternet, width: 260, height: 260),
            const SizedBox(height: 10),
            Text('oops'.tr, style: robotoBold.copyWith(
              fontSize: 30,
              color: Theme.of(context).textTheme.bodyLarge!.color,
            )),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            Text(
              'no_internet_connection'.tr,
              textAlign: TextAlign.center,
              style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
            ),
            const SizedBox(height: 35),

            GestureDetector(
              onTap: _handleRetry,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor,
                  boxShadow: [
                    BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.3), blurRadius: 10, spreadRadius: 2),
                  ],
                ),
                padding: const EdgeInsets.all(14),
                child: Center(
                  child: _isChecking
                      ? const SizedBox(
                          width: 30, height: 30,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : Icon(Icons.refresh, size: 30, color: Theme.of(context).cardColor),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    ],
    );

    if (widget.isScaffold) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: Navigator.canPop(context) ? AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).textTheme.bodyLarge?.color),
            onPressed: () => Get.back(),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ) : null,
        body: content,
      );
    }

    return content;
  }
}
