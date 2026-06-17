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
    this.createdAt,
    this.expiresAt,
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
  final DateTime? createdAt;
  final DateTime? expiresAt;

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
      requesterName: str(profile['full_name']),
      requesterPhone: str(requester['phone']),
    );
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
