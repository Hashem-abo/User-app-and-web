import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/product_question/controllers/product_question_controller.dart';
import 'package:sixam_mart/features/product_question/widgets/product_question_widget.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/no_data_screen.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';

class ProductQuestionScreen extends StatefulWidget {
  final Item item;
  const ProductQuestionScreen({super.key, required this.item});

  @override
  State<ProductQuestionScreen> createState() => _ProductQuestionScreenState();
}

class _ProductQuestionScreenState extends State<ProductQuestionScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<ProductQuestionController>().getProductQuestionList(widget.item.id!, 1, reload: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'product_questions'.tr),
      body: GetBuilder<ProductQuestionController>(builder: (productQuestionController) {
        if (productQuestionController.productQuestionModel == null || productQuestionController.productQuestionModel!.questions == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (productQuestionController.productQuestionModel!.questions!.isEmpty) {
          return Center(child: NoDataScreen(text: 'no_questions_found'.tr));
        }

        return ListView.builder(
          itemCount: productQuestionController.productQuestionModel!.questions!.length,
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            return ProductQuestionWidget(
              question: productQuestionController.productQuestionModel!.questions![index],
              width: null,
              margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
            );
          },
        );
      }),
      bottomNavigationBar: Container(
        height: 90,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeDefault),
        child: Center(child: SizedBox(width: Dimensions.webMaxWidth, child: InkWell(
          onTap: () {
            if(Get.find<AuthController>().isLoggedIn()) {
              Get.toNamed(RouteHelper.getAddQuestionRoute(widget.item));
            } else {
              showCustomSnackBar('you_must_login_to_ask_question'.tr);
            }
          },
          child: Container(
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            child: Text(
              'ask_a_question'.tr,
              style: robotoBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeLarge),
            ),
          ),
        ))),
      ),
    );
  }
}
