// lib/core/network/auth_interceptor.dart
//
// Attaches the Bearer access token to every request and transparently refreshes
// it on a 401 using the refresh token — with single-flight locking so a burst of
// 401s triggers exactly ONE /auth/refresh call. On refresh failure the session is
// cleared and an onLogout callback fires (router redirects to login).
import 'dart:async';
import 'package:dio/dio.dart';
import '../config/env.dart';
import '../storage/token_store.dart';

// Extends QueuedInterceptor so refresh handling is serialized per Dio's contract.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({required this.onLogout});

  final TokenStore _store = TokenStore.instance;
  final void Function() onLogout;

  // Bare Dio (no interceptors) used only to call /auth/refresh, avoiding recursion.
  final Dio _refreshDio = Dio(BaseOptions(baseUrl: Env.apiRoot));

  Completer<String?>? _refreshLock;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Endpoints that must NOT carry a (stale) Bearer token.
    final noAuth = options.path.contains('/auth/login') ||
        options.path.contains('/auth/verify-otp') ||
        options.path.contains('/auth/register') ||
        options.path.contains('/auth/resend-otp') ||
        options.path.contains('/auth/refresh');
    if (!noAuth) {
      final token = await _store.accessToken();
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final res = err.response;
    final isAuthCall = err.requestOptions.path.contains('/auth/');
    if (res?.statusCode != 401 || isAuthCall) return handler.next(err);

    try {
      final newToken = await _refreshOnce();
      if (newToken == null) {
        onLogout();
        return handler.next(err);
      }
      // Retry the original request once with the fresh token.
      final req = err.requestOptions;
      req.headers['Authorization'] = 'Bearer $newToken';
      final clone = await Dio(BaseOptions(baseUrl: Env.apiRoot)).fetch(req);
      return handler.resolve(clone);
    } catch (_) {
      onLogout();
      return handler.next(err);
    }
  }

  /// Single-flight refresh: concurrent callers await the same in-progress refresh.
  Future<String?> _refreshOnce() {
    if (_refreshLock != null) return _refreshLock!.future;
    final lock = Completer<String?>();
    _refreshLock = lock;
    _doRefresh().then((t) => lock.complete(t)).catchError((e) => lock.completeError(e))
        .whenComplete(() => _refreshLock = null);
    return lock.future;
  }

  Future<String?> _doRefresh() async {
    final refresh = await _store.refreshToken();
    if (refresh == null) return null;
    final resp = await _refreshDio.post('/auth/refresh', data: {'refresh_token': refresh});
    final access = resp.data['access_token'] ?? resp.data['token'] ?? resp.data['access'];
    if (access is String && access.isNotEmpty) {
      await _store.updateAccess(access);
      // If the API rotates refresh tokens, persist the new one too.
      final newRefresh = resp.data['refresh_token'];
      if (newRefresh is String && newRefresh.isNotEmpty) {
        await _store.save(access: access, refresh: newRefresh);
      }
      return access;
    }
    return null;
  }
}
