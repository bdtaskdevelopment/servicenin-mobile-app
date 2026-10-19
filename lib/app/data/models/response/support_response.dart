import 'dart:convert';

/// One admin-configured support number: a label ("Booking Help") and the
/// number to dial. Every module's `GET /{module}/hotlines` returns this shape,
/// so a single model and a single screen serve all of them.
class SupportHotline {
  SupportHotline({
    required this.label,
    required this.number,
    this.whatsappUrl = '',
  });

  final String label;
  final String number;

  /// Ready-to-open `https://wa.me/...` link, already built server-side from
  /// the admin-configured WhatsApp number — empty when none is set, in which
  /// case the WhatsApp button simply doesn't render.
  final String whatsappUrl;

  factory SupportHotline.fromMap(Map<String, dynamic> j) => SupportHotline(
        label: (j['label'] ?? '').toString().trim(),
        number: (j['number'] ?? '').toString().trim(),
        whatsappUrl: (j['whatsapp_url'] ?? '').toString().trim(),
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
