import 'dart:convert';
import 'dart:io';

import '../../core/values/app_url.dart';
import '../models/response/auth_response.dart';
import '../models/response/matchmaking_response.dart';
import '../providers/matchmaking.provider.dart';

class MatchmakingRepository {
  MatchmakingRepository({required this.provider});

  final MatchmakingProvider provider;

  dynamic _payload(dynamic res) {
    final body = res.body;
    if (body is Map) return body;
    final raw = res.bodyString;
    if (raw != null && raw.toString().trim().isNotEmpty) return raw;
    throw Exception('সংযোগে সমস্যা — আবার চেষ্টা করুন');
  }

  /// Builds a simple response for mutation endpoints. Success is decided by the
  /// HTTP status (any 2xx → success), and the message is taken from the common
  /// `{ success, message }` envelope when present. Tolerates an empty /
  /// non-JSON body (e.g. 204 No Content).
  AuthSimpleResponse _simple(dynamic res, String okMessage) {
    final code = res.statusCode;
    final ok = (res.isOk == true) ||
        (code is int && code >= 200 && code < 300);

    Map? map;
    final body = res.body;
    if (body is Map) {
      map = body;
    } else {
      final raw = res.bodyString;
      if (raw != null && raw.toString().trim().startsWith('{')) {
        try {
          map = jsonDecode(raw) as Map;
        } catch (_) {}
      }
    }
    final apiMessage = map?['message']?.toString() ?? '';

    return AuthSimpleResponse(
      success: ok,
      message: apiMessage.isNotEmpty
          ? apiMessage
          : (ok ? okMessage : 'সংযোগে সমস্যা — আবার চেষ্টা করুন'),
    );
  }

  Future<MmCategories> fetchCategories() async {
    final res = await provider.getData(ApiURL.mmCategories);
    return MmCategories.fromResponse(_payload(res));
  }

  Future<MmBiodataFields> fetchBiodataFields() async {
    final res = await provider.getData(ApiURL.mmBiodataFields);
    return MmBiodataFields.fromResponse(_payload(res));
  }

  Future<List<MmProfile>> fetchProfiles() async {
    final res = await provider.getData(ApiURL.mmProfiles);
    return MmProfile.listFromResponse(_payload(res));
  }

  Future<List<MmSuggestion>> fetchSuggestions() async {
    final res = await provider.getData(ApiURL.mmSuggestions);
    return MmSuggestion.listFromResponse(_payload(res));
  }

  Future<MmProfile?> fetchMyProfile() async {
    final res = await provider.getData(ApiURL.mmProfileMe);
    final body = _payload(res);
    if (body is Map && body['success'] == false) return null;
    final data = body is Map ? body['data'] : null;
    if (data is! Map) return null;
    return MmProfile.fromResponse(body);
  }

  Future<MmProfile> fetchProfile(String id) async {
    final res = await provider.getData(ApiURL.mmProfile(id));
    return MmProfile.fromResponse(_payload(res));
  }

  Future<MmProfile> createProfile(Map<String, dynamic> payload) async {
    final res = await provider.postData(ApiURL.mmProfiles, payload);
    return MmProfile.fromResponse(_payload(res));
  }

  Future<AuthSimpleResponse> updateProfile(
      Map<String, dynamic> payload) async {
    final res = await provider.putData(ApiURL.mmProfileMe, payload);
    return AuthSimpleResponse.fromMap(_payload(res));
  }

  // ── Partner preference ──────────────────────────────────────────────
  Future<AuthSimpleResponse> updatePreference(
      Map<String, dynamic> payload) async {
    final res = await provider.putData(ApiURL.mmPreference, payload);
    return _simple(res, 'Preferences saved');
  }

  // ── Documents ───────────────────────────────────────────────────────
  Future<List<MmDocument>> fetchDocuments() async {
    final res = await provider.getData(ApiURL.mmDocuments);
    return MmDocument.listFromResponse(_payload(res));
  }

  Future<AuthSimpleResponse> uploadDocument(File file,
      {required String kind, String remarks = ''}) async {
    final res = await provider.uploadDocument(ApiURL.mmDocuments, file,
        kind: kind, remarks: remarks);
    return _simple(res, 'Uploaded');
  }

  Future<AuthSimpleResponse> expressInterest(String profileId) async {
    final res = await provider.postData(ApiURL.mmInterest(profileId), {});
    return AuthSimpleResponse.fromMap(_payload(res));
  }

  Future<List<MmInterest>> fetchReceived() async {
    final res = await provider.getData(ApiURL.mmInterestsReceived);
    return MmInterest.listFromResponse(_payload(res));
  }

  Future<List<MmInterest>> fetchSent() async {
    final res = await provider.getData(ApiURL.mmInterestsSent);
    return MmInterest.listFromResponse(_payload(res));
  }

  Future<AuthSimpleResponse> respondInterest(String id, bool accept) async {
    final res = await provider
        .patchData(ApiURL.mmInterestRespond(id), {'accept': accept});
    return AuthSimpleResponse.fromMap(_payload(res));
  }

  Future<List<MmMatchEntry>> fetchMatches() async {
    final res = await provider.getData(ApiURL.mmMatches);
    return MmMatchEntry.listFromResponse(_payload(res));
  }

  Future<List<MmChatMessage>> fetchChat(String interestId) async {
    final res = await provider.getData(ApiURL.mmInterestChat(interestId));
    return MmChatMessage.listFromResponse(_payload(res));
  }

  Future<AuthSimpleResponse> sendChat(
      String interestId, String message) async {
    final res = await provider
        .postData(ApiURL.mmInterestChat(interestId), {'message': message});
    return AuthSimpleResponse.fromMap(_payload(res));
  }
}
