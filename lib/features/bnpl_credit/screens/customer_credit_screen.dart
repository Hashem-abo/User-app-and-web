import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/features/bnpl_credit/controllers/customer_credit_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class CustomerCreditScreen extends StatefulWidget {
  const CustomerCreditScreen({super.key});

  @override
  State<CustomerCreditScreen> createState() => _CustomerCreditScreenState();
}

class _CustomerCreditScreenState extends State<CustomerCreditScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<CustomerCreditController>().getCustomerCreditAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'My Store Credit Lines'),
      body: GetBuilder<CustomerCreditController>(builder: (creditController) {
        if (creditController.isLoading && creditController.creditList == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final credits = creditController.creditList ?? [];

        return RefreshIndicator(
          onRefresh: () async {
            await creditController.getCustomerCreditAccounts();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Store Credit Accounts (${credits.length})',
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                if (credits.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
                    alignment: Alignment.center,
                    child: Text(
                      'You do not have any active credit accounts with stores.',
                      style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: credits.length,
                    itemBuilder: (context, index) {
                      final credit = credits[index];
                      final storeName = credit.store?.name ?? 'Store #${credit.vendorId}';
                      final limit = credit.creditLimit ?? 0.0;
                      final used = credit.usedCredit ?? 0.0;
                      final available = credit.availableCredit ?? (limit - used);
                      final isFrozen = credit.status == 'suspended';
                      final progress = limit > 0 ? (used / limit).clamp(0.0, 1.0) : 0.0;

                      return Card(
                        margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                        child: Padding(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.between,
                                children: [
                                  Expanded(
                                    child: Text(
                                      storeName,
                                      style: robotoBold.copyWith(fontSize: Dimensions.fontSizeMedium),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isFrozen ? Colors.red.shade100 : Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      isFrozen ? 'FROZEN' : 'ACTIVE',
                                      style: robotoBold.copyWith(
                                        color: isFrozen ? Colors.red.shade900 : Colors.green.shade900,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: Dimensions.paddingSizeSmall),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Credit Limit: \$${limit.toStringAsFixed(2)}', style: robotoRegular),
                                  Text(
                                    'Available: \$${available.toStringAsFixed(2)}',
                                    style: robotoBold.copyWith(color: Colors.green.shade700),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.between,
                                children: [
                                  Text(
                                    'Used Debt: \$${used.toStringAsFixed(2)}',
                                    style: robotoMedium.copyWith(color: used > 0 ? Colors.red : Colors.grey),
                                  ),
                                  Text('${credit.paymentTermsDays} Days Term', style: robotoRegular.copyWith(fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.grey.shade200,
                                color: progress > 0.8 ? Colors.red : Theme.of(context).primaryColor,
                              ),

                              if (used > 0) ...[
                                const SizedBox(height: Dimensions.paddingSizeDefault),
                                CustomButton(
                                  buttonText: 'Repay Debt Online',
                                  onPressed: () {
                                    _showRepayDialog(context, creditController, credit.id!, used);
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _showRepayDialog(BuildContext context, CustomerCreditController controller, int creditId, double maxDebt) {
    final amountController = TextEditingController(text: maxDebt.toStringAsFixed(2));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Repay Credit Debt'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Repayment Amount (\$)'),
            ),
            const SizedBox(height: 8),
            const Text(
              'ⓘ Payment will automatically clear your oldest due open invoices first (FIFO Order).',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amountStr = amountController.text.trim();
              if (amountStr.isNotEmpty && double.tryParse(amountStr) != null) {
                Navigator.pop(ctx);
                await controller.repayCreditAccount(creditId, double.parse(amountStr), 'online_wallet', null);
              }
            },
            child: const Text('Confirm Repayment'),
          ),
        ],
      ),
    );
  }
}
