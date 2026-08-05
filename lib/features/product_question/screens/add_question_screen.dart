import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/product_question/controllers/product_question_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class AddQuestionScreen extends StatefulWidget {
  final Item item;
  const AddQuestionScreen({super.key, required this.item});

  @override
  State<AddQuestionScreen> createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
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
    return Scaffold(
      appBar: CustomAppBar(title: 'ask_a_question'.tr),
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: FooterView(
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: Dimensions.webMaxWidth,
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  
                  Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
                    ),
                    child: Row(children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        child: CustomImage(
                          image: '${widget.item.imageFullUrl}',
                          height: 70, width: 70, fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(
                          widget.item.name ?? '',
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                          maxLines: 2, overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                        Text(
                          widget.item.storeName ?? '',
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                        ),
                      ])),
                    ]),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
          
                  //Text('your_question'.tr, style: robotoMedium),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  
                  TextField(
                    controller: _controller,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'type_your_question_here'.tr,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                      errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.error), borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor), borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                    ),
                  ),
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
                    return !productQuestionController.isSubmitLoading ? CustomButton(
                      buttonText: 'submit'.tr,
                      onPressed: () {
                        if(_controller.text.isEmpty) {
                          showCustomSnackBar('please_enter_your_question'.tr);
                        } else {
                          productQuestionController.submitProductQuestion(widget.item.id!, _controller.text, isAnonymous: _isAnonymous);
                        }
                      },
                    ) : const Center(child: CircularProgressIndicator());
                  }),
          
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
