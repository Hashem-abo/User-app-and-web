import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';
import 'package:sixam_mart/features/global_shopping/controllers/global_browse_controller.dart';
import 'package:sixam_mart/features/global_shopping/screens/global_order_form_screen.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class GlobalHomeScreen extends StatefulWidget {
  const GlobalHomeScreen({super.key});

  @override
  State<GlobalHomeScreen> createState() => _GlobalHomeScreenState();
}

class _GlobalHomeScreenState extends State<GlobalHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<GlobalBrowseController>().getGlobalStores();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GlobalBrowseController>(
      builder: (browseController) {
        if (browseController.isLoading && browseController.globalStores == null) {
          return const SizedBox(
            height: 300,
            child: Center(child: CustomLoaderWidget()),
          );
        }

        final stores = browseController.globalStores ?? [];

        return Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Banner Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withValues(alpha: 0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.public_rounded, size: 48, color: Colors.white),
                    const SizedBox(width: Dimensions.paddingSizeDefault),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'المتاجر العالمية (Global Stores)',
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                          Text(
                            'اختر المتجر العالمي، انسخ رابط السلة، وسنقوم بشرائه وتوصيله إليك!',
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: Dimensions.paddingSizeLarge),

              if (stores.isNotEmpty) ...[
                Text(
                  'المتاجر المتاحة للطلب:',
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: stores.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.95,
                    crossAxisSpacing: Dimensions.paddingSizeSmall,
                    mainAxisSpacing: Dimensions.paddingSizeSmall,
                  ),
                  itemBuilder: (context, index) {
                    final store = stores[index];
                    return InkWell(
                      onTap: () {
                        Get.to(() => GlobalOrderFormScreen(
                              storeName: store.name ?? 'متجر عالمي',
                              storeLogo: store.logoFullUrl,
                              urlPlaceholder: store.urlPlaceholder,
                            ));
                      },
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      child: Container(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          border: Border.all(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 65,
                              height: 65,
                              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                                shape: BoxShape.circle,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(35),
                                child: (store.logoFullUrl != null && store.logoFullUrl!.isNotEmpty)
                                    ? CustomImage(image: store.logoFullUrl!, fit: BoxFit.contain)
                                    : Icon(Icons.storefront_rounded, size: 35, color: Theme.of(context).primaryColor),
                              ),
                            ),
                            const SizedBox(height: Dimensions.paddingSizeSmall),
                            Text(
                              store.name ?? '',
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                            ),
                            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'انقر للطلب',
                                    style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeExtraSmall,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Theme.of(context).primaryColor),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ] else ...[
                // Empty State UI
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: Dimensions.paddingSizeLarge),
                  margin: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.storefront_outlined,
                          size: 60,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeLarge),
                      Text(
                        'لا توجد متاجر عالمية متاحة حالياً'.tr,
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      Text(
                        'لم يتم إضافة أي بطاقات متاجر عالمية من قبل الأدمن حتى الآن.\nيرجى التنسيق مع الإدارة أو التحديث لاحقاً.'.tr,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).disabledColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                      SizedBox(
                        width: 180,
                        child: CustomButton(
                          buttonText: 'تحديث الصفحة'.tr,
                          onPressed: () {
                            browseController.getGlobalStores(reload: true);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
