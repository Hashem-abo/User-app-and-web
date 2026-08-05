import 'package:sixam_mart/features/report/domain/models/report_model.dart';
import 'package:get/get.dart';

abstract class ReportServiceInterface {
  Future<Response> submitReport(ReportModel reportModel);
}
