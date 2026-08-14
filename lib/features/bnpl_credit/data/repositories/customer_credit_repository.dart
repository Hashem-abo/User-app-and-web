import 'package:get/get_connect/http/src/response/response.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/bnpl_credit/domain/repositories/customer_credit_repository_interface.dart';
import 'package:sixam_mart/util/app_constants.dart';

class CustomerCreditRepository implements CustomerCreditRepositoryInterface {
  final ApiClient apiClient;
  CustomerCreditRepository({required this.apiClient});

  @override
  Future<Response> getCustomerCreditAccounts() async {
    return await apiClient.getData(AppConstants.customerCreditAccountsUri);
  }

  @override
  Future<Response> validateBNPLCheckout(int storeId, double orderAmount) async {
    return await apiClient.postData(AppConstants.customerCreditValidateCheckoutUri, {
      'store_id': storeId,
      'order_amount': orderAmount,
    });
  }

  @override
  Future<Response> repayCreditAccount(int creditId, double amount, String paymentMethod, String? referenceNumber) async {
    return await apiClient.postData(AppConstants.customerCreditRepayUri, {
      'vendor_customer_credit_id': creditId,
      'amount': amount,
      'payment_method': paymentMethod,
      'reference_number': referenceNumber,
    });
  }
}
