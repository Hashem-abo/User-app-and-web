import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> with SingleTickerProviderStateMixin {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isScanCompleted = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scanWindow = Rect.fromCenter(
      center: Offset(
        MediaQuery.of(context).size.width / 2,
        MediaQuery.of(context).size.height / 2 - 50,
      ),
      width: 280,
      height: 280,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'scan_barcode'.tr,
          style: robotoBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeExtraLarge),
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            scanWindow: scanWindow,
            onDetect: (capture) {
              if (_isScanCompleted) return;
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final barcodeValue = barcodes.first.rawValue;
                if (barcodeValue != null && barcodeValue.isNotEmpty) {
                  _isScanCompleted = true;
                  Get.back(result: barcodeValue);
                }
              }
            },
          ),
          
          // Outer overlay with cut-out hole
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.6),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  color: Colors.transparent,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 100),
                    height: 280,
                    width: 280,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Border outlines around scanning region
          Align(
            alignment: Alignment.center,
            child: Container(
              margin: const EdgeInsets.only(bottom: 100),
              height: 280,
              width: 280,
              child: Stack(
                children: [
                  // Top-Left corner
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Theme.of(context).primaryColor, width: 4),
                          left: BorderSide(color: Theme.of(context).primaryColor, width: 4),
                        ),
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(8)),
                      ),
                    ),
                  ),
                  // Top-Right corner
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Theme.of(context).primaryColor, width: 4),
                          right: BorderSide(color: Theme.of(context).primaryColor, width: 4),
                        ),
                        borderRadius: const BorderRadius.only(topRight: Radius.circular(8)),
                      ),
                    ),
                  ),
                  // Bottom-Left corner
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Theme.of(context).primaryColor, width: 4),
                          left: BorderSide(color: Theme.of(context).primaryColor, width: 4),
                        ),
                        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(8)),
                      ),
                    ),
                  ),
                  // Bottom-Right corner
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Theme.of(context).primaryColor, width: 4),
                          right: BorderSide(color: Theme.of(context).primaryColor, width: 4),
                        ),
                        borderRadius: const BorderRadius.only(bottomRight: Radius.circular(8)),
                      ),
                    ),
                  ),

                  // Laser scanning line animation
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Positioned(
                        top: _animation.value * 270 + 5,
                        left: 10,
                        right: 10,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Bottom Control Actions (Flashlight & Switch Camera)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'align_barcode_inside_frame'.tr,
                  style: robotoRegular.copyWith(color: Colors.white.withValues(alpha: 0.75), fontSize: Dimensions.fontSizeDefault),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Flashlight button
                    ValueListenableBuilder<MobileScannerState>(
                      valueListenable: controller,
                      builder: (context, state, child) {
                        final isTorchOn = state.torchState == TorchState.on;
                        return InkWell(
                          onTap: () => controller.toggleTorch(),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isTorchOn ? Icons.flash_on : Icons.flash_off,
                              color: isTorchOn ? Theme.of(context).primaryColor : Colors.white,
                              size: 28,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: Dimensions.paddingSizeExtraLarge),
                    // Switch camera button
                    InkWell(
                      onTap: () => controller.switchCamera(),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.cameraswitch_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
