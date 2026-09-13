import 'package:suliman/common/enums/data_source_enum.dart';
import 'package:suliman/features/shelf/domain/models/shelf_model.dart';
import 'package:suliman/features/shelf/domain/repositories/shelf_repository_interface.dart';
import 'package:suliman/features/shelf/domain/services/shelf_service_interface.dart';

class ShelfService implements ShelfServiceInterface {
  final ShelfRepositoryInterface shelfRepositoryInterface;
  ShelfService({required this.shelfRepositoryInterface});

  @override
  Future<ShelfDataModel?> getShelfList(DataSourceEnum source, {int? offset}) async {
    return await shelfRepositoryInterface.getShelfList(source: source, offset: offset);
  }
}
