import 'dart:convert';

dynamic _decode(dynamic src) => src is String ? jsonDecode(src) : src;

/// A blood bank directory entry from `/api/v1/blood/banks`.
class BloodBank {
  BloodBank({
    required this.id,
    required this.name,
    required this.area,
    required this.address,
    required this.phone,
  });

  final String id;
  final String name;
  final String area;
  final String address;
  final String phone;

  factory BloodBank.fromMap(Map<String, dynamic> json) {
    String str(dynamic v) => v?.toString().trim() ?? '';
    return BloodBank(
      id: str(json['id']),
      name: str(json['name']),
      area: str(json['area']),
      address: str(json['address']),
      phone: str(json['phone']),
    );
  }

  /// Parses a bare array or `{ success, message, data: [...] }`.
  static List<BloodBank> listFromResponse(dynamic src) {
    final decoded = _decode(src);
    final list = decoded is Map
        ? (decoded['data'] is List ? decoded['data'] as List : const [])
        : (decoded is List ? decoded : const []);
    return list
        .whereType<Map>()
        .map((e) => BloodBank.fromMap(e.cast<String, dynamic>()))
        .toList();
  }
}
