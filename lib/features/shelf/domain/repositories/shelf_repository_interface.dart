import 'package:suliman/common/enums/data_source_enum.dart';
import 'package:suliman/features/shelf/domain/models/shelf_model.dart';
import 'package:suliman/interfaces/repository_interface.dart';

abstract class ShelfRepositoryInterface extends RepositoryInterface {
  Future<ShelfDataModel?> getShelfList({required DataSourceEnum source, int? offset});
}
