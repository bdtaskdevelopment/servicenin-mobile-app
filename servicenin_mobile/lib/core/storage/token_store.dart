// lib/core/storage/token_store.dart
//
// Secure storage for JWTs. Uses iOS Keychain + Android Keystore-backed
// encrypted storage. NEVER store tokens in SharedPreferences.
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStore {
  TokenStore._();
  static final TokenStore instance = TokenStore._();

  static const _kAccess = 'sn_access_token';
  static const _kRefresh = 'sn_refresh_token';

  final FlutterSecureStorage _s = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // In-memory cache so the interceptor doesn't hit the keychain every request.
  String? _accessCache;

  Future<void> save({required String access, required String refresh}) async {
    _accessCache = access;
    await _s.write(key: _kAccess, value: access);
    await _s.write(key: _kRefresh, value: refresh);
  }

  Future<void> updateAccess(String access) async {
    _accessCache = access;
    await _s.write(key: _kAccess, value: access);
  }

  Future<String?> accessToken() async => _accessCache ??= await _s.read(key: _kAccess);
  Future<String?> refreshToken() => _s.read(key: _kRefresh);

  Future<bool> get hasSession async => (await accessToken()) != null;

  Future<void> clear() async {
    _accessCache = null;
    await _s.delete(key: _kAccess);
    await _s.delete(key: _kRefresh);
  }
}
