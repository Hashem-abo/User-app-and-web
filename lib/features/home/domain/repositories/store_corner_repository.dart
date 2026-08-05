import 'package:get/get_connect/http/src/response/response.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/interfaces/repository_interface.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/features/home/domain/models/store_corner_model.dart';

abstract class StoreCornerRepositoryInterface extends RepositoryInterface {
  Future<StoreCornerDataModel?> getStoreCorners({int? offset});
}

class StoreCornerRepository implements StoreCornerRepositoryInterface {
  final ApiClient apiClient;
  StoreCornerRepository({required this.apiClient});

  @override
  Future<StoreCornerDataModel?> getStoreCorners({int? offset}) async {
    Response response = await apiClient.getData('${AppConstants.storeCornerUri}?limit=10&offset=${offset ?? 1}');
    if(response.statusCode == 200) {
      return StoreCornerDataModel.fromJson(response.body);
    }
    return null;
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
