import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/profile/domain/models/size_info_model.dart';
import 'package:sixam_mart/features/profile/screens/edit_size_screen.dart';
import 'package:sixam_mart/features/profile/screens/preference_screen.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class SizeInformationScreen extends StatefulWidget {
  const SizeInformationScreen({super.key});

  @override
  State<SizeInformationScreen> createState() => _SizeInformationScreenState();
}

class _SizeInformationScreenState extends State<SizeInformationScreen> {

  @override
  void initState() {
    super.initState();
    Get.find<ProfileController>().loadSizeAndPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'my_profile'.tr,
          style: robotoBold.copyWith(fontSize: 18, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: GetBuilder<ProfileController>(builder: (profileController) {
        return SingleChildScrollView(
          child: Column(
            children: [
              // User Avatar/Header Info
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.grey[200],
                      child: const Text('H', style: TextStyle(fontSize: 20, color: Colors.black)),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      profileController.userInfoModel != null 
                        ? '${profileController.userInfoModel!.fName ?? ''} ${profileController.userInfoModel!.lName ?? ''}'
                        : 'hashem2026123',
                      style: robotoBold.copyWith(fontSize: 16),
                    ),
                    const Spacer(),
                    const Icon(Icons.qr_code_scanner, color: Colors.grey),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Size Information Block
              Container(
                color: Colors.white,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            Get.to(() => const EditSizeScreen());
                          },
                          child: Row(
                            children: [
                              const Icon(Icons.add, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text('add_more'.tr, style: robotoRegular.copyWith(color: Colors.grey[600], fontSize: 13)),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.straighten, size: 18, color: Colors.black),
                            const SizedBox(width: 4),
                            Text('size_information'.tr, style: robotoBold.copyWith(fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    profileController.sizeList.isEmpty 
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: Text(
                              'no_size_profiles_yet'.tr,
                              style: robotoRegular.copyWith(color: Colors.grey),
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: profileController.sizeList.length,
                          separatorBuilder: (context, index) => const Divider(height: 16),
                          itemBuilder: (context, index) {
                            final size = profileController.sizeList[index];
                            return Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    Get.to(() => EditSizeScreen(sizeInfo: size));
                                  },
                                  child: const Icon(Icons.edit_outlined, color: Colors.grey, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  size.label,
                                  style: robotoMedium.copyWith(fontSize: 15),
                                ),
                                const Spacer(),
                                PopupMenuButton<String>(
                                  onSelected: (val) {
                                    if (val == 'edit') {
                                      Get.to(() => EditSizeScreen(sizeInfo: size));
                                    } else if (val == 'delete') {
                                      profileController.deleteSizeInfo(size.id);
                                    }
                                  },
                                  itemBuilder: (BuildContext context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Edit'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Delete'),
                                    ),
                                  ],
                                  child: const Icon(Icons.more_horiz, color: Colors.grey),
                                )
                              ],
                            );
                          },
                        ),
                  ],
                ),
              ),

              // My Preference Block
              Container(
                color: Colors.white,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.arrow_back_ios, size: 14, color: Colors.grey),
                        InkWell(
                          onTap: () {
                            Get.to(() => const PreferenceScreen());
                          },
                          child: Row(
                            children: [
                              Text('my_preference'.tr, style: robotoBold.copyWith(fontSize: 14)),
                              const SizedBox(width: 4),
                              const Icon(Icons.favorite_border, size: 18, color: Colors.black),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    profileController.shoppingPreference.isCompleted
                      ? Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.end,
                          children: [
                            ...profileController.shoppingPreference.favoriteCategories,
                            ...profileController.shoppingPreference.targetAudience,
                            ...profileController.shoppingPreference.favoriteStyles,
                          ].map((pref) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                pref.tr,
                                style: robotoRegular.copyWith(fontSize: 12, color: Colors.black87),
                              ),
                            );
                          }).toList(),
                        )
                      : Center(
                          child: TextButton(
                            onPressed: () {
                              Get.to(() => const PreferenceScreen());
                            },
                            child: Text('configure_preferences'.tr),
                          ),
                        ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.verified_user_outlined, color: Colors.green, size: 16),
                  const SizedBox(width: 4),
                  Text('personal_privacy_protection'.tr, style: robotoRegular.copyWith(color: Colors.grey, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }
}
