import 'package:get/get.dart';
import 'package:suliman/features/report/domain/models/report_model.dart';
import 'package:suliman/features/report/domain/repositories/report_repository_interface.dart';
import 'package:suliman/features/report/domain/services/report_service_interface.dart';

class ReportService implements ReportServiceInterface {
  final ReportRepositoryInterface reportRepositoryInterface;
  ReportService({required this.reportRepositoryInterface});

  @override
  Future<Response> submitReport(ReportModel reportModel) async {
    return await reportRepositoryInterface.submitReport(reportModel);
  }
}
