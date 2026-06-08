import 'dart:convert';

import 'package:intl/intl.dart';

import 'blood_request_response.dart';

dynamic _decode(dynamic src) => src is String ? jsonDecode(src) : src;

/// A donor's own response from `/api/v1/blood/responses/my` (and the create
/// response from `/api/v1/blood/requests/:id/respond`).
class BloodResponseEntry {
  BloodResponseEntry({
    required this.id,
    required this.requestId,
    required this.donorId,
    required this.status,
    required this.otpVerified,
    this.createdAt,
    this.request,
  });

  final String id;
  final String requestId;
  final String donorId;
  final String status; // pending / accepted / verified / ...
  final bool otpVerified;
  final DateTime? createdAt;
  final BloodRequestEntry? request;

  // Convenience pass-throughs from the embedded request.
  String get bloodGroup => request?.bloodGroup ?? '';
  String get hospital => [
        request?.hospitalName ?? '',
        request?.hospitalAddress ?? '',
      ].where((s) => s.isNotEmpty).join(' · ');
  String get requesterName => request?.requesterName ?? '';
  String get phone => request?.phone ?? '';

  String get respondedLabel {
    final dt = createdAt?.toLocal();
    if (dt == null) return '';
    return 'Responded ${DateFormat('d MMM, h:mm a').format(dt)}';
  }

  factory BloodResponseEntry.fromMap(Map<String, dynamic> json) {
    String str(dynamic v) => v?.toString().trim() ?? '';
    final created = str(json['created_at']);
    final request = json['request'] is Map
        ? BloodRequestEntry.fromMap((json['request'] as Map).cast<String, dynamic>())
        : null;
    // The chat endpoint is keyed by the request id; fall back to the nested
    // request's id when the API doesn't echo a top-level `request_id`.
    final requestId =
        str(json['request_id']).isNotEmpty ? str(json['request_id']) : (request?.id ?? '');
    return BloodResponseEntry(
      id: str(json['id']),
      requestId: requestId,
      donorId: str(json['donor_id']),
      status: str(json['status']).toLowerCase(),
      otpVerified: json['otp_verified'] == true,
      createdAt: created.isEmpty ? null : DateTime.tryParse(created),
      request: request,
    );
  }

  /// Parses a bare array or `{ success, message, data: [...] }`.
  static List<BloodResponseEntry> listFromResponse(dynamic src) {
    final decoded = _decode(src);
    final list = decoded is Map
        ? (decoded['data'] is List ? decoded['data'] as List : const [])
        : (decoded is List ? decoded : const []);
    return list
        .whereType<Map>()
        .map((e) => BloodResponseEntry.fromMap(e.cast<String, dynamic>()))
        .toList();
  }
}
