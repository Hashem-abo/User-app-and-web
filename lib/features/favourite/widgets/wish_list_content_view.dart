import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/favourite/controllers/wish_list_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:intl/intl.dart';
import 'package:sixam_mart/common/widgets/no_data_screen.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/checkout/domain/models/place_order_body_model.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/features/favourite/domain/models/wish_list_model.dart';

class WishListContentView extends StatefulWidget {
  const WishListContentView({super.key});

  @override
  State<WishListContentView> createState() => _WishListContentViewState();
}

class _WishListContentViewState extends State<WishListContentView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _searchText = '';

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WishListController>(builder: (wishListController) {
      return Column(children: [
        SizedBox(
          width: Dimensions.webMaxWidth,
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
                decoration: InputDecoration(
                  hintText: 'search'.tr,
                  hintStyle: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  isDense: true,
                  prefixIcon: Icon(Icons.search, color: Theme.of(context).disabledColor, size: 24),
                  suffixIcon: _searchText.isNotEmpty ? IconButton(
                    icon: Icon(Icons.clear, color: Theme.of(context).disabledColor, size: 24),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchText = '';
                      });
                      FocusScope.of(context).unfocus();
                    },
                  ) : null,
                ),
                onChanged: (String query) {
                  setState(() {
                    _searchText = query;
                  });
                },
              ),
            ),
          ),
        ),

        Expanded(
          child: wishListController.wishLists.isNotEmpty ? ListView.builder(
            itemCount: wishListController.wishLists.length,
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            itemBuilder: (context, index) {
              final wishList = wishListController.wishLists[index];
              if(_searchText.isNotEmpty && !wishList.name!.toLowerCase().contains(_searchText.toLowerCase())) {
                return const SizedBox();
              }
              return Container(
                margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(wishList.name!, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => wishListController.deleteWishList(index),
                    ),
                  ]),
                  Text('${wishList.items?.length ?? 0} ${'items'.tr}', style: robotoRegular.copyWith(color: Theme.of(context).disabledColor)),
                  if(wishList.reminderDate != null)
                    Text('${'reminder'.tr}: ${DateFormat('dd/MM/yyyy').format(wishList.reminderDate!)}', style: robotoRegular.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall)),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  
                  Row(children: [
                    Expanded(child: CustomButton(
                      buttonText: 'view_items'.tr,
                      onPressed: () {
                        _showItemsDialog(context, wishList);
                      },
                      height: 35,
                      radius: Dimensions.radiusSmall,
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                      textColor: Theme.of(context).textTheme.bodyLarge!.color,
                    )),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(child: CustomButton(
                      buttonText: 'add_to_cart'.tr,
                      onPressed: () async {
                        CartController cartController = Get.find<CartController>();
                        for (var cartModel in wishList.items!) {
                          if (AuthHelper.isLoggedIn() || AuthHelper.isGuestLoggedIn()) {
                            OnlineCart onlineCart = OnlineCart(
                              cartId: null, itemId: cartModel.item!.id, itemCampaignId: null, 
                              price: cartModel.price.toString(), variant: '',
                              variation: cartModel.variation, variations: [], quantity: cartModel.quantity, 
                              addOnIds: cartModel.addOnIds?.map((e) => e.id).toList(), 
                              addOns: cartModel.addOns, addOnQtys: cartModel.addOnIds?.map((e) => e.quantity).toList(), model: 'Item',
                            );
                            await cartController.addToCartOnline(onlineCart, cartModel);
                          } else {
                            await cartController.addToCart(cartModel, null);
                          }
                        }
                        showCustomSnackBar('added_to_cart_successfully'.tr, isError: false);
                      },
                      height: 35,
                      radius: Dimensions.radiusSmall,
                      fontSize: Dimensions.fontSizeSmall,
                    )),
                  ]),

                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                ]),
              );
            },
          ) : NoDataScreen(text: 'no_wishlist_found'.tr, showFooter: false),
        ),
      ]);
    });
  }

  void _showItemsDialog(BuildContext context, WishListModel wishList) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(wishList.name!, style: robotoBold),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: wishList.items?.length ?? 0,
            itemBuilder: (context, i) {
              final item = wishList.items![i].item!;
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  child: CustomImage(
                    image: '${item.imageFullUrl}',
                    height: 40, width: 40, fit: BoxFit.cover,
                  ),
                ),
                title: Text(item.name!, style: robotoMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(PriceConverter.convertPrice(item.price), style: robotoRegular.copyWith(color: Theme.of(context).primaryColor)),
                trailing: Text('x${wishList.items![i].quantity}', style: robotoMedium),
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('close'.tr)),
        ],
      ),
    );
  }
}
