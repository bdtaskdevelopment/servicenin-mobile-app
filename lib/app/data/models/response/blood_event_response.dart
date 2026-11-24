import 'dart:convert';

import 'package:intl/intl.dart';

dynamic _decode(dynamic src) => src is String ? jsonDecode(src) : src;

/// A blood camp / donation drive from `/api/v1/blood/events`.
class BloodEvent {
  BloodEvent({
    required this.id,
    required this.title,
    required this.organizer,
    required this.bannerUrl,
    required this.description,
    required this.location,
    required this.address,
    required this.startAt,
    required this.isFree,
    required this.contactPhone,
    required this.attendeeCount,
    required this.hasJoined,
    this.endAt,
  });

  final String id;
  final String title;
  final String organizer;
  final String bannerUrl;
  final String description;
  final String location;
  final String address;
  final DateTime startAt;
  final DateTime? endAt;
  final bool isFree;
  final String contactPhone;
  final int attendeeCount;
  final bool hasJoined;

  bool get isUpcoming => startAt.toLocal().isAfter(DateTime.now());

  /// "২০ নভেম্বর ২০২৬, শুক্রবার" rendered by the view via `.tr`-wrapped
  /// month/weekday names — this just gives the raw English parts.
  String get dateLabel => DateFormat('d MMM yyyy, EEEE').format(startAt.toLocal());

  String get timeRangeLabel {
    final start = DateFormat('h:mm a').format(startAt.toLocal());
    if (endAt == null) return start;
    final end = DateFormat('h:mm a').format(endAt!.toLocal());
    return '$start - $end';
  }

  factory BloodEvent.fromMap(Map<String, dynamic> json) {
    String str(dynamic v) => v?.toString().trim() ?? '';
    DateTime? date(dynamic v) {
      final s = str(v);
      return s.isEmpty ? null : DateTime.tryParse(s);
    }

    return BloodEvent(
      id: str(json['id']),
      title: str(json['title']),
      organizer: str(json['organizer']),
      bannerUrl: str(json['banner_url']),
      description: str(json['description']),
      location: str(json['location']),
      address: str(json['address']),
      startAt: date(json['start_at']) ?? DateTime.now(),
      endAt: date(json['end_at']),
      isFree: json['is_free'] != false,
      contactPhone: str(json['contact_phone']),
      attendeeCount: json['attendee_count'] is int
          ? json['attendee_count'] as int
          : int.tryParse(str(json['attendee_count'])) ?? 0,
      hasJoined: json['has_joined'] == true,
    );
  }

  static List<BloodEvent> listFromResponse(dynamic src) {
    final decoded = _decode(src);
    final list = decoded is Map
        ? (decoded['data'] is List ? decoded['data'] as List : const [])
        : (decoded is List ? decoded : const []);
    return list
        .whereType<Map>()
        .map((e) => BloodEvent.fromMap(e.cast<String, dynamic>()))
        .toList();
  }

  /// Parses `{ success, message, data: {...} }` for the detail endpoint.
  static BloodEvent? fromResponse(dynamic src) {
    final decoded = _decode(src);
    final data = decoded is Map ? decoded['data'] : null;
    if (data is Map) return BloodEvent.fromMap(data.cast<String, dynamic>());
    return null;
  }
}
