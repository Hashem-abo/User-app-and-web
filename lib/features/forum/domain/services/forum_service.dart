import 'package:get/get.dart';
import 'package:suliman/features/forum/domain/models/forum_post_model.dart';
import 'package:suliman/features/forum/domain/repositories/forum_repository_interface.dart';
import 'package:suliman/features/forum/domain/services/forum_service_interface.dart';

class ForumService implements ForumServiceInterface {
  final ForumRepositoryInterface forumRepository;
  ForumService({required this.forumRepository});

  @override
  Future<ForumPostModel?> getForumPosts({required int offset, String? category, String? search}) async {
    Response response = await forumRepository.getForumPosts(offset: offset, category: category, search: search);
    if (response.statusCode == 200) {
      return ForumPostModel.fromJson(response.body);
    }
    return null;
  }

  @override
  Future<ForumPost?> getForumPostDetails(int postId) async {
    Response response = await forumRepository.getForumPostDetails(postId);
    if (response.statusCode == 200) {
      return ForumPost.fromJson(response.body);
    }
    return null;
  }
}
