import 'package:servicenin/app/core/helpers/app_helper.dart';

import '../../core/values/app_url.dart';
import '../data.dart';
import '../models/response/common_response.dart';
import '../models/response/login_response.dart';

class AuthRepository {
  AuthRepository({required this.authProvider});

  final AuthProvider authProvider;

  Future<LoginResponse> login({String? email, String? password}) async {
    final Map payload = {"email": email, "password": password};
    final res = await authProvider.postData(ApiURL.login, payload);
    if (BaseResponse.handleApiResponse(res)) {
      return loginResponseFromMap(res.body);
    } else {
      final message = Helpers.extractErrorMessage(res.bodyString ?? res.body);
      throw Exception(message);
    }
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
