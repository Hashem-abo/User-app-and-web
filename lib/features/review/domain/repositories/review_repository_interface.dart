import 'package:sixam_mart/features/review/domain/models/review_body_model.dart';
import 'package:sixam_mart/features/review/domain/models/review_model.dart';
import 'package:sixam_mart/interfaces/repository_interface.dart';
import 'package:sixam_mart/api/api_client.dart';

abstract class ReviewRepositoryInterface extends RepositoryInterface {
  @override
  Future<List<ReviewModel>?> getList({int? offset, String? storeID, String? serviceID});
  Future<List<ReviewModel>?> getUserReviewList();
  Future<dynamic> submitReview(ReviewBodyModel reviewBody, List<MultipartBody> images);
  Future<dynamic> submitDeliveryManReview(ReviewBodyModel reviewBody);
  Future<dynamic> likeReview(int reviewID);
  Future<dynamic> unlikeReview(int reviewID);
  Future<dynamic> deleteReview(int reviewID, bool isDeliveryMan);
  Future<dynamic> updateReview(ReviewBodyModel reviewBody, List<MultipartBody> images, bool isDeliveryMan);
}