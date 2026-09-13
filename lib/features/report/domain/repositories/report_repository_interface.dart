import 'package:suliman/features/report/domain/models/report_model.dart';
import 'package:suliman/interfaces/repository_interface.dart';
import 'package:get/get.dart';

abstract class ReportRepositoryInterface implements RepositoryInterface {
  Future<Response> submitReport(ReportModel reportModel);
}
