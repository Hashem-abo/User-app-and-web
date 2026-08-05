import 'dart:convert';
import 'package:get/get.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/api/local_client.dart';
import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'package:sixam_mart/features/shelf/domain/models/shelf_model.dart';
import 'package:sixam_mart/features/shelf/domain/repositories/shelf_repository_interface.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/util/app_constants.dart';

class ShelfRepository implements ShelfRepositoryInterface {
  final ApiClient apiClient;
  ShelfRepository({required this.apiClient});

  @override
  Future<ShelfDataModel?> getShelfList({required DataSourceEnum source, int? offset}) async {
    ShelfDataModel? shelfData;
    String cacheId = '${AppConstants.shelfUri}-${Get.find<SplashController>().module!.id!}';

    switch(source) {
      case DataSourceEnum.client:
        Response response = await apiClient.getData('${AppConstants.shelfUri}?limit=10&offset=${offset ?? 1}');
        if(response.statusCode == 200) {
          if (response.body is List) {
            List<ShelfModel> shelves = [];
            for (var v in (response.body as List)) {
              shelves.add(ShelfModel.fromJson(v));
            }
            shelfData = ShelfDataModel(totalSize: shelves.length, limit: 10, offset: offset ?? 1, shelves: shelves);
          } else {
            shelfData = ShelfDataModel.fromJson(response.body);
          }
          if (offset == null || offset == 1) {
            LocalClient.organize(source, cacheId, jsonEncode(response.body), apiClient.getHeader());
          }
        }

      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(source, cacheId, null, null);
        if(cacheResponseData != null) {
          var decodedData = jsonDecode(cacheResponseData);
          if (decodedData is List) {
            List<ShelfModel> shelves = [];
            for (var v in decodedData) {
              shelves.add(ShelfModel.fromJson(v));
            }
            shelfData = ShelfDataModel(totalSize: shelves.length, limit: 10, offset: offset ?? 1, shelves: shelves);
          } else {
            shelfData = ShelfDataModel.fromJson(decodedData);
          }
        }
    }

    return shelfData;
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
