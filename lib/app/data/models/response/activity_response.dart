import 'dart:convert';

import 'package:intl/intl.dart';

dynamic _decode(dynamic src) => src is String ? jsonDecode(src) : src;

/// A single entry from `/api/v1/users/me/activity`.
class ActivityItem {
  ActivityItem({
    required this.module,
    required this.type,
    required this.title,
    required this.refId,
    this.status,
    this.createdAt,
  });

  final String module;
  final String type;
  final String title;
  final String refId;
  final String? status;
  final DateTime? createdAt;

  factory ActivityItem.fromMap(Map<String, dynamic> json) {
    String str(dynamic v) => v?.toString().trim() ?? '';
    final created = str(json['created_at']);
    return ActivityItem(
      module: str(json['module']),
      type: str(json['type']),
      title: str(json['title']),
      refId: str(json['ref_id']),
      status: () {
        final s = str(json['status']);
        return s.isEmpty ? null : s;
      }(),
      createdAt: created.isEmpty ? null : DateTime.tryParse(created),
    );
  }

  /// Relative time for the card subtitle, e.g. "Today 5:58 PM" or "3 days ago".
  String get displayTime {
    final dt = createdAt?.toLocal();
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    final sameDay =
        now.year == dt.year && now.month == dt.month && now.day == dt.day;
    if (sameDay) return 'Today ${DateFormat('h:mm a').format(dt)}';
    if (diff.inDays < 2) return 'Yesterday ${DateFormat('h:mm a').format(dt)}';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return DateFormat('d MMM').format(dt);
  }
}

/// Parsed `/api/v1/users/me/activity` response.
class ActivityResponse {
  ActivityResponse({
    required this.activities,
    required this.total,
    required this.days,
  });

  final List<ActivityItem> activities;
  final int total;
  final int days;

  factory ActivityResponse.fromMap(dynamic src) {
    final decoded = _decode(src);
    final data = decoded is Map && decoded['data'] is Map
        ? decoded['data'] as Map
        : (decoded is Map ? decoded : const {});
    final list = data['activities'] is List ? data['activities'] as List : const [];
    int asInt(dynamic v) =>
        v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
    return ActivityResponse(
      activities: list
          .whereType<Map>()
          .map((e) => ActivityItem.fromMap(e.cast<String, dynamic>()))
          .toList(),
      total: asInt(data['total']),
      days: asInt(data['days']),
    );
  }
}
