import 'package:get/get_connect/http/src/response/response.dart';

abstract class CustomerCreditRepositoryInterface {
  Future<Response> getCustomerCreditAccounts();
  Future<Response> validateBNPLCheckout(int storeId, double orderAmount);
  Future<Response> repayCreditAccount(int creditId, double amount, String paymentMethod, String? referenceNumber);
}
