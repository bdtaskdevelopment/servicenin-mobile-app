import 'dart:io';

import '../../core/values/app_url.dart';
import '../models/response/auth_response.dart';
import '../models/response/blood_bank_response.dart';
import '../models/response/blood_content_response.dart';
import '../models/response/blood_donation_response.dart';
import '../models/response/blood_event_response.dart';
import '../models/response/blood_request_response.dart';
import '../models/response/blood_responder_response.dart';
import '../models/response/blood_response_response.dart';
import '../models/response/chat_message_response.dart';
import '../models/response/donor_response.dart';
import '../providers/blood.provider.dart';

class BloodRepository {
  BloodRepository({required this.provider});

  final BloodProvider provider;

  /// Returns the decoded JSON whether it's in `res.body` or `res.bodyString`,
  /// so the exact API `message` is preserved on both success and error.
  dynamic _payload(dynamic res) {
    final body = res.body;
    if (body is Map) return body;
    final raw = res.bodyString;
    if (raw != null && raw.toString().trim().isNotEmpty) return raw;
    throw Exception('সংযোগে সমস্যা — আবার চেষ্টা করুন');
  }

  /// Create a blood request. Returns success/message from the API.
  Future<AuthSimpleResponse> createRequest(Map<String, dynamic> payload) async {
    final res = await provider.postData(ApiURL.bloodRequests, payload);
    return AuthSimpleResponse.fromMap(_payload(res));
  }

  /// Register the logged-in user as a blood donor. The API responds with
  /// `{ success, message, data }` and sends an OTP to verify the donor.
  Future<AuthSimpleResponse> registerDonor(Map<String, dynamic> payload) async {
    final res = await provider.postData(ApiURL.bloodDonorRegister, payload);
    return AuthSimpleResponse.fromMap(_payload(res));
  }

  /// Verify the OTP sent after donor registration.
  Future<AuthSimpleResponse> verifyDonorOtp(String otp) async {
    final res = await provider.postData(ApiURL.bloodDonorVerifyOtp, {'otp': otp});
    return AuthSimpleResponse.fromMap(_payload(res));
  }

  /// GET /api/v1/blood/donors/me — the logged-in user's donor profile, or null
  /// when they aren't a registered donor (API returns "donor not found").
  Future<DonorEntry?> fetchMyDonor() async {
    final res = await provider.getData(ApiURL.bloodDonorMe);
    final body = _payload(res);
    if (body is Map) {
      if (body['success'] == false) return null;
      final data = body['data'];
      if (data is Map) return DonorEntry.fromMap(data.cast<String, dynamic>());
    }
    return null;
  }

  /// Update the logged-in donor's availability.
  Future<AuthSimpleResponse> updateAvailability(bool isAvailable) async {
    final payload = {'is_available': isAvailable};
    final res = await provider.putData(ApiURL.bloodDonorAvailability, payload);
    return AuthSimpleResponse.fromMap(_payload(res));
  }

  /// GET /api/v1/blood/donors/nearest — donors closest to the user.
  Future<List<DonorEntry>> fetchNearestDonors() async {
    final res = await provider.getData(ApiURL.bloodDonorsNearest);
    return DonorEntry.listFromResponse(_payload(res));
  }

  /// GET /api/v1/blood/donors — all donors.
  Future<List<DonorEntry>> fetchDonors() async {
    final res = await provider.getData(ApiURL.bloodDonors);
    return DonorEntry.listFromResponse(_payload(res));
  }

  /// GET /api/v1/blood/donors/leaderboard — top donors.
  Future<List<DonorEntry>> fetchLeaderboard() async {
    final res = await provider.getData(ApiURL.bloodDonorsLeaderboard);
    return DonorEntry.listFromResponse(_payload(res));
  }

  /// GET /api/v1/blood/requests — open blood requests.
  Future<List<BloodRequestEntry>> fetchRequests({
    double? lat,
    double? lng,
  }) async {
    final res =
        await provider.getData(ApiURL.bloodRequestsNear(lat: lat, lng: lng));
    return BloodRequestEntry.listFromResponse(_payload(res));
  }

  /// GET /api/v1/blood/requests/my — the requests I created.
  Future<List<BloodRequestEntry>> fetchMyRequests() async {
    final res = await provider.getData(ApiURL.bloodRequestsMy);
    return BloodRequestEntry.listFromResponse(_payload(res));
  }

  /// GET /api/v1/blood/requests/:id/responders — donors who responded.
  Future<List<BloodResponder>> fetchResponders(String requestId) async {
    final res =
        await provider.getData(ApiURL.bloodRequestResponders(requestId));
    return BloodResponder.listFromResponse(_payload(res));
  }

  /// POST /api/v1/blood/fulfillments/:id/received — confirm blood received.
  Future<AuthSimpleResponse> confirmReceived(String fulfillmentId) async {
    final res = await provider
        .postData(ApiURL.bloodFulfillmentReceived(fulfillmentId), {});
    return AuthSimpleResponse.fromMap(_payload(res));
  }

  /// POST /api/v1/blood/requests/:id/respond — offer to donate.
  Future<AuthSimpleResponse> respondToRequest(String requestId) async {
    final res = await provider.postData(ApiURL.bloodRequestRespond(requestId), {});
    return AuthSimpleResponse.fromMap(_payload(res));
  }

  /// GET /api/v1/blood/responses/my — the requests I've responded to.
  Future<List<BloodResponseEntry>> fetchMyResponses() async {
    final res = await provider.getData(ApiURL.bloodResponsesMy);
    return BloodResponseEntry.listFromResponse(_payload(res));
  }

  /// GET /api/v1/blood/fulfillments/:id/chat — fetch the chat thread.
  Future<List<ChatMessage>> fetchChat(String id) async {
    final res = await provider.getData(ApiURL.bloodFulfillmentChat(id));
    return ChatMessage.listFromResponse(_payload(res));
  }

  /// POST /api/v1/blood/fulfillments/:id/chat — send a message.
  Future<ChatMessage> sendChat(String id, String message) async {
    final res = await provider.postData(
        ApiURL.bloodFulfillmentChat(id), {'message': message});
    return ChatMessage.fromResponse(_payload(res));
  }

  /// GET /api/v1/blood/articles — paginated blog list.
  Future<List<BloodArticle>> fetchArticles(
      {int page = 1, int limit = 10}) async {
    final res = await provider
        .getData(ApiURL.bloodArticlesPaged(page: page, limit: limit));
    return BloodArticle.listFromResponse(_payload(res));
  }

  /// GET /api/v1/blood/articles/:id — full blog post.
  Future<BloodArticle?> fetchArticle(String id) async {
    final res = await provider.getData(ApiURL.bloodArticleById(id));
    return BloodArticle.fromResponse(_payload(res));
  }

  /// GET /api/v1/blood/faqs — all active FAQs (API returns the full list;
  /// there's no pagination or per-item detail route).
  Future<List<BloodFaq>> fetchFaqs() async {
    final res = await provider.getData(ApiURL.bloodFaqs);
    return BloodFaq.listFromResponse(_payload(res));
  }

  /// GET /api/v1/blood/stats — small community-impact summary for the home
  /// screen. Returns zeros on any failure rather than throwing, since it's
  /// a non-critical decorative card.
  Future<Map<String, int>> fetchCommunityStats() async {
    try {
      final res = await provider.getData(ApiURL.bloodStats);
      final body = _payload(res);
      final data = body is Map ? body['data'] : null;
      if (data is! Map) return const {};
      int n(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
      return {
        'donors': n(data['TotalDonors']),
        'bags': n(data['TotalDonationBags']),
        'camps': n(data['CampCount']),
        'grouping': n(data['GroupingCount']),
      };
    } catch (_) {
      return const {};
    }
  }

  /// GET /api/v1/blood/banks — the blood-bank directory, optionally
  /// filtered by a name/area search.
  Future<List<BloodBank>> fetchBanks({String? q}) async {
    final res = await provider.getData(ApiURL.bloodBanks(q: q));
    return BloodBank.listFromResponse(_payload(res));
  }

  /// GET /api/v1/blood/events — upcoming or past events.
  Future<List<BloodEvent>> fetchEvents({String scope = 'upcoming'}) async {
    final res = await provider.getData(ApiURL.bloodEvents(scope: scope));
    return BloodEvent.listFromResponse(_payload(res));
  }

  /// GET /api/v1/blood/events/:id — a single event's detail.
  Future<BloodEvent?> fetchEvent(String id) async {
    final res = await provider.getData(ApiURL.bloodEventById(id));
    return BloodEvent.fromResponse(_payload(res));
  }

  /// POST /api/v1/blood/events/:id/join
  Future<AuthSimpleResponse> joinEvent(String id) async {
    final res = await provider.postData(ApiURL.bloodEventJoin(id), {});
    return AuthSimpleResponse.fromMap(_payload(res));
  }

  /// DELETE /api/v1/blood/events/:id/join
  Future<AuthSimpleResponse> leaveEvent(String id) async {
    final res = await provider.deleteData(ApiURL.bloodEventJoin(id));
    return AuthSimpleResponse.fromMap(_payload(res));
  }

  /// POST /api/v1/blood/volunteers — submit a volunteer application.
  Future<AuthSimpleResponse> registerVolunteer(Map<String, dynamic> payload) async {
    final res = await provider.postData(ApiURL.bloodVolunteers, payload);
    return AuthSimpleResponse.fromMap(_payload(res));
  }

  /// POST /api/v1/blood/donations — log a completed donation, with up to a
  /// few photos attached in the same multipart request.
  Future<AuthSimpleResponse> logDonation(
      Map<String, dynamic> payload, List<File> photos) async {
    final res = await provider.postMultipart(ApiURL.bloodDonations, payload, photos);
    return AuthSimpleResponse.fromMap(_payload(res));
  }

  /// GET /api/v1/blood/donations/me — my donation history.
  Future<List<BloodDonation>> fetchMyDonations() async {
    final res = await provider.getData(ApiURL.bloodDonationsMe);
    return BloodDonation.listFromResponse(_payload(res));
  }

  /// PATCH /api/v1/blood/requests/:id — edit a still-open request.
  Future<AuthSimpleResponse> updateRequest(
      String id, Map<String, dynamic> payload) async {
    final res = await provider.patchData(ApiURL.bloodRequestById(id), payload);
    return AuthSimpleResponse.fromMap(_payload(res));
  }

  /// POST /api/v1/blood/requests/:id/close — cancel a still-open request.
  Future<AuthSimpleResponse> closeRequest(String id) async {
    final res = await provider.postData(ApiURL.bloodRequestClose(id), {});
    return AuthSimpleResponse.fromMap(_payload(res));
  }
}
