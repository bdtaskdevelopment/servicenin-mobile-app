// lib/features/auth/data/auth_models.dart
class AuthTokens {
  final String access;
  final String refresh;
  const AuthTokens({required this.access, required this.refresh});

  factory AuthTokens.fromJson(Map<String, dynamic> j) => AuthTokens(
        access: (j['access_token'] ?? j['token'] ?? j['access'] ?? '') as String,
        refresh: (j['refresh_token'] ?? j['refresh'] ?? '') as String,
      );
}

class UserProfile {
  final String id;
  final String fullName;
  final String phone;
  final String? email;
  final String? gender;
  final String? bloodGroup;
  final String? address;
  final bool nidVerified;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
    this.gender,
    this.bloodGroup,
    this.address,
    this.nidVerified = false,
  });

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
        id: '${j['id'] ?? ''}',
        fullName: (j['full_name'] ?? j['name'] ?? '') as String,
        phone: (j['phone'] ?? '') as String,
        email: j['email'] as String?,
        gender: j['gender'] as String?,
        bloodGroup: j['blood_group'] as String?,
        address: j['address'] as String?,
        nidVerified: (j['nid_verified'] ?? false) as bool,
      );
}
