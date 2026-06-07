import '../../core/values/app_url.dart';
import '../models/response/auth_response.dart';
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

  /// Update the logged-in donor's availability.
  Future<AuthSimpleResponse> updateAvailability(bool isAvailable) async {
    final payload = {'is_available': isAvailable};
    final res = await provider.putData(ApiURL.bloodDonorAvailability, payload);
    return AuthSimpleResponse.fromMap(_payload(res));
  }
}
