import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/checkout/widgets/add_address_options_bottom_sheet.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/checkout/controllers/checkout_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_text_field.dart';

class GuestDeliveryAddress extends StatelessWidget {
  final CheckoutController checkoutController;
  final TextEditingController guestNameTextEditingController;
  final TextEditingController guestNumberTextEditingController;
  final TextEditingController guestEmailController;
  final FocusNode guestNumberNode;
  final FocusNode guestEmailNode;
  const GuestDeliveryAddress({super.key, required this.checkoutController, required this.guestNameTextEditingController,
    required this.guestNumberTextEditingController, required this.guestNumberNode, required this.guestEmailController, required this.guestEmailNode,
  });

  @override
  Widget build(BuildContext context) {
    bool takeAway = (checkoutController.orderType == 'take_away');

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
      child: Column(children: [
        Row(children: [
          Image.asset(Images.truck, height: 14, width: 14, color: Theme.of(context).textTheme.bodyLarge!.color),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Text(takeAway ? 'contact_information'.tr : 'delivery_information'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge!.color)),
          const Spacer(),

          takeAway ? const SizedBox() : InkWell(
            onTap: () {
              Get.bottomSheet(
                AddAddressOptionsBottomSheet(checkoutController: checkoutController),
                isScrollControlled: true,
              );
            },
            child: Image.asset(Images.editDelivery, height: 20, width: 20, color: Theme.of(context).primaryColor),
          ),
        ]),

        Padding(
          padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
          child: Divider(color: Theme.of(context).disabledColor),
        ),

        takeAway ? Column(children: [
          const SizedBox(height: Dimensions.paddingSizeLarge),
          CustomTextField(
            labelText: 'contact_person_name'.tr,
            titleText: 'write_name'.tr,
            inputType: TextInputType.name,
            controller: guestNameTextEditingController,
            nextFocus: guestNumberNode,
            capitalization: TextCapitalization.words,
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          CustomTextField(
            labelText: 'contact_person_number'.tr,
            titleText: 'write_number'.tr,
            controller: guestNumberTextEditingController,
            focusNode: guestNumberNode,
            // nextFocus: guestEmailNode,
            inputType: TextInputType.phone,
            isPhone: true,
            onCountryChanged: (CountryCode countryCode) {
              checkoutController.countryDialCode = countryCode.dialCode;
            },
            countryDialCode: checkoutController.countryDialCode ?? Get.find<LocalizationController>().locale.countryCode,
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          // CustomTextField(
          //   titleText: 'enter_email'.tr,
          //   labelText: 'email'.tr,
          //   controller: guestEmailController,
          //   focusNode: guestEmailNode,
          //   inputAction: TextInputAction.done,
          //   inputType: TextInputType.emailAddress,
          //   prefixIcon: Icons.mail,
          // ),
          // const SizedBox(height: Dimensions.paddingSizeLarge),

        ]) : checkoutController.guestAddress == null ? InkWell(
          onTap: () {
            Get.bottomSheet(
              AddAddressOptionsBottomSheet(checkoutController: checkoutController),
              isScrollControlled: true,
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
            child: Column(children: [
              Image.asset(Images.truck, height: 20, width: 20, color: Theme.of(context).primaryColor),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Text('please_update_your_delivery_info'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor)),
            ]),
          ),
        ) : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ),
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Image.asset(Images.guestLocationIcon, height: 15, color: Theme.of(context).primaryColor),
              Text(' ${(checkoutController.guestAddress?.addressType ?? 'others').tr}:', style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              Flexible(child: Text(
                checkoutController.guestAddress?.address ?? '',
                style: robotoRegular, maxLines: 1, overflow: TextOverflow.ellipsis,
              )),
            ]),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          CustomTextField(
            labelText: 'contact_person_number'.tr,
            titleText: 'write_number'.tr,
            controller: guestNumberTextEditingController,
            focusNode: guestNumberNode,
            inputType: TextInputType.phone,
            isPhone: true,
            onCountryChanged: (CountryCode countryCode) {
              checkoutController.countryDialCode = countryCode.dialCode;
            },
            countryDialCode: checkoutController.countryDialCode ?? Get.find<LocalizationController>().locale.countryCode,
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          if (checkoutController.guestAddress?.contactPersonName != null && checkoutController.guestAddress!.contactPersonName!.isNotEmpty)
            addressInfo('name'.tr, checkoutController.guestAddress!.contactPersonName!),
          if (checkoutController.guestAddress?.contactPersonNumber != null && checkoutController.guestAddress!.contactPersonNumber!.isNotEmpty && checkoutController.guestAddress!.contactPersonNumber != '0000000000')
            addressInfo('phone'.tr, checkoutController.guestAddress!.contactPersonNumber!),
          if (checkoutController.guestAddress?.email != null && checkoutController.guestAddress!.email!.isNotEmpty)
            addressInfo('email'.tr, checkoutController.guestAddress!.email!),

          Row(mainAxisSize: MainAxisSize.min, spacing: Dimensions.paddingSizeLarge, children: [
            if(checkoutController.guestAddress?.streetNumber != null && checkoutController.guestAddress!.streetNumber!.isNotEmpty)
              Flexible(child: addressInfo('street'.tr, checkoutController.guestAddress!.streetNumber!)),
            if(checkoutController.guestAddress?.house != null && checkoutController.guestAddress!.house!.isNotEmpty)
              Flexible(child: addressInfo('house'.tr, checkoutController.guestAddress!.house!)),
            if(checkoutController.guestAddress?.floor != null && checkoutController.guestAddress!.floor!.isNotEmpty)
              Flexible(child: addressInfo('floor'.tr, checkoutController.guestAddress!.floor!)),
          ]),

        ]),

      ]),
    );
  }

  Widget addressInfo(String key, String value) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text('$key: ', style: robotoRegular),
        Flexible(child: Text(value, style: robotoRegular, maxLines: 1, overflow: TextOverflow.ellipsis)),
      ]),
    );
  }
}
