import 'dart:convert';

import 'package:intl/intl.dart';

dynamic _dec(dynamic src) => src is String ? jsonDecode(src) : src;
String _str(dynamic v) => v?.toString().trim() ?? '';
int _int(dynamic v) =>
    v is int ? v : int.tryParse(_str(v)) ?? (v is num ? v.toInt() : 0);

dynamic _data(dynamic src) {
  final d = _dec(src);
  return d is Map && d.containsKey('data') ? d['data'] : d;
}

// ── Coordinator ─────────────────────────────────────────────────────
class FuneralCoordinator {
  FuneralCoordinator({
    required this.name,
    required this.phone,
    required this.altPhone,
    required this.whatsapp,
    required this.hotline,
    required this.email,
    required this.available,
    required this.description,
  });

  final String name;
  final String phone;
  final String altPhone;
  final String whatsapp;
  final String hotline;
  final String email;
  final String available;
  final String description;

  factory FuneralCoordinator.fromResponse(dynamic src) {
    final d = _data(src);
    final m = d is Map ? d : const {};
    return FuneralCoordinator(
      name: _str(m['name']),
      phone: _str(m['phone']),
      altPhone: _str(m['alt_phone']),
      whatsapp: _str(m['whatsapp']),
      hotline: _str(m['hotline']),
      email: _str(m['email']),
      available: _str(m['available']),
      description: _str(m['description']),
    );
  }
}

// ── Service option ──────────────────────────────────────────────────
class FuneralServiceOption {
  FuneralServiceOption({
    required this.key,
    required this.label,
    required this.description,
    required this.icon,
    required this.priceFrom,
  });

  final String key;
  final String label;
  final String description;
  final String icon;
  final int priceFrom;

  String get priceLabel => priceFrom > 0 ? 'From ৳$priceFrom' : '';

  factory FuneralServiceOption.fromMap(Map<String, dynamic> j) =>
      FuneralServiceOption(
        key: _str(j['key']),
        label: _str(j['label']),
        description: _str(j['description']),
        icon: _str(j['icon']),
        priceFrom: _int(j['price_from']),
      );

  /// Parses `{ data: { services: [...] } }`.
  static List<FuneralServiceOption> listFromResponse(dynamic src) {
    final d = _data(src);
    final list = d is Map && d['services'] is List
        ? d['services'] as List
        : (d is List ? d : const []);
    return list
        .whereType<Map>()
        .map((e) => FuneralServiceOption.fromMap(e.cast<String, dynamic>()))
        .toList();
  }
}

// ── Unit ────────────────────────────────────────────────────────────
class FuneralUnitModel {
  FuneralUnitModel({
    required this.id,
    required this.name,
    required this.unitType,
    required this.registrationNo,
    required this.driverName,
    required this.driverPhone,
    required this.isAvailable,
    required this.notes,
  });

  final String id;
  final String name;
  final String unitType;
  final String registrationNo;
  final String driverName;
  final String driverPhone;
  final bool isAvailable;
  final String notes;

  String get typeLabel {
    final s = unitType.replaceAll('_', ' ');
    return s.isEmpty ? '' : s[0].toUpperCase() + s.substring(1);
  }

  factory FuneralUnitModel.fromMap(Map<String, dynamic> j) => FuneralUnitModel(
        id: _str(j['id']),
        name: _str(j['name']),
        unitType: _str(j['unit_type']),
        registrationNo: _str(j['registration_no']),
        driverName: _str(j['driver_name']),
        driverPhone: _str(j['driver_phone']),
        isAvailable: j['is_available'] == true,
        notes: _str(j['notes']),
      );

  static List<FuneralUnitModel> listFromResponse(dynamic src) {
    final d = _data(src);
    final list = d is List ? d : const [];
    return list
        .whereType<Map>()
        .map((e) => FuneralUnitModel.fromMap(e.cast<String, dynamic>()))
        .toList();
  }
}

// ── Request ─────────────────────────────────────────────────────────
class FuneralRequest {
  FuneralRequest(this.raw);
  final Map<String, dynamic> raw;

  String get id => _str(raw['id']);
  String get registrationNo => _str(raw['registration_no']);
  String get deceasedName => _str(raw['deceased_name']);
  int get deceasedAge => _int(raw['deceased_age']);
  String get gender => _str(raw['gender']);
  String get placeOfDeath => _str(raw['place_of_death']);
  String get causeOfDeath => _str(raw['cause_of_death']);
  String get address => _str(raw['address']);
  String get wardNo => _str(raw['ward_no']);
  String get serviceType => _str(raw['service_type']);
  String get contactName => _str(raw['contact_name']);
  String get contactPhone => _str(raw['contact_phone']);
  String get status => _str(raw['status']);
  String get workflowStatus => _str(raw['workflow_status']);
  String get scheduledAt => _str(raw['scheduled_at']);

  String get statusLabel {
    final s = status.replaceAll('_', ' ');
    return s.isEmpty ? 'Pending' : s[0].toUpperCase() + s.substring(1);
  }

  String get createdLabel {
    final created = _str(raw['created_at']);
    final dt = created.isEmpty ? null : DateTime.tryParse(created)?.toLocal();
    return dt == null ? '' : DateFormat('d MMM, h:mm a').format(dt);
  }

  factory FuneralRequest.fromMap(Map<String, dynamic> j) => FuneralRequest(j);

  static FuneralRequest fromResponse(dynamic src) =>
      FuneralRequest((_data(src) as Map).cast<String, dynamic>());

  static List<FuneralRequest> listFromResponse(dynamic src) {
    final d = _data(src);
    final list = d is List ? d : const [];
    return list
        .whereType<Map>()
        .map((e) => FuneralRequest(e.cast<String, dynamic>()))
        .toList();
  }
}
