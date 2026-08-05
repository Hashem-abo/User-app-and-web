
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/common/widgets/no_data_screen.dart';
import 'package:sixam_mart/features/review/controllers/review_controller.dart';
import 'package:sixam_mart/features/review/widgets/user_review_widget.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';
import 'package:sixam_mart/common/widgets/not_logged_in_screen.dart';
import 'package:sixam_mart/features/review/domain/models/review_model.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/util/styles.dart';

class UserReviewScreen extends StatefulWidget {
  const UserReviewScreen({super.key});

  @override
  State<UserReviewScreen> createState() => _UserReviewScreenState();
}

class _UserReviewScreenState extends State<UserReviewScreen> {

  int _tabIndex = 0; // 0: All, 1: Items, 2: Delivery

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
        title: Text('my_reviews'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge!.color)),
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
      endDrawer: const MenuDrawer(), endDrawerEnableOpenDragGesture: false,
      body: isLoggedIn ? GetBuilder<ReviewController>(builder: (reviewController) {
        return reviewController.userReviewList != null ? RefreshIndicator(
          onRefresh: () async {
            await reviewController.getUserReviewList();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: FooterView(
              child: Column(children: [

                // Filter Chips
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                    children: [
                      _buildFilterChip('all'.tr, 0),
                      _buildFilterChip('items'.tr, 1),
                      _buildFilterChip('delivery'.tr, 2),
                      _buildFilterChip('stores'.tr, 3),
                    ],
                  ),
                ),

                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
                  child: Align(
                    alignment: Alignment.topCenter,
                      child: GetBuilder<ReviewController>(builder: (rController) {
                        List<ReviewModel> reviews = [];
                        if(_tabIndex == 0) {
                          reviews = rController.userReviewList!;
                        } else if(_tabIndex == 1) {
                          reviews = rController.userReviewList!.where((review) => (review.item != null || review.itemId != null)).toList();
                        } else if(_tabIndex == 2) {
                          reviews = rController.userReviewList!.where((review) => (review.item == null && review.itemId == null && review.storeName == null)).toList();
                        } else if(_tabIndex == 3) {
                          reviews = rController.userReviewList!.where((review) => (review.item == null && review.itemId == null && review.storeName != null)).toList();
                        }
                        
                        return reviews.isNotEmpty ? ListView.builder(
                          itemCount: reviews.length,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
                          itemBuilder: (context, index) {
                            return UserReviewWidget(review: reviews[index]);
                          },
                        ) : NoDataScreen(text: 'no_review_found'.tr);
                      }),
                  ),
                ),
              ]),
            ),
          ),
        ) : const CustomLoaderWidget();
      }) : NotLoggedInScreen(callBack: (v){
        initData();
        setState(() {});
      }),
    );
  }

  Widget _buildFilterChip(String title, int index) {
    bool isSelected = _tabIndex == index;
    return Padding(
      padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
      child: InkWell(
        onTap: () => setState(() => _tabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
            border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withValues(alpha: 0.2)),
          ),
          child: Text(
            title,
            style: robotoMedium.copyWith(color: isSelected ? Colors.white : Theme.of(context).disabledColor),
          ),
        ),
      ),
    );
  }

  void initData() {
    if(AuthHelper.isLoggedIn()) {
      Get.find<ReviewController>().getUserReviewList();
    }
  }
}
