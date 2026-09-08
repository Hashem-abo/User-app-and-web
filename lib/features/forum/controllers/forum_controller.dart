import 'package:get/get.dart';
import 'package:sixam_mart/features/forum/domain/models/forum_post_model.dart';
import 'package:sixam_mart/features/forum/domain/services/forum_service_interface.dart';

class ForumController extends GetxController implements GetxService {
  final ForumServiceInterface forumServiceInterface;
  ForumController({required this.forumServiceInterface});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<ForumPost>? _postList;
  List<ForumPost>? get postList => _postList;

  ForumPost? _selectedPost;
  ForumPost? get selectedPost => _selectedPost;

  int _offset = 1;
  int get offset => _offset;

  int? _pageSize;
  int? get pageSize => _pageSize;

  String _selectedCategory = 'all';
  String get selectedCategory => _selectedCategory;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  final List<String> categories = ['all', 'general', 'news', 'offers', 'updates'];

  Future<void> getForumPosts({required int offset, bool reload = false, String? category, String? search}) async {
    if (reload) {
      _offset = 1;
      _postList = null;
      update();
    } else {
      _offset = offset;
    }

    if (category != null) {
      _selectedCategory = category;
    }
    if (search != null) {
      _searchQuery = search;
    }

    _isLoading = true;
    update();

    ForumPostModel? model = await forumServiceInterface.getForumPosts(
      offset: _offset,
      category: _selectedCategory,
      search: _searchQuery,
    );

    if (model != null) {
      if (reload || _postList == null) {
        _postList = [];
      }
      if (model.posts != null) {
        _postList!.addAll(model.posts!);
      }
      _pageSize = model.totalSize;
    }

    _isLoading = false;
    update();
  }

  void setSelectedPost(ForumPost post, {bool notify = true}) {
    _selectedPost = post;
    _isLoading = false;
    if (notify) {
      update();
    }
  }

  Future<void> getForumPostDetails(int postId, {bool showLoading = true}) async {
    if (showLoading) {
      _selectedPost = null;
      _isLoading = true;
      update();
    }

    ForumPost? post = await forumServiceInterface.getForumPostDetails(postId);
    if (post != null) {
      _selectedPost = post;
    }

    _isLoading = false;
    update();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    getForumPosts(offset: 1, reload: true);
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    getForumPosts(offset: 1, reload: true);
  }
}
