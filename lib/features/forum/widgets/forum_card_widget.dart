import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/forum/domain/models/forum_post_model.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';

class ForumCardWidget extends StatelessWidget {
  final ForumPost post;
  const ForumCardWidget({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: InkWell(
        onTap: () {
          Get.toNamed(RouteHelper.getForumDetailsRoute(post.id!), arguments: post);
        },
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.imageFullUrl != null && post.imageFullUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusDefault)),
                child: CustomImage(
                  image: post.imageFullUrl!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        ),
                        child: Text(
                          post.category?.tr ?? 'general'.tr,
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),

                      Row(
                        children: [
                          Icon(Icons.visibility_outlined, size: 16, color: Theme.of(context).disabledColor),
                          const SizedBox(width: 4),
                          Text(
                            '${post.views ?? 0}',
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeExtraSmall,
                              color: Theme.of(context).disabledColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (post.createdAt != null)
                            Text(
                              DateConverter.isoStringToLocalDateOnly(post.createdAt!),
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeExtraSmall,
                                color: Theme.of(context).disabledColor,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Text(
                    post.title ?? '',
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  if (post.description != null && post.description!.isNotEmpty)
                    Text(
                      post.description!,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
