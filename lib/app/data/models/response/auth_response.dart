import 'dart:convert';

Map<String, dynamic> _asMap(dynamic src) =>
    src is String ? jsonDecode(src) as Map<String, dynamic> : src as Map<String, dynamic>;

/// Common envelope for login / register / resend-otp:
/// `{ "success": true, "message": "..." }` (plus optional data fields).
class AuthSimpleResponse {
  AuthSimpleResponse({
    required this.success,
    required this.message,
    this.phone,
    this.userId,
    this.otpSent,
  });

  final bool success;
  final String message;
  final String? phone;
  final String? userId;
  final bool? otpSent;

  factory AuthSimpleResponse.fromMap(dynamic src) {
    final json = _asMap(src);
    final data = json['data'] is Map ? json['data'] as Map<String, dynamic> : null;
    return AuthSimpleResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      phone: (data?['phone'] ?? json['phone'])?.toString(),
      userId: (data?['user_id'] ?? json['user_id'])?.toString(),
      otpSent: data?['otp_sent'] as bool?,
    );
  }
}

/// Response of /verify-otp.
class VerifyOtpResponse {
  VerifyOtpResponse({
    required this.success,
    required this.message,
    required this.userExist,
    this.token,
    this.refreshToken,
    this.expiresIn,
    this.phone,
    this.user,
  });

  final bool success;
  final String message;
  final bool userExist;
  final String? token;
  final String? refreshToken;
  final int? expiresIn;
  final String? phone;
  final AuthUser? user;

  factory VerifyOtpResponse.fromMap(dynamic src) {
    final json = _asMap(src);
    return VerifyOtpResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      // Defaults to true when the field is absent (successful logins omit it).
      userExist: json['user_exist'] == null
          ? json['success'] == true
          : json['user_exist'] == true,
      token: json['token']?.toString(),
      refreshToken: json['refresh_token']?.toString(),
      expiresIn: json['expires_in'] is int ? json['expires_in'] as int : null,
      phone: json['phone']?.toString(),
      user: json['user'] is Map ? AuthUser.fromMap(json['user']) : null,
    );
  }
}

class AuthUser {
  AuthUser({
    required this.id,
    required this.phone,
    required this.email,
    required this.role,
    required this.isVerified,
    this.name,
  });

  final String id;
  final String phone;
  final String email;
  final String role;
  final bool isVerified;
  final String? name;

  factory AuthUser.fromMap(dynamic src) {
    final json = _asMap(src);
    return AuthUser(
      id: json['id']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      isVerified: json['is_verified'] == true,
      name: json['name']?.toString(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'phone': phone,
        'email': email,
        'role': role,
        'is_verified': isVerified,
        'name': name,
      };
}
