import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:sixam_mart/features/chat/domain/enum/chat_role_enum.dart';
import 'package:sixam_mart/features/chat/domain/models/chat_message.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/features/coupon/domain/models/coupon_model.dart' hide Store;
import 'package:sixam_mart/features/order/domain/models/order_model.dart';
import 'package:sixam_mart/features/coupon/controllers/coupon_controller.dart';
import 'package:sixam_mart/features/order/controllers/order_controller.dart';
import 'package:sixam_mart/features/favourite/controllers/favourite_controller.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart/features/chat/domain/models/conversation_model.dart';
import 'package:sixam_mart/features/cart/domain/models/cart_model.dart';
import 'package:sixam_mart/features/checkout/domain/models/place_order_body_model.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/module_helper.dart';
import 'package:sixam_mart/common/widgets/confirmation_dialog.dart';
import 'package:sixam_mart/util/images.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.role == ChatRole.system) {
       return Center(
         child: Padding(
           padding: const EdgeInsets.all(8.0),
           child: Text(
             message.text,
             style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
           ),
         )
       );
    }

    final isUser = message.role == ChatRole.user;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isUser ? const Radius.circular(12) : const Radius.circular(0),
            bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 1,
            )
          ],
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser)
               Padding(
                 padding: const EdgeInsets.only(bottom: 4.0),
                 child: Text("hoopoe_name".tr, style: robotoBold.copyWith(fontSize: 10, color: Theme.of(context).primaryColor)),
               ),

            if (message.image != null)
               Container(
                 margin: const EdgeInsets.only(bottom: 5),
                 height: 150,
                 width: 200,
                 decoration: BoxDecoration(
                   borderRadius: BorderRadius.circular(10),
                   image: DecorationImage(
                     image: kIsWeb ? NetworkImage(message.image!.path) : FileImage(File(message.image!.path)) as ImageProvider,
                     fit: BoxFit.cover,
                   ),
                 ),
               ),
               
            isUser ? 
            SelectableText(
              message.text,
              style: robotoRegular.copyWith(
                color: Colors.white,
                fontSize: Dimensions.fontSizeDefault,
              ),
            )
            : _buildRichTextWithCartButtons(context, message.text),

            if (message.items != null && message.items!.isNotEmpty)
               Container(
                 margin: const EdgeInsets.only(top: 10),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: message.items!.map((item) {
                     final bool hasVariations = (item.variations != null && item.variations!.isNotEmpty) ||
                         (item.foodVariations != null && item.foodVariations!.isNotEmpty);

                     if (!hasVariations) {
                       // Simple card for items without variants
                       return GestureDetector(
                         onTap: () => Get.toNamed(RouteHelper.getItemDetailsRoute(item.id, true)),
                         child: Container(
                           margin: const EdgeInsets.only(bottom: 8),
                           padding: const EdgeInsets.all(8),
                           decoration: BoxDecoration(
                             color: Theme.of(context).cardColor,
                             borderRadius: BorderRadius.circular(10),
                             border: Border.all(color: Theme.of(context).disabledColor.withOpacity(0.2)),
                           ),
                           child: Row(children: [
                             ClipRRect(
                               borderRadius: BorderRadius.circular(8),
                               child: CustomImage(image: item.imageFullUrl ?? '', height: 50, width: 50, fit: BoxFit.cover),
                             ),
                             const SizedBox(width: 10),
                             Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                               Text(item.name ?? '', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall), maxLines: 1, overflow: TextOverflow.ellipsis),
                               const SizedBox(height: 2),
                               Text(PriceConverter.convertPrice(item.price), style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)),
                             ])),
                             GetBuilder<CartController>(builder: (cartCtrl) {
                               final isInCart = cartCtrl.cartList.any((c) => c.item?.id == item.id);
                               return InkWell(
                                 onTap: () { if (!isInCart) Get.find<ItemController>().itemDirectlyAddToCart(item, context); },
                                 child: Container(
                                   padding: const EdgeInsets.all(6),
                                   decoration: BoxDecoration(color: isInCart ? Colors.green : Theme.of(context).primaryColor, shape: BoxShape.circle),
                                   child: Icon(isInCart ? Icons.check : Icons.add_shopping_cart, size: 16, color: Colors.white),
                                 ),
                               );
                             }),
                           ]),
                         ),
                       );
                     }

                     // Expanded card for items with variants
                     return GestureDetector(
                       onTap: () => Get.toNamed(RouteHelper.getItemDetailsRoute(item.id, true)),
                       child: Container(
                         margin: const EdgeInsets.only(bottom: 10),
                         decoration: BoxDecoration(
                           color: Theme.of(context).cardColor,
                           borderRadius: BorderRadius.circular(10),
                           border: Border.all(color: Theme.of(context).disabledColor.withOpacity(0.2)),
                         ),
                         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                           // Header: image + name
                           Padding(
                             padding: const EdgeInsets.all(8),
                             child: Row(children: [
                               ClipRRect(
                                 borderRadius: BorderRadius.circular(8),
                                 child: CustomImage(image: item.imageFullUrl ?? '', height: 45, width: 45, fit: BoxFit.cover),
                               ),
                               const SizedBox(width: 10),
                               Expanded(child: Text(item.name ?? '', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault), maxLines: 2, overflow: TextOverflow.ellipsis)),
                             ]),
                           ),
                           Divider(height: 1, color: Theme.of(context).disabledColor.withOpacity(0.2)),

                           // Regular variations (e.g. Size: S-100, M-120, L-150)
                           if (item.variations != null && item.variations!.isNotEmpty)
                             ...item.variations!.map((v) => _buildVariationRow(context, item, v.type ?? '', v.price ?? item.price!)),

                           // Food variations (e.g. Size → Small 100, Medium 120)
                           if (item.foodVariations != null && item.foodVariations!.isNotEmpty)
                             ...item.foodVariations!.expand((fv) {
                               return (fv.variationValues ?? []).map((vv) {
                                 final label = '${fv.name ?? ''}: ${vv.level ?? ''}';
                                 final price = (item.price ?? 0) + (vv.optionPrice ?? 0);
                                 return _buildVariationRow(context, item, label, price, foodVariation: fv, variationValue: vv);
                               });
                             }),
                         ]),
                       ),
                     );
                   }).toList(),
                 ),
               ),

            if (message.coupons != null && message.coupons!.isNotEmpty)
               Container(
                 margin: const EdgeInsets.only(top: 10),
                 height: 110,
                 child: ListView.builder(
                   scrollDirection: Axis.horizontal,
                   itemCount: message.coupons!.length,
                   itemBuilder: (context, index) {
                     final coupon = message.coupons![index];
                     return Container(
                       width: 220,
                       margin: const EdgeInsets.only(right: 10),
                       padding: const EdgeInsets.all(10),
                       decoration: BoxDecoration(
                         color: Theme.of(context).cardColor,
                         borderRadius: BorderRadius.circular(10),
                         border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
                       ),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           Row(
                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                             children: [
                               Container(
                                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                 decoration: BoxDecoration(
                                   color: Theme.of(context).primaryColor.withOpacity(0.1),
                                   borderRadius: BorderRadius.circular(5),
                                 ),
                                 child: Text(
                                   coupon.code ?? '',
                                   style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                                 ),
                               ),
                               Text(
                                 coupon.discountType == 'percent' ? "${coupon.discount}% ${'off_discount'.tr}" : "${PriceConverter.convertPrice(coupon.discount)} ${'off_discount'.tr}",
                                 style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.green),
                               ),
                             ],
                           ),
                           Text(
                             coupon.title ?? '',
                             style: robotoMedium.copyWith(fontSize: 11),
                             maxLines: 1,
                             overflow: TextOverflow.ellipsis,
                           ),
                           Row(
                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                             children: [
                               Text(
                                 "${'min_purchase'.tr}: ${PriceConverter.convertPrice(coupon.minPurchase)}",
                                 style: robotoRegular.copyWith(fontSize: 10, color: Theme.of(context).disabledColor),
                               ),
                               ElevatedButton(
                                 onPressed: () {
                                   Get.find<CouponController>().applyCoupon(coupon.code!, 100.0, 10.0, null);
                                   showCustomSnackBar("${'coupon_applied_success'.tr} ${coupon.code}! 🎟️", isError: false);
                                 },
                                 style: ElevatedButton.styleFrom(
                                   backgroundColor: Theme.of(context).primaryColor,
                                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                   minimumSize: Size.zero,
                                   tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                 ),
                                 child: Text("apply".tr, style: const TextStyle(fontSize: 10, color: Colors.white)),
                               ),
                             ],
                           ),
                         ],
                       ),
                     );
                   },
                 ),
               ),

            if (message.chatOrders != null && message.chatOrders!.isNotEmpty) ...[
               if (message.chatOrders!.length == 1) ...[
                 Builder(builder: (context) {
                   final order = message.chatOrders!.first;
                   final status = order.orderStatus ?? 'pending';
                   
                   int step = 0;
                   if (status == 'accepted') step = 1;
                   if (status == 'processing' || status == 'confirmed') step = 2;
                   if (status == 'handover' || status == 'picked_up') step = 3;
                   if (status == 'delivered') step = 4;
                   
                   return Container(
                     margin: const EdgeInsets.only(top: 10),
                     padding: const EdgeInsets.all(12),
                     decoration: BoxDecoration(
                       color: Theme.of(context).cardColor,
                       borderRadius: BorderRadius.circular(10),
                       border: Border.all(color: Theme.of(context).disabledColor.withOpacity(0.2)),
                     ),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text("${'order_status'.tr} #${order.id}", style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall)),
                         const SizedBox(height: 15),
                         
                         Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                             _buildStep(context, "step_pending".tr, step >= 0),
                             _buildStepLine(step >= 1),
                             _buildStep(context, "step_accepted".tr, step >= 1),
                             _buildStepLine(step >= 2),
                             _buildStep(context, "step_processing".tr, step >= 2),
                             _buildStepLine(step >= 3),
                             _buildStep(context, "step_delivering".tr, step >= 3),
                             _buildStepLine(step >= 4),
                             _buildStep(context, "step_delivered".tr, step >= 4),
                           ],
                         ),
                         
                         const SizedBox(height: 15),
                         Text(
                           "تاريخ الطلب: ${order.createdAt ?? ''}",
                           style: robotoRegular.copyWith(fontSize: 10, color: Theme.of(context).disabledColor),
                         ),
                         const SizedBox(height: 5),
                         Text(
                           "المجموع الإجمالي: ${PriceConverter.convertPrice(order.orderAmount)}",
                           style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                         ),
                         
                         if (order.deliveryMan != null) ...[
                           const Divider(height: 20),
                           Row(
                             children: [
                               CircleAvatar(
                                 radius: 20,
                                 backgroundImage: NetworkImage(order.deliveryMan!.imageFullUrl ?? ''),
                               ),
                               const SizedBox(width: 10),
                               Expanded(
                                 child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     Text("${order.deliveryMan!.fName} ${order.deliveryMan!.lName}", style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                                     Text("delivery_man_label".tr, style: robotoRegular.copyWith(fontSize: 10, color: Theme.of(context).disabledColor)),
                                   ],
                                 ),
                               ),
                               IconButton(
                                 icon: const Icon(Icons.phone, color: Colors.green),
                                 onPressed: () => Get.toNamed(RouteHelper.getChatRoute(
                                   notificationBody: NotificationBodyModel(
                                     deliverymanId: order.deliveryMan!.id,
                                     orderId: order.id,
                                   ),
                                   user: User(
                                     id: order.deliveryMan!.id,
                                     fName: order.deliveryMan!.fName,
                                     lName: order.deliveryMan!.lName,
                                     imageFullUrl: order.deliveryMan!.imageFullUrl,
                                   ),
                                 )),
                               )
                             ],
                           ),
                         ],
                       ],
                     ),
                   );
                 }),
               ] else ...[
                 Container(
                   margin: const EdgeInsets.only(top: 10),
                   height: 130,
                   child: ListView.builder(
                     scrollDirection: Axis.horizontal,
                     itemCount: message.chatOrders!.length,
                     itemBuilder: (context, index) {
                       final itemOrder = message.chatOrders!.elementAt(index);
                       return Container(
                         width: 200,
                         margin: const EdgeInsets.only(right: 10),
                         padding: const EdgeInsets.all(10),
                         decoration: BoxDecoration(
                           color: Theme.of(context).cardColor,
                           borderRadius: BorderRadius.circular(10),
                           border: Border.all(color: Theme.of(context).disabledColor.withOpacity(0.2)),
                         ),
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                             Row(
                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                               children: [
                                 Text(
                                   "طلب #${itemOrder.id}",
                                   style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall),
                                 ),
                                 Container(
                                   padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                   decoration: BoxDecoration(
                                     color: Colors.green.withOpacity(0.1),
                                     borderRadius: BorderRadius.circular(5),
                                   ),
                                   child: Text(
                                     itemOrder.orderStatus == 'delivered' ? 'مكتمل' : itemOrder.orderStatus ?? '',
                                     style: robotoMedium.copyWith(fontSize: 9, color: Colors.green),
                                   ),
                                 ),
                               ],
                             ),
                             Text(
                               "التاريخ: ${itemOrder.createdAt?.split('T')[0] ?? ''}",
                               style: robotoRegular.copyWith(fontSize: 10, color: Theme.of(context).disabledColor),
                             ),
                             Text(
                               PriceConverter.convertPrice(itemOrder.orderAmount),
                               style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                             ),
                             Align(
                               alignment: Alignment.centerLeft,
                               child: ElevatedButton(
                                 onPressed: () {
                                   Get.find<OrderController>().reorder(itemOrder.id!, order: itemOrder);
                                   showCustomSnackBar("${'readding_order_items_to_cart'.tr} #${itemOrder.id}! 🛒", isError: false);
                                 },
                                 style: ElevatedButton.styleFrom(
                                   backgroundColor: Colors.green,
                                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                   minimumSize: Size.zero,
                                   tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                 ),
                                 child: Text("reorder_btn".tr, style: const TextStyle(fontSize: 10, color: Colors.white)),
                               ),
                             ),
                           ],
                         ),
                       );
                     },
                   ),
                 ),
               ]
            ],

            if (message.showCartButton)
               Padding(
                 padding: const EdgeInsets.only(top: 8.0),
                 child: Align(
                   alignment: Alignment.centerLeft,
                   child: ElevatedButton.icon(
                     onPressed: () => Get.toNamed(RouteHelper.getCartRoute()),
                     icon: const Icon(Icons.shopping_cart, size: 14, color: Colors.white),
                     label: Text("view_cart_btn".tr, style: const TextStyle(fontSize: 12, color: Colors.white)),
                     style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.green,
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                     ),
                   ),
                 ),
               ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context, String label, bool active) {
    return Column(
      children: [
        CircleAvatar(
          radius: 8,
          backgroundColor: active ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withOpacity(0.3),
          child: active ? const Icon(Icons.check, size: 10, color: Colors.white) : const SizedBox(),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: robotoRegular.copyWith(
            fontSize: 9, 
            color: active ? Theme.of(context).primaryColor : Theme.of(context).disabledColor
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool active) {
    return Expanded(
      child: Container(
        height: 2,
        color: active ? Get.context!.theme.primaryColor : Get.context!.theme.disabledColor.withOpacity(0.3),
      ),
    );
  }

  /// Builds a single variation row with label, price, and add-to-cart button.
  Widget _buildVariationRow(BuildContext context, Item item, String label, double price, {FoodVariation? foodVariation, VariationValue? variationValue}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  PriceConverter.convertPrice(price),
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                ),
              ],
            ),
          ),
          GetBuilder<CartController>(builder: (cartCtrl) {
            // Check if this specific variation is already in cart
            final isInCart = cartCtrl.cartList.any((c) {
              if (c.item?.id != item.id) return false;
              // For regular variations, match by type
              if (foodVariation == null && c.variation != null && c.variation!.isNotEmpty) {
                return c.variation!.any((v) => v.type == label);
              }
              // For food variations, match by variation name + value label
              if (foodVariation != null && variationValue != null && c.foodVariations != null) {
                // Check if the food variation indices match
                final fvIndex = item.foodVariations?.indexOf(foodVariation) ?? -1;
                final vvIndex = foodVariation.variationValues?.indexOf(variationValue) ?? -1;
                if (fvIndex >= 0 && vvIndex >= 0 && fvIndex < c.foodVariations!.length && vvIndex < c.foodVariations![fvIndex].length) {
                  return c.foodVariations![fvIndex][vvIndex] == true;
                }
              }
              return false;
            });
            return InkWell(
              onTap: () {
                if (isInCart) return;
                _addVariationToCart(context, item, label, price, foodVariation: foodVariation, variationValue: variationValue);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isInCart ? Colors.green : Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(isInCart ? Icons.check : Icons.add_shopping_cart, size: 12, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    isInCart ? 'in_cart'.tr : 'add'.tr,
                    style: robotoRegular.copyWith(fontSize: 10, color: Colors.white),
                  ),
                ]),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Adds a specific variation directly to the cart.
  void _addVariationToCart(BuildContext context, Item item, String label, double price, {FoodVariation? foodVariation, VariationValue? variationValue}) {
    final cartController = Get.find<CartController>();
    final splashController = Get.find<SplashController>();

    double discount = item.discount ?? 0;
    double discountPrice = PriceConverter.convertWithDiscount(price, discount, item.discountType) ?? price;

    // Check stock
    if (splashController.configModel!.moduleConfig!.module!.stock! && (item.stock ?? 0) <= 0) {
      showCustomSnackBar('out_of_stock'.tr);
      return;
    }

    List<Variation> variations = [];
    List<List<bool?>> foodVariationsSelection = [];
    List<OrderVariation> orderVariations = [];

    if (foodVariation != null && variationValue != null) {
      // Food variation: build the selection arrays
      if (item.foodVariations != null) {
        for (int i = 0; i < item.foodVariations!.length; i++) {
          List<bool?> selections = [];
          for (int j = 0; j < (item.foodVariations![i].variationValues?.length ?? 0); j++) {
            // Select only the matching variation value in the matching variation group
            if (item.foodVariations![i] == foodVariation && item.foodVariations![i].variationValues![j] == variationValue) {
              selections.add(true);
            } else {
              selections.add(false);
            }
          }
          foodVariationsSelection.add(selections);
        }
        // Build order variations
        final fvIndex = item.foodVariations!.indexOf(foodVariation);
        if (fvIndex >= 0) {
          orderVariations.add(OrderVariation(
            name: foodVariation.name,
            values: OrderVariationValue(label: [variationValue.level]),
          ));
        }
      }
    } else {
      // Regular variation: find the matching variation by label (type)
      if (item.variations != null) {
        for (var v in item.variations!) {
          if (v.type == label) {
            variations.add(v);
            break;
          }
        }
      }
    }

    CartModel cartModel = CartModel(
      id: null,
      price: price,
      discountedPrice: discountPrice,
      variation: variations,
      foodVariations: foodVariationsSelection,
      discountAmount: (price - discountPrice),
      quantity: 1,
      addOnIds: [],
      addOns: [],
      isCampaign: false,
      stock: item.stock,
      item: item,
      quantityLimit: item.quantityLimit,
    );

    OnlineCart onlineCart = OnlineCart(
      cartId: null,
      itemId: item.id,
      itemCampaignId: null,
      price: price.toString(),
      variant: foodVariation == null && variations.isNotEmpty ? variations.first.type : '',
      variation: foodVariation == null ? variations : null,
      variations: foodVariation != null ? orderVariations : null,
      quantity: 1,
      addOnIds: [],
      addOns: [],
      addOnQtys: [],
      model: 'Item',
    );

    if (cartController.existAnotherStoreItem(item.storeId, ModuleHelper.getModule() != null ? ModuleHelper.getModule()?.id : ModuleHelper.getCacheModule()?.id)) {
      Get.dialog(ConfirmationDialog(
        icon: Images.warning,
        title: 'are_you_sure_to_reset'.tr,
        description: splashController.configModel!.moduleConfig!.module!.showRestaurantText!
            ? 'if_you_continue'.tr : 'if_you_continue_without_another_store'.tr,
        onYesPressed: () {
          cartController.clearCartOnline().then((success) async {
            if (success) {
              cartController.addToCartOnline(onlineCart, cartModel);
              Get.back();
            }
          });
        },
      ), barrierDismissible: false);
    } else {
      cartController.addToCartOnline(onlineCart, cartModel);
      showCustomSnackBar('${'added_to_cart'.tr} ✅', isError: false);
    }
  }


  /// Parses markdown text, finds item links like [Name](/item-details?id=ID&page=item),
  /// and renders them as tappable links with an add-to-cart checkbox icon next to each.
  Widget _buildRichTextWithCartButtons(BuildContext context, String text) {
    // Pattern: [Link Text](href) — standard markdown link
    final linkPattern = RegExp(r'\[([^\]]+)\]\(([^)]+)\)');
    // Pattern for item detail links specifically
    final itemIdPattern = RegExp(r'/item-details\?id=(\d+)');

    // Split text into segments: plain text and links
    final List<_TextSegment> segments = [];
    int lastEnd = 0;

    for (final match in linkPattern.allMatches(text)) {
      // Add plain text before this link
      if (match.start > lastEnd) {
        segments.add(_TextSegment(text: text.substring(lastEnd, match.start)));
      }
      final linkText = match.group(1)!;
      final href = match.group(2)!;
      final itemIdMatch = itemIdPattern.firstMatch(href);
      segments.add(_TextSegment(
        text: linkText,
        href: href,
        itemId: itemIdMatch != null ? int.tryParse(itemIdMatch.group(1)!) : null,
      ));
      lastEnd = match.end;
    }
    // Add remaining text
    if (lastEnd < text.length) {
      segments.add(_TextSegment(text: text.substring(lastEnd)));
    }

    // Check if there are any item links
    final hasItemLinks = segments.any((s) => s.itemId != null);

    if (!hasItemLinks) {
      // No item links, render as plain markdown
      return MarkdownBody(
        data: text,
        selectable: true,
        styleSheet: MarkdownStyleSheet(
          p: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium!.color),
        ),
        onTapLink: (text, href, title) {
          if (href != null && href.startsWith('/')) {
            Get.toNamed(href);
          }
        },
      );
    }

    // Build rich widgets with cart buttons next to item links
    return GetBuilder<CartController>(
      builder: (cartCtrl) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildSegmentRows(context, segments, cartCtrl),
        );
      },
    );
  }

  List<Widget> _buildSegmentRows(BuildContext context, List<_TextSegment> segments, CartController cartCtrl) {
    final List<Widget> rows = [];
    List<InlineSpan> currentSpans = [];

    // Remove markdown formatting from plain text (bold, bullets, etc.)
    String cleanPlainText(String raw) {
      raw = raw.replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'\1'); // **bold**
      raw = raw.replaceAll(RegExp(r'^\s*[-•]\s*', multiLine: true), '• '); // bullets
      return raw;
    }

    void flushSpans() {
      if (currentSpans.isNotEmpty) {
        rows.add(SelectableText.rich(TextSpan(children: List.from(currentSpans))));
        currentSpans.clear();
      }
    }

    for (final seg in segments) {
      if (seg.href == null) {
        // Plain text - may contain newlines
        final lines = cleanPlainText(seg.text).split('\n');
        for (int i = 0; i < lines.length; i++) {
          if (i > 0) {
            flushSpans();
            rows.add(const SizedBox(height: 2));
          }
          if (lines[i].isNotEmpty) {
            currentSpans.add(TextSpan(
              text: lines[i],
              style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium!.color),
            ));
          }
        }
      } else if (seg.itemId != null) {
        // Item link with cart checkbox
        final isInCart = cartCtrl.cartList.any((c) => c.item?.id == seg.itemId);
        currentSpans.add(TextSpan(
          text: seg.text,
          style: robotoMedium.copyWith(
            color: Theme.of(context).primaryColor,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () => Get.toNamed(seg.href!),
        ));
        // Add the cart checkbox as a WidgetSpan
        currentSpans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.only(left: 4, right: 2),
            child: InkWell(
              onTap: () {
                if (!isInCart && message.items != null) {
                  final item = message.items!.where((i) => i.id == seg.itemId).firstOrNull;
                  if (item != null) {
                    Get.find<ItemController>().itemDirectlyAddToCart(item, context);
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isInCart ? Colors.green : Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  isInCart ? Icons.check : Icons.add_shopping_cart,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ));
      } else {
        // Non-item link (store link etc.)
        currentSpans.add(TextSpan(
          text: seg.text,
          style: robotoMedium.copyWith(
            color: Theme.of(context).primaryColor,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              if (seg.href != null && seg.href!.startsWith('/')) {
                Get.toNamed(seg.href!);
              }
            },
        ));
      }
    }
    flushSpans();
    return rows;
  }
}

class _TextSegment {
  final String text;
  final String? href;
  final int? itemId;
  const _TextSegment({required this.text, this.href, this.itemId});
}
