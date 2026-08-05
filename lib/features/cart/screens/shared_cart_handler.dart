import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/cart/domain/models/cart_model.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/helper/route_helper.dart';

class SharedCartHandler extends StatefulWidget {
  const SharedCartHandler({super.key});

  @override
  State<SharedCartHandler> createState() => _SharedCartHandlerState();
}

class _SharedCartHandlerState extends State<SharedCartHandler> {
  @override
  void initState() {
    super.initState();
    _processSharedCart();
  }

  Future<void> _processSharedCart() async {
    String? data = Get.parameters['data'];
    if (data != null && data.isNotEmpty) {
      try {
        final decoded = jsonDecode(utf8.decode(base64Decode(data)));
        if (decoded is List) {
           await Get.find<CartController>().clearCartList();
           
           for (var itemData in decoded) {
             int itemId = itemData['id'];
             int quantity = itemData['qty'];
             // Variation handling is complex without full Item object. 
             // We will try to fetch item first.
             
             Item? item = await Get.find<ItemController>().itemServiceInterface.getItemDetails(itemId);
             if (item != null) {
               // Reconstruct CartModel. 
               // For simplicity, we are defaulting to base variation if not fully specified.
               // Ideally we should pass variation indices in the link.
               
               double price = item.price!;
               double discountedPrice = price; // Calculate proper discount if possible
               
               CartModel cartModel = CartModel(
                 id: null, 
                 price: price, 
                 discountedPrice: discountedPrice, 
                 variation: [], // Variations
                 foodVariations: [], // Food Variations
                 discountAmount: 0, 
                 quantity: quantity, 
                 addOnIds: [], // Addon IDs
                 addOns: [], // Addons
                 isCampaign: false, 
                 stock: item.stock, 
                 item: item, 
                 quantityLimit: item.quantityLimit
               );
               
               Get.find<CartController>().addToCart(cartModel, null); 
             }
           }
        }
      } catch (e) {
        debugPrint('Error processing shared cart: $e');
      }
    }
    // proper navigation
    Get.offNamed(RouteHelper.getCartRoute());
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
