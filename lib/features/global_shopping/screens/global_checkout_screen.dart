import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/global_shopping/controllers/global_cart_controller.dart';
import 'package:sixam_mart/features/global_shopping/controllers/global_order_controller.dart';
import 'package:sixam_mart/features/global_shopping/screens/global_order_list_screen.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';

class GlobalCheckoutScreen extends StatefulWidget {
  const GlobalCheckoutScreen({super.key});

  @override
  State<GlobalCheckoutScreen> createState() => _GlobalCheckoutScreenState();
}

class _GlobalCheckoutScreenState extends State<GlobalCheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  // Address fields
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();
  final _countryCtrl = TextEditingController(text: 'US');
  final _notesCtrl = TextEditingController();

  String _paymentMethod = 'cash_on_delivery';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!AuthHelper.isLoggedIn()) {
        Get.offAllNamed(RouteHelper.getSignInRoute(RouteHelper.main));
        showCustomSnackBar('you_are_not_logged_in'.tr);
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _zipCtrl.dispose();
    _countryCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GlobalCartController>(builder: (cartCtrl) {
      return GetBuilder<GlobalOrderController>(builder: (orderCtrl) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Theme.of(context).primaryColor,
            title: Text('Checkout', style: robotoMedium.copyWith(color: Colors.white)),
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shipping Address Section
                  _SectionHeader(icon: Icons.local_shipping_outlined, title: 'Shipping Address'),
                  const SizedBox(height: 12),

                  _buildField('Full Name', _nameCtrl, Icons.person_outline, required: true),
                  _buildField('Email Address', _emailCtrl, Icons.email_outlined, required: true, keyboardType: TextInputType.emailAddress),
                  _buildField('Phone Number', _phoneCtrl, Icons.phone_outlined, required: true, keyboardType: TextInputType.phone),
                  _buildField('Street Address', _addressCtrl, Icons.home_outlined, required: true),
                  Row(
                    children: [
                      Expanded(child: _buildField('City', _cityCtrl, null, required: true)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildField('State', _stateCtrl, null)),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: _buildField('ZIP Code', _zipCtrl, null, required: true, keyboardType: TextInputType.number)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildField('Country', _countryCtrl, null, required: true)),
                    ],
                  ),

                  const SizedBox(height: 16),
                  _SectionHeader(icon: Icons.payment_outlined, title: 'Payment Method'),
                  const SizedBox(height: 12),

                  _PaymentOption(
                    value: 'cash_on_delivery',
                    groupValue: _paymentMethod,
                    label: 'Cash on Delivery',
                    icon: Icons.money,
                    onChanged: (v) => setState(() => _paymentMethod = v!),
                  ),
                  _PaymentOption(
                    value: 'digital_payment',
                    groupValue: _paymentMethod,
                    label: 'Digital Payment',
                    icon: Icons.credit_card_outlined,
                    onChanged: (v) => setState(() => _paymentMethod = v!),
                  ),

                  const SizedBox(height: 16),
                  _SectionHeader(icon: Icons.notes_outlined, title: 'Order Notes (Optional)'),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _notesCtrl,
                    maxLines: 3,
                    decoration: _inputDecoration('Special instructions for your order...', null),
                  ),

                  const SizedBox(height: 20),
                  // Order Summary
                  Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Subtotal', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                            Text('\$${cartCtrl.subtotal.toStringAsFixed(2)}', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Shipping', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                            Text('\$${cartCtrl.shippingCost.toStringAsFixed(2)}', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                          ],
                        ),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total', style: robotoMedium),
                            Text('\$${cartCtrl.grandTotal.toStringAsFixed(2)}', style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Place Order Button
                  orderCtrl.isLoading
                      ? const Center(child: CustomLoaderWidget())
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              if (_paymentMethod == 'cash_on_delivery') {
                                await _placeOrder(cartCtrl);
                              } else {
                                await _handleDigitalPayment(cartCtrl);
                              }
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle_outline, size: 20),
                              const SizedBox(width: 8),
                              Text('Place Order • \$${cartCtrl.grandTotal.toStringAsFixed(2)}', style: robotoMedium.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeLarge)),
                            ],
                          ),
                        ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      });
    });
  }

  Future<void> _placeOrder(GlobalCartController cartCtrl) async {
    if (!_formKey.currentState!.validate()) return;
    final checkoutData = _buildCheckoutData();
    final order = await Get.find<GlobalOrderController>().placeOrder(checkoutData);
    if (order != null) {
      await cartCtrl.clearCart();
      Get.offAll(() => const GlobalOrderListScreen());
      _showSnack('Order Placed!', 'Order #${order.orderNumber} placed successfully.', Colors.green);
    } else {
      _showSnack('Error', 'Failed to place order. Please try again.', Colors.red);
    }
  }

  Future<void> _handleDigitalPayment(GlobalCartController cartCtrl) async {
    if (!_formKey.currentState!.validate()) return;
    final total = cartCtrl.grandTotal;
    final checkoutData = _buildCheckoutData();

    // Show payment confirmation dialog first
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.credit_card, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text('Digital Payment'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Amount:', style: robotoRegular.copyWith(color: Colors.grey)),
            const SizedBox(height: 4),
            Text('\$${total.toStringAsFixed(2)}', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor)),
            const SizedBox(height: 16),
            Text('Your order will be placed and processed automatically after payment confirmation.', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
            child: Text('Pay \$${total.toStringAsFixed(2)}', style: robotoMedium.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Place order directly - backend marks digital payments as 'paid' and auto-fulfills
    checkoutData['payment_method'] = 'digital_payment';
    final order = await Get.find<GlobalOrderController>().placeOrder(checkoutData);
    if (order != null) {
      await cartCtrl.clearCart();
      Get.offAll(() => const GlobalOrderListScreen());
      _showSnack('Order Placed!', 'Order #${order.orderNumber} placed and processing.', Colors.green);
    } else {
      _showSnack('Error', 'Failed to place order.', Colors.red);
    }
  }

  Map<String, dynamic> _buildCheckoutData() {
    return {
      'shipping_address': {
        'contact_person_name': _nameCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'zip': _zipCtrl.text.trim(),
        'country': _countryCtrl.text.trim(),
        'state': _stateCtrl.text.trim(),
      },
      'customer_email': _emailCtrl.text.trim(),
      'customer_phone': _phoneCtrl.text.trim(),
      'payment_method': _paymentMethod,
      'notes': _notesCtrl.text.trim(),
    };
  }

  void _showSnack(String title, String message, Color color) {
    Get.snackbar(title, message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: color,
      colorText: Colors.white,
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    IconData? icon, {
    bool required = false,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: _inputDecoration(label, icon),
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null
            : null,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData? icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon) : null,
      filled: true,
      fillColor: Theme.of(context).cardColor,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        borderSide: BorderSide(color: Theme.of(context).disabledColor.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        borderSide: BorderSide(color: Theme.of(context).disabledColor.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        borderSide: BorderSide(color: Theme.of(context).primaryColor),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 20),
        const SizedBox(width: 8),
        Text(title, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor)),
      ],
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String value;
  final String groupValue;
  final String label;
  final IconData icon;
  final ValueChanged<String?> onChanged;

  const _PaymentOption({
    required this.value,
    required this.groupValue,
    required this.label,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    bool selected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? Theme.of(context).primaryColor.withOpacity(0.08) : Theme.of(context).cardColor,
          border: Border.all(color: selected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor, size: 22),
            const SizedBox(width: 12),
            Text(label, style: robotoMedium.copyWith(color: selected ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyMedium?.color)),
            const Spacer(),
            if (selected) Icon(Icons.check_circle, color: Theme.of(context).primaryColor, size: 20),
          ],
        ),
      ),
    );
  }
}


