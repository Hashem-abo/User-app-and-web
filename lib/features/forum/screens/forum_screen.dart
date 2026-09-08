import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/common/widgets/no_data_screen.dart';
import 'package:sixam_mart/features/forum/controllers/forum_controller.dart';
import 'package:sixam_mart/features/forum/widgets/forum_card_widget.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Get.find<ForumController>().getForumPosts(offset: 1, reload: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'forum'.tr),
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      body: GetBuilder<ForumController>(
        builder: (forumController) {
          return RefreshIndicator(
            onRefresh: () async {
              await forumController.getForumPosts(offset: 1, reload: true);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: FooterView(
                minHeight: 0,
                child: Center(
                  child: SizedBox(
                    width: Dimensions.webMaxWidth,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault,
                        vertical: Dimensions.paddingSizeSmall,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        // Search bar
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              hintText: 'search_in_forum'.tr,
                              hintStyle: robotoRegular.copyWith(
                                color: Theme.of(context).hintColor,
                                fontSize: Dimensions.fontSizeSmall,
                              ),
                              prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 20),
                                      onPressed: () {
                                        _searchController.clear();
                                        forumController.setSearchQuery('');
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                            onSubmitted: (value) {
                              forumController.setSearchQuery(value.trim());
                            },
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeDefault),

                        // Categories Horizontal List
                        SizedBox(
                          height: 38,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: forumController.categories.length,
                            itemBuilder: (context, index) {
                              String category = forumController.categories[index];
                              bool isSelected = forumController.selectedCategory == category;
                              return Padding(
                                padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                                child: InkWell(
                                  onTap: () {
                                    forumController.setCategory(category);
                                  },
                                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                                      border: Border.all(
                                        color: isSelected
                                            ? Theme.of(context).primaryColor
                                            : Theme.of(context).disabledColor.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Text(
                                      category.tr,
                                      style: robotoMedium.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: isSelected
                                            ? Theme.of(context).cardColor
                                            : Theme.of(context).textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeDefault),

                        // Post List
                        if (forumController.isLoading && forumController.postList == null)
                          const Center(child: Padding(
                            padding: EdgeInsets.all(50.0),
                            child: CircularProgressIndicator(),
                          ))
                        else if (forumController.postList != null && forumController.postList!.isNotEmpty)
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: forumController.postList!.length,
                            itemBuilder: (context, index) {
                              return ForumCardWidget(post: forumController.postList![index]);
                            },
                          )
                        else
                          NoDataScreen(text: 'no_forum_posts_found'.tr),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
  }
}
