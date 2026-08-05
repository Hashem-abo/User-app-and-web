import 'package:sixam_mart/features/report/domain/models/report_model.dart';
import 'package:sixam_mart/interfaces/repository_interface.dart';
import 'package:get/get.dart';

abstract class ReportRepositoryInterface implements RepositoryInterface {
  Future<Response> submitReport(ReportModel reportModel);
}
