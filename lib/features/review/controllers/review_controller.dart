import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/models/response_model.dart';
import 'package:sixam_mart/features/review/domain/models/review_body_model.dart';
import 'package:sixam_mart/features/review/domain/models/review_model.dart';
import 'package:sixam_mart/features/order/domain/models/order_details_model.dart';
import 'package:sixam_mart/features/review/domain/services/review_service_interface.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';

class ReviewController extends GetxController implements GetxService {
  final ReviewServiceInterface reviewServiceInterface;
  ReviewController({required this.reviewServiceInterface});

  List<ReviewModel>? _storeReviewList;
  List<ReviewModel>? get storeReviewList => _storeReviewList;

  List<ReviewModel>? _originalStoreReviewList;
  List<ReviewModel>? get originalStoreReviewList => _originalStoreReviewList;

  String? _loadingStoreId;
  String? _activeStoreId;

  int _ratingFilter = 0; // 0 = All
  int get ratingFilter => _ratingFilter;

  bool _isAscendingSort = false;
  bool get isAscendingSort => _isAscendingSort;

  List<ReviewModel>? _userReviewList;
  List<ReviewModel>? get userReviewList => _userReviewList;

  List<ReviewModel>? _serviceReviewList;
  List<ReviewModel>? get serviceReviewList => _serviceReviewList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<int> _ratingList = [];
  List<int> get ratingList => _ratingList;

  List<String> _reviewList = [];
  List<String> get reviewList => _reviewList;

  List<bool> _loadingList = [];
  List<bool> get loadingList => _loadingList;

  List<bool> _submitList = [];
  List<bool> get submitList => _submitList;
  
  final List<bool> _isAnonymousList = [];
  List<bool> get isAnonymousList => _isAnonymousList;

  int _deliveryManRating = 0;
  int get deliveryManRating => _deliveryManRating;

  List<List<XFile>> _pickedImages = [];
  List<List<XFile>> get pickedImages => _pickedImages;

  void pickImage(int index, bool isRemove) async {
    if(isRemove) {
      _pickedImages[index] = [];
    }else {
      List<XFile> images = [];
      images = await ImagePicker().pickMultiImage(imageQuality: 30);
      if (images.isNotEmpty) {
        _pickedImages[index].addAll(images);
      }
    }
    update();
  }

  void removeImage(int index, int imageIndex) {
    _pickedImages[index].removeAt(imageIndex);
    update();
  }

  Future<void> getStoreReviewList(String? storeID, {bool force = false}) async {
    if (storeID == null) return;
    if (!force) {
      if (_loadingStoreId == storeID) {
        return;
      }
      if (_activeStoreId == storeID && _storeReviewList != null) {
        return;
      }
    }

    _loadingStoreId = storeID;

    if (_activeStoreId != storeID || force) {
      _storeReviewList = null;
      update();
    }

    try {
      List<ReviewModel>? storeReviewList = await reviewServiceInterface.getStoreReviewList(storeID);
      if (_loadingStoreId == storeID) {
        if (storeReviewList != null) {
          _originalStoreReviewList = [];
          _originalStoreReviewList!.addAll(storeReviewList);
          _storeReviewList = [];
          _storeReviewList!.addAll(storeReviewList);
          _ratingFilter = 0;
          _isAscendingSort = false;
          _activeStoreId = storeID;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching store reviews: $e");
      }
    } finally {
      if (_loadingStoreId == storeID) {
        _loadingStoreId = null;
        update();
      }
    }
  }

  void filterStoreReviewList(int rating) {
    _ratingFilter = rating;
    _applyFilterAndSort();
  }

  void sortStoreReviewList() {
    _isAscendingSort = !_isAscendingSort;
    _applyFilterAndSort();
  }

  void _applyFilterAndSort() {
    if (_originalStoreReviewList == null) return;
    
    // Apply Filter
    if (_ratingFilter == 0) {
      _storeReviewList = List.from(_originalStoreReviewList!);
    } else {
      _storeReviewList = _originalStoreReviewList!.where((review) => review.rating == _ratingFilter).toList();
    }

    // Apply Sort
    if (_isAscendingSort) {
      _storeReviewList!.sort((a, b) => (a.rating ?? 0).compareTo(b.rating ?? 0));
    } else {
      _storeReviewList!.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
    }

    update();
  }

  Future<void> getServiceReviewList(String? serviceID) async {
    _serviceReviewList = null;
    List<ReviewModel>? serviceReviewList = await reviewServiceInterface.getServiceReviewList(serviceID);
    if (serviceReviewList != null) {
      _serviceReviewList = [];
      _serviceReviewList!.addAll(serviceReviewList);
    }
    update();
  }

  Future<void> getUserReviewList() async {
    _userReviewList = null;
    List<ReviewModel>? userReviewList = await reviewServiceInterface.getUserReviewList();
    if (userReviewList != null) {
      _userReviewList = [];
      _userReviewList!.addAll(userReviewList);
    }
    update();
  }

  void initRatingData(List<OrderDetailsModel> orderDetailsList) {
    _ratingList = [];
    _reviewList = [];
    _loadingList = [];
    _submitList = [];
    _pickedImages = [];
    _deliveryManRating = 0;
    for (var orderDetails in orderDetailsList) {
      _ratingList.add(0);
      _reviewList.add('');
      _loadingList.add(false);
      _submitList.add(false);
      _pickedImages.add([]);
      bool isGlobalAnonymous = false;
      if (Get.isRegistered<ProfileController>() && Get.find<ProfileController>().userInfoModel != null) {
        isGlobalAnonymous = Get.find<ProfileController>().userInfoModel!.isAnonymous ?? false;
      }
      _isAnonymousList.add(isGlobalAnonymous);
      if (kDebugMode) {
        print(orderDetails);
       }
    }
  }

  void setRating(int index, int rate, {bool notify = true}) {
    _ratingList[index] = rate;
    if(notify) update();
  }

  void setReview(int index, String review, {bool notify = true}) {
    _reviewList[index] = review;
    if (notify) update();
  }

  void setAnonymous(int index, bool value) {
    _isAnonymousList[index] = value;
    update();
  }

  void setDeliveryManRating(int rate) {
    _deliveryManRating = rate;
    update();
  }

  Future<ResponseModel> submitReview(int index, ReviewBodyModel reviewBody) async {
    _loadingList[index] = true;
    update();

    List<MultipartBody> images = [];
    for(XFile file in _pickedImages[index]) {
      images.add(MultipartBody('attachment[]', file));
    }

    ResponseModel responseModel = await reviewServiceInterface.submitReview(reviewBody, images);
    if (responseModel.isSuccess) {
      _submitList[index] = true;
      update();
    }
    _loadingList[index] = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> submitDeliveryManReview(ReviewBodyModel reviewBody) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await reviewServiceInterface.submitDeliveryManReview(reviewBody);
    if (responseModel.isSuccess) {
      _deliveryManRating = 0;
      update();
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<void> toggleReviewLike(int reviewID) async {
    ReviewModel? review;

    // Check _storeReviewList
    if (_storeReviewList != null) {
      review = _storeReviewList!.firstWhereOrNull((r) => r.id == reviewID);
    }

    // Check _serviceReviewList
    if (review == null && _serviceReviewList != null) {
      review = _serviceReviewList!.firstWhereOrNull((r) => r.id == reviewID);
    }

    // Check _userReviewList if not found
    if (review == null && _userReviewList != null) {
      review = _userReviewList!.firstWhereOrNull((r) => r.id == reviewID);
    }
    
    // Check ItemController if not found
    if (review == null && Get.isRegistered<ItemController>() && Get.find<ItemController>().item != null && Get.find<ItemController>().item!.reviews != null) {
      review = Get.find<ItemController>().item!.reviews!.firstWhereOrNull((r) => r.id == reviewID);
    }

    if (review != null) {
      bool wasLiked = review.isLikedByUser ?? false;
      int oldCount = review.likeCount ?? 0;

      review.isLikedByUser = !wasLiked;
      review.likeCount = wasLiked ? (oldCount > 0 ? oldCount - 1 : 0) : oldCount + 1;
      update();

      // Backend sync
      ResponseModel responseModel = wasLiked
          ? await reviewServiceInterface.unlikeReview(reviewID)
          : await reviewServiceInterface.likeReview(reviewID);

      // Rollback on failure
      if (!responseModel.isSuccess) {
        review.isLikedByUser = wasLiked;
        review.likeCount = oldCount;
        showCustomSnackBar(responseModel.message);
        update();
      }
    }
  }

  Future<void> deleteReview(int reviewID, bool isDeliveryMan) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await reviewServiceInterface.deleteReview(reviewID, isDeliveryMan);
    if (responseModel.isSuccess) {
      _userReviewList?.removeWhere((review) => review.id == reviewID);
      showCustomSnackBar(responseModel.message, isError: false);
    } else {
      showCustomSnackBar(responseModel.message);
    }
    _isLoading = false;
    update();
  }

  Future<void> updateReview(ReviewBodyModel reviewBody, List<MultipartBody> images, bool isDeliveryMan, {int index = -1}) async {
    if(index != -1) {
      _loadingList[index] = true;
    } else {
      _isLoading = true;
    }
    update();
    ResponseModel responseModel = await reviewServiceInterface.updateReview(reviewBody, images, isDeliveryMan);
    if (responseModel.isSuccess) {
      getUserReviewList();
      showCustomSnackBar(responseModel.message, isError: false);
    } else {
      showCustomSnackBar(responseModel.message);
    }
    if(index != -1) {
      _loadingList[index] = false;
    } else {
      _isLoading = false;
    }
    update();
  }

}