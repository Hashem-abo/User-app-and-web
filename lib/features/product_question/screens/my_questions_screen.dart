import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/no_data_screen.dart';
import 'package:sixam_mart/common/widgets/paginated_list_view.dart';
import 'package:sixam_mart/features/product_question/controllers/product_question_controller.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

import 'package:sixam_mart/common/widgets/not_logged_in_screen.dart';
import 'package:sixam_mart/helper/auth_helper.dart';

class MyQuestionsScreen extends StatefulWidget {
  const MyQuestionsScreen({super.key});

  @override
  State<MyQuestionsScreen> createState() => _MyQuestionsScreenState();
}

class _MyQuestionsScreenState extends State<MyQuestionsScreen> {
  final ScrollController _scrollController = ScrollController();

  int _tabIndex = 0; // 0: Replied, 1: Pending

  @override
  void initState() {
    super.initState();
    initData();
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = AuthHelper.isLoggedIn();
    return Scaffold(
      appBar: AppBar(
        title: Text('my_questions'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge!.color)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.tune, color: Theme.of(context).textTheme.bodyLarge!.color),
          onPressed: () {}, // Filter logic if needed
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_forward, color: Theme.of(context).textTheme.bodyLarge!.color),
            onPressed: () => Get.back(),
          ),
        ],
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
      ),
      body: isLoggedIn ? GetBuilder<ProductQuestionController>(builder: (productQuestionController) {
        return productQuestionController.myQuestionsModel != null ? productQuestionController.myQuestionsModel!.questions!.isNotEmpty ? SingleChildScrollView(
          controller: _scrollController,
          child: FooterView(
            child: Column(children: [ 
              
              // Custom Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
                child: Row(children: [
                  Expanded(child: InkWell(
                    onTap: () => setState(() => _tabIndex = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _tabIndex == 0 ? Theme.of(context).primaryColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        border: _tabIndex == 0 ? null : Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.2)),
                      ),
                      child: Text('replied'.tr, style: robotoBold.copyWith(color: _tabIndex == 0 ? Colors.white : Theme.of(context).disabledColor)),
                    ),
                  )),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  Expanded(child: InkWell(
                    onTap: () => setState(() => _tabIndex = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _tabIndex == 1 ? Theme.of(context).primaryColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        border: _tabIndex == 1 ? null : Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.2)),
                      ),
                      child: Text('pending'.tr, style: robotoBold.copyWith(color: _tabIndex == 1 ? Colors.white : Theme.of(context).disabledColor)),
                    ),
                  )),
                ]),
              ),

              ConstrainedBox(
                constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: Dimensions.webMaxWidth,
                    child: GetBuilder<ProductQuestionController>(builder: (pController) {
                      List questions = pController.myQuestionsModel?.questions?.where((q) => _tabIndex == 0 ? q.reply != null : q.reply == null).toList() ?? [];
                      
                      return questions.isNotEmpty ? PaginatedListView(
                        scrollController: _scrollController,
                        totalSize: pController.myQuestionsModel!.totalSize,
                        offset: pController.myQuestionsModel!.offset,
                        onPaginate: (int? offset) async => await pController.getUserQuestions(offset!, reload: false),
                        itemView: ListView.builder(
                          itemCount: questions.length,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            var question = questions[index];
                            return Container(
                              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                              margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.1)),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))],
                              ),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  OutlinedButton(
                                    onPressed: () => Get.toNamed(RouteHelper.getItemDetailsRoute(question.itemId, question.item!.moduleType == 'food')),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: Theme.of(context).primaryColor),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                      minimumSize: const Size(0, 35),
                                    ),
                                    child: Text('view_product'.tr, style: robotoBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeExtraSmall)),
                                  ),

                                  Row(children: [
                                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                      Text(question.item!.name ?? '', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall)),
                                      Text(DateConverter.containTAndZToUTCFormat(question.createdAt!), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor)),
                                    ]),
                                    const SizedBox(width: Dimensions.paddingSizeSmall),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                      child: CustomImage(image: '${question.item!.imageFullUrl}', height: 50, width: 50, fit: BoxFit.cover),
                                    ),
                                  ]),
                                ]),
                                
                                const SizedBox(height: Dimensions.paddingSizeSmall),
                                Text(question.question ?? '', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                                const SizedBox(height: Dimensions.paddingSizeSmall),

                                if(question.reply != null) ...[
                                  const Divider(),
                                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    const SizedBox(width: Dimensions.paddingSizeSmall),
                                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Row(children: [
                                        Icon(Icons.store, size: 16, color: Theme.of(context).primaryColor),
                                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                        Text('${'replied_by'.tr} ${question.item!.storeName ?? ''}', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor)),
                                      ]),
                                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                      Text(question.reply ?? '', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                                    ])),
                                  ]),
                                ],

                                if(question.reply == null) ...[
                                  const Divider(),
                                  const SizedBox(height: Dimensions.paddingSizeSmall),
                                  Row(children: [
                                    Expanded(child: OutlinedButton(
                                      onPressed: () {}, // Escalation logic if available
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: Theme.of(context).primaryColor.withValues(alpha: 0.5)),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                                        minimumSize: const Size(0, 40),
                                      ),
                                      child: Text('escalate_to_customer_service'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall)),
                                    )),
                                    const SizedBox(width: Dimensions.paddingSizeSmall),
                                    Expanded(child: OutlinedButton(
                                      onPressed: () {}, // Delete logic if available
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: Colors.red.withValues(alpha: 0.5)),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                                        minimumSize: const Size(0, 40),
                                      ),
                                      child: Text('delete_question'.tr, style: robotoMedium.copyWith(color: Colors.red, fontSize: Dimensions.fontSizeSmall)),
                                    )),
                                  ]),
                                ],

                                const SizedBox(height: Dimensions.paddingSizeSmall),
                                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                  InkWell(
                                    onTap: () => pController.toggleQuestionLike(question.id!, index),
                                    child: Row(children: [
                                      Icon(
                                        question.isLikedByUser == true ? Icons.thumb_up : Icons.thumb_up_off_alt,
                                        size: 18,
                                        color: question.isLikedByUser == true ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                                      ),
                                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                      Text(
                                        '${question.likeCount ?? 0}',
                                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                                      ),
                                    ]),
                                  ),
                                ]),

                              ]),
                            );
                          },
                        ),
                      ) : NoDataScreen(text: _tabIndex == 0 ? 'no_replied_questions'.tr : 'no_pending_questions'.tr);
                    }),
                  ),
                ),
              ),
              
            ]),
          ),
        ) : NoDataScreen(text: 'no_question_found'.tr) : const Center(child: CircularProgressIndicator());
      }) : NotLoggedInScreen(callBack: (v){
        initData();
        setState(() {});
      }),
    );
  }

  void initData() {
    if(AuthHelper.isLoggedIn()) {
      Get.find<ProductQuestionController>().getUserQuestions(1);
    }
  }
}
