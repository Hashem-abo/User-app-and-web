import 'package:get/get.dart';
import 'package:sixam_mart/features/product_question/domain/models/product_question_model.dart';
import 'package:sixam_mart/features/product_question/domain/services/product_question_service_interface.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/models/response_model.dart';

class ProductQuestionController extends GetxController implements GetxService {
  final ProductQuestionServiceInterface productQuestionServiceInterface;
  ProductQuestionController({required this.productQuestionServiceInterface});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSubmitLoading = false;
  bool get isSubmitLoading => _isSubmitLoading;

  ProductQuestionModel? _productQuestionModel;
  ProductQuestionModel? get productQuestionModel => _productQuestionModel;

  Future<void> getProductQuestionList(int itemID, int offset, {bool reload = false}) async {
    if(reload) {
      _productQuestionModel = null;
      update();
    }
    _isLoading = true;
    // update(); // Don't verify loading state here to prevent flicker if pagination
    ProductQuestionModel? productQuestionModel = await productQuestionServiceInterface.getProductQuestionList(itemID, offset);
    if (productQuestionModel != null) {
      if (offset == 1) {
        _productQuestionModel = productQuestionModel;
      } else {
         _productQuestionModel!.totalSize = productQuestionModel.totalSize;
         _productQuestionModel!.offset = productQuestionModel.offset;
         _productQuestionModel!.questions!.addAll(productQuestionModel.questions!);
      }
    }
    _isLoading = false;
    update();
  }

  Future<void> submitProductQuestion(int itemID, String question, {bool isAnonymous = false}) async {
    _isSubmitLoading = true;
    update();
    bool isSuccess = await productQuestionServiceInterface.submitProductQuestion(itemID, question, isAnonymous: isAnonymous);
    if (isSuccess) {
      getProductQuestionList(itemID, 1, reload: true);
      showCustomSnackBar('Question submitted successfully', isError: false);
      Get.back(); // Close dialog or bottom sheet
    } else {
      showCustomSnackBar('Failed to submit question');
    }
    _isSubmitLoading = false;
    update();
  }

  ProductQuestionModel? _myQuestionsModel;
  ProductQuestionModel? get myQuestionsModel => _myQuestionsModel;

  Future<void> getUserQuestions(int offset, {bool reload = false}) async {
    if(reload) {
      _myQuestionsModel = null;
      update();
    }
    _isLoading = true;
    update();
    ProductQuestionModel? productQuestionModel = await productQuestionServiceInterface.getUserQuestions(offset);
    if (productQuestionModel != null) {
      if (offset == 1) {
        _myQuestionsModel = productQuestionModel;
      } else {
          _myQuestionsModel!.totalSize = productQuestionModel.totalSize;
          _myQuestionsModel!.offset = productQuestionModel.offset;
          _myQuestionsModel!.questions!.addAll(productQuestionModel.questions!);
      }
    }
    _isLoading = false;
    update();
  }

  Future<void> toggleQuestionLike(int questionID, int questionIndex) async {
    ProductQuestion? question;
    
    // Check _productQuestionModel
    if (_productQuestionModel != null && _productQuestionModel!.questions != null) {
      if (questionIndex != -1 && questionIndex < _productQuestionModel!.questions!.length && _productQuestionModel!.questions![questionIndex].id == questionID) {
        question = _productQuestionModel!.questions![questionIndex];
      } else {
        question = _productQuestionModel!.questions!.firstWhereOrNull((q) => q.id == questionID);
      }
    }
    
    // Check _myQuestionsModel if not found
    if (question == null && _myQuestionsModel != null && _myQuestionsModel!.questions != null) {
      question = _myQuestionsModel!.questions!.firstWhereOrNull((q) => q.id == questionID);
    }
    
    if (question != null) {
      bool wasLiked = question.isLikedByUser ?? false;
      int oldCount = question.likeCount ?? 0;
      
      question.isLikedByUser = !wasLiked;
      question.likeCount = wasLiked ? (oldCount > 0 ? oldCount - 1 : 0) : oldCount + 1;
      update();
      
      // Backend sync
      ResponseModel responseModel = wasLiked 
        ? await productQuestionServiceInterface.unlikeQuestion(questionID)
        : await productQuestionServiceInterface.likeQuestion(questionID);
      
      // Rollback on failure
      if (!responseModel.isSuccess) {
        question.isLikedByUser = wasLiked;
        question.likeCount = oldCount;
        showCustomSnackBar(responseModel.message);
        update();
      }
    }
  }
}
