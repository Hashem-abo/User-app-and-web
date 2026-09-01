import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/custom_text_field.dart';
import 'package:sixam_mart/features/address/controllers/address_controller.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/checkout/domain/models/place_order_body_model.dart';
import 'package:sixam_mart/features/parcel/controllers/parcel_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class GlobalOrderFormScreen extends StatefulWidget {
  final String storeName;
  final String? storeLogo;
  final String? urlPlaceholder;

  const GlobalOrderFormScreen({
    super.key,
    required this.storeName,
    this.storeLogo,
    this.urlPlaceholder,
  });

  @override
  State<GlobalOrderFormScreen> createState() => _GlobalOrderFormScreenState();
}

class _GlobalOrderFormScreenState extends State<GlobalOrderFormScreen> {
  final TextEditingController _cartLinkController = TextEditingController();
  AddressModel? _selectedAddress;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.find<AddressController>().addressList == null) {
        Get.find<AddressController>().getAddressList();
      }
      _selectedAddress = AddressHelper.getUserAddressFromSharedPref();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _cartLinkController.dispose();
    super.dispose();
  }

  Future<void> _submitOrder() async {
    final String cartLink = _cartLinkController.text.trim();
    if (cartLink.isEmpty) {
      showCustomSnackBar('يرجى لصق رابط السلة أولاً'.tr);
      return;
    }
    if (_selectedAddress == null) {
      showCustomSnackBar('please_setup_your_delivery_address_first'.tr);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final bool isLoggedIn = AuthHelper.isLoggedIn();
      final String guestId = AuthHelper.getGuestId();
      final profile = Get.find<ProfileController>().userInfoModel;

      final PlaceOrderBodyModel placeOrderBody = PlaceOrderBodyModel(
        cart: [],
        couponDiscountAmount: 0.0,
        couponCode: '',
        orderAmount: 0.0,
        orderType: 'parcel',
        paymentMethod: 'cash_on_delivery',
        storeId: null,
        distance: 1.0,
        discountAmount: 0.0,
        taxAmount: 0.0,
        orderNote: '$cartLink (المتجر: ${widget.storeName})',
        address: _selectedAddress!.address,
        receiverDetails: _selectedAddress,
        latitude: _selectedAddress!.latitude,
        longitude: _selectedAddress!.longitude,
        contactPersonName: _selectedAddress!.contactPersonName ?? (profile != null ? '${profile.fName} ${profile.lName}' : 'Customer'),
        contactPersonNumber: _selectedAddress!.contactPersonNumber ?? (profile?.phone ?? ''),
        addressType: _selectedAddress!.addressType ?? 'home',
        parcelCategoryId: '1',
        chargePayer: 'sender',
        dmTips: '0',
        unavailableItemNote: '',
        cutlery: 0,
        partialPayment: 0,
        guestId: isLoggedIn ? 0 : int.tryParse(guestId) ?? 0,
        isBuyNow: 1,
        guestEmail: _selectedAddress!.email,
        extraPackagingAmount: 0.0,
        createNewUser: 0,
        password: '',
      );

      final parcelController = Get.find<ParcelController>();
      await parcelController.placeOrder(
        placeOrderBody,
        _selectedAddress!.zoneId,
        0.0,
        0.0,
        false,
        true,
      );

      showCustomSnackBar('تم إرسال طلب التسوق بنجاح، بانتظار إرسال عرض السعر'.tr, isError: false);
      Get.offAllNamed(RouteHelper.getInitialRoute());
    } catch (e) {
      showCustomSnackBar('حدث خطأ أثناء إرسال الطلب، يرجى المحاولة لاحقاً'.tr);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'طلب تسوق - ${widget.storeName}'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Store Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        child: (widget.storeLogo != null && widget.storeLogo!.isNotEmpty)
                            ? CustomImage(image: widget.storeLogo!, fit: BoxFit.cover)
                            : Icon(Icons.shopping_bag_outlined, size: 35, color: Theme.of(context).primaryColor),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeDefault),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.storeName,
                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                          Text(
                            'قم بفتح المتجر، انسخ رابط السلة، وألصقه هنا مباشرة'.tr,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).disabledColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: Dimensions.paddingSizeLarge),

              // Cart Link Input Section
              Text('رابط السلة (Cart Link)', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              CustomTextField(
                hintText: widget.urlPlaceholder ?? 'الصق رابط السلة هنا (e.g. https://shein.com/cart)',
                controller: _cartLinkController,
                inputType: TextInputType.url,
                maxLines: 2,
                prefixIcon: Icons.link_rounded,
              ),

              const SizedBox(height: Dimensions.paddingSizeLarge),

              // Delivery Address Section
              Text('عنوان التوصيل (Delivery Address)', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              GetBuilder<AddressController>(builder: (addressController) {
                return Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      if (_selectedAddress != null)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.location_on, color: Theme.of(context).primaryColor),
                          title: Text(_selectedAddress!.addressType ?? 'home', style: robotoBold),
                          subtitle: Text(
                            _selectedAddress!.address ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          child: Text('لم يتم اختيار عنوان توصيل بعد'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor)),
                        ),
                      const Divider(),
                      InkWell(
                        onTap: () async {
                          final result = await Get.toNamed(RouteHelper.getAddAddressRoute(false, false, 0));
                          if (result != null && result is AddressModel) {
                            setState(() {
                              _selectedAddress = result;
                            });
                          } else {
                            Get.find<AddressController>().getAddressList();
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_location_alt_outlined, color: Theme.of(context).primaryColor, size: 20),
                            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                            Text(
                              'تغيير أو إضافة عنوان جديد'.tr,
                              style: robotoMedium.copyWith(color: Theme.of(context).primaryColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: Dimensions.paddingSizeExtraLarge),

              // Submit Button
              CustomButton(
                buttonText: 'إرسال طلب التسوق العالمي'.tr,
                isLoading: _isLoading,
                onPressed: _submitOrder,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
