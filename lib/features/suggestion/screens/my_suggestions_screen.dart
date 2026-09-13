import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:suliman/common/widgets/custom_app_bar.dart';
import 'package:suliman/common/widgets/footer_view.dart';
import 'package:suliman/common/widgets/no_data_screen.dart';
import 'package:suliman/common/widgets/not_logged_in_screen.dart';
import 'package:suliman/common/widgets/paginated_list_view.dart';
import 'package:suliman/features/suggestion/controllers/suggestion_controller.dart';
import 'package:suliman/features/suggestion/domain/models/suggestion_model.dart';
import 'package:suliman/features/suggestion/widgets/suggestion_widget.dart';
import 'package:suliman/helper/auth_helper.dart';
import 'package:suliman/helper/route_helper.dart';
import 'package:suliman/util/dimensions.dart';
import 'package:suliman/util/styles.dart';

class MySuggestionsScreen extends StatefulWidget {
  const MySuggestionsScreen({super.key});

  @override
  State<MySuggestionsScreen> createState() => _MySuggestionsScreenState();
}

class _MySuggestionsScreenState extends State<MySuggestionsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    initData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void initData() {
    if (AuthHelper.isLoggedIn()) {
      Get.find<SuggestionController>().getUserSuggestions(1, reload: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = AuthHelper.isLoggedIn();

    return Scaffold(
      appBar: CustomAppBar(title: 'my_suggestions'.tr),
      floatingActionButton: isLoggedIn
          ? FloatingActionButton.extended(
              onPressed: () => Get.toNamed(RouteHelper.getAddSuggestionRoute()),
              backgroundColor: Theme.of(context).primaryColor,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text('add_suggestion'.tr, style: robotoBold.copyWith(color: Colors.white)),
            )
          : null,
      body: isLoggedIn
          ? GetBuilder<SuggestionController>(builder: (suggestionController) {
              return suggestionController.suggestionModel != null
                  ? suggestionController.suggestionModel!.suggestions != null
                      ? SingleChildScrollView(
                          controller: _scrollController,
                          child: FooterView(
                            child: Padding(
                              padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height * 0.7),
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: SizedBox(
                                    width: Dimensions.webMaxWidth,
                                    child: GetBuilder<SuggestionController>(builder: (sController) {
                                      List<CustomerSuggestion> suggestions = sController.suggestionModel?.suggestions ?? [];

                                      return suggestions.isNotEmpty
                                          ? PaginatedListView(
                                              scrollController: _scrollController,
                                              totalSize: sController.suggestionModel!.totalSize,
                                              offset: sController.suggestionModel!.offset,
                                              onPaginate: (int? offset) async =>
                                                  await sController.getUserSuggestions(offset!, reload: false),
                                              itemView: ListView.builder(
                                                itemCount: suggestions.length,
                                                physics: const NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                itemBuilder: (context, index) {
                                                  return SuggestionWidget(
                                                    suggestion: suggestions[index],
                                                    controller: sController,
                                                  );
                                                },
                                              ),
                                            )
                                          : NoDataScreen(text: 'no_suggestions_found'.tr);
                                    }),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      : NoDataScreen(text: 'no_suggestions_found'.tr)
                  : const Center(child: CircularProgressIndicator());
            })
          : NotLoggedInScreen(callBack: (v) {
              initData();
              setState(() {});
            }),
    );
  }
}
