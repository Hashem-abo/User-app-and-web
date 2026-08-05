import 'package:sixam_mart/common/models/response_model.dart';
import 'package:sixam_mart/features/review/domain/models/review_body_model.dart';
import 'package:sixam_mart/features/review/domain/models/review_model.dart';
import 'package:sixam_mart/features/review/domain/repositories/review_repository_interface.dart';
import 'package:sixam_mart/features/review/domain/services/review_service_interface.dart';
import 'package:sixam_mart/api/api_client.dart';

class ReviewService implements ReviewServiceInterface {
  final ReviewRepositoryInterface reviewRepositoryInterface;
  ReviewService({required this.reviewRepositoryInterface});

  @override
  Future<List<ReviewModel>?> getStoreReviewList(String? storeID) async {
    return await reviewRepositoryInterface.getList(storeID: storeID);
  }

  @override
  Future<List<ReviewModel>?> getServiceReviewList(String? serviceID) async {
    return await reviewRepositoryInterface.getList(serviceID: serviceID);
  }


  @override
  Future<List<ReviewModel>?> getUserReviewList() async {
    return await reviewRepositoryInterface.getUserReviewList();
  }

  @override
  Future<ResponseModel> submitReview(ReviewBodyModel reviewBody, List<MultipartBody> images) async {
    return await reviewRepositoryInterface.submitReview(reviewBody, images);
  }

  @override
  Future<ResponseModel> submitDeliveryManReview(ReviewBodyModel reviewBody) async {
    return await reviewRepositoryInterface.submitDeliveryManReview(reviewBody);
  }

  @override
  Future<ResponseModel> likeReview(int reviewID) async {
    return await reviewRepositoryInterface.likeReview(reviewID);
  }

  @override
  Future<ResponseModel> unlikeReview(int reviewID) async {
    return await reviewRepositoryInterface.unlikeReview(reviewID);
  }

  @override
  Future<ResponseModel> deleteReview(int reviewID, bool isDeliveryMan) async {
    return await reviewRepositoryInterface.deleteReview(reviewID, isDeliveryMan);
  }

  @override
  Future<ResponseModel> updateReview(ReviewBodyModel reviewBody, List<MultipartBody> images, bool isDeliveryMan) async {
    return await reviewRepositoryInterface.updateReview(reviewBody, images, isDeliveryMan);
  }
}