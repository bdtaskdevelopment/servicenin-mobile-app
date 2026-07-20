import 'package:get/get.dart';

import '../data.dart';

/// Backs the public "Our Work" / "Our News" endpoints
/// (/api/v1/works/..., /api/v1/news/...) — read-only, no auth required.
class ContentProvider extends BaseProvider {
  Future<Response> getData(String path) {
    return get(path);
  }
}
