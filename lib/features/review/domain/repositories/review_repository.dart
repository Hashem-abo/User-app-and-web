import 'package:get/get.dart';
import 'package:sixam_mart/common/models/response_model.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/review/domain/models/review_body_model.dart';
import 'package:sixam_mart/features/review/domain/models/review_model.dart';
import 'package:sixam_mart/features/review/domain/repositories/review_repository_interface.dart';
import 'package:sixam_mart/util/app_constants.dart';

class ReviewRepository implements ReviewRepositoryInterface {
  final ApiClient apiClient;
  ReviewRepository({required this.apiClient});

  @override
  Future<List<ReviewModel>?> getList({int? offset, String? storeID, String? serviceID}) async {
    List<ReviewModel>? reviewList;
    Response response = await apiClient.getData(serviceID != null
        ? '${AppConstants.serviceReviewListUri}$serviceID'
        : '${AppConstants.storeReviewUri}?store_id=$storeID');
    if (response.statusCode == 200) {
      reviewList = [];
      response.body.forEach((review) => reviewList!.add(ReviewModel.fromJson(review)));
    }
    return reviewList;
  }

  @override
  Future<List<ReviewModel>?> getUserReviewList() async {
    List<ReviewModel>? userReviewList;
    Response response = await apiClient.getData(AppConstants.customerReviewUri);
    if (response.statusCode == 200) {
      userReviewList = [];
      response.body.forEach((review) => userReviewList!.add(ReviewModel.fromJson(review)));
    }
    return userReviewList;
  }

  @override
  Future<ResponseModel> submitReview(ReviewBodyModel reviewBody, List<MultipartBody> images) async {
    ResponseModel responseModel;
    Map<String, String> body = {};
    reviewBody.toJson().forEach((key, value) {
      body[key] = value.toString();
    });
    Response response = await apiClient.postMultipartData(AppConstants.reviewUri, body, images);
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, 'review_submitted_successfully'.tr);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    return responseModel;
  }

  @override
  Future<ResponseModel> submitDeliveryManReview(ReviewBodyModel reviewBody) async {
    ResponseModel responseModel;
    Response response = await apiClient.postData(AppConstants.deliveryManReviewUri, reviewBody.toJson(), handleError: false);
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, 'review_submitted_successfully'.tr);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    return responseModel;
  }

  @override
  Future<ResponseModel> likeReview(int reviewID) async {
    Response response = await apiClient.postData('${AppConstants.reviewLikeUri}/$reviewID/like', {});
    if (response.statusCode == 200) {
      return ResponseModel(true, 'success');
    } else {
      return ResponseModel(false, response.statusText);
    }
  }

  @override
  Future<ResponseModel> unlikeReview(int reviewID) async {
    Response response = await apiClient.deleteData('${AppConstants.reviewLikeUri}/$reviewID/like');
    if (response.statusCode == 200) {
      return ResponseModel(true, 'success');
    } else {
      return ResponseModel(false, response.statusText);
    }
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }

  @override
  Future<ResponseModel> deleteReview(int reviewID, bool isDeliveryMan) async {
    Response response = await apiClient.deleteData('${isDeliveryMan ? AppConstants.deliveryManReviewDeleteUri : AppConstants.reviewDeleteUri}$reviewID');
    if (response.statusCode == 200) {
      return ResponseModel(true, 'review_deleted_successfully'.tr);
    } else {
      return ResponseModel(false, response.statusText);
    }
  }

  @override
  Future<ResponseModel> updateReview(ReviewBodyModel reviewBody, List<MultipartBody> images, bool isDeliveryMan) async {
    ResponseModel responseModel;
    Map<String, String> body = {};
    reviewBody.toJson().forEach((key, value) {
      body[key] = value.toString();
    });
    Response response = await apiClient.postMultipartData(isDeliveryMan ? AppConstants.deliveryManReviewUpdateUri : AppConstants.reviewUpdateUri, body, images);
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, 'review_updated_successfully'.tr);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    return responseModel;
  }
}