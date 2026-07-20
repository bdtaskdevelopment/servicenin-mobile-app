import 'dart:convert';

dynamic _decode(dynamic src) => src is String ? jsonDecode(src) : src;

/// A single civic-information / hotline entry from `/api/v1/info`.
class InfoEntry {
  InfoEntry({
    required this.id,
    required this.domain,
    required this.subtype,
    required this.category,
    required this.title,
    required this.titleBn,
    required this.description,
    required this.descriptionBn,
    required this.hotline,
    required this.phone,
    required this.address,
    required this.division,
    required this.district,
    required this.officeHours,
    required this.isEmergency,
    required this.isActive,
    required this.verified,
    required this.sortOrder,
    required this.logoUrl,
    required this.contactPerson,
    required this.phone2,
    required this.fax,
    required this.email,
    required this.website,
    required this.facebookPage,
    required this.whatsapp,
    required this.upazila,
    required this.wardNo,
    required this.mapUrl,
    required this.ministry,
    required this.emergencyContact,
    required this.specialization,
    required this.serviceArea,
    required this.availableServices,
  });

  final String id;
  final String domain;
  final String subtype;
  final String category;
  final String title;
  final String titleBn;
  final String description;
  final String descriptionBn;
  final String hotline;
  final String phone;
  final String address;
  final String division;
  final String district;
  final String officeHours;
  final bool isEmergency;
  final bool isActive;
  final bool verified;
  final int sortOrder;

  // ── Richer fields (detail page only — the list endpoint omits most of
  // these when empty, but they're always parsed if present) ────────────
  final String logoUrl;
  final String contactPerson;
  final String phone2;
  final String fax;
  final String email;
  final String website;
  final String facebookPage;
  final String whatsapp;
  final String upazila;
  final String wardNo;
  final String mapUrl;
  final String ministry;
  final String emergencyContact;
  final String specialization;
  final String serviceArea;
  final String availableServices;

  bool get isNationalEmergency => subtype == 'national_emergency';

  /// The number to dial — hotline takes precedence, then phone.
  String get callNumber => hotline.isNotEmpty ? hotline : phone;

  /// Readable category label, e.g. "govt_hospital" → "Govt hospital".
  String get typeLabel {
    final src = subtype.isNotEmpty ? subtype : category;
    final s = src.replaceAll('_', ' ');
    return s.isEmpty ? '' : s[0].toUpperCase() + s.substring(1);
  }

  factory InfoEntry.fromMap(Map<String, dynamic> json) {
    String str(dynamic v) => v?.toString().trim() ?? '';
    return InfoEntry(
      id: str(json['id']),
      domain: str(json['domain']),
      subtype: str(json['subtype']),
      category: str(json['category']),
      title: str(json['title']),
      titleBn: str(json['title_bn']),
      description: str(json['description']),
      descriptionBn: str(json['description_bn']),
      hotline: str(json['hotline']),
      phone: str(json['phone']),
      address: str(json['address']),
      division: str(json['division']),
      district: str(json['district']),
      officeHours: str(json['office_hours']),
      isEmergency: json['is_emergency'] == true,
      isActive: json['is_active'] == true,
      verified: json['verified'] == true,
      sortOrder: json['sort_order'] is int
          ? json['sort_order'] as int
          : int.tryParse(str(json['sort_order'])) ?? 0,
      logoUrl: str(json['logo_url']),
      contactPerson: str(json['contact_person']),
      phone2: str(json['phone2']),
      fax: str(json['fax']),
      email: str(json['email']),
      website: str(json['website']),
      facebookPage: str(json['facebook_page']),
      whatsapp: str(json['whatsapp']),
      upazila: str(json['upazila']),
      wardNo: str(json['ward_no']),
      mapUrl: str(json['map_url']),
      ministry: str(json['ministry']),
      emergencyContact: str(json['emergency_contact']),
      specialization: str(json['specialization']),
      serviceArea: str(json['service_area']),
      availableServices: str(json['available_services']),
    );
  }

  /// Parses the list endpoint, which returns either a bare JSON array or an
  /// envelope `{ success, message, data: [...] }`.
  static List<InfoEntry> listFromResponse(dynamic src) {
    final decoded = _decode(src);
    final list = decoded is Map
        ? (decoded['data'] is List ? decoded['data'] as List : const [])
        : (decoded is List ? decoded : const []);
    return list
        .whereType<Map>()
        .map((e) => InfoEntry.fromMap(e.cast<String, dynamic>()))
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  /// Parses the single-entry endpoint envelope `{ success, message, data }`.
  static InfoEntry fromResponse(dynamic src) {
    final decoded = _decode(src);
    final data = decoded is Map && decoded['data'] is Map
        ? decoded['data'] as Map
        : decoded as Map;
    return InfoEntry.fromMap(data.cast<String, dynamic>());
  }
}

/// A directory category ("domain") from `/api/v1/info/domains` — e.g.
/// Emergency, Government, Health, Utility, Other.
class InfoDomain {
  InfoDomain({
    required this.key,
    required this.label,
    required this.labelBn,
    required this.emoji,
    required this.sortOrder,
  });

  final String key;
  final String label;
  final String labelBn;
  final String emoji;
  final int sortOrder;

  factory InfoDomain.fromMap(Map<String, dynamic> json) {
    String str(dynamic v) => v?.toString().trim() ?? '';
    return InfoDomain(
      key: str(json['key']),
      label: str(json['label']),
      labelBn: str(json['label_bn']),
      emoji: str(json['emoji']),
      sortOrder: json['sort_order'] is int
          ? json['sort_order'] as int
          : int.tryParse(str(json['sort_order'])) ?? 0,
    );
  }

  static List<InfoDomain> listFromResponse(dynamic src) {
    final decoded = _decode(src);
    final list = decoded is Map
        ? (decoded['data'] is List ? decoded['data'] as List : const [])
        : (decoded is List ? decoded : const []);
    return list
        .whereType<Map>()
        .map((e) => InfoDomain.fromMap(e.cast<String, dynamic>()))
        .toList();
  }
}
