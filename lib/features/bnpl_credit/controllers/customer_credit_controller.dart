import 'package:get/get.dart';
import 'package:sixam_mart/features/bnpl_credit/domain/models/customer_credit_model.dart';
import 'package:sixam_mart/features/bnpl_credit/domain/services/customer_credit_service_interface.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';

class CustomerCreditController extends GetxController implements GetxService {
  final CustomerCreditServiceInterface customerCreditServiceInterface;
  CustomerCreditController({required this.customerCreditServiceInterface});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<CustomerCreditModel>? _creditList;
  List<CustomerCreditModel>? get creditList => _creditList;

  Future<void> getCustomerCreditAccounts() async {
    _isLoading = true;
    update();
    Response response = await customerCreditServiceInterface.getCustomerCreditAccounts();
    if (response.statusCode == 200) {
      List<dynamic> list = response.body['credits'] ?? [];
      _creditList = list.map((item) => CustomerCreditModel.fromJson(item)).toList();
    }
    _isLoading = false;
    update();
  }

  Future<bool> repayCreditAccount(int creditId, double amount, String paymentMethod, String? ref) async {
    _isLoading = true;
    update();
    Response response = await customerCreditServiceInterface.repayCreditAccount(creditId, amount, paymentMethod, ref);
    _isLoading = false;
    if (response.statusCode == 200) {
      showCustomSnackBar('Repayment processed successfully via FIFO allocation!', isError: false);
      getCustomerCreditAccounts();
      return true;
    } else {
      showCustomSnackBar(response.body['errors']?[0]?['message'] ?? 'Failed to process repayment');
      update();
      return false;
    }
  }
}
