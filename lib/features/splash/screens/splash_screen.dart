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

    Get.find<SplashController>().initSplashSession();
    Get.find<SplashController>().initSharedData();
    if((AuthHelper.getGuestId().isNotEmpty || AuthHelper.isLoggedIn()) && Get.find<SplashController>().cacheModule != null) {
      Get.find<CartController>().getCartDataOnline();
    }
    
    _checkAndInitVideo();
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
            _videoController?.setVolume(1.0);

            setState(() {
              _isVideoInitialized = true;
            });

            _videoController?.addListener(_videoListener);
          }
        }).catchError((error) {
          debugPrint('Splash video initialization error: $error');
          splashController.setVideoFinished();
        });
    }
  }

  void _videoListener() {
    if (_videoController != null && _videoController!.value.isInitialized) {
      if (_videoController!.value.duration > Duration.zero &&
          _videoController!.value.position >= _videoController!.value.duration) {
        _videoController?.removeListener(_videoListener);
        Get.find<SplashController>().setVideoFinished();
      }
    }
  }

  @override
  void dispose() {
    _onConnectivityChanged?.cancel();
    try {
      _videoController?.removeListener(_videoListener);
      _videoController?.pause();
      _videoController?.setVolume(0.0);
      _videoController?.dispose();
    } catch (_) {}
    _videoController = null;
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: GetBuilder<SplashController>(builder: (splashController) {
        if (!splashController.hasConnection) {
          return Center(child: NoInternetScreen(child: SplashScreen(body: widget.body)));
        }

        final String? rawSplash = splashController.cacheModule?.splashScreenImageFullUrl 
            ?? splashController.module?.splashScreenImageFullUrl;
        final String? moduleSplash = (rawSplash != null && rawSplash.trim().isNotEmpty && rawSplash.trim() != 'null') 
            ? rawSplash.trim() 
            : null;

        Widget content;
        if (moduleSplash != null && moduleSplash.toLowerCase().contains('.mp4')) {
          if (_videoController == null || !_isVideoInitialized) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _checkAndInitVideo();
            });
            content = KeyedSubtree(
              key: const ValueKey('splash_logo_video_pending'),
              child: _buildAnimatedLogo(context),
            );
          } else {
            content = SizedBox.expand(
              key: const ValueKey('splash_video'),
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController!.value.size.width,
                  height: _videoController!.value.size.height,
                  child: VideoPlayer(_videoController!),
                ),
              ),
            );
          }
        } else if (moduleSplash != null && moduleSplash.startsWith('http')) {
          content = Stack(
            key: const ValueKey('splash_image_stack'),
            fit: StackFit.expand,
            children: [
              _buildAnimatedLogo(context),
              CustomImage(
                image: moduleSplash,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
                placeholder: '',
              ),
            ],
          );
        } else {
          content = KeyedSubtree(
            key: const ValueKey('splash_logo'),
            child: _buildAnimatedLogo(context),
          );
        }

        return AnimatedScale(
          scale: splashController.isExiting ? 1.04 : 1.0,
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeOutCubic,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            child: content,
          ),
        );
      }),
    );
  }

  Widget _buildAnimatedLogo(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(Images.logo, width: 210, key: const ValueKey('logo'))
              .animate()
              .fadeIn(duration: 700.ms, curve: Curves.easeOut)
              .scale(
                begin: const Offset(0.88, 0.88),
                end: const Offset(1.0, 1.0),
                duration: 700.ms,
                curve: Curves.easeOutCubic,
              )
              .shimmer(delay: 750.ms, duration: 1200.ms, curve: Curves.easeInOut),
          const SizedBox(height: Dimensions.paddingSizeSmall),
        ],
      ),
    );
  }
}
