import 'package:flutter/material.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:get/get.dart';

class ArFurnitureScreen extends StatelessWidget {
  final String imageUrl;
  const ArFurnitureScreen({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'furniture_ar'.tr),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 50, color: Colors.grey),
            const SizedBox(height: 10),
            Text("AR Feature Temporarily Disabled", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 5),
            const Text("Dependency 'ar_flutter_plugin_updated' caused build errors."),
          ],
        ),
      ),
    );
  }
}