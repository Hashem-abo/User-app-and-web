import 'package:get/get.dart';
import 'package:sixam_mart/api/api_checker.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/report/domain/models/report_model.dart';
// Added for navigation if needed, though Get.back is used.
import 'package:sixam_mart/features/report/domain/services/report_service_interface.dart';

class ReportController extends GetxController implements GetxService {
  final ReportServiceInterface reportServiceInterface;
  ReportController({required this.reportServiceInterface});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> submitReport(ReportModel reportModel) async {
    _isLoading = true;
    update();
    Response response = await reportServiceInterface.submitReport(reportModel);
    if (response.statusCode == 200) {
      Get.back();
      showCustomSnackBar('report_submitted_successfully'.tr, isError: false);
    } else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }
}
