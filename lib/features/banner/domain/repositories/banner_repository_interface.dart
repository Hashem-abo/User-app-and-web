import 'package:suliman/common/enums/data_source_enum.dart';
import 'package:suliman/interfaces/repository_interface.dart';

abstract class BannerRepositoryInterface implements RepositoryInterface {
  @override
  Future getList({int? offset, bool isBanner = false, bool isTaxiBanner = false, bool isFeaturedBanner = false, bool isParcelOtherBanner = false, bool isPromotionalBanner = false, DataSourceEnum? source});
}