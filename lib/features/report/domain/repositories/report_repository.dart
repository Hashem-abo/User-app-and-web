import 'package:get/get.dart';
import 'package:suliman/api/api_client.dart';
import 'package:suliman/features/report/domain/models/report_model.dart';
import 'package:suliman/features/report/domain/repositories/report_repository_interface.dart';
import 'package:suliman/util/app_constants.dart';

class ReportRepository implements ReportRepositoryInterface {
  final ApiClient apiClient;
  ReportRepository({required this.apiClient});

  @override
  Future<Response> submitReport(ReportModel reportModel) async {
    return await apiClient.postData(AppConstants.reportSubmitUri, reportModel.toJson());
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset}) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }
}
