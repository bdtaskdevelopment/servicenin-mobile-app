import 'dart:convert';

import 'package:intl/intl.dart';

dynamic _dec(dynamic src) => src is String ? jsonDecode(src) : src;
String _str(dynamic v) => v?.toString().trim() ?? '';

dynamic _data(dynamic src) {
  final d = _dec(src);
  return d is Map && d.containsKey('data') ? d['data'] : d;
}

/// A service the admin has made available — citizens pick one when they
/// submit a funeral request.
class FuneralService {
  FuneralService({
    required this.id,
    required this.name,
    required this.description,
  });

  final String id;
  final String name;
  final String description;

  factory FuneralService.fromMap(Map<String, dynamic> j) => FuneralService(
        id: _str(j['id']),
        name: _str(j['name']),
        description: _str(j['description']),
      );

  static List<FuneralService> listFromResponse(dynamic src) {
    final d = _data(src);
    final list = d is List ? d : const [];
    return list
        .whereType<Map>()
        .map((e) => FuneralService.fromMap(e.cast<String, dynamic>()))
        .toList();
  }
}

/// A support-center number the admin configured for the funeral module —
/// the same shape the ambulance hotlines use.
class FuneralHotline {
  FuneralHotline({required this.label, required this.number});

  final String label;
  final String number;

  factory FuneralHotline.fromMap(Map<String, dynamic> j) => FuneralHotline(
        label: _str(j['label']),
        number: _str(j['number']),
      );

  static List<FuneralHotline> listFromResponse(dynamic src) {
    final d = _data(src);
    final list = d is List ? d : const [];
    return list
        .whereType<Map>()
        .map((e) => FuneralHotline.fromMap(e.cast<String, dynamic>()))
        .where((h) => h.number.isNotEmpty)
        .toList();
  }
}

/// A citizen's funeral service request — flat: who's asking, which
/// service, and how to reach them. Status is set by the admin and moves
/// forward through pending → assigned → in_progress → completed/cancelled.
class FuneralRequest {
  FuneralRequest(this.raw);
  final Map<String, dynamic> raw;

  String get id => _str(raw['id']);
  String get serviceId => _str(raw['service_id']);
  String get serviceName => _str(raw['service_name']);
  String get name => _str(raw['name']);
  String get address => _str(raw['address']);
  String get phone => _str(raw['phone']);
  String get notes => _str(raw['notes']);
  String get status => _str(raw['status']);

  // ── Assigned staff ────────────────────────────────────────────────
  //
  // Read from the flat staff_* snapshot the server writes onto the request,
  // NOT from the nested `staff` object: that object disappears once a staff
  // member is removed from the team, and the family must still be able to see
  // and call whoever handled their request. `designation` has no snapshot, so
  // it falls back to the nested object and is simply absent afterwards.
  String get staffName => _str(raw['staff_name']);
  String get staffPhone => _str(raw['staff_phone']);
  String get staffPhoto => _str(raw['staff_photo']);

  String get staffDesignation {
    final s = raw['staff'];
    return s is Map ? _str(s['designation']) : '';
  }

  /// True once someone is assigned and reachable — what the UI gates on.
  bool get hasStaff => staffName.isNotEmpty || staffPhone.isNotEmpty;

  String get assignedLabel {
    final at = _str(raw['assigned_at']);
    final dt = at.isEmpty ? null : DateTime.tryParse(at)?.toLocal();
    return dt == null ? '' : DateFormat('d MMM, h:mm a').format(dt);
  }

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'assigned':
        return 'Assigned';
      case 'in_progress':
        return 'In progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status.isEmpty ? 'Pending' : status;
    }
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
