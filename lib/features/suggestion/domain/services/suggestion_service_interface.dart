import 'package:suliman/features/suggestion/domain/models/suggestion_model.dart';
import 'package:suliman/common/models/response_model.dart';

abstract class SuggestionServiceInterface {
  Future<CustomerSuggestionModel?> getUserSuggestions(int offset);
  Future<ResponseModel> submitSuggestion({
    required String title,
    required String description,
    required String category,
    bool isAnonymous = false,
  });
  Future<ResponseModel> deleteSuggestion(int suggestionId);
}
