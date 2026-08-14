import 'package:get/get_connect/http/src/response/response.dart';
import 'package:sixam_mart/features/bnpl_credit/domain/repositories/customer_credit_repository_interface.dart';
import 'package:sixam_mart/features/bnpl_credit/domain/services/customer_credit_service_interface.dart';

class CustomerCreditService implements CustomerCreditServiceInterface {
  final CustomerCreditRepositoryInterface customerCreditRepositoryInterface;
  CustomerCreditService({required this.customerCreditRepositoryInterface});

  @override
  Future<Response> getCustomerCreditAccounts() async {
    return await customerCreditRepositoryInterface.getCustomerCreditAccounts();
  }

  @override
  Future<Response> validateBNPLCheckout(int storeId, double orderAmount) async {
    return await customerCreditRepositoryInterface.validateBNPLCheckout(storeId, orderAmount);
  }

  @override
  Future<Response> repayCreditAccount(int creditId, double amount, String paymentMethod, String? referenceNumber) async {
    return await customerCreditRepositoryInterface.repayCreditAccount(creditId, amount, paymentMethod, referenceNumber);
  }
}
