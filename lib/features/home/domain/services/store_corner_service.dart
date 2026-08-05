import 'package:sixam_mart/features/home/domain/repositories/store_corner_repository.dart';
import 'package:sixam_mart/features/home/domain/models/store_corner_model.dart';

abstract class StoreCornerServiceInterface {
  Future<StoreCornerDataModel?> getStoreCorners({int? offset});
}

class StoreCornerService implements StoreCornerServiceInterface {
  final StoreCornerRepositoryInterface storeCornerRepositoryInterface;
  StoreCornerService({required this.storeCornerRepositoryInterface});

  @override
  Future<StoreCornerDataModel?> getStoreCorners({int? offset}) async {
    return await storeCornerRepositoryInterface.getStoreCorners(offset: offset);
  }
}
