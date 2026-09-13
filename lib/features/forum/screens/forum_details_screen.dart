import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:suliman/common/widgets/custom_app_bar.dart';
import 'package:suliman/common/widgets/custom_image.dart';
import 'package:suliman/common/widgets/footer_view.dart';
import 'package:suliman/common/widgets/menu_drawer.dart';
import 'package:suliman/common/widgets/no_data_screen.dart';
import 'package:suliman/features/forum/controllers/forum_controller.dart';
import 'package:suliman/helper/date_converter.dart';
import 'package:suliman/util/dimensions.dart';
import 'package:suliman/util/styles.dart';

import 'package:suliman/features/contact_share/screens/contact_share_sheet.dart';
import 'package:suliman/features/forum/domain/models/forum_post_model.dart';

class ForumDetailsScreen extends StatefulWidget {
  final int? postId;
  final ForumPost? post;
  const ForumDetailsScreen({super.key, this.postId, this.post});

  @override
  State<ForumDetailsScreen> createState() => _ForumDetailsScreenState();
}

class _ForumDetailsScreenState extends State<ForumDetailsScreen> {
  @override
  void initState() {
    super.initState();
    final controller = Get.find<ForumController>();
    if (widget.post != null) {
      controller.setSelectedPost(widget.post!, notify: false);
    }
    int? id = widget.postId ?? widget.post?.id;
    if (id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.getForumPostDetails(id, showLoading: widget.post == null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'forum_post_details'.tr),
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      body: GetBuilder<ForumController>(
        builder: (forumController) {
          if (forumController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (forumController.selectedPost == null) {
            return NoDataScreen(text: 'no_forum_posts_found'.tr);
          }

          final post = forumController.selectedPost!;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
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
                        // Cover Image if exists
                        if (post.imageFullUrl != null && post.imageFullUrl!.isNotEmpty) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            child: CustomImage(
                              image: post.imageFullUrl!,
                              width: double.infinity,
                              height: 220,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeDefault),
                        ],

                        // Header Metadata
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              ),
                              child: Text(
                                post.category?.tr ?? 'general'.tr,
                                style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Icon(Icons.visibility_outlined, size: 18, color: Theme.of(context).disabledColor),
                                const SizedBox(width: 4),
                                Text(
                                  '${post.views ?? 0}',
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: Theme.of(context).disabledColor,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                if (post.createdAt != null)
                                  Text(
                                    DateConverter.isoStringToLocalDateOnly(post.createdAt!),
                                    style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: Theme.of(context).disabledColor,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: Dimensions.paddingSizeDefault),

                        // Title
                        Text(
                          post.title ?? '',
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeExtraLarge,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeDefault),

                        const Divider(),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        // Post Content / Description
                        Text(
                          post.description ?? '',
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            height: 1.6,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                        // Share Button
                        Center(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (con) => ContactShareSheet(
                                  shareableType: 'forum',
                                  shareableId: post.id!,
                                  shareableName: post.title ?? '',
                                  shareUrl: '${post.title}\n\n${post.description}',
                                ),
                              );
                            },
                            icon: Icon(Icons.share, color: Theme.of(context).primaryColor),
                            label: Text(
                              'share'.tr,
                              style: robotoMedium.copyWith(color: Theme.of(context).primaryColor),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              side: BorderSide(color: Theme.of(context).primaryColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                              ),
                            ),
                          ),
                        ),
                      ],
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
