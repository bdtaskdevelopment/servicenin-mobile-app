import '../../core/values/app_url.dart';
import '../models/response/auth_response.dart';
import '../models/response/blood_request_response.dart';
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
  Future<List<BloodRequestEntry>> fetchRequests() async {
    final res = await provider.getData(ApiURL.bloodRequests);
    return BloodRequestEntry.listFromResponse(_payload(res));
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
}
