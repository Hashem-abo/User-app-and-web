import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/features/checkout/screens/checkout_screen.dart';
import 'package:sixam_mart/features/checkout/controllers/checkout_controller.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';

class PrescriptionStoreBottomSheetWidget extends StatefulWidget {
  const PrescriptionStoreBottomSheetWidget({super.key});

  @override
  State<PrescriptionStoreBottomSheetWidget> createState() => _PrescriptionStoreBottomSheetWidgetState();
}

class _PrescriptionStoreBottomSheetWidgetState extends State<PrescriptionStoreBottomSheetWidget> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';

  String _getVal(String key, String enVal, String arVal) {
    return key.tr;
  }

  @override
  void initState() {
    super.initState();
    
    // Fetch store list if it hasn't been loaded yet
    final storeController = Get.find<StoreController>();
    if (storeController.storeModel == null) {
      storeController.getStoreList(1, false);
    }

    // Scroll listener for pagination/infinite scroll
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent &&
          storeController.storeModel != null &&
          !storeController.isLoading) {
        int? totalSize = storeController.storeModel!.totalSize;
        int? offset = storeController.storeModel!.offset;
        if (storeController.storeModel!.stores!.length < totalSize!) {
          storeController.getStoreList(offset! + 1, false);
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimensions.radiusExtraLarge),
          topRight: Radius.circular(Dimensions.radiusExtraLarge),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeLarge,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle indicator
          Center(
            child: Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          // Sheet Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _getVal('select_pharmacy_to_order', 'Select Pharmacy to upload prescription', 'اختر صيدلية لإرسال الوصفة الطبية'),
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Search Field
          Container(
            height: 45,
            decoration: BoxDecoration(
              color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              decoration: InputDecoration(
                hintText: _getVal('search_pharmacy', 'Search pharmacy...', 'البحث عن صيدلية...'),
                hintStyle: robotoRegular.copyWith(
                  color: Theme.of(context).hintColor,
                  fontSize: Dimensions.fontSizeDefault,
                ),
                prefixIcon: Icon(Icons.search, color: Theme.of(context).hintColor),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Theme.of(context).hintColor),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Pharmacy List
          Flexible(
            child: GetBuilder<StoreController>(
              builder: (storeController) {
                if (storeController.storeModel == null) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                // Debug print stores and their prescription status
                if (storeController.storeModel != null && storeController.storeModel!.stores != null) {
                  debugPrint("STORE_DEBUG: Total stores loaded: ${storeController.storeModel!.stores!.length}");
                  for (var store in storeController.storeModel!.stores!) {
                    debugPrint("STORE_DEBUG: name='${store.name}', id=${store.id}, prescriptionOrder=${store.prescriptionOrder} (type: ${store.prescriptionOrder.runtimeType})");
                  }
                }

                // Filter stores that support prescription order
                List<Store> prescriptionStores = storeController.storeModel?.stores
                        ?.where((store) => store.prescriptionOrder == true)
                        .toList() ?? [];

                // Filter by search query if any
                if (_searchQuery.isNotEmpty) {
                  prescriptionStores = prescriptionStores
                      .where((store) =>
                          store.name!.toLowerCase().contains(_searchQuery.toLowerCase()))
                      .toList();
                }

                if (prescriptionStores.isEmpty) {
                  return SizedBox(
                    height: 150,
                    child: Center(
                      child: Text(
                        _getVal('no_prescription_pharmacy_found', 'No pharmacies found supporting prescription orders', 'لم يتم العثور على صيدلية تدعم طلبات الوصفة الطبية'),
                        style: robotoMedium.copyWith(color: Theme.of(context).hintColor),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  shrinkWrap: true,
                  itemCount: prescriptionStores.length + (storeController.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == prescriptionStores.length) {
                      return const Padding(
                        padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    Store store = prescriptionStores[index];

                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Theme.of(context).disabledColor.withValues(alpha: 0.15),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                      child: InkWell(
                        onTap: () {
                          // Close bottom sheet
                          Navigator.pop(context);
                          
                          // Navigate to checkout
                          Get.find<CheckoutController>().updateFirstTime();
                          Get.find<CheckoutController>().updateFirstTimeCodActive();
                          Get.toNamed(
                            RouteHelper.getCheckoutRoute('prescription', storeId: store.id),
                            arguments: CheckoutScreen(fromCart: false, cartList: null, storeId: store.id),
                          );
                        },
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        child: Padding(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          child: Row(
                            children: [
                              // Store Logo
                              ClipRRect(
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                child: CustomImage(
                                  image: store.logoFullUrl ?? '',
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: Dimensions.paddingSizeSmall),

                              // Store Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      store.name ?? '',
                                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      store.address ?? '',
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeExtraSmall,
                                        color: Theme.of(context).disabledColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        // Rating
                                        Icon(Icons.star, color: Theme.of(context).primaryColor, size: 14),
                                        const SizedBox(width: 2),
                                        Text(
                                          store.avgRating?.toStringAsFixed(1) ?? '0.0',
                                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall),
                                        ),
                                        const SizedBox(width: Dimensions.paddingSizeSmall),
                                        
                                        // Distance
                                        if (store.distance != null) ...[
                                          Icon(Icons.location_on, color: Theme.of(context).disabledColor, size: 14),
                                          const SizedBox(width: 2),
                                          Text(
                                            '${store.distance!.toStringAsFixed(1)} km',
                                            style: robotoRegular.copyWith(
                                              fontSize: Dimensions.fontSizeExtraSmall,
                                              color: Theme.of(context).disabledColor,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Action Arrow
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Theme.of(context).primaryColor,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
