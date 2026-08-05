import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/rating_bar.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/cart/domain/models/cart_model.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/review/domain/models/review_model.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class ReviewImageViewerScreen extends StatefulWidget {
  final ReviewModel review;
  final Item item;
  final int initialIndex;
  const ReviewImageViewerScreen({super.key, required this.review, required this.item, this.initialIndex = 0});

  @override
  State<ReviewImageViewerScreen> createState() => _ReviewImageViewerScreenState();
}

class _ReviewImageViewerScreenState extends State<ReviewImageViewerScreen> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    String reviewImageUrl = Get.find<SplashController>().configModel?.baseUrls?.reviewImageUrl ?? '';

    return Scaffold(
      appBar: CustomAppBar(title: 'review_images'.tr),
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: Stack(children: [
              PhotoViewGallery.builder(
                scrollPhysics: const BouncingScrollPhysics(),
                backgroundDecoration: BoxDecoration(color: Theme.of(context).cardColor),
                itemCount: widget.review.attachment!.length,
                pageController: _pageController,
                builder: (BuildContext context, int index) {
                  return PhotoViewGalleryPageOptions(
                    imageProvider: NetworkImage('$reviewImageUrl/${widget.review.attachment![index]}'),
                    initialScale: PhotoViewComputedScale.contained,
                  );
                },
                loadingBuilder: (context, event) => const CustomLoaderWidget(),
                onPageChanged: (int index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),

              _currentIndex != 0 ? Positioned(
                left: 10, top: 0, bottom: 0,
                child: IconButton(
                  icon: Icon(Icons.chevron_left, size: 40, color: Colors.grey),
                  onPressed: () => _pageController.previousPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut),
                ),
              ) : SizedBox(),

              _currentIndex != (widget.review.attachment!.length - 1) ? Positioned(
                right: 10, top: 0, bottom: 0,
                child: IconButton(
                  icon: Icon(Icons.chevron_right, size: 40, color: Colors.grey),
                  onPressed: () => _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut),
                ),
              ) : SizedBox(),
            ]),
          ),

          Container(
            padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, spreadRadius: 1)],
              borderRadius: BorderRadius.vertical(top: Radius.circular(Dimensions.radiusLarge)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(child: Text(widget.review.customerName ?? '', style: robotoBold, maxLines: 1, overflow: TextOverflow.ellipsis)),
                Text(
                  DateConverter.dateTimeStringToDateTime(widget.review.createdAt!),
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                ),
              ]),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                RatingBar(rating: widget.review.rating?.toDouble(), ratingCount: null, size: 15),
                Text(
                  PriceConverter.convertPrice(widget.item.price, discount: widget.item.discount, discountType: widget.item.discountType),
                  style: robotoBold.copyWith(color: Theme.of(context).primaryColor),
                ),
              ]),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Text(widget.review.comment ?? '', style: robotoRegular, maxLines: 5, overflow: TextOverflow.ellipsis),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              GetBuilder<ItemController>(builder: (itemController) {
                return GetBuilder<CartController>(builder: (cartController) {
                  int cartIndex = cartController.isExistInCart(widget.item.id, '', false, null);
                  bool isAdded = cartIndex != -1;

                  return CustomButton(
                    buttonText: isAdded ? 'already_added'.tr : 'add_to_cart'.tr,
                    onPressed: isAdded ? null : () {
                      double discountedPrice = PriceConverter.convertWithDiscount(widget.item.price, widget.item.discount, widget.item.discountType)!;
                      CartModel cartModel = CartModel(
                        id: null, price: widget.item.price, discountedPrice: discountedPrice, variation: [], foodVariations: [],
                        discountAmount: (widget.item.price! - discountedPrice),
                        quantity: 1, addOnIds: [], addOns: [], isCampaign: widget.item.availableDateStarts != null, stock: widget.item.stock, item: widget.item,
                        quantityLimit: widget.item.quantityLimit,
                      );
                      cartController.addToCart(cartModel, cartIndex);
                      Get.snackbar('success'.tr, 'item_added_to_cart'.tr, backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.TOP);
                    },
                  );
                });
              }),
            ]),
          ),
        ]),
      ),
    );
  }
}
