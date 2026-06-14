import 'dart:convert';

import 'package:intl/intl.dart';

dynamic _dec(dynamic src) => src is String ? jsonDecode(src) : src;
String _str(dynamic v) => v?.toString().trim() ?? '';
int _int(dynamic v) =>
    v is int ? v : int.tryParse(_str(v)) ?? (v is num ? v.toInt() : 0);
double _dbl(dynamic v) =>
    v is num ? v.toDouble() : double.tryParse(_str(v)) ?? 0;

dynamic _data(dynamic src) {
  final d = _dec(src);
  return d is Map && d.containsKey('data') ? d['data'] : d;
}

String _fullName(dynamic sender) {
  if (sender is Map) {
    final profile = sender['profile'];
    if (profile is Map && _str(profile['full_name']).isNotEmpty) {
      return _str(profile['full_name']);
    }
    if (_str(sender['email']).isNotEmpty) return _str(sender['email']);
  }
  return '';
}

// ── Hotlines ────────────────────────────────────────────────────────
class NagarikHotline {
  NagarikHotline({required this.key, required this.label, required this.number});
  final String key;
  final String label;
  final String number;

  factory NagarikHotline.fromMap(Map<String, dynamic> j) => NagarikHotline(
        key: _str(j['key']),
        label: _str(j['label']),
        number: _str(j['number']),
      );
}

class NagarikHotlinesData {
  NagarikHotlinesData({
    required this.dnccName,
    required this.dnccHotline,
    required this.dnccPhone,
    required this.dnccEmail,
    required this.dnccWebsite,
    required this.hotlines,
  });

  final String dnccName;
  final String dnccHotline;
  final String dnccPhone;
  final String dnccEmail;
  final String dnccWebsite;
  final List<NagarikHotline> hotlines;

  factory NagarikHotlinesData.fromResponse(dynamic src) {
    final d = _data(src);
    final m = d is Map ? d : const {};
    final dncc = m['dncc'] is Map ? m['dncc'] as Map : const {};
    final list = m['hotlines'] is List ? m['hotlines'] as List : const [];
    return NagarikHotlinesData(
      dnccName: _str(dncc['name']),
      dnccHotline: _str(dncc['hotline']),
      dnccPhone: _str(dncc['phone']),
      dnccEmail: _str(dncc['email']),
      dnccWebsite: _str(dncc['website']),
      hotlines: list
          .whereType<Map>()
          .map((e) => NagarikHotline.fromMap(e.cast<String, dynamic>()))
          .toList(),
    );
  }
}

// ── Report category ─────────────────────────────────────────────────
class NagarikReportCategory {
  NagarikReportCategory({
    required this.key,
    required this.label,
    required this.description,
    required this.icon,
  });
  final String key;
  final String label;
  final String description;
  final String icon;

  factory NagarikReportCategory.fromMap(Map<String, dynamic> j) =>
      NagarikReportCategory(
        key: _str(j['key']),
        label: _str(j['label']),
        description: _str(j['description']),
        icon: _str(j['icon']),
      );

  /// Parses `{ data: { categories: [...] } }`.
  static List<NagarikReportCategory> listFromResponse(dynamic src) {
    final d = _data(src);
    final list = d is Map && d['categories'] is List
        ? d['categories'] as List
        : (d is List ? d : const []);
    return list
        .whereType<Map>()
        .map((e) => NagarikReportCategory.fromMap(e.cast<String, dynamic>()))
        .toList();
  }
}

// ── Grievance ───────────────────────────────────────────────────────
class NagarikGrievance {
  NagarikGrievance(this.raw);
  final Map<String, dynamic> raw;

  String get id => _str(raw['id']);
  String get trackingCode => _str(raw['tracking_code']);
  String get category => _str(raw['category']);
  String get title => _str(raw['title']);
  String get description => _str(raw['description']);
  String get address => _str(raw['address']);
  String get wardNo => _str(raw['ward_no']);
  double get lat => _dbl(raw['lat']);
  double get lng => _dbl(raw['lng']);
  String get photoUrl => _str(raw['photo_url']);
  String get priority => _str(raw['priority']);

  /// All attached photo URLs from `media[]`, falling back to `photo_url`.
  List<String> get mediaUrls {
    final out = <String>[];
    final media = raw['media'];
    if (media is List) {
      for (final m in media) {
        if (m is Map) {
          final url = _str(m['url']);
          if (url.isNotEmpty) out.add(url);
        }
      }
    }
    if (out.isEmpty && photoUrl.isNotEmpty) out.add(photoUrl);
    return out;
  }
  String get status => _str(raw['status']);
  int get upvoteCount => _int(raw['upvote_count']);
  double get ratingAverage => _dbl(raw['rating_average']);
  int get ratingCount => _int(raw['rating_count']);
  String get reporterName => _fullName(raw['user']);

  bool get isResolved => status == 'resolved' || status == 'closed';

  // ── Citizen verification flags ──────────────────────────────────────
  /// Whether the authority has marked this grievance resolved.
  bool get resolved => raw['resolved'] == true || isResolved;

  /// Whether the reporter has confirmed the resolution.
  bool get verified => raw['verified'] == true;

  /// Resolved but waiting for the reporter to confirm.
  bool get awaitingCitizenVerification =>
      raw['awaiting_citizen_verification'] == true;

  /// Whether the current user is allowed to verify right now.
  bool get canVerify => raw['can_verify'] == true;

  String get resolvedAtLabel {
    final r = _str(raw['resolved_at']);
    if (r.isEmpty) return '';
    final dt = DateTime.tryParse(r)?.toLocal();
    return dt == null ? r : DateFormat('d MMM yyyy, h:mm a').format(dt);
  }

  String get statusLabel {
    final s = status.replaceAll('_', ' ');
    return s.isEmpty ? 'Open' : s[0].toUpperCase() + s.substring(1);
  }

  String get categoryLabel {
    final s = category.replaceAll('_', ' ');
    return s.isEmpty ? '' : s[0].toUpperCase() + s.substring(1);
  }

  String get createdLabel {
    final c = _str(raw['created_at']);
    final dt = c.isEmpty ? null : DateTime.tryParse(c)?.toLocal();
    return dt == null ? '' : DateFormat('d MMM yyyy, h:mm a').format(dt);
  }

  factory NagarikGrievance.fromMap(Map<String, dynamic> j) =>
      NagarikGrievance(j);

  static NagarikGrievance fromResponse(dynamic src) =>
      NagarikGrievance((_data(src) as Map).cast<String, dynamic>());

  static List<NagarikGrievance> listFromResponse(dynamic src) {
    final d = _data(src);
    final list = d is List ? d : const [];
    return list
        .whereType<Map>()
        .map((e) => NagarikGrievance(e.cast<String, dynamic>()))
        .toList();
  }
}

// ── Ticket ──────────────────────────────────────────────────────────
class NagarikTicket {
  NagarikTicket(this.raw);
  final Map<String, dynamic> raw;

  String get id => _str(raw['id']);
  String get category => _str(raw['category']);
  String get subject => _str(raw['subject']);
  String get description => _str(raw['description']);
  String get status => _str(raw['status']);
  String get priority => _str(raw['priority']);

  bool get isResolved => status == 'resolved' || status == 'closed';

  String get statusLabel {
    final s = status.replaceAll('_', ' ');
    return s.isEmpty ? 'Open' : s[0].toUpperCase() + s.substring(1);
  }

  String get categoryLabel {
    final s = category.replaceAll('_', ' ');
    return s.isEmpty ? '' : s[0].toUpperCase() + s.substring(1);
  }

  String get createdLabel {
    final c = _str(raw['created_at']);
    final dt = c.isEmpty ? null : DateTime.tryParse(c)?.toLocal();
    return dt == null ? '' : DateFormat('d MMM, h:mm a').format(dt);
  }

  /// Citizen's name from the embedded user.profile (detail endpoint).
  String get userName {
    final user = raw['user'] is Map ? raw['user'] as Map : const {};
    final profile = user['profile'] is Map ? user['profile'] as Map : const {};
    return _str(profile['full_name']);
  }

  List<NagarikMessage> get messages {
    final m = raw['messages'];
    if (m is! List) return [];
    return m
        .whereType<Map>()
        .map((e) => NagarikMessage(e.cast<String, dynamic>()))
        .toList();
  }

  factory NagarikTicket.fromMap(Map<String, dynamic> j) => NagarikTicket(j);

  static NagarikTicket fromResponse(dynamic src) =>
      NagarikTicket((_data(src) as Map).cast<String, dynamic>());

  static List<NagarikTicket> listFromResponse(dynamic src) {
    final d = _data(src);
    final list = d is List ? d : const [];
    return list
        .whereType<Map>()
        .map((e) => NagarikTicket(e.cast<String, dynamic>()))
        .toList();
  }
}

// ── Ticket message ──────────────────────────────────────────────────
class NagarikMessage {
  NagarikMessage(this.raw);
  final Map<String, dynamic> raw;

  String get id => _str(raw['id']);
  String get ticketId => _str(raw['ticket_id']);
  String get senderId => _str(raw['sender_id']);
  String get message => _str(raw['message']);
  String get senderName => _fullName(raw['sender']);
  String get senderRole =>
      raw['sender'] is Map ? _str((raw['sender'] as Map)['role']) : '';

  DateTime? get createdAt {
    final c = _str(raw['created_at']);
    return c.isEmpty ? null : DateTime.tryParse(c)?.toLocal();
  }

  String get timeLabel {
    final dt = createdAt;
    return dt == null ? '' : DateFormat('h:mm a').format(dt);
  }

  factory NagarikMessage.fromMap(Map<String, dynamic> j) => NagarikMessage(j);

  static NagarikMessage fromResponse(dynamic src) =>
      NagarikMessage((_data(src) as Map).cast<String, dynamic>());

  static List<NagarikMessage> listFromResponse(dynamic src) {
    final d = _data(src);
    final list = d is List ? d : const [];
    return list
        .whereType<Map>()
        .map((e) => NagarikMessage(e.cast<String, dynamic>()))
        .toList();
  }
}
