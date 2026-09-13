import 'package:suliman/common/enums/data_source_enum.dart';
import 'package:suliman/features/shelf/domain/models/shelf_model.dart';

abstract class ShelfServiceInterface {
  Future<ShelfDataModel?> getShelfList(DataSourceEnum source, {int? offset});
}
