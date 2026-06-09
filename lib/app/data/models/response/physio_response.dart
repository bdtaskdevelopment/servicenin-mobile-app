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

// ── Concern ─────────────────────────────────────────────────────────
class PhysioConcernModel {
  PhysioConcernModel({
    required this.key,
    required this.label,
    required this.description,
    required this.icon,
  });
  final String key;
  final String label;
  final String description;
  final String icon;

  factory PhysioConcernModel.fromMap(Map<String, dynamic> j) =>
      PhysioConcernModel(
        key: _str(j['key']),
        label: _str(j['label']),
        description: _str(j['description']),
        icon: _str(j['icon']),
      );

  /// Parses `{ data: { concerns: [...] } }`.
  static List<PhysioConcernModel> listFromResponse(dynamic src) {
    final d = _data(src);
    final list =
        d is Map && d['concerns'] is List ? d['concerns'] as List : const [];
    return list
        .whereType<Map>()
        .map((e) => PhysioConcernModel.fromMap(e.cast<String, dynamic>()))
        .toList();
  }
}

// ── Staff (therapist) ───────────────────────────────────────────────
class PhysioStaff {
  PhysioStaff({
    required this.id,
    required this.centerId,
    required this.fullName,
    required this.specialization,
    required this.phone,
    required this.bio,
    required this.yearsExp,
    required this.schedule,
    required this.slotMinutes,
    required this.isAvailable,
  });

  final String id;
  final String centerId;
  final String fullName;
  final String specialization;
  final String phone;
  final String bio;
  final int yearsExp;
  final String schedule;
  final int slotMinutes;
  final bool isAvailable;

  String get initials {
    final clean = fullName.replaceAll(
        RegExp(r'^(Dr\.?|Md\.?|ডা\.?)\s*', caseSensitive: false), '');
    final parts =
        clean.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'T';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  factory PhysioStaff.fromMap(Map<String, dynamic> j) => PhysioStaff(
        id: _str(j['id']),
        centerId: _str(j['center_id']),
        fullName: _str(j['full_name']),
        specialization: _str(j['specialization']),
        phone: _str(j['phone']),
        bio: _str(j['bio']),
        yearsExp: _int(j['years_exp']),
        schedule: _str(j['schedule']),
        slotMinutes: _int(j['slot_minutes']),
        isAvailable: j['is_available'] == true,
      );

  static List<PhysioStaff> listFromResponse(dynamic src) {
    final d = _data(src);
    final list = d is List ? d : const [];
    return list
        .whereType<Map>()
        .map((e) => PhysioStaff.fromMap(e.cast<String, dynamic>()))
        .toList();
  }

  static List<PhysioStaff> listFrom(dynamic list) =>
      (list is List ? list : const [])
          .whereType<Map>()
          .map((e) => PhysioStaff.fromMap(e.cast<String, dynamic>()))
          .toList();
}

// ── Center ──────────────────────────────────────────────────────────
class PhysioCenterModel {
  PhysioCenterModel({
    required this.id,
    required this.name,
    required this.address,
    required this.contactPhone,
    required this.email,
    required this.description,
    required this.wardNo,
    required this.matchingTherapists,
    required this.matchCount,
  });

  final String id;
  final String name;
  final String address;
  final String contactPhone;
  final String email;
  final String description;
  final String wardNo;
  final List<PhysioStaff> matchingTherapists;
  final int matchCount;

  factory PhysioCenterModel.fromMap(Map<String, dynamic> j) =>
      PhysioCenterModel(
        id: _str(j['id']),
        name: _str(j['name']),
        address: _str(j['address']),
        contactPhone: _str(j['contact_phone']),
        email: _str(j['email']),
        description: _str(j['description']),
        wardNo: _str(j['ward_no']),
        matchingTherapists:
            PhysioStaff.listFrom(j['matching_therapists']),
        matchCount: _int(j['match_count']),
      );

  static List<PhysioCenterModel> listFromResponse(dynamic src) {
    final d = _data(src);
    final list = d is List ? d : const [];
    return list
        .whereType<Map>()
        .map((e) => PhysioCenterModel.fromMap(e.cast<String, dynamic>()))
        .toList();
  }

  /// Parses `{ data: { centers: [...] } }` (concern-centers endpoint).
  static List<PhysioCenterModel> centersFromResponse(dynamic src) {
    final d = _data(src);
    final list =
        d is Map && d['centers'] is List ? d['centers'] as List : (d is List ? d : const []);
    return list
        .whereType<Map>()
        .map((e) => PhysioCenterModel.fromMap(e.cast<String, dynamic>()))
        .toList();
  }

  static PhysioCenterModel fromResponse(dynamic src) =>
      PhysioCenterModel.fromMap((_data(src) as Map).cast<String, dynamic>());
}

// ── Visit type / payment method (same shape) ────────────────────────
class PhysioOption {
  PhysioOption({
    required this.key,
    required this.label,
    required this.description,
    required this.enabled,
  });
  final String key;
  final String label;
  final String description;
  final bool enabled;

  factory PhysioOption.fromMap(Map<String, dynamic> j) => PhysioOption(
        key: _str(j['key']),
        label: _str(j['label']),
        description: _str(j['description']),
        enabled: j['enabled'] == true,
      );

  static List<PhysioOption> fromResponse(dynamic src, String listKey) {
    final d = _data(src);
    final list = d is Map && d[listKey] is List ? d[listKey] as List : const [];
    return list
        .whereType<Map>()
        .map((e) => PhysioOption.fromMap(e.cast<String, dynamic>()))
        .toList();
  }

  static String defaultKey(dynamic src) {
    final d = _data(src);
    return d is Map ? _str(d['default']) : '';
  }
}

// ── Schedule date ───────────────────────────────────────────────────
class PhysioScheduleDate {
  PhysioScheduleDate(
      {required this.date, required this.day, required this.label});
  final String date;
  final String day;
  final String label;

  String get dayShort => day.isEmpty
      ? ''
      : day[0].toUpperCase() + (day.length > 1 ? day.substring(1) : '');

  factory PhysioScheduleDate.fromMap(Map<String, dynamic> j) =>
      PhysioScheduleDate(
        date: _str(j['date']),
        day: _str(j['day']),
        label: _str(j['label']),
      );

  static List<PhysioScheduleDate> listFromResponse(dynamic src) {
    final d = _data(src);
    final list = d is Map && d['dates'] is List ? d['dates'] as List : const [];
    return list
        .whereType<Map>()
        .map((e) => PhysioScheduleDate.fromMap(e.cast<String, dynamic>()))
        .toList();
  }
}

// ── Time slot ───────────────────────────────────────────────────────
class PhysioTimeSlot {
  PhysioTimeSlot({
    required this.time,
    required this.scheduledAt,
    required this.available,
    required this.isBooked,
  });
  final String time;
  final String scheduledAt; // "2026-06-09 09:00"
  final bool available;
  final bool isBooked;

  factory PhysioTimeSlot.fromMap(Map<String, dynamic> j) => PhysioTimeSlot(
        time: _str(j['time']),
        scheduledAt: _str(j['scheduled_at']),
        available: j['available'] == true,
        isBooked: j['is_booked'] == true,
      );

  static List<PhysioTimeSlot> listFromResponse(dynamic src) {
    final d = _data(src);
    final list = d is Map && d['slots'] is List ? d['slots'] as List : const [];
    return list
        .whereType<Map>()
        .map((e) => PhysioTimeSlot.fromMap(e.cast<String, dynamic>()))
        .toList();
  }
}

// ── Appointment ─────────────────────────────────────────────────────
class PhysioAppointment {
  PhysioAppointment({
    required this.id,
    required this.staffId,
    required this.centerId,
    required this.appointmentType,
    required this.concern,
    required this.status,
    required this.amount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.notes,
    required this.staffName,
    required this.centerName,
    this.scheduledAt,
  });

  final String id;
  final String staffId;
  final String centerId;
  final String appointmentType;
  final String concern;
  final String status;
  final int amount;
  final String paymentMethod;
  final String paymentStatus;
  final String notes;
  final String staffName;
  final String centerName;
  final DateTime? scheduledAt;

  bool get upcoming {
    final s = status.toLowerCase();
    return s != 'completed' && s != 'cancelled' && s != 'canceled';
  }

  String get whenLabel {
    final dt = scheduledAt?.toLocal();
    return dt == null ? '' : DateFormat('d MMM · h:mm a').format(dt);
  }

  factory PhysioAppointment.fromMap(Map<String, dynamic> j) {
    final staff = j['staff'] is Map ? j['staff'] as Map : const {};
    final center = j['center'] is Map ? j['center'] as Map : const {};
    final sched = _str(j['scheduled_at']);
    // API uses "2026-06-11 09:00" (space). Make it ISO-parseable.
    final iso = sched.contains(' ') ? sched.replaceFirst(' ', 'T') : sched;
    return PhysioAppointment(
      id: _str(j['id']),
      staffId: _str(j['staff_id']),
      centerId: _str(j['center_id']),
      appointmentType: _str(j['appointment_type']),
      concern: _str(j['concern']),
      status: _str(j['status']),
      amount: _int(j['amount']),
      paymentMethod: _str(j['payment_method']),
      paymentStatus: _str(j['payment_status']),
      notes: _str(j['notes']),
      staffName: _str(staff['full_name']),
      centerName: _str(center['name']),
      scheduledAt: iso.isEmpty ? null : DateTime.tryParse(iso),
    );
  }

  static PhysioAppointment fromResponse(dynamic src) =>
      PhysioAppointment.fromMap((_data(src) as Map).cast<String, dynamic>());

  static List<PhysioAppointment> listFromResponse(dynamic src) {
    final d = _data(src);
    final list = d is List ? d : const [];
    return list
        .whereType<Map>()
        .map((e) => PhysioAppointment.fromMap(e.cast<String, dynamic>()))
        .toList();
  }
}
