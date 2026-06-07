import 'dart:io';

import '../../core/values/app_url.dart';
import '../models/response/activity_response.dart';
import '../models/response/auth_response.dart';
import '../models/response/profile_response.dart';
import '../providers/profile.provider.dart';

class ProfileRepository {
  ProfileRepository({required this.provider});

  final ProfileProvider provider;

  /// Returns the decoded JSON whether it lives in `res.body` (Map) or only in
  /// `res.bodyString` (raw), so the exact API `message` is never lost.
  dynamic _payload(dynamic res) {
    final body = res.body;
    if (body is Map) return body;
    final raw = res.bodyString;
    if (raw != null && raw.toString().trim().isNotEmpty) return raw;
    throw Exception('সংযোগে সমস্যা — আবার চেষ্টা করুন');
  }

  /// GET /api/v1/users/me — the logged-in user's profile.
  Future<UserProfile> fetchProfile() async {
    final res = await provider.getData(ApiURL.usersMe);
    return UserProfile.fromMap(_payload(res));
  }

  /// PUT /api/v1/users/me/profile — update the editable fields.
  Future<AuthSimpleResponse> updateProfile({
    required String fullName,
    required String email,
    required String gender,
    required String bloodGroup,
    required String address,
  }) async {
    final payload = {
      'full_name': fullName,
      'email': email,
      'gender': gender,
      'blood_group': bloodGroup,
      'address': address,
    };
    final res = await provider.putData(ApiURL.usersMeProfile, payload);
    return AuthSimpleResponse.fromMap(_payload(res));
  }

  /// POST /api/v1/users/me/photo — multipart avatar upload.
  Future<PhotoUploadResponse> uploadPhoto(File file) async {
    final res = await provider.uploadPhoto(ApiURL.usersMePhoto, file);
    return PhotoUploadResponse.fromMap(_payload(res));
  }

  /// GET /api/v1/users/me/activity?days=N — the user's recent activity.
  Future<ActivityResponse> fetchActivity({int days = 7}) async {
    final res = await provider.getData(ApiURL.usersMeActivity(days: days));
    return ActivityResponse.fromMap(_payload(res));
  }
}
