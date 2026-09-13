import 'package:suliman/api/api_client.dart';
import 'package:suliman/features/home/domain/repositories/super_banner_repository_interface.dart';
import 'package:suliman/util/app_constants.dart';

class SuperBannerRepository implements SuperBannerRepositoryInterface {
  final ApiClient apiClient;

  SuperBannerRepository({required this.apiClient});

  @override
  Future<dynamic> getSuperBanner(int id) async {
    return await apiClient.getData('${AppConstants.superBannerUri}$id');
  }
}
