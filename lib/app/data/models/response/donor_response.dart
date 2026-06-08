import 'dart:convert';

import 'package:intl/intl.dart';

dynamic _decode(dynamic src) => src is String ? jsonDecode(src) : src;

/// A donor entry from `/api/v1/blood/donors` and `/api/v1/blood/donors/nearest`.
class DonorEntry {
  DonorEntry({
    required this.id,
    required this.userId,
    required this.bloodGroup,
    required this.totalDonations,
    required this.isAvailable,
    required this.isVerified,
    required this.badgeLevel,
    required this.notes,
    required this.fullName,
    required this.fullNameBn,
    required this.phone,
    required this.address,
    this.lastDonatedAt,
    this.lat,
    this.lng,
  });

  final String id;
  final String userId;
  final String bloodGroup;
  final int totalDonations;
  final bool isAvailable;
  final bool isVerified;
  final String badgeLevel;
  final String notes;
  final DateTime? lastDonatedAt;
  final double? lat;
  final double? lng;

  // Flattened from `user` / `user.profile`.
  final String fullName;
  final String fullNameBn;
  final String phone;
  final String address;

  /// Initials for the avatar fallback, e.g. "Tanvir Ahmed" -> "TA".
  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return 'D';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  /// "Last donated 3 Mar" style label, or empty when never recorded.
  String get lastDonatedLabel {
    final dt = lastDonatedAt?.toLocal();
    if (dt == null) return '';
    return 'Last donated ${DateFormat('d MMM yyyy').format(dt)}';
  }

  factory DonorEntry.fromMap(Map<String, dynamic> json) {
    String str(dynamic v) => v?.toString().trim() ?? '';
    double? dbl(dynamic v) =>
        v == null ? null : (v is num ? v.toDouble() : double.tryParse(v.toString()));

    final user = json['user'] is Map ? json['user'] as Map : const {};
    final profile = user['profile'] is Map ? user['profile'] as Map : const {};
    final last = str(json['last_donated_at']);

    return DonorEntry(
      id: str(json['id']),
      userId: str(json['user_id']),
      bloodGroup:
          str(json['blood_group']).isNotEmpty ? str(json['blood_group']) : str(profile['blood_group']),
      totalDonations: json['total_donations'] is int
          ? json['total_donations'] as int
          : int.tryParse(str(json['total_donations'])) ?? 0,
      isAvailable: json['is_available'] == true,
      isVerified: json['is_verified'] == true || json['otp_verified'] == true,
      badgeLevel: str(json['badge_level']),
      notes: str(json['notes']),
      lastDonatedAt: last.isEmpty ? null : DateTime.tryParse(last),
      lat: dbl(json['lat']),
      lng: dbl(json['lng']),
      fullName: str(profile['full_name']),
      fullNameBn: str(profile['full_name_bn']),
      phone: str(user['phone']),
      address: str(profile['address']),
    );
  }

  /// Parses either a bare array or `{ success, message, data: [...] }`.
  static List<DonorEntry> listFromResponse(dynamic src) {
    final decoded = _decode(src);
    final list = decoded is Map
        ? (decoded['data'] is List ? decoded['data'] as List : const [])
        : (decoded is List ? decoded : const []);
    return list
        .whereType<Map>()
        .map((e) => DonorEntry.fromMap(e.cast<String, dynamic>()))
        .toList();
  }
}
