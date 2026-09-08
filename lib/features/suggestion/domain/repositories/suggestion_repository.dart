import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/suggestion/domain/repositories/suggestion_repository_interface.dart';
import 'package:sixam_mart/util/app_constants.dart';

class SuggestionRepository implements SuggestionRepositoryInterface {
  final ApiClient apiClient;
  SuggestionRepository({required this.apiClient});

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) async {
    return await deleteSuggestion(id!);
  }

  @override
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset}) async {
    return await getUserSuggestions(offset: offset);
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }

  @override
  Future getUserSuggestions({int? offset}) async {
    return await apiClient.getData('${AppConstants.customerSuggestionUri}?limit=10&offset=$offset');
  }

  @override
  Future submitSuggestion({
    required String title,
    required String description,
    required String category,
    bool isAnonymous = false,
  }) async {
    return await apiClient.postData(AppConstants.customerSuggestionUri, {
      'title': title,
      'description': description,
      'category': category,
      'is_anonymous': isAnonymous ? 1 : 0,
    });
  }

  @override
  Future deleteSuggestion(int suggestionId) async {
    return await apiClient.deleteData('${AppConstants.customerSuggestionUri}/$suggestionId');
  }
}
