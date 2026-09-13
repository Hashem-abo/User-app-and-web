import 'package:suliman/common/enums/data_source_enum.dart';
import 'package:suliman/features/brands/domain/models/brands_model.dart';
import 'package:suliman/features/brands/domain/repositories/brands_repository_interface.dart';
import 'package:suliman/features/brands/domain/services/brands_service_interface.dart';
import 'package:suliman/features/item/domain/models/item_model.dart';

class BrandsService implements BrandsServiceInterface {
  final BrandsRepositoryInterface brandsRepositoryInterface;
  BrandsService({required this.brandsRepositoryInterface});

  @override
  Future<List<BrandModel>?> getBrandList(DataSourceEnum source) async {
    return await brandsRepositoryInterface.getBrandList(source: source);
  }

  @override
  Future<ItemModel?> getBrandItemList({required int brandId, int? offset}) async {
    return await brandsRepositoryInterface.getBrandItemList(brandId: brandId, offset: offset);
  }

}