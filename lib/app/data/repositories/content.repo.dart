import '../../core/values/app_url.dart';
import '../models/response/content_response.dart';
import '../providers/content.provider.dart';

/// "Our Work" (video showcase) and "Our News" (articles) — both served by
/// the same public content API, mirroring what the admin panel manages at
/// /admin/works and /admin/news.
class ContentRepository {
  ContentRepository({required this.provider});

  final ContentProvider provider;

  dynamic _payload(dynamic res) {
    final body = res.body;
    if (body is Map) return body;
    final raw = res.bodyString;
    if (raw != null && raw.toString().trim().isNotEmpty) return raw;
    throw Exception('সংযোগে সমস্যা — আবার চেষ্টা করুন');
  }

  /// GET /api/v1/works/categories
  Future<List<ContentCategory>> fetchWorkCategories() async {
    final res = await provider.getData(ApiURL.worksCategories);
    return ContentCategory.listFromResponse(_payload(res));
  }

  /// GET /api/v1/works/posts — paginated "Our Work" list, optionally
  /// filtered to one category.
  Future<List<WorkPost>> fetchWorks(
      {int page = 1, int limit = 10, String? categoryId}) async {
    final res = await provider.getData(
        ApiURL.worksPostsPaged(page: page, limit: limit, categoryId: categoryId));
    return WorkPost.listFromResponse(_payload(res));
  }

  /// GET /api/v1/works/posts/:id
  Future<WorkPost?> fetchWork(String id) async {
    final res = await provider.getData(ApiURL.worksPostById(id));
    return WorkPost.fromResponse(_payload(res));
  }

  /// GET /api/v1/news/categories
  Future<List<ContentCategory>> fetchNewsCategories() async {
    final res = await provider.getData(ApiURL.newsCategories);
    return ContentCategory.listFromResponse(_payload(res));
  }

  /// GET /api/v1/news/posts — paginated "Our News" list, optionally
  /// filtered to one category.
  Future<List<NewsPost>> fetchNews(
      {int page = 1, int limit = 10, String? categoryId}) async {
    final res = await provider.getData(
        ApiURL.newsPostsPaged(page: page, limit: limit, categoryId: categoryId));
    return NewsPost.listFromResponse(_payload(res));
  }

  /// GET /api/v1/news/posts/:id
  Future<NewsPost?> fetchNewsDetail(String id) async {
    final res = await provider.getData(ApiURL.newsPostById(id));
    return NewsPost.fromResponse(_payload(res));
  }
}
