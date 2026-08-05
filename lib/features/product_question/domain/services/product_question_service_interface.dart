import 'package:sixam_mart/features/product_question/domain/models/product_question_model.dart';
import 'package:sixam_mart/common/models/response_model.dart';

abstract class ProductQuestionServiceInterface {
  Future<ProductQuestionModel?> getProductQuestionList(int itemID, int offset);
  Future<bool> submitProductQuestion(int itemID, String question, {bool isAnonymous = false});
  Future<ProductQuestionModel?> getUserQuestions(int offset);
  Future<ResponseModel> likeQuestion(int itemID);
  Future<ResponseModel> unlikeQuestion(int itemID);
}
