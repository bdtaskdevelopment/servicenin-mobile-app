import 'dart:io';

import '../../core/values/app_url.dart';
import '../models/response/auth_response.dart';
import '../models/response/nagarik_response.dart';
import '../providers/nagarik.provider.dart';

class NagarikRepository {
  NagarikRepository({required this.provider});

  final NagarikProvider provider;

  /// Rejects a backend error (HTTP 4xx/5xx or `{success:false}`) instead of
  /// parsing the error body as a successful result — otherwise a failed
  /// grievance/ticket submission silently reads as successful to the caller.
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
    if (body is List) return body;
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
  Future<NagarikGrievance> fileGrievance(
    Map<String, dynamic> payload, {
    List<File> images = const [],
  }) async {
    final res = await provider.postGrievanceMultipart(
        ApiURL.nagarikGrievances, payload, images);
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

  /// Citizen verification of a resolved grievance (common response).
  Future<AuthSimpleResponse> verifyGrievance(
    String id,
    Map<String, dynamic> payload, {
    File? proofPhoto,
  }) async {
    final res = await provider.postVerifyMultipart(
        ApiURL.nagarikGrievanceVerify(id), payload, proofPhoto);
    return AuthSimpleResponse.fromMap(_payload(res));
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
