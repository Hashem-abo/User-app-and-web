
import 'package:sixam_mart/local/cache_response.dart';

final database = AppDatabase();

class DbHelper{
  static Future<void> insertOrUpdate({required String id, required CacheResponseCompanion data}) async {
    await database.insertCacheResponse(data);
  }
}