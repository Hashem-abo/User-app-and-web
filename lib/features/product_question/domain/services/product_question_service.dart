import 'package:sixam_mart/features/product_question/domain/models/product_question_model.dart';
import 'package:sixam_mart/features/product_question/domain/repositories/product_question_repository_interface.dart';
import 'package:sixam_mart/features/product_question/domain/services/product_question_service_interface.dart';
import 'package:sixam_mart/common/models/response_model.dart';

class ProductQuestionService implements ProductQuestionServiceInterface {
  final ProductQuestionRepositoryInterface productQuestionRepositoryInterface;
  ProductQuestionService({required this.productQuestionRepositoryInterface});

  @override
  Future<ProductQuestionModel?> getProductQuestionList(int itemID, int offset) async {
    return await _getProductQuestionList(itemID, offset);
  }

  Future<ProductQuestionModel?> _getProductQuestionList(int itemID, int offset) async {
    dynamic response = await productQuestionRepositoryInterface.getList(offset: offset, itemID: itemID);
    if (response.statusCode == 200) {
      return ProductQuestionModel.fromJson(response.body);
    }
    return null;
  }

  @override
  Future<bool> submitProductQuestion(int itemID, String question, {bool isAnonymous = false}) async {
    dynamic response = await productQuestionRepositoryInterface.submitQuestion(itemID, question, isAnonymous: isAnonymous);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  @override
  Future<ProductQuestionModel?> getUserQuestions(int offset) async {
    dynamic response = await productQuestionRepositoryInterface.getUserQuestions(offset: offset);
    if (response.statusCode == 200) {
      return ProductQuestionModel.fromJson(response.body);
    }
    return null;
  }

  @override
  Future<ResponseModel> likeQuestion(int itemID) async {
    dynamic response = await productQuestionRepositoryInterface.likeQuestion(itemID);
    if (response.statusCode == 200) {
      return ResponseModel(true, 'success');
    }
    return ResponseModel(false, response.statusText);
  }

  @override
  Future<ResponseModel> unlikeQuestion(int itemID) async {
    dynamic response = await productQuestionRepositoryInterface.unlikeQuestion(itemID);
    if (response.statusCode == 200) {
      return ResponseModel(true, 'success');
    }
    return ResponseModel(false, response.statusText);
  }
}
