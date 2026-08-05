import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/product_question/domain/repositories/product_question_repository_interface.dart';
import 'package:sixam_mart/util/app_constants.dart';

class ProductQuestionRepository implements ProductQuestionRepositoryInterface {
  final ApiClient apiClient;
  ProductQuestionRepository({required this.apiClient});

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
  Future getList({int? offset, int? itemID}) async {
    return await apiClient.getData('${AppConstants.productQuestionUri}/$itemID?limit=10&offset=$offset', handleError: false);
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }
  
  @override
  Future submitQuestion(int itemID, String question, {bool isAnonymous = false}) async {
    return await apiClient.postData('${AppConstants.productQuestionUri}/submit', {'item_id': itemID, 'question': question, 'is_anonymous': isAnonymous ? 1 : 0});
  }

  @override
  Future getUserQuestions({int? offset}) async {
    return await apiClient.getData('${AppConstants.customerQuestionUri}?limit=10&offset=$offset');
  }

  @override
  Future likeQuestion(int questionID) async {
    return await apiClient.postData('${AppConstants.productQuestionUri}/$questionID/like', {});
  }

  @override
  Future unlikeQuestion(int questionID) async {
    return await apiClient.deleteData('${AppConstants.productQuestionUri}/$questionID/like');
  }
}
