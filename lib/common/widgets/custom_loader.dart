import 'package:sixam_mart/util/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sixam_mart/util/images.dart';

class CustomLoaderWidget extends StatelessWidget {
  final double size;
  const CustomLoaderWidget({super.key, this.size = 300});

  @override
  Widget build(BuildContext context) {
    return Center(child: Container(
      height: size, width: size,
      decoration: const BoxDecoration(color: Colors.transparent),
      alignment: Alignment.center,
      child: Lottie.asset(Images.loadingAnimation, width: size, height: size),
    ));
  }
}
