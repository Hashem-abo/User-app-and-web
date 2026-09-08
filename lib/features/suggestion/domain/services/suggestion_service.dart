import 'package:sixam_mart/features/suggestion/domain/models/suggestion_model.dart';
import 'package:sixam_mart/features/suggestion/domain/repositories/suggestion_repository_interface.dart';
import 'package:sixam_mart/features/suggestion/domain/services/suggestion_service_interface.dart';
import 'package:sixam_mart/common/models/response_model.dart';

class SuggestionService implements SuggestionServiceInterface {
  final SuggestionRepositoryInterface suggestionRepositoryInterface;
  SuggestionService({required this.suggestionRepositoryInterface});

  @override
  Future<CustomerSuggestionModel?> getUserSuggestions(int offset) async {
    dynamic response = await suggestionRepositoryInterface.getUserSuggestions(offset: offset);
    if (response.statusCode == 200) {
      return CustomerSuggestionModel.fromJson(response.body);
    }
    return null;
  }

  @override
  Future<ResponseModel> submitSuggestion({
    required String title,
    required String description,
    required String category,
    bool isAnonymous = false,
  }) async {
    dynamic response = await suggestionRepositoryInterface.submitSuggestion(
      title: title,
      description: description,
      category: category,
      isAnonymous: isAnonymous,
    );
    if (response.statusCode == 200) {
      return ResponseModel(true, response.body['message'] ?? 'Suggestion submitted successfully');
    }
    return ResponseModel(false, response.statusText);
  }

  @override
  Future<ResponseModel> deleteSuggestion(int suggestionId) async {
    dynamic response = await suggestionRepositoryInterface.deleteSuggestion(suggestionId);
    if (response.statusCode == 200) {
      return ResponseModel(true, response.body['message'] ?? 'Suggestion deleted successfully');
    }
    return ResponseModel(false, response.statusText);
  }
}
