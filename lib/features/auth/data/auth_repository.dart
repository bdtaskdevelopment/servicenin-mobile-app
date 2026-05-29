// lib/features/auth/data/auth_repository.dart
//
// Wraps the /auth + /users endpoints. Persists tokens securely on verify.
import 'package:dio/dio.dart';
import '../../../core/storage/token_store.dart';
import 'auth_models.dart';

class AuthRepository {
  AuthRepository(this._dio);
  final Dio _dio;
  final TokenStore _store = TokenStore.instance;

  /// Step 1: request an OTP for this phone. POST /auth/login {phone}
  Future<void> requestOtp(String phone) async {
    await _dio.post('/auth/login', data: {'phone': phone});
  }

  /// New-user registration. POST /auth/register {name, phone, email}
  Future<void> register({required String name, required String phone, String? email}) async {
    await _dio.post('/auth/register', data: {'name': name, 'phone': phone, if (email != null) 'email': email});
  }

  Future<void> resendOtp(String phone) async {
    await _dio.post('/auth/resend-otp', data: {'phone': phone});
  }

  /// Step 2: verify OTP -> tokens. POST /auth/verify-otp {phone, otp}
  Future<AuthTokens> verifyOtp({required String phone, required String otp}) async {
    final r = await _dio.post('/auth/verify-otp', data: {'phone': phone, 'otp': otp});
    final tokens = AuthTokens.fromJson(Map<String, dynamic>.from(r.data));
    await _store.save(access: tokens.access, refresh: tokens.refresh);
    return tokens;
  }

  /// GET /users/me
  Future<UserProfile> me() async {
    final r = await _dio.get('/users/me');
    final data = r.data is Map && r.data['data'] != null ? r.data['data'] : r.data;
    return UserProfile.fromJson(Map<String, dynamic>.from(data));
  }

  /// PUT /users/me/profile {full_name, gender, blood_group, address}
  Future<UserProfile> updateProfile(Map<String, dynamic> body) async {
    final r = await _dio.put('/users/me/profile', data: body);
    final data = r.data is Map && r.data['data'] != null ? r.data['data'] : r.data;
    return UserProfile.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> logout() => _store.clear();
  Future<bool> get hasSession => _store.hasSession;
}
