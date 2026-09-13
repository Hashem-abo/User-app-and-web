import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:suliman/features/home/widgets/module_home_layout_builder.dart';
import 'package:suliman/features/splash/controllers/splash_controller.dart';
import 'package:suliman/helper/auth_helper.dart';

class GroceryHomeScreen extends StatelessWidget {
  const GroceryHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = AuthHelper.isLoggedIn();
    return GetBuilder<SplashController>(builder: (splashController) {
      return ModuleHomeLayoutBuilder(module: splashController.module!, isLoggedIn: isLoggedIn);
    });
  }
}
