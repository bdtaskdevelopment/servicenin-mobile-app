import 'dart:convert';

import 'package:intl/intl.dart';

dynamic _dec(dynamic src) => src is String ? jsonDecode(src) : src;
String _str(dynamic v) => v?.toString().trim() ?? '';
int _int(dynamic v) =>
    v is int ? v : int.tryParse(_str(v)) ?? (v is num ? v.toInt() : 0);

dynamic _data(dynamic src) {
  final d = _dec(src);
  return d is Map && d.containsKey('data') ? d['data'] : d;
}

List<String> _strList(dynamic v) =>
    (v is List ? v : const []).map((e) => e.toString()).toList();

// ── Key / label option ──────────────────────────────────────────────
class MmOption {
  MmOption({required this.key, required this.label});
  final String key;
  final String label;
  factory MmOption.fromMap(Map<String, dynamic> j) =>
      MmOption(key: _str(j['key']), label: _str(j['label']));
}

// ── Categories ──────────────────────────────────────────────────────
class MmCategories {
  MmCategories({required this.ageRanges, required this.professions});
  final List<MmOption> ageRanges;
  final List<MmOption> professions;

  factory MmCategories.fromResponse(dynamic src) {
    final d = _data(src);
    final map = d is Map ? d : const {};
    List<MmOption> opts(String k) => (map[k] is List ? map[k] as List : const [])
        .whereType<Map>()
        .map((e) => MmOption.fromMap(e.cast<String, dynamic>()))
        .toList();
    return MmCategories(
      ageRanges: opts('age_ranges'),
      professions: opts('professions'),
    );
  }
}

// ── Biodata fields ──────────────────────────────────────────────────
class MmBiodataFields {
  MmBiodataFields({
    required this.complexions,
    required this.educationLevels,
    required this.familyTypes,
    required this.genders,
    required this.incomeRanges,
    required this.maritalStatus,
    required this.religions,
    required this.required,
    required this.optional,
  });

  final List<String> complexions;
  final List<String> educationLevels;
  final List<String> familyTypes;
  final List<String> genders;
  final List<String> incomeRanges;
  final List<String> maritalStatus;
  final List<String> religions;
  final List<String> required;
  final List<String> optional;

  factory MmBiodataFields.fromResponse(dynamic src) {
    final d = _data(src);
    final m = d is Map ? d : const {};
    return MmBiodataFields(
      complexions: _strList(m['complexions']),
      educationLevels: _strList(m['education_levels']),
      familyTypes: _strList(m['family_types']),
      genders: _strList(m['genders']),
      incomeRanges: _strList(m['income_ranges']),
      maritalStatus: _strList(m['marital_status']),
      religions: _strList(m['religions']),
      required: _strList(m['required']),
      optional: _strList(m['optional']),
    );
  }
}

// ── Profile ─────────────────────────────────────────────────────────
class MmProfile {
  MmProfile(this.raw);
  final Map<String, dynamic> raw;

  String get id => _str(raw['id']);
  String get userId => _str(raw['user_id']);
  String get profileId => _str(raw['profile_id']);
  String get fullName => _str(raw['full_name']);
  int get age => _int(raw['age']);
  int get heightCm => _int(raw['height_cm']);
  String get education => _str(raw['education']);
  String get profession => _str(raw['profession']);
  String get incomeRange => _str(raw['income_range']);
  String get fatherName => _str(raw['father_name']);
  String get motherName => _str(raw['mother_name']);
  String get familyType => _str(raw['family_type']);
  String get dateOfBirth => _str(raw['date_of_birth']);
  String get birthPlace => _str(raw['birth_place']);
  String get location => _str(raw['location']);
  String get religion => _str(raw['religion']);
  String get maritalStatus => _str(raw['marital_status']);
  String get nationality => _str(raw['nationality']);
  bool get photoVisible => raw['photo_visible'] == true;
  String get photoUrl => _str(raw['photo_url']);
  String get bio => _str(raw['bio']);
  String get gender => _str(raw['gender']);
  String get language => _str(raw['language']);
  String get lifestyle => _str(raw['lifestyle']);
  int get weightKg => _int(raw['weight_kg']);
  String get siblings => _str(raw['siblings']);
  String get familyBackground => _str(raw['family_background']);
  String get status => _str(raw['status']);
  String get workflowStatus => _str(raw['workflow_status']);

  /// Partner preference, if the API embedded it on the profile.
  MmPreference? get preference => raw['preference'] is Map
      ? MmPreference.fromMap((raw['preference'] as Map).cast<String, dynamic>())
      : null;

  /// Uploaded documents embedded on the profile (if any).
  List<MmDocument> get documents => (raw['documents'] is List
          ? raw['documents'] as List
          : const [])
      .whereType<Map>()
      .map((e) => MmDocument.fromMap(e.cast<String, dynamic>()))
      .toList();

  String dyn(String key) => _str(raw[key]);

  String get letter => fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';

  String get code => profileId.isNotEmpty ? profileId : 'SN-${id.substring(0, id.length.clamp(0, 5))}';

  /// "27 yrs · Engineer · Dhaka"
  String get summary => [
        if (age > 0) '$age yrs',
        if (profession.isNotEmpty) profession,
        if (location.isNotEmpty) location,
      ].join(' · ');

  String get eduLocation =>
      [education, location].where((s) => s.isNotEmpty).join(' · ');

  factory MmProfile.fromMap(Map<String, dynamic> j) => MmProfile(j);

  static MmProfile fromResponse(dynamic src) =>
      MmProfile((_data(src) as Map).cast<String, dynamic>());

  static List<MmProfile> listFromResponse(dynamic src) {
    final d = _data(src);
    final list = d is List ? d : const [];
    return list
        .whereType<Map>()
        .map((e) => MmProfile(e.cast<String, dynamic>()))
        .toList();
  }
}

// ── Partner preference ──────────────────────────────────────────────
class MmPreference {
  MmPreference(this.raw);
  final Map<String, dynamic> raw;

  int get ageMin => _int(raw['age_min']);
  int get ageMax => _int(raw['age_max']);
  int get heightMinCm => _int(raw['height_min_cm']);
  int get heightMaxCm => _int(raw['height_max_cm']);
  String get gender => _str(raw['gender']);
  String get religion => _str(raw['religion']);
  String get maritalStatus => _str(raw['marital_status']);
  String get education => _str(raw['education']);
  String get profession => _str(raw['profession']);
  String get location => _str(raw['location']);
  String get incomeRange => _str(raw['income_range']);
  String get lifestyle => _str(raw['lifestyle']);
  String get familyType => _str(raw['family_type']);
  String get notes => _str(raw['notes']);

  String dyn(String key) => _str(raw[key]);

  factory MmPreference.fromMap(Map<String, dynamic> j) => MmPreference(j);

  static MmPreference fromResponse(dynamic src) {
    final d = _data(src);
    return MmPreference(d is Map ? d.cast<String, dynamic>() : <String, dynamic>{});
  }
}

// ── Document ────────────────────────────────────────────────────────
class MmDocument {
  MmDocument({
    required this.id,
    required this.kind,
    required this.fileUrl,
    required this.status,
    required this.remarks,
  });

  final String id;
  final String kind;
  final String fileUrl;
  final String status;
  final String remarks;

  /// "bio_data" → "Bio data".
  String get kindLabel {
    if (kind.isEmpty) return '';
    final s = kind.replaceAll('_', ' ');
    return s[0].toUpperCase() + s.substring(1);
  }

  factory MmDocument.fromMap(Map<String, dynamic> j) => MmDocument(
        id: _str(j['id']),
        kind: _str(j['kind']),
        fileUrl: _str(j['file_url']),
        status: _str(j['status']),
        remarks: _str(j['remarks']),
      );

  static List<MmDocument> listFromResponse(dynamic src) {
    final d = _data(src);
    final list = d is List ? d : const [];
    return list
        .whereType<Map>()
        .map((e) => MmDocument.fromMap(e.cast<String, dynamic>()))
        .toList();
  }
}

// ── Suggestion ──────────────────────────────────────────────────────
class MmSuggestion {
  MmSuggestion(
      {required this.profile, required this.reasons, required this.score});
  final MmProfile profile;
  final List<String> reasons;
  final int score;

  factory MmSuggestion.fromMap(Map<String, dynamic> j) => MmSuggestion(
        profile: MmProfile((j['profile'] is Map
                ? j['profile'] as Map
                : const {})
            .cast<String, dynamic>()),
        reasons: _strList(j['reasons']),
        score: _int(j['score']),
      );

  /// Parses `{ data: { suggestions: [...] } }`.
  static List<MmSuggestion> listFromResponse(dynamic src) {
    final d = _data(src);
    final list = d is Map && d['suggestions'] is List
        ? d['suggestions'] as List
        : (d is List ? d : const []);
    return list
        .whereType<Map>()
        .map((e) => MmSuggestion.fromMap(e.cast<String, dynamic>()))
        .toList();
  }
}

// ── Interest ────────────────────────────────────────────────────────
class MmInterest {
  MmInterest({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.status,
    this.sender,
    this.receiver,
    this.respondedAt,
  });

  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final String status;
  final MmProfile? sender;
  final MmProfile? receiver;
  final DateTime? respondedAt;

  bool get pending => status.toLowerCase() == 'pending';
  bool get accepted => status.toLowerCase() == 'accepted';

  factory MmInterest.fromMap(Map<String, dynamic> j) {
    final responded = _str(j['responded_at']);
    return MmInterest(
      id: _str(j['id']),
      senderId: _str(j['sender_id']),
      receiverId: _str(j['receiver_id']),
      message: _str(j['message']),
      status: _str(j['status']),
      sender: j['sender'] is Map
          ? MmProfile((j['sender'] as Map).cast<String, dynamic>())
          : null,
      receiver: j['receiver'] is Map
          ? MmProfile((j['receiver'] as Map).cast<String, dynamic>())
          : null,
      respondedAt: responded.isEmpty ? null : DateTime.tryParse(responded),
    );
  }

  static List<MmInterest> listFromResponse(dynamic src) {
    final d = _data(src);
    final list = d is List ? d : const [];
    return list
        .whereType<Map>()
        .map((e) => MmInterest.fromMap(e.cast<String, dynamic>()))
        .toList();
  }
}

// ── Match (accepted) ────────────────────────────────────────────────
class MmMatchEntry {
  MmMatchEntry({required this.interest, required this.match});
  final MmInterest interest;
  final MmProfile match;

  factory MmMatchEntry.fromMap(Map<String, dynamic> j) => MmMatchEntry(
        interest: MmInterest.fromMap(
            (j['interest'] is Map ? j['interest'] as Map : const {})
                .cast<String, dynamic>()),
        match: MmProfile(
            (j['match'] is Map ? j['match'] as Map : const {})
                .cast<String, dynamic>()),
      );

  static List<MmMatchEntry> listFromResponse(dynamic src) {
    final d = _data(src);
    final list = d is List ? d : const [];
    return list
        .whereType<Map>()
        .map((e) => MmMatchEntry.fromMap(e.cast<String, dynamic>()))
        .toList();
  }
}

// ── Chat ────────────────────────────────────────────────────────────
class MmChatMessage {
  MmChatMessage({
    required this.id,
    required this.senderId,
    required this.message,
    required this.senderName,
    this.createdAt,
  });
  final String id;
  final String senderId;
  final String message;
  final String senderName;
  final DateTime? createdAt;

  String get timeLabel {
    final dt = createdAt?.toLocal();
    return dt == null ? '' : DateFormat('h:mm a').format(dt);
  }

  factory MmChatMessage.fromMap(Map<String, dynamic> j) {
    final sender = j['sender'] is Map ? j['sender'] as Map : const {};
    final profile = sender['profile'] is Map ? sender['profile'] as Map : const {};
    final created = _str(j['created_at']);
    return MmChatMessage(
      id: _str(j['id']),
      senderId: _str(j['sender_id']),
      message: _str(j['message']),
      senderName: _str(profile['full_name']),
      createdAt: created.isEmpty ? null : DateTime.tryParse(created),
    );
  }

  static List<MmChatMessage> listFromResponse(dynamic src) {
    final d = _data(src);
    final list = d is List ? d : const [];
    return list
        .whereType<Map>()
        .map((e) => MmChatMessage.fromMap(e.cast<String, dynamic>()))
        .toList();
  }
}
