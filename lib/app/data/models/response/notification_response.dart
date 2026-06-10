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

class AppNotification {
  AppNotification(this.raw);
  final Map<String, dynamic> raw;

  String get id => _str(raw['id']);
  String get title => _str(raw['title']);
  String get body => _str(raw['body']);
  String get type => _str(raw['type']);
  String get referenceId => _str(raw['reference_id']);
  String get referenceType => _str(raw['reference_type']);
  bool get isRead => raw['is_read'] == true;
  set isRead(bool v) => raw['is_read'] = v;

  DateTime? get createdAt {
    final c = _str(raw['created_at']);
    return c.isEmpty ? null : DateTime.tryParse(c)?.toLocal();
  }

  String get timeLabel {
    final dt = createdAt;
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return DateFormat('d MMM').format(dt);
  }

  static List<AppNotification> listFromResponse(dynamic src) {
    final d = _data(src);
    final list = d is List ? d : const [];
    return list
        .whereType<Map>()
        .map((e) => AppNotification(e.cast<String, dynamic>()))
        .toList();
  }

  /// Parses `{ data: { unread: N } }`.
  static int unreadFromResponse(dynamic src) {
    final d = _data(src);
    if (d is Map) return _int(d['unread']);
    return _int(d);
  }
}
