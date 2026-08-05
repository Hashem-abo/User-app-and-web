import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/no_internet_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatefulWidget {
  final NotificationBodyModel? body;
  const SplashScreen({super.key, required this.body});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  StreamSubscription<List<ConnectivityResult>>? _onConnectivityChanged;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();

    bool firstTime = true;
    _onConnectivityChanged = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      bool isConnected = result.contains(ConnectivityResult.wifi) || result.contains(ConnectivityResult.mobile);

      if(!firstTime) {
        isConnected ? ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar() : const SizedBox();
        ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
          backgroundColor: isConnected ? Colors.green : Colors.red,
          duration: Duration(seconds: isConnected ? 3 : 6000),
          content: Text(isConnected ? 'connected'.tr : 'no_connection'.tr, textAlign: TextAlign.center),
        ));
        if(isConnected) {
          Get.find<SplashController>().getConfigData(notificationBody: widget.body);
        }
      }

      firstTime = false;
    });

    Get.find<SplashController>().initSharedData();
    if((AuthHelper.getGuestId().isNotEmpty || AuthHelper.isLoggedIn()) && Get.find<SplashController>().cacheModule != null) {
      Get.find<CartController>().getCartDataOnline();
    }
    
    _checkAndInitVideo();
   // Get.find<SplashController>().getConfigData(notificationBody: widget.body);
    Get.find<SplashController>().getConfigData(notificationBody: widget.body).then((value) {
     _checkAndInitVideo(); // Try again after config is fetched
  });
  }

  void _checkAndInitVideo() {
  if (_videoController != null) return;

  SplashController splashController = Get.find<SplashController>();
  String? splashImage = splashController.cacheModule?.splashScreenImageFullUrl 
      ?? splashController.module?.splashScreenImageFullUrl;

  if (splashImage != null && splashImage.toLowerCase().contains('.mp4')) {
    _videoController = VideoPlayerController.networkUrl(Uri.parse(splashImage))
      ..initialize().then((_) {
        if (mounted) {
          _videoController?.play();
          _videoController?.setLooping(false);
          _videoController?.setVolume(1.0); // Ensure sound isn't muted by default

          setState(() {
            _isVideoInitialized = true; // This will now be "used" in the build method
          });

          _videoController?.addListener(_videoListener);
        }
      });
  }
}

// Extract the listener for cleaner code
void _videoListener() {
  if (_videoController!.value.position >= _videoController!.value.duration) {
    _videoController?.removeListener(_videoListener);
    Get.find<SplashController>().setVideoFinished();
  }
}

  @override
  void dispose() {
    _onConnectivityChanged?.cancel();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var userAddress = AddressHelper.getUserAddressFromSharedPref();
    if(userAddress != null && userAddress.zoneIds == null) {
      Get.find<AuthController>().clearSharedAddress();
    }

    return Scaffold(
      key: _globalKey,
      body: GetBuilder<SplashController>(builder: (splashController) {
        if (splashController.hasConnection) {
          // Priority logic: 
          // 1. Module splash (prefer cacheModule then active module)
          // 2. Fallback to animated logo (ignoring configModel.splashScreenImageFullUrl)
          String? moduleSplash = splashController.cacheModule?.splashScreenImageFullUrl 
            ?? splashController.module?.splashScreenImageFullUrl;

          if (moduleSplash != null) {
            bool isVideo = moduleSplash.toLowerCase().endsWith('.mp4');
            
            if (isVideo) {
              if (_videoController == null) {
                    _checkAndInitVideo(); // Trigger init if it was skipped
                    return _buildAnimatedLogo(context); 
                  }
               if (!_isVideoInitialized || _videoController == null) {
                    return _buildAnimatedLogo(context); 
                  }
               return SizedBox.expand(
                 child: FittedBox(
                   fit: BoxFit.cover,
                   child: SizedBox(
                     width: _videoController!.value.size.width,
                     height: _videoController!.value.size.height,
                     child: VideoPlayer(_videoController!),
                   ),
                 ),
               ).animate(
                 // If you want it to disappear smoothly at the end:
                 onComplete: (controller) => {}, 
               ).fadeIn(duration: 500.ms); // Modern entrance
            } else {
              return CustomImage(
                image: moduleSplash,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.fill,
                isUseMemCache: false,
              ).animate().fadeIn(duration: 1000.ms);
            }
          } else {
            return _buildAnimatedLogo(context);
          }
        }
        return Center(child: NoInternetScreen(child: SplashScreen(body: widget.body)));
      }),
    );
  }

  Widget _buildAnimatedLogo(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(Images.logo, width: 200, key: const ValueKey('logo'))
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .fadeIn(duration: 800.ms)
              .scale(duration: 800.ms, curve: Curves.easeOutBack)
              .shimmer(delay: 1000.ms, duration: 1000.ms),
          const SizedBox(height: Dimensions.paddingSizeSmall),
        ],
      ),
    );
  }
}
