import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/contact_share/controllers/contact_share_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';

class ContactShareSheet extends StatefulWidget {
  final String shareableType; // 'item' or 'store'
  final int shareableId;
  final String shareableName;
  final String shareUrl;

  const ContactShareSheet({
    super.key,
    required this.shareableType,
    required this.shareableId,
    required this.shareableName,
    required this.shareUrl,
  });

  @override
  State<ContactShareSheet> createState() => _ContactShareSheetState();
}

class _ContactShareSheetState extends State<ContactShareSheet> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Get.find<ContactShareController>().initSharing();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeLarge,
        vertical: Dimensions.paddingSizeDefault,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimensions.radiusExtraLarge),
          topRight: Radius.circular(Dimensions.radiusExtraLarge),
        ),
      ),
      child: GetBuilder<ContactShareController>(
        builder: (controller) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Gray pull line
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              // Title
              Text(
                widget.shareableType == 'item' ? 'share_product'.tr : 'share_store'.tr,
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              // Subtitle
              Text(
                'send_to_friends_inside_or_outside_app'.tr,
                style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              // Search Bar & Invite button row
              Row(
                children: [
                  // Invite + Button
                  InkWell(
                    onTap: () => controller.shareExternally(widget.shareUrl),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                      child: Icon(Icons.add, color: Theme.of(context).primaryColor, size: 25),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  // Search Bar
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => controller.searchContacts(val),
                        decoration: InputDecoration(
                          hintText: 'search_for_user'.tr,
                          hintStyle: robotoRegular.copyWith(color: Theme.of(context).hintColor),
                          prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              // Loader or Matched Contacts Grid
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 180),
                child: controller.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : controller.filteredMatchedUsers.isEmpty
                        ? Center(
                            child: Text(
                              'no_friends_found'.tr,
                              style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                            ),
                          )
                        : GridView.builder(
                            shrinkWrap: true,
                            itemCount: controller.filteredMatchedUsers.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 0.8,
                            ),
                            itemBuilder: (context, index) {
                              var user = controller.filteredMatchedUsers[index];
                              return InkWell(
                                onTap: () {
                                  controller.shareToUser(
                                    recipientId: user['id'],
                                    shareableType: widget.shareableType,
                                    shareableId: widget.shareableId,
                                  );
                                  Get.back();
                                },
                                child: Column(
                                  children: [
                                    ClipOval(
                                      child: CustomImage(
                                        image: user['image'] ?? '',
                                        height: 50,
                                        width: 50,
                                        fit: BoxFit.cover,
                                        placeholder: 'assets/image/placeholder.png',
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      user['name'] ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
              const Divider(),

              // Quick External Sharing & Copy Link Actions Row
              Padding(
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                key: const Key('external_shares'),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Copy Link Action
                    _buildShareAction(
                      icon: Icons.copy_all_outlined,
                      label: 'copy_link'.tr,
                      onTap: () => controller.copyLinkToClipboard(widget.shareUrl),
                    ),

                    // Native System Share Sheet
                    _buildShareAction(
                      icon: Icons.share_outlined,
                      label: 'share_via'.tr,
                      onTap: () => controller.shareExternally(widget.shareUrl),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildShareAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
          ),
        ],
      ),
    );
  }
}
