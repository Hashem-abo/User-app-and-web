import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class CartCountView extends StatelessWidget {
  final Item item;
  final Widget? child;
  final int? index;
  final bool isCampaign;
  const CartCountView({super.key, required this.item, this.child, this.index = -1, this.isCampaign = false});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(builder: (cartController) {
      int cartQty = cartController.cartQuantity(item.id!);
      int cartIndex = cartController.isExistInCart(item.id, cartController.cartVariant(item.id!), false, null);
      if (cartIndex == -1 && cartQty != 0) {
        cartIndex = cartController.cartList.indexWhere((c) => c.item?.id == item.id);
      }
      bool isValidCartIndex = cartIndex >= 0 && cartIndex < cartController.cartList.length;

      return (cartQty != 0 && isValidCartIndex) ? Center(
        child: Container(
          width: 100,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            InkWell(
              onTap: () {
                int liveIndex = cartController.isExistInCart(item.id, cartController.cartVariant(item.id!), false, null);
                if (liveIndex == -1) {
                  liveIndex = cartController.cartList.indexWhere((c) => c.item?.id == item.id);
                }
                if (liveIndex < 0 || liveIndex >= cartController.cartList.length) return;
                var targetCartItem = cartController.cartList[liveIndex];
                int currentQty = targetCartItem.quantity ?? 1;
                cartController.setDirectlyAddToCartIndex(index);
                if (currentQty > 1) {
                  cartController.setQuantity(
                    false, liveIndex,
                    targetCartItem.stock,
                    targetCartItem.item?.quantityLimit ?? targetCartItem.quantityLimit,
                    cartId: targetCartItem.id,
                    cartModel: targetCartItem,
                  );
                } else {
                  cartController.removeFromCart(
                    liveIndex,
                    item: targetCartItem.item,
                    cartId: targetCartItem.id,
                    cartModel: targetCartItem,
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  shape: BoxShape.circle,
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
                ),
                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                child: const Icon(
                  Icons.remove, size: 16,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
              child: Text(
                cartQty.toString(),
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
              ),
            ),

            InkWell(
              onTap: () {
                int liveIndex = cartController.isExistInCart(item.id, cartController.cartVariant(item.id!), false, null);
                if (liveIndex == -1) {
                  liveIndex = cartController.cartList.indexWhere((c) => c.item?.id == item.id);
                }
                if (liveIndex < 0 || liveIndex >= cartController.cartList.length) return;
                var targetCartItem = cartController.cartList[liveIndex];
                int currentQty = targetCartItem.quantity ?? 1;
                int? limit = item.quantityLimit ?? targetCartItem.quantityLimit ?? targetCartItem.item?.quantityLimit;
                if (limit != null && limit != 0 && currentQty >= limit) {
                  showCustomSnackBar('${'maximum_quantity_limit'.tr} $limit');
                } else {
                  cartController.setDirectlyAddToCartIndex(index);
                  cartController.setQuantity(
                    true, liveIndex,
                    targetCartItem.stock,
                    limit,
                    cartId: targetCartItem.id,
                    cartModel: targetCartItem,
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).disabledColor,
                  shape: BoxShape.circle,
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
                  border: Border.all(color: Theme.of(context).cardColor),
                ),
                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                child: Icon(
                  Icons.add, size: 16, color: Theme.of(context).cardColor,
                ),
              ),
            ),
          ]),
        ),
      ) : GetBuilder<ItemController>(builder: (itemController) {
        bool isAdding = cartController.isItemAdding(item.id) || itemController.isDirectAdding(item.id);
        return InkWell(
          onTap: isAdding ? null : () {
            itemController.itemDirectlyAddToCart(item, context, isCampaign: isCampaign);
          },
          child: child ?? Container(
            height: 25, width: 25,
            decoration: BoxDecoration(
              shape: BoxShape.circle, color: Theme.of(context).cardColor,
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
            ),
            child: isAdding
                ? const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : Icon(Icons.add, size: 20, color: Theme.of(context).primaryColor),
          ),
        );
      });
    });
  }
}
