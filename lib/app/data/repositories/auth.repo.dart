import 'package:servicenin/app/core/helpers/app_helper.dart';

import '../../core/values/app_url.dart';
import '../data.dart';
import '../models/response/auth_response.dart';
import '../models/response/common_response.dart';

class AuthRepository {
  AuthRepository({required this.authProvider});

  final AuthProvider authProvider;

  // ── ServiceNin phone + OTP auth ─────────────────────────────────────

  /// Returns the decoded JSON body whether it's in `res.body` (Map) or only
  /// in `res.bodyString` (raw), so the exact API `message` is never lost.
  dynamic _payload(dynamic res) {
    final body = res.body;
    if (body is Map) return body;
    final raw = res.bodyString;
    if (raw != null && raw.toString().trim().isNotEmpty) return raw;
    throw Exception('সংযোগে সমস্যা — আবার চেষ্টা করুন');
  }

  /// Request an OTP for sign-in.
  Future<AuthSimpleResponse> requestOtp(String phone) async {
    final res = await authProvider.postData(ApiURL.authLogin, {'phone': phone});
    return AuthSimpleResponse.fromMap(_payload(res));
  }

  /// Resend the OTP.
  Future<AuthSimpleResponse> resendOtp(String phone) async {
    final res =
        await authProvider.postData(ApiURL.authResendOtp, {'phone': phone});
    return AuthSimpleResponse.fromMap(_payload(res));
  }

  /// Register a new citizen account.
  Future<AuthSimpleResponse> register({
    required String name,
    required String phone,
    required String email,
  }) async {
    final res = await authProvider.postData(
        ApiURL.authRegister, {'name': name, 'phone': phone, 'email': email});
    return AuthSimpleResponse.fromMap(_payload(res));
  }

  /// Verify the OTP. Returns the parsed response even when `success` is
  /// false (e.g. user_exist == false) so the caller can react.
  Future<VerifyOtpResponse> verifyOtp(String phone, String otp) async {
    final res = await authProvider
        .postData(ApiURL.authVerifyOtp, {'phone': phone, 'otp': otp});
    return VerifyOtpResponse.fromMap(_payload(res));
  }

  Future<CommonResponse> logout() async {
    final res = await authProvider.postData(ApiURL.logout, {});
    if (BaseResponse.handleApiResponse(res)) {
      return commonResponseFromMap(res.body);
    } else {
      final message = Helpers.extractErrorMessage(res.bodyString ?? res.body);
      throw Exception(message);
    }
  }

  Future<CommonResponse> forgotPassword({String? email}) async {
    final Map payload = {"email": email};
    final res = await authProvider.postData(ApiURL.forgotPassword, payload);
    if (BaseResponse.handleApiResponse(res)) {
      return commonResponseFromMap(res.body);
    } else {
      final message = Helpers.extractErrorMessage(res.bodyString ?? res.body);
      throw Exception(message);
    }
  }
}
