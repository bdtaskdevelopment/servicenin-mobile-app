import 'dart:convert';

Map<String, dynamic> _asMap(dynamic src) =>
    src is String ? jsonDecode(src) as Map<String, dynamic> : src as Map<String, dynamic>;

/// Parsed `/api/v1/users/me` response. The account/profile screens read every
/// field from here so the UI always reflects the server.
class UserProfile {
  UserProfile({
    required this.id,
    required this.phone,
    required this.email,
    required this.role,
    required this.isVerified,
    required this.isActive,
    required this.fullName,
    this.gender,
    this.bloodGroup,
    this.address,
    this.photoUrl,
    this.maskedPhone,
  });

  final String id;
  final String phone;
  final String email;
  final String role;
  final bool isVerified;
  final bool isActive;
  final String fullName;

  /// Server-side masked phone, e.g. "+8801744***67".
  final String? maskedPhone;

  /// Optional profile fields — only present once the user fills them in.
  final String? gender;
  final String? bloodGroup;
  final String? address;
  final String? photoUrl;

  /// Builds from the full `{ success, message, data: { ..., profile } }`
  /// envelope or from a bare user `data` map.
  factory UserProfile.fromMap(dynamic src) {
    final json = _asMap(src);
    // Unwrap the envelope when present.
    final user = json['data'] is Map ? json['data'] as Map<String, dynamic> : json;
    final profile =
        user['profile'] is Map ? user['profile'] as Map<String, dynamic> : const {};

    String? str(dynamic v) {
      final s = v?.toString().trim();
      return (s == null || s.isEmpty) ? null : s;
    }

    return UserProfile(
      id: user['id']?.toString() ?? '',
      phone: user['phone']?.toString() ?? '',
      email: user['email']?.toString() ?? '',
      role: user['role']?.toString() ?? '',
      isVerified: user['is_verified'] == true,
      isActive: user['is_active'] == true,
      fullName: (profile['full_name'] ?? user['full_name'] ?? '').toString(),
      gender: str(profile['gender']),
      bloodGroup: str(profile['blood_group']),
      address: str(profile['address']),
      photoUrl: str(profile['photo_url'] ?? user['photo_url']),
      maskedPhone: str(user['masked_phone']),
    );
  }

  UserProfile copyWith({
    String? email,
    String? fullName,
    String? gender,
    String? bloodGroup,
    String? address,
    String? photoUrl,
  }) =>
      UserProfile(
        id: id,
        phone: phone,
        email: email ?? this.email,
        role: role,
        isVerified: isVerified,
        isActive: isActive,
        fullName: fullName ?? this.fullName,
        gender: gender ?? this.gender,
        bloodGroup: bloodGroup ?? this.bloodGroup,
        address: address ?? this.address,
        photoUrl: photoUrl ?? this.photoUrl,
        maskedPhone: maskedPhone,
      );
}

/// `/api/v1/users/me/photo` response — carries the new avatar URL.
class PhotoUploadResponse {
  PhotoUploadResponse({
    required this.success,
    required this.message,
    this.photoUrl,
  });

  final bool success;
  final String message;
  final String? photoUrl;

  factory PhotoUploadResponse.fromMap(dynamic src) {
    final json = _asMap(src);
    final data = json['data'] is Map ? json['data'] as Map<String, dynamic> : null;
    return PhotoUploadResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      photoUrl: data?['photo_url']?.toString(),
    );
  }
}
