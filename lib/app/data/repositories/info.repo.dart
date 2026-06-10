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

  /// GET /api/v1/info — all active information / hotline entries.
  Future<List<InfoEntry>> fetchAll() async {
    final res = await provider.getData(ApiURL.info);
    return InfoEntry.listFromResponse(_payload(res));
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
