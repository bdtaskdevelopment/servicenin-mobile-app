import 'dart:convert';

import 'package:intl/intl.dart';

dynamic _decode(dynamic src) => src is String ? jsonDecode(src) : src;

/// A blood request from `/api/v1/blood/requests`.
class BloodRequestEntry {
  BloodRequestEntry({
    required this.id,
    required this.requesterId,
    required this.bloodGroup,
    required this.unitsNeeded,
    required this.hospitalName,
    required this.hospitalAddress,
    required this.contactName,
    required this.contactPhone,
    required this.contactEmail,
    required this.urgency,
    required this.status,
    required this.notes,
    required this.requesterName,
    required this.requesterPhone,
    this.requesterPhoto = '',
    this.responseCount = 0,
    this.createdAt,
    this.expiresAt,
    this.neededAt,
    this.lat,
    this.lng,
    this.searchRadiusKm = 0,
  });

  final String id;
  final String requesterId;
  final String bloodGroup;
  final int unitsNeeded;
  final String hospitalName;
  final String hospitalAddress;
  final String contactName;
  final String contactPhone;
  final String contactEmail;
  final String urgency; // critical / urgent / routine
  final String status; // open / fulfilled / ...
  final String notes;
  final String requesterName;
  final String requesterPhone;
  final String requesterPhoto;
  final int responseCount;
  final DateTime? createdAt;
  final DateTime? expiresAt;

  /// When the requester needs the blood (date + time), as chosen on the form.
  final DateTime? neededAt;

  /// "Needed 12 Aug, 3:30 PM" style label for the donor-facing list. Empty
  /// when no date/time was set.
  String get neededLabel {
    final dt = neededAt?.toLocal();
    if (dt == null) return '';
    final now = DateTime.now();
    final sameDay =
        dt.year == now.year && dt.month == now.month && dt.day == now.day;
    final datePart = sameDay ? 'Today' : DateFormat('d MMM').format(dt);
    return '$datePart, ${DateFormat('h:mm a').format(dt)}';
  }

  /// Hospital coordinates + the alert radius the requester chose (km;
  /// 0 = "all over", no distance limit). Used to match requests against the
  /// viewer's current location.
  final double? lat;
  final double? lng;
  final int searchRadiusKm;

  /// Distance (km) from the viewer's current location to this request,
  /// computed client-side after the list loads. Null until set.
  double? distanceKm;

  /// A short "3.2 km" style label, or '' when distance isn't known.
  String get distanceLabel {
    final d = distanceKm;
    if (d == null) return '';
    if (d < 1) return '${(d * 1000).round()} m';
    return '${d.toStringAsFixed(1)} km';
  }

  /// Best display name for the contact person.
  String get contactDisplay =>
      contactName.isNotEmpty ? contactName : (requesterName.isNotEmpty ? requesterName : 'Requester');

  /// Best phone to reach the requester.
  String get phone => contactPhone.isNotEmpty ? contactPhone : requesterPhone;

  /// "8 min ago" / "Today 7:29 PM" style label from [createdAt].
  String get timeAgo {
    final dt = createdAt?.toLocal();
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    if (diff.inDays < 7) return '${diff.inDays} d ago';
    return DateFormat('d MMM').format(dt);
  }

  factory BloodRequestEntry.fromMap(Map<String, dynamic> json) {
    String str(dynamic v) => v?.toString().trim() ?? '';
    int asInt(dynamic v) =>
        v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
    double? asDouble(dynamic v) =>
        v == null ? null : (v is num ? v.toDouble() : double.tryParse('$v'));
    DateTime? date(dynamic v) {
      final s = str(v);
      return s.isEmpty ? null : DateTime.tryParse(s);
    }

    final requester = json['requester'] is Map ? json['requester'] as Map : const {};
    final profile =
        requester['profile'] is Map ? requester['profile'] as Map : const {};

    return BloodRequestEntry(
      id: str(json['id']),
      requesterId: str(json['requester_id']),
      bloodGroup: str(json['blood_group']),
      unitsNeeded: asInt(json['units_needed']),
      hospitalName: str(json['hospital_name']),
      hospitalAddress: str(json['hospital_address']),
      contactName: str(json['contact_name']),
      contactPhone: str(json['contact_phone']),
      contactEmail: str(json['contact_email']),
      urgency: str(json['urgency']).toLowerCase(),
      status: str(json['status']).toLowerCase(),
      notes: str(json['notes']),
      createdAt: date(json['created_at']),
      expiresAt: date(json['expires_at']),
      neededAt: date(json['needed_at']),
      requesterName: str(profile['full_name']),
      requesterPhone: str(requester['phone']),
      requesterPhoto: str(profile['photo_url']),
      responseCount: asInt(json['response_count']),
      lat: asDouble(json['lat']),
      lng: asDouble(json['lng']),
      searchRadiusKm: asInt(json['search_radius_km']),
    );
  }

  /// Human label for the request status (e.g. "open" → "Open").
  String get statusLabel =>
      status.isEmpty ? '' : status[0].toUpperCase() + status.substring(1);

  /// True once the request has been fulfilled / closed.
  bool get isFulfilled {
    final s = status.toLowerCase();
    return s == 'fulfilled' || s == 'completed' || s == 'closed';
  }

  /// Parses a bare array or `{ success, message, data: [...] }`.
  static List<BloodRequestEntry> listFromResponse(dynamic src) {
    final decoded = _decode(src);
    final list = decoded is Map
        ? (decoded['data'] is List ? decoded['data'] as List : const [])
        : (decoded is List ? decoded : const []);
    return list
        .whereType<Map>()
        .map((e) => BloodRequestEntry.fromMap(e.cast<String, dynamic>()))
        .toList();
  }
}
