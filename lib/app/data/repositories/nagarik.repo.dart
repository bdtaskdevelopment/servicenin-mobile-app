import '../../core/values/app_url.dart';
import '../models/response/nagarik_response.dart';
import '../providers/nagarik.provider.dart';

class NagarikRepository {
  NagarikRepository({required this.provider});

  final NagarikProvider provider;

  dynamic _payload(dynamic res) {
    final body = res.body;
    if (body is Map || body is List) return body;
    final raw = res.bodyString;
    if (raw != null && raw.toString().trim().isNotEmpty) return raw;
    throw Exception('সংযোগে সমস্যা — আবার চেষ্টা করুন');
  }

  // ── Hotlines & categories ─────────────────────────────────────────
  Future<NagarikHotlinesData> fetchHotlines() async {
    final res = await provider.getData(ApiURL.nagarikHotlines);
    return NagarikHotlinesData.fromResponse(_payload(res));
  }

  Future<List<NagarikReportCategory>> fetchCategories() async {
    final res = await provider.getData(ApiURL.nagarikCategories);
    return NagarikReportCategory.listFromResponse(_payload(res));
  }

  // ── Grievances ────────────────────────────────────────────────────
  Future<NagarikGrievance> fileGrievance(Map<String, dynamic> payload) async {
    final res = await provider.postData(ApiURL.nagarikGrievances, payload);
    return NagarikGrievance.fromResponse(_payload(res));
  }

  Future<List<NagarikGrievance>> fetchMyGrievances() async {
    final res = await provider.getData(ApiURL.nagarikGrievances);
    return NagarikGrievance.listFromResponse(_payload(res));
  }

  Future<NagarikGrievance> fetchGrievance(String id) async {
    final res = await provider.getData(ApiURL.nagarikGrievanceById(id));
    return NagarikGrievance.fromResponse(_payload(res));
  }

  // ── Tickets ───────────────────────────────────────────────────────
  Future<NagarikTicket> createTicket(Map<String, dynamic> payload) async {
    final res = await provider.postData(ApiURL.nagarikTickets, payload);
    return NagarikTicket.fromResponse(_payload(res));
  }

  Future<List<NagarikTicket>> fetchMyTickets() async {
    final res = await provider.getData(ApiURL.nagarikTickets);
    return NagarikTicket.listFromResponse(_payload(res));
  }

  Future<NagarikTicket> fetchTicket(String id) async {
    final res = await provider.getData(ApiURL.nagarikTicketById(id));
    return NagarikTicket.fromResponse(_payload(res));
  }

  // ── Ticket chat ───────────────────────────────────────────────────
  Future<List<NagarikMessage>> fetchTicketMessages(String id) async {
    final res = await provider.getData(ApiURL.nagarikTicketMessages(id));
    return NagarikMessage.listFromResponse(_payload(res));
  }

  Future<NagarikMessage> sendTicketMessage(String id, String message) async {
    final res = await provider.postData(
        ApiURL.nagarikTicketMessages(id), {'message': message});
    return NagarikMessage.fromResponse(_payload(res));
  }
}
