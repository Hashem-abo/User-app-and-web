import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/home/domain/repositories/super_banner_repository_interface.dart';
import 'package:sixam_mart/util/app_constants.dart';

class SuperBannerRepository implements SuperBannerRepositoryInterface {
  final ApiClient apiClient;

  SuperBannerRepository({required this.apiClient});

  @override
  Future<dynamic> getSuperBanner(int id) async {
    return await apiClient.getData('${AppConstants.superBannerUri}$id');
  }
}
