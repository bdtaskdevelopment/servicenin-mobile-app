import 'package:get/get.dart';

import '../../../data/models/response/content_response.dart';
import '../../../data/repositories/content.repo.dart';
import '../../../routes/app_pages.dart';

/// Drives the "Our News" (articles) list + detail screens, backed by
/// GET /api/v1/news/posts.
class NewsController extends GetxController {
  ContentRepository get _repo => Get.find<ContentRepository>();

  // ── Categories ──────────────────────────────────────────────────────
  List<ContentCategory> categories = [];
  int categoryIndex = 0; // 0 == "All"
  bool loadingCategories = false;

  String? get selectedCategoryId =>
      (categoryIndex > 0 && categoryIndex <= categories.length)
          ? categories[categoryIndex - 1].id
          : null;

  List<NewsPost> posts = [];
  bool loading = false;
  bool loadingMore = false;
  bool hasMore = true;
  int _page = 1;
  static const _limit = 10;

  NewsPost? selected;
  bool loadingDetail = false;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchPosts(reset: true);
  }

  Future<void> fetchCategories() async {
    loadingCategories = true;
    update();
    try {
      categories = await _repo.fetchNewsCategories();
    } catch (_) {
    } finally {
      loadingCategories = false;
      update();
    }
  }

  void setCategory(int i) {
    categoryIndex = i;
    update();
    fetchPosts(reset: true);
  }

  Future<void> fetchPosts({bool reset = false}) async {
    if (reset) {
      _page = 1;
      hasMore = true;
    }
    loading = true;
    update();
    try {
      final list = await _repo.fetchNews(
          page: _page, limit: _limit, categoryId: selectedCategoryId);
      posts = list;
      hasMore = list.length >= _limit;
    } catch (_) {
    } finally {
      loading = false;
      update();
    }
  }

  Future<void> loadMore() async {
    if (loadingMore || loading || !hasMore) return;
    loadingMore = true;
    update();
    try {
      _page += 1;
      final list = await _repo.fetchNews(
          page: _page, limit: _limit, categoryId: selectedCategoryId);
      posts.addAll(list);
      hasMore = list.length >= _limit;
    } catch (_) {
      _page -= 1;
    } finally {
      loadingMore = false;
      update();
    }
  }

  /// Opens the detail screen immediately with the list's copy, then
  /// refreshes it in the background in case the post changed since.
  void openPost(NewsPost p) async {
    selected = p;
    update();
    Get.toNamed(Routes.OUR_NEWS_DETAIL);
    loadingDetail = true;
    update();
    try {
      final fresh = await _repo.fetchNewsDetail(p.id);
      if (fresh != null) selected = fresh;
    } catch (_) {
    } finally {
      loadingDetail = false;
      update();
    }
  }
}
