import '../../core/values/app_url.dart';
import '../models/response/funeral_response.dart';
import '../providers/funeral.provider.dart';

class FuneralRepository {
  FuneralRepository({required this.provider});

  final FuneralProvider provider;

  /// Returns the decoded JSON body whether it's in `res.body` (Map) or only
  /// in `res.bodyString` (raw) — but first rejects a backend error (HTTP
  /// 4xx/5xx or `{success:false}`) instead of parsing the error body as a
  /// successful result, which previously let a failed submission silently
  /// reach the "Done" screen.
  dynamic _payload(dynamic res) {
    final body = res.body;
    if (body is Map) {
      final code = res.statusCode;
      final failed = body['success'] == false || (code is int && code >= 400);
      if (failed) {
        final msg = (body['message'] ?? '').toString().trim();
        throw Exception(msg.isNotEmpty ? msg : 'অনুরোধটি সম্পন্ন করা যায়নি');
      }
      return body;
    }
    final raw = res.bodyString;
    if (raw != null && raw.toString().trim().isNotEmpty) return raw;
    throw Exception('সংযোগে সমস্যা — আবার চেষ্টা করুন');
  }

  Future<List<FuneralService>> fetchServices() async {
    final res = await provider.getData(ApiURL.funeralServices);
    return FuneralService.listFromResponse(_payload(res));
  }

  Future<FuneralRequest> createRequest(Map<String, dynamic> payload) async {
    final res = await provider.postData(ApiURL.funeralRequests, payload);
    return FuneralRequest.fromResponse(_payload(res));
  }

  /// GET /api/v1/funeral/hotlines — the admin-configured support center
  /// numbers. Public, so this works before the citizen has signed in.
  Future<List<FuneralHotline>> fetchHotlines() async {
    final res = await provider.getData(ApiURL.funeralHotlines);
    return FuneralHotline.listFromResponse(_payload(res));
  }

  Future<List<FuneralRequest>> fetchMyRequests() async {
    final res = await provider.getData(ApiURL.funeralRequestsMy);
    return FuneralRequest.listFromResponse(_payload(res));
  }
}
