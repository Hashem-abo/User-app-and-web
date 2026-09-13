import 'package:suliman/common/enums/data_source_enum.dart';
import 'package:suliman/features/home/domain/models/advertisement_model.dart';
import 'package:suliman/interfaces/repository_interface.dart';

abstract class AdvertisementRepositoryInterface extends RepositoryInterface{
  @override
  Future<List<AdvertisementModel>?> getList({int? offset, DataSourceEnum source = DataSourceEnum.client});
}