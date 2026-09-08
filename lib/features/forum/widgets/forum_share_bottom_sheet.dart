import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/forum/domain/models/forum_post_model.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';

class ForumShareBottomSheet extends StatelessWidget {
  final ForumPost post;
  const ForumShareBottomSheet({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final String shareText = '${post.title ?? ''}\n\n${post.description ?? ''}';

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'share'.tr,
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
              ),
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Preview Card
          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                if (post.imageFullUrl != null && post.imageFullUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    child: CustomImage(
                      image: post.imageFullUrl!,
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    ),
                    child: Icon(Icons.forum, color: Theme.of(context).primaryColor),
                  ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title ?? '',
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        post.description ?? '',
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall,
                          color: Theme.of(context).disabledColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          // Options Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Copy Option
              _ShareOptionWidget(
                icon: Icons.copy_rounded,
                color: Colors.blue,
                title: 'copy'.tr,
                onTap: () {
                  Clipboard.setData(ClipboardData(text: shareText));
                  Get.back();
                  showCustomSnackBar('copied_to_clipboard'.tr, isError: false);
                },
              ),

              // WhatsApp Option
              _ShareOptionWidget(
                icon: Icons.chat_bubble_outline,
                color: Colors.green,
                title: 'WhatsApp',
                onTap: () async {
                  Get.back();
                  final String whatsappUrl = "whatsapp://send?text=${Uri.encodeComponent(shareText)}";
                  try {
                    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
                      await launchUrl(Uri.parse(whatsappUrl));
                    } else {
                      SharePlus.instance.share(ShareParams(text: shareText));
                    }
                  } catch (e) {
                    SharePlus.instance.share(ShareParams(text: shareText));
                  }
                },
              ),

              // More Options (System Share)
              _ShareOptionWidget(
                icon: Icons.more_horiz_rounded,
                color: Theme.of(context).primaryColor,
                title: 'more'.tr,
                onTap: () {
                  Get.back();
                  SharePlus.instance.share(ShareParams(text: shareText));
                },
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
        ],
      ),
    );
  }
}

class _ShareOptionWidget extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final VoidCallback onTap;

  const _ShareOptionWidget({
    required this.icon,
    required this.color,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      child: Column(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Text(
            title,
            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
          ),
        ],
      ),
    );
  }
}
