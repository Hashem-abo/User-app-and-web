import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/product_question/controllers/product_question_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class AskQuestionDialog extends StatefulWidget {
  final int itemID;
  const AskQuestionDialog({super.key, required this.itemID});

  @override
  State<AskQuestionDialog> createState() => _AskQuestionDialogState();
}

class _AskQuestionDialogState extends State<AskQuestionDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _isAnonymous = false;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<ProfileController>() && Get.find<ProfileController>().userInfoModel != null) {
      _isAnonymous = Get.find<ProfileController>().userInfoModel!.isAnonymous ?? false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          
          Text('ask_a_question'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          
          TextField(
            controller: _controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'type_your_question_here'.tr,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          Row(
            children: [
              SizedBox(
                width: 24, height: 24,
                child: Checkbox(
                  value: _isAnonymous,
                  onChanged: (value) {
                    setState(() {
                      _isAnonymous = value ?? false;
                    });
                  },
                  activeColor: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Text('hide_my_name'.tr, style: robotoRegular),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          GetBuilder<ProductQuestionController>(builder: (productQuestionController) {
            return !productQuestionController.isSubmitLoading ? Row(children: [
              Expanded(child: CustomButton(
                buttonText: 'cancel'.tr,
                transparent: true,
                onPressed: () => Get.back(),
              )),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              
              Expanded(child: CustomButton(
                buttonText: 'submit'.tr,
                onPressed: () {
                  if(_controller.text.isEmpty) {
                    showCustomSnackBar('please_enter_your_question'.tr);
                  } else {
                    productQuestionController.submitProductQuestion(widget.itemID, _controller.text, isAnonymous: _isAnonymous);
                  }
                },
              )),
            ]) : const Center(child: CircularProgressIndicator());
          }),
        ]),
      ),
    );
  }
}
