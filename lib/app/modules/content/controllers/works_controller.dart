import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/helpers/snack_helper.dart';
import '../../../data/models/response/content_response.dart';
import '../../../data/repositories/content.repo.dart';
import '../../../routes/app_pages.dart';

/// Drives the "Our Work" (video showcase) list + detail screens, backed by
/// GET /api/v1/works/posts. Videos are opened externally (YouTube/Facebook
/// app or browser) rather than embedded in-app.
class WorksController extends GetxController {
  ContentRepository get _repo => Get.find<ContentRepository>();

  // ── Categories ──────────────────────────────────────────────────────
  List<ContentCategory> categories = [];
  int categoryIndex = 0; // 0 == "All"
  bool loadingCategories = false;

  String? get selectedCategoryId =>
      (categoryIndex > 0 && categoryIndex <= categories.length)
          ? categories[categoryIndex - 1].id
          : null;

  List<WorkPost> posts = [];
  bool loading = false;
  bool loadingMore = false;
  bool hasMore = true;
  int _page = 1;
  static const _limit = 10;

  WorkPost? selected;

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
      categories = await _repo.fetchWorkCategories();
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
      final list = await _repo.fetchWorks(
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
      final list = await _repo.fetchWorks(
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

  void openPost(WorkPost p) {
    selected = p;
    update();
    Get.toNamed(Routes.OUR_WORK_DETAIL);
  }

  Future<void> playVideo(String videoUrl) async {
    if (videoUrl.isEmpty) return;
    try {
      final ok = await launchUrl(Uri.parse(videoUrl),
          mode: LaunchMode.externalApplication);
      if (!ok) SnackHelper.error('খুলতে সমস্যা হয়েছে');
    } catch (_) {
      SnackHelper.error('খুলতে সমস্যা হয়েছে');
    }
  }
}
