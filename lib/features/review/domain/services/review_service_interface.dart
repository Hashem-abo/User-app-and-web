import 'package:sixam_mart/common/models/response_model.dart';
import 'package:sixam_mart/features/review/domain/models/review_body_model.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/review/domain/models/review_model.dart';

abstract class ReviewServiceInterface {
  Future<List<ReviewModel>?> getStoreReviewList(String? storeID);
  Future<List<ReviewModel>?> getServiceReviewList(String? serviceID);
  Future<List<ReviewModel>?> getUserReviewList();
  Future<ResponseModel> submitReview(ReviewBodyModel reviewBody, List<MultipartBody> images);
  Future<ResponseModel> submitDeliveryManReview(ReviewBodyModel reviewBody);
  Future<ResponseModel> likeReview(int reviewID);
  Future<ResponseModel> unlikeReview(int reviewID);
  Future<ResponseModel> deleteReview(int reviewID, bool isDeliveryMan);
  Future<ResponseModel> updateReview(ReviewBodyModel reviewBody, List<MultipartBody> images, bool isDeliveryMan);
}