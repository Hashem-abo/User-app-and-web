import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

class FashnService {
  final ApiClient apiClient = Get.find<ApiClient>();

  Future<String?> generateTryOn({
    required String modelImageBase64,
    required String garmentImageUrl,
    required String category,
  }) async {
    try {
      final response = await apiClient.postData(
        AppConstants.virtualTryOnUri,
        {
          'model_image': modelImageBase64,
          'garment_image': garmentImageUrl,
          'category': category,
        },
      );

      if (response.statusCode == 200 && response.body != null) {
        if (response.body['image_url'] != null) {
          return response.body['image_url'];
        }
      } else {
        if (response.body != null && response.body['errors'] != null) {
          debugPrint('Fashn API Error: ${response.body['errors']}');
        }
      }
    } catch (e) {
      debugPrint('Fashn Service Exception: $e');
    }
    return null;
  }
}
