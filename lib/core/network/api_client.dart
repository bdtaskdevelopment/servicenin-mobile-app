// lib/core/network/api_client.dart
import 'package:dio/dio.dart';
import '../config/env.dart';
import 'auth_interceptor.dart';

/// Single configured Dio instance for the whole app.
class ApiClient {
  ApiClient({required void Function() onLogout}) {
    dio = Dio(BaseOptions(
      baseUrl: Env.apiRoot,
      connectTimeout: Env.connectTimeout,
      receiveTimeout: Env.receiveTimeout,
      headers: {'Accept': 'application/json'},
      // Treat only <400 as success; let the interceptor see 401s.
      validateStatus: (s) => s != null && s < 400,
    ));
    dio.interceptors.add(AuthInterceptor(onLogout: onLogout));
    assert(() {
      dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
      return true;
    }());
  }

  late final Dio dio;
}
