import 'dart:convert';

import 'package:intl/intl.dart';

dynamic _decode(dynamic src) => src is String ? jsonDecode(src) : src;

/// A logged donation entry from `/api/v1/blood/donations/me`.
class BloodDonation {
  BloodDonation({
    required this.id,
    required this.donatedAt,
    required this.bags,
    required this.hospitalName,
    required this.photoUrls,
    required this.feeling,
    required this.consentMediaUse,
    required this.suggestion,
    this.requestId,
  });

  final String id;
  final String? requestId;
  final DateTime donatedAt;
  final int bags;
  final String hospitalName;
  final List<String> photoUrls;
  final String feeling;
  final bool consentMediaUse;
  final String suggestion;

  bool get hasPhoto => photoUrls.isNotEmpty;
  String get dateLabel => DateFormat('d MMM yyyy').format(donatedAt.toLocal());

  factory BloodDonation.fromMap(Map<String, dynamic> json) {
    String str(dynamic v) => v?.toString().trim() ?? '';
    DateTime? date(dynamic v) {
      final s = str(v);
      return s.isEmpty ? null : DateTime.tryParse(s);
    }

    final photosRaw = str(json['photo_urls']);
    return BloodDonation(
      id: str(json['id']),
      requestId: str(json['request_id']).isEmpty ? null : str(json['request_id']),
      donatedAt: date(json['donated_at']) ?? DateTime.now(),
      bags: json['bags'] is int ? json['bags'] as int : int.tryParse(str(json['bags'])) ?? 1,
      hospitalName: str(json['hospital_name']),
      photoUrls: photosRaw.isEmpty
          ? const []
          : photosRaw.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
      feeling: str(json['feeling']),
      consentMediaUse: json['consent_media_use'] == true,
      suggestion: str(json['suggestion']),
    );
  }

  static List<BloodDonation> listFromResponse(dynamic src) {
    final decoded = _decode(src);
    final list = decoded is Map
        ? (decoded['data'] is List ? decoded['data'] as List : const [])
        : (decoded is List ? decoded : const []);
    return list
        .whereType<Map>()
        .map((e) => BloodDonation.fromMap(e.cast<String, dynamic>()))
        .toList();
  }
}
