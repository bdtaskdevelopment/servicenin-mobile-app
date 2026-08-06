import 'dart:convert';

/// One admin-configured support number: a label ("Booking Help") and the
/// number to dial. Every module's `GET /{module}/hotlines` returns this shape,
/// so a single model and a single screen serve all of them.
class SupportHotline {
  SupportHotline({required this.label, required this.number});

  final String label;
  final String number;

  factory SupportHotline.fromMap(Map<String, dynamic> j) => SupportHotline(
        label: (j['label'] ?? '').toString().trim(),
        number: (j['number'] ?? '').toString().trim(),
      );

  static List<SupportHotline> listFromResponse(dynamic src) {
    final decoded = src is String ? jsonDecode(src) : src;
    final data = decoded is Map && decoded.containsKey('data')
        ? decoded['data']
        : decoded;
    final list = data is List ? data : const [];
    return list
        .whereType<Map>()
        .map((e) => SupportHotline.fromMap(e.cast<String, dynamic>()))
        // A slot the admin left blank is not a contact — drop it here rather
        // than rendering an un-callable row.
        .where((h) => h.number.isNotEmpty)
        .toList();
  }
}
