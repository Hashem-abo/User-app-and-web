import 'package:get/get.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/trends/domain/models/trend_model.dart';

class TrendsController extends GetxController implements GetxService {
  final ApiClient apiClient;
  TrendsController({required this.apiClient});

  List<TrendHashtagModel>? _hashtags;
  List<TrendHashtagModel>? get hashtags => _hashtags;

  List<TrendBrandModel>? _brands;
  List<TrendBrandModel>? get brands => _brands;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _selectedHashtagIndex = 0;
  int get selectedHashtagIndex => _selectedHashtagIndex;

  void selectHashtag(int index) {
    _selectedHashtagIndex = index;
    update();
  }

  Future<void> getTrendsList({bool reload = false}) async {
    if (reload || _hashtags == null) {
      _isLoading = true;
      if (reload) {
        update();
      }

      Response response = await apiClient.getData('/api/v1/items/trends');
      if (response.statusCode == 200 && response.body != null) {
        _hashtags = [];
        _brands = [];
        if (response.body['hashtags'] != null) {
          response.body['hashtags'].forEach((v) {
            _hashtags!.add(TrendHashtagModel.fromJson(v));
          });
        }
        if (response.body['brands'] != null) {
          response.body['brands'].forEach((v) {
            _brands!.add(TrendBrandModel.fromJson(v));
          });
        }
      } else {
        _hashtags = [];
        _brands = [];
      }
      _isLoading = false;
      update();
    }
  }
}
