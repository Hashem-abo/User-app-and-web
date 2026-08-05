import 'package:get/get.dart';
import 'package:sixam_mart/features/home/domain/models/super_banner_model.dart';
import 'package:sixam_mart/features/home/domain/repositories/super_banner_repository_interface.dart';

class SuperBannerController extends GetxController implements GetxService {
  final SuperBannerRepositoryInterface superBannerRepositoryInterface;
  SuperBannerController({required this.superBannerRepositoryInterface});

  final Map<int, SuperBanner> _superBanners = {};
  Map<int, SuperBanner> get superBanners => _superBanners;

  final Map<int, bool> _isLoading = {};
  bool isLoading(int id) => _isLoading[id] ?? false;

  Future<void> getSuperBanner(int id) async {
    _isLoading[id] = true;
    update();
    try {
      Response response = await superBannerRepositoryInterface.getSuperBanner(id);
      if (response.statusCode == 200) {
        _superBanners[id] = SuperBanner.fromJson(response.body);
      } else {
        // Handle error
      }
    } catch (e) {
      // Handle exception
    }
    _isLoading[id] = false;
    update();
  }

  /// Inject a SuperBanner directly from the homepage payload — skips the individual API call.
  void preloadSuperBanner(SuperBanner banner) {
    if (banner.id != null) {
      _superBanners[banner.id!] = banner;
      update();
    }
  }
}
