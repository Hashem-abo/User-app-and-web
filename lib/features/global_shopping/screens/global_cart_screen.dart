import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/global_shopping/controllers/global_cart_controller.dart';
import 'package:sixam_mart/features/global_shopping/screens/global_checkout_screen.dart';
import 'package:sixam_mart/features/global_shopping/widgets/global_cart_item_widget.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';
import 'package:sixam_mart/common/widgets/no_data_screen.dart';

class GlobalCartScreen extends StatefulWidget {
  const GlobalCartScreen({super.key});

  @override
  State<GlobalCartScreen> createState() => _GlobalCartScreenState();
}

class _GlobalCartScreenState extends State<GlobalCartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<GlobalCartController>().getCartList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GlobalCartController>(builder: (cartCtrl) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
          title: Text('My Cart', style: robotoMedium.copyWith(color: Colors.white)),
          actions: [
            if (cartCtrl.cartList.isNotEmpty)
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Clear Cart'),
                      content: const Text('Remove all items from your cart?'),
                      actions: [
                        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                        TextButton(
                          onPressed: () { Get.back(); cartCtrl.clearCart(); },
                          child: const Text('Clear', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                child: Text('Clear', style: robotoMedium.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeSmall)),
              ),
          ],
        ),
        body: cartCtrl.isLoading
            ? const CustomLoaderWidget()
            : cartCtrl.cartList.isEmpty
                ? NoDataScreen(text: 'cart_is_empty'.tr, isCart: true)
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                          itemCount: cartCtrl.cartList.length,
                          itemBuilder: (context, index) {
                            final item = cartCtrl.cartList[index];
                            return GlobalCartItemWidget(
                              item: item,
                              onRemove: () {
                                if (item.id != null) {
                                  cartCtrl.removeFromCart(item.id!);
                                }
                              },
                            );
                          },
                        ),
                      ),

                      // Price Summary
                      Container(
                        margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 2))],
                        ),
                        child: Column(
                          children: [
                            _SummaryRow(label: 'Subtotal', value: '\$${cartCtrl.subtotal.toStringAsFixed(2)}'),
                            const SizedBox(height: 8),
                            _SummaryRow(label: 'Shipping', value: '\$${cartCtrl.shippingCost.toStringAsFixed(2)}'),
                            const Divider(height: 16),
                            _SummaryRow(
                              label: 'Total',
                              value: '\$${cartCtrl.grandTotal.toStringAsFixed(2)}',
                              isBold: true,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 52),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                              ),
                              onPressed: () => Get.to(() => const GlobalCheckoutScreen(), transition: Transition.rightToLeft),
                              child: Text(
                                'Checkout • \$${cartCtrl.grandTotal.toStringAsFixed(2)}',
                                style: robotoMedium.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeDefault),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
      );
    });
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _SummaryRow({required this.label, required this.value, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    final style = isBold ? robotoMedium : robotoRegular;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style.copyWith(fontSize: isBold ? Dimensions.fontSizeDefault : Dimensions.fontSizeSmall)),
        Text(value, style: style.copyWith(
          fontSize: isBold ? Dimensions.fontSizeDefault : Dimensions.fontSizeSmall,
          color: isBold ? Theme.of(context).primaryColor : null,
        )),
      ],
    );
  }
}
