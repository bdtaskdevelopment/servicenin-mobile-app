import '../models/response/support_response.dart';
import '../providers/support.provider.dart';

/// Fetches a module's support numbers. The endpoint is passed in rather than
/// hard-coded, because every module exposes the same contract at its own path
/// (api/v1/blood/hotlines, api/v1/services/hotlines, …).
class SupportRepository {
  SupportRepository({required this.provider});

  final SupportProvider provider;

  Future<List<SupportHotline>> fetchHotlines(String endpoint) async {
    final res = await provider.getData(endpoint);
    final body = res.body ?? res.bodyString;
    if (body == null) return [];
    return SupportHotline.listFromResponse(body);
  }
}
