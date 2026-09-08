import 'package:sixam_mart/interfaces/repository_interface.dart';

abstract class SuggestionRepositoryInterface extends RepositoryInterface {
  Future<dynamic> getUserSuggestions({int? offset});
  Future<dynamic> submitSuggestion({
    required String title,
    required String description,
    required String category,
    bool isAnonymous = false,
  });
  Future<dynamic> deleteSuggestion(int suggestionId);
}
