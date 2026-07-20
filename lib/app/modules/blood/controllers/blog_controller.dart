import 'package:get/get.dart';

import '../../../data/models/response/blood_content_response.dart';
import '../../../data/repositories/blood.repo.dart';
import '../../../routes/app_pages.dart';

/// Drives the blood-bank "Blog" (articles) list + detail screens.
class BlogController extends GetxController {
  BloodRepository get _repo => Get.find<BloodRepository>();

  List<BloodArticle> articles = [];
  bool loading = false;
  bool loadingMore = false;
  bool hasMore = true;
  int _page = 1;
  static const _limit = 10;

  BloodArticle? selected;
  bool loadingDetail = false;

  @override
  void onInit() {
    super.onInit();
    fetchArticles(reset: true);
  }

  Future<void> fetchArticles({bool reset = false}) async {
    if (reset) {
      _page = 1;
      hasMore = true;
    }
    loading = true;
    update();
    try {
      final list = await _repo.fetchArticles(page: _page, limit: _limit);
      articles = list;
      hasMore = list.length >= _limit;
    } catch (_) {
      // Keep whatever was already loaded; the list simply won't refresh.
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
      final list = await _repo.fetchArticles(page: _page, limit: _limit);
      articles.addAll(list);
      hasMore = list.length >= _limit;
    } catch (_) {
      _page -= 1;
    } finally {
      loadingMore = false;
      update();
    }
  }

  /// Opens the detail screen immediately with the list's copy (already has
  /// the full body), then refreshes it in the background in case the
  /// article changed since the list was fetched.
  void openArticle(BloodArticle a) async {
    selected = a;
    update();
    Get.toNamed(Routes.BLOOD_BLOG_DETAIL);
    loadingDetail = true;
    update();
    try {
      final fresh = await _repo.fetchArticle(a.id);
      if (fresh != null) selected = fresh;
    } catch (_) {
    } finally {
      loadingDetail = false;
      update();
    }
  }
}
