import 'package:flutter/material.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/features/home/widgets/module_home_layout_builder.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/service/controllers/service_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
// removed unused imports
import 'package:sixam_mart/features/service/widgets/service_widget.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';

class ServiceScreen extends StatefulWidget {
  final bool fromHomeScreen;
  final int categoryId;
  const ServiceScreen({super.key, this.fromHomeScreen = false, this.categoryId = -1});

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  final int _selectedCategory = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Get.find<ServiceController>().getCategories();
      if(widget.categoryId != -1) {
        int index = Get.find<ServiceController>().categories!.indexWhere((category) => category.id == widget.categoryId);
        Get.find<ServiceController>().setCategory(index, reload: true);
      } else {
        Get.find<ServiceController>().getServices(1, reload: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = AuthHelper.isLoggedIn();
    return GetBuilder<SplashController>(builder: (splashController) {
      return GetBuilder<ServiceController>(builder: (serviceController) {
        Widget content = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            if (splashController.module != null && 
                splashController.module!.layoutConfig != null && 
                splashController.module!.layoutConfig!.isNotEmpty &&
                widget.categoryId == -1)
              ModuleHomeLayoutBuilder(module: splashController.module!, isLoggedIn: isLoggedIn, wrapInSliver: false)
            else 
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: Dimensions.paddingSizeSmall),

                serviceController.categories != null ? Container(
                  height: 110,
                  width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: serviceController.categories!.length + 1,
                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                  itemBuilder: (context, index) {
                    bool isAll = index == 0;
                    bool isSelected = isAll ? serviceController.selectedCategory == -1 : serviceController.selectedCategory == index - 1;
                    return InkWell(
                      onTap: () {
                        serviceController.setCategory(isAll ? -1 : index - 1);
                      },
                      child: Container(
                        width: 80,
                        margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                        child: Column(children: [
                          Container(
                            height: 60, width: 60,
                            decoration: BoxDecoration(
                              color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                              border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withOpacity(0.3)),
                            ),
                            child: Center(
                              child: isAll ? Icon(Icons.grid_view_rounded, color: isSelected ? Colors.white : Theme.of(context).primaryColor) : ClipRRect(
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                child: CustomImage(
                                  image: '${serviceController.categories![index - 1].imageFullUrl}',
                                  height: 55, width: 55, fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                          Text(
                            isAll ? 'all'.tr : serviceController.categories![index - 1].name ?? '',
                            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyMedium!.color),
                            maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                          ),
                        ]),
                      ),
                    );
                  },
                ),
              ) : const SizedBox(),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                child: Text('all_services'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
              ),

              serviceController.services != null ? ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: serviceController.services!.length,
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                itemBuilder: (context, index) {
                  return ServiceWidget(service: serviceController.services![index], index: index);
                },
              ) : const CustomLoaderWidget(),
            ]),
          ]);

        return widget.fromHomeScreen ? content : Scaffold(
          appBar: CustomAppBar(title: 'services'.tr),
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: content,
          ),
        );
      });
    });
  }
}
