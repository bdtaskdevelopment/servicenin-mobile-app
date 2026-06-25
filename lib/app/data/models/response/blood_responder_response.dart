import 'dart:convert';

dynamic _decode(dynamic src) => src is String ? jsonDecode(src) : src;

/// A donor who responded to a blood request, from
/// `GET /api/v1/blood/requests/:id/responders`.
class BloodResponder {
  BloodResponder({
    required this.id,
    required this.requestId,
    required this.donorId,
    required this.status,
    required this.voiceChannel,
    required this.joinCode,
    required this.distanceKm,
    required this.donorName,
    required this.donorBloodGroup,
    required this.donorPhone,
  });

  /// The fulfillment id — used for chat and the "blood received" confirmation.
  final String id;
  final String requestId;
  final String donorId;
  final String status;
  final String voiceChannel;
  final String joinCode;
  final double distanceKm;
  final String donorName;
  final String donorBloodGroup;
  final String donorPhone;

  String get displayName => donorName.isNotEmpty ? donorName : 'Donor';

  String get initials {
    final parts =
        displayName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return 'D';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  /// "1.8 km away" style label (empty when no distance is known).
  String get distanceLabel =>
      distanceKm > 0 ? '${distanceKm.toStringAsFixed(1)} km away' : '';

  factory BloodResponder.fromMap(Map<String, dynamic> json) {
    String str(dynamic v) => v?.toString().trim() ?? '';
    double dbl(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse(str(v)) ?? 0;

    final donor = json['donor'] is Map ? json['donor'] as Map : const {};
    final user = donor['user'] is Map ? donor['user'] as Map : const {};
    final profile = user['profile'] is Map ? user['profile'] as Map : const {};

    return BloodResponder(
      id: str(json['id']),
      requestId: str(json['request_id']),
      donorId: str(json['donor_id']),
      status: str(json['status']).toLowerCase(),
      voiceChannel: str(json['voice_channel']),
      joinCode: str(json['join_code']),
      distanceKm: dbl(json['distance_km']),
      donorName: str(profile['full_name']),
      donorBloodGroup: str(donor['blood_group']),
      donorPhone: str(user['phone']),
    );
  }

  static List<BloodResponder> listFromResponse(dynamic src) {
    final decoded = _decode(src);
    final list = decoded is Map
        ? (decoded['data'] is List ? decoded['data'] as List : const [])
        : (decoded is List ? decoded : const []);
    return list
        .whereType<Map>()
        .map((e) => BloodResponder.fromMap(e.cast<String, dynamic>()))
        .toList();
  }
}
