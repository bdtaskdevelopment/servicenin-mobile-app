import '../../core/values/app_url.dart';
import '../models/response/info_response.dart';
import '../providers/info.provider.dart';

class InfoRepository {
  InfoRepository({required this.provider});

  final InfoProvider provider;

  /// Returns the decoded body whether it lives in `res.body` (already parsed)
  /// or only in `res.bodyString` (raw), so list/single parsing always works.
  dynamic _payload(dynamic res) {
    final body = res.body;
    if (body is Map || body is List) return body;
    final raw = res.bodyString;
    if (raw != null && raw.toString().trim().isNotEmpty) return raw;
    throw Exception('সংযোগে সমস্যা — আবার চেষ্টা করুন');
  }

  /// GET /api/v1/info — paginated directory, optionally filtered to one
  /// category (domain) and/or a search term.
  Future<List<InfoEntry>> fetchDirectory(
      {int page = 1, int limit = 10, String? domain, String? search}) async {
    final res = await provider.getData(
        ApiURL.infoPaged(page: page, limit: limit, domain: domain, search: search));
    return InfoEntry.listFromResponse(_payload(res));
  }

  /// GET /api/v1/info/domains — the directory's categories (Emergency,
  /// Government, Health, Utility, Other, …).
  Future<List<InfoDomain>> fetchDomains() async {
    final res = await provider.getData(ApiURL.infoDomains);
    return InfoDomain.listFromResponse(_payload(res));
  }

  /// GET /api/v1/info/emergency — emergency contacts only.
  Future<List<InfoEntry>> fetchEmergency() async {
    final res = await provider.getData(ApiURL.infoEmergency);
    return InfoEntry.listFromResponse(_payload(res));
  }

  /// GET /api/v1/info/{id} — a single entry.
  Future<InfoEntry> fetchById(String id) async {
    final res = await provider.getData(ApiURL.infoById(id));
    return InfoEntry.fromResponse(_payload(res));
  }
}
