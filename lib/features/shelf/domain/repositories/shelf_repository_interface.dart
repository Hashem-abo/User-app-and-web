import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'package:sixam_mart/features/shelf/domain/models/shelf_model.dart';
import 'package:sixam_mart/interfaces/repository_interface.dart';

abstract class ShelfRepositoryInterface extends RepositoryInterface {
  Future<ShelfDataModel?> getShelfList({required DataSourceEnum source, int? offset});
}
