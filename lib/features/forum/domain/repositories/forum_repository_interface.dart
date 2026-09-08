abstract class ForumRepositoryInterface {
  Future getForumPosts({required int offset, String? category, String? search});
  Future getForumPostDetails(int postId);
}
