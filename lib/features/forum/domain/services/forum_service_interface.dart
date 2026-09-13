import 'package:suliman/features/forum/domain/models/forum_post_model.dart';

abstract class ForumServiceInterface {
  Future<ForumPostModel?> getForumPosts({required int offset, String? category, String? search});
  Future<ForumPost?> getForumPostDetails(int postId);
}
