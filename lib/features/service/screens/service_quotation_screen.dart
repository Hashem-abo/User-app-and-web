import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart/features/service/controllers/service_controller.dart';
import 'package:sixam_mart/features/service/domain/models/service_model.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_text_field.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';

class ServiceQuotationScreen extends StatefulWidget {
  final int serviceId;
  const ServiceQuotationScreen({super.key, required this.serviceId});

  @override
  State<ServiceQuotationScreen> createState() => _ServiceQuotationScreenState();
}

class _ServiceQuotationScreenState extends State<ServiceQuotationScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final List<XFile> _pickedImages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'quotation'.tr),
      body: GetBuilder<ServiceController>(builder: (serviceController) {
        Service? service = serviceController.serviceDetails;
        if (service == null) return const CustomLoaderWidget();

        return Column(children: [
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              
              Text(service.name ?? '', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Text('quotation_description_hint'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor)),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              CustomTextField(
                titleText: 'describe_your_request'.tr,
                controller: _descriptionController,
                maxLines: 5,
                inputType: TextInputType.multiline,
                inputAction: TextInputAction.done,
                showTitle: true,
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Text('upload_images_optional'.tr, style: robotoMedium),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _pickedImages.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _pickedImages.length) {
                      return InkWell(
                        onTap: () async {
                          XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);
                          if (image != null) setState(() => _pickedImages.add(image));
                        },
                        child: Container(
                          width: 100, height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.5)),
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          ),
                          child: const Icon(Icons.add_a_photo, size: 30),
                        ),
                      );
                    }
                    return Stack(clipBehavior: Clip.none, children: [
                      Container(
                        width: 100, height: 100,
                        margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          image: DecorationImage(image: FileImage(File(_pickedImages[index].path)), fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        top: -5, right: 0,
                        child: InkWell(
                          onTap: () => setState(() => _pickedImages.removeAt(index)),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            child: const Icon(Icons.close, color: Colors.white, size: 15),
                          ),
                        ),
                      ),
                    ]);
                  },
                ),
              ),

            ]),
          )),

          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, -1))],
            ),
            child: CustomButton(
              buttonText: 'send_request'.tr,
              isLoading: serviceController.isLoading,
              onPressed: () {
                if (_descriptionController.text.trim().isEmpty) {
                  showCustomSnackBar('please_enter_description'.tr);
                  return;
                }

                serviceController.placeQuotation(
                  serviceId: service.id!,
                  providerId: service.providerId!,
                  description: _descriptionController.text.trim(),
                  images: _pickedImages,
                ).then((status) {
                  if (status.isSuccess) {
                    Get.back();
                    showCustomSnackBar('quotation_sent_successfully'.tr, isError: false);
                  } else {
                    showCustomSnackBar(status.message);
                  }
                });
              },
            ),
          ),
        ]);
      }),
    );
  }
}
