import 'package:suliman/api/api_client.dart';
import 'package:suliman/features/forum/domain/repositories/forum_repository_interface.dart';
import 'package:suliman/util/app_constants.dart';

class ForumRepository implements ForumRepositoryInterface {
  final ApiClient apiClient;
  ForumRepository({required this.apiClient});

  @override
  Future getForumPosts({required int offset, String? category, String? search}) async {
    String url = '${AppConstants.forumPostsUri}?limit=10&offset=$offset';
    if (category != null && category.isNotEmpty && category != 'all') {
      url += '&category=$category';
    }
    if (search != null && search.isNotEmpty) {
      url += '&search=$search';
    }
    return await apiClient.getData(url);
  }

  @override
  Future getForumPostDetails(int postId) async {
    return await apiClient.getData('${AppConstants.forumPostDetailsUri}$postId');
  }
}
