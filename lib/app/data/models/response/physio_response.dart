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

// ── Service (day-rate catalogue item) ────────────────────────────────
class PhysioServiceItem {
  PhysioServiceItem({
    required this.id,
    required this.name,
    required this.description,
    required this.centerPricePerDay,
    required this.homePricePerDay,
    required this.isActive,
    this.categoryId = '',
    this.categoryName = '',
  });
  final String id;
  final String name;
  final String description;
  // These are now only the service's suggested-default price, kept for
  // back-compat display before a center is chosen — once a center is
  // picked, PhysioCenterModel.centerPricePerDay/homePricePerDay (that
  // center's OWN price) is the number that actually gets charged.
  final int centerPricePerDay;
  final int homePricePerDay;
  final bool isActive;
  final String categoryId;
  final String categoryName;

  factory PhysioServiceItem.fromMap(Map<String, dynamic> j) {
    final cat = j['category'] is Map ? j['category'] as Map : const {};
    return PhysioServiceItem(
      id: _str(j['id']),
      name: _str(j['name']),
      description: _str(j['description']),
      centerPricePerDay: _int(j['center_price_per_day']),
      homePricePerDay: _int(j['home_price_per_day']),
      isActive: j['is_active'] == true,
      categoryId: _str(j['category_id']),
      categoryName: _str(cat['name']),
    );
  }

  static List<PhysioServiceItem> listFromResponse(dynamic src) {
    final d = _data(src);
    final list = d is List ? d : const [];
    return list
        .whereType<Map>()
        .map((e) => PhysioServiceItem.fromMap(e.cast<String, dynamic>()))
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

// ── Center-scoped catalog item (new center-first flow) ────────────────
// One center's own priced, enabled offering within one top-level kind
// ("lab"|"patient_care") — GET /physio/centers/:id/services?kind=.
class PhysioCatalogItem {
  PhysioCatalogItem({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.categoryName,
    required this.centerPricePerDay,
    required this.homePricePerDay,
    this.centerPricePerDayDiscount,
    this.homePricePerDayDiscount,
  });
  final String id;
  final String name;
  final String description;
  final String categoryId;
  final String categoryName;
  final int centerPricePerDay;
  final int homePricePerDay;
  // Null means "no discount" — same convention as everywhere else in the
  // app (struck-through original beside the discounted price).
  final int? centerPricePerDayDiscount;
  final int? homePricePerDayDiscount;

  /// The price actually charged for [visitType] ("center"|"home").
  int priceFor(String visitType) {
    final discount = visitType == 'home'
        ? homePricePerDayDiscount
        : centerPricePerDayDiscount;
    if (discount != null && discount > 0) return discount;
    return visitType == 'home' ? homePricePerDay : centerPricePerDay;
  }

  /// The struck-through original price for [visitType], or null when
  /// there's no discount to show.
  int? originalPriceFor(String visitType) {
    final discount = visitType == 'home'
        ? homePricePerDayDiscount
        : centerPricePerDayDiscount;
    final base = visitType == 'home' ? homePricePerDay : centerPricePerDay;
    if (discount != null && discount > 0 && discount < base) return base;
    return null;
  }

  factory PhysioCatalogItem.fromMap(Map<String, dynamic> j) =>
      PhysioCatalogItem(
        id: _str(j['id']),
        name: _str(j['name']),
        description: _str(j['description']),
        categoryId: _str(j['category_id']),
        categoryName: _str(j['category_name']),
        centerPricePerDay: _int(j['center_price_per_day']),
        homePricePerDay: _int(j['home_price_per_day']),
        centerPricePerDayDiscount: j['center_price_per_day_discount'] == null
            ? null
            : _int(j['center_price_per_day_discount']),
        homePricePerDayDiscount: j['home_price_per_day_discount'] == null
            ? null
            : _int(j['home_price_per_day_discount']),
      );

  static List<PhysioCatalogItem> listFromResponse(dynamic src) {
    final d = _data(src);
    final list = d is List ? d : const [];
    return list
        .whereType<Map>()
        .map((e) => PhysioCatalogItem.fromMap(e.cast<String, dynamic>()))
        .toList();
  }
}

// ── Appointment line item (cart-based booking) ─────────────────────────
class PhysioAppointmentItem {
  PhysioAppointmentItem({
    required this.serviceId,
    required this.serviceName,
    required this.unitPrice,
    required this.quantity,
    this.originalPrice,
    this.categoryKind = '',
  });
  final String serviceId;
  final String serviceName;
  final int unitPrice;
  final int? originalPrice;
  final int quantity;
  // 'lab' | 'patient_care' | '' (unknown — e.g. a legacy booking with no
  // category on its service) — read from the nested service.category.kind
  // the backend now includes, so the app can tell a lab-only booking
  // apart from one with therapy/patient-care items.
  final String categoryKind;

  bool get hasDiscount => originalPrice != null && originalPrice! > unitPrice;
  int get lineTotal => unitPrice * quantity;

  factory PhysioAppointmentItem.fromMap(Map<String, dynamic> j) {
    final service = j['service'] is Map ? j['service'] as Map : const {};
    final category =
        service['category'] is Map ? service['category'] as Map : const {};
    return PhysioAppointmentItem(
      serviceId: _str(j['service_id']),
      serviceName: _str(j['service_name']),
      unitPrice: _int(j['unit_price']),
      originalPrice:
          j['original_price'] == null ? null : _int(j['original_price']),
      quantity: j['quantity'] != null ? _int(j['quantity']) : 1,
      categoryKind: _str(category['kind']),
    );
  }

  static List<PhysioAppointmentItem> listFrom(dynamic list) =>
      (list is List ? list : const [])
          .whereType<Map>()
          .map((e) => PhysioAppointmentItem.fromMap(e.cast<String, dynamic>()))
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
    this.centerPricePerDay = 0,
    this.homePricePerDay = 0,
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
  // This center's OWN price for whichever service was used to fetch it
  // (GET /physio/services/:id/centers) — 0 when fetched from an endpoint
  // that doesn't carry pricing (e.g. the plain centers list).
  final int centerPricePerDay;
  final int homePricePerDay;

  factory PhysioCenterModel.fromMap(Map<String, dynamic> j) =>
      PhysioCenterModel(
        id: _str(j['id']),
        name: _str(j['name']),
        address: _str(j['address']),
        contactPhone: _str(j['contact_phone']),
        email: _str(j['email']),
        description: _str(j['description']),
        wardNo: _str(j['ward_no']),
        matchingTherapists: PhysioStaff.listFrom(j['matching_therapists']),
        matchCount: _int(j['match_count']),
        centerPricePerDay: _int(j['center_price_per_day']),
        homePricePerDay: _int(j['home_price_per_day']),
      );

  static List<PhysioCenterModel> listFromResponse(dynamic src) {
    final d = _data(src);
    final list = d is List ? d : const [];
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
    this.serviceId = '',
    this.dayCount = 1,
    this.bookingGroupId = '',
    this.groupTotalAmount = 0,
    this.paidAmount = 0,
    this.patientProfileId = '',
    this.referralNote = '',
    this.items = const [],
    this.kind = '',
    this.reportUrl = '',
    this.reportUploadedAt,
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
  // Day-wise multi-day booking fields — all additive/nullable-safe so a
  // response that doesn't send them (or an older server) still parses.
  final String serviceId;
  final int dayCount;
  final String bookingGroupId;
  final int groupTotalAmount;
  // Partial-payment/free-treatment fields — additive, nullable-safe.
  final int paidAmount;
  final String patientProfileId;
  final String referralNote;
  // Cart line items — populated for the new center-first booking flow.
  // Empty for a legacy single-service booking.
  final List<PhysioAppointmentItem> items;
  // The appointment's own "lab" | "patient_care" split, set once by the
  // server at booking time (see backend models.PhysioAppointment.Kind) —
  // authoritative over isLabOnly's items-derivation below, which only
  // exists as a fallback for a cached/older payload with no `kind`.
  final String kind;
  // Uploaded lab/X-ray report file (signed URL, ready to open) — only
  // ever set when kind == "lab".
  final String reportUrl;
  final DateTime? reportUploadedAt;

  /// A cart booking starts with no therapist/lab technician — true until
  /// the center assigns one (staffId becomes non-empty).
  bool get awaitingAssignment => staffId.isEmpty;

  bool get upcoming {
    final s = status.toLowerCase();
    return s != 'completed' && s != 'cancelled' && s != 'canceled';
  }

  /// True for a lab/X-ray booking. Prefers the server-set `kind` field;
  /// falls back to the old items-derivation (every cart item a lab
  /// service) only when `kind` is empty, for safety against a stale
  /// cached response. Drives "booking" vs "session" wording, the status
  /// pill's labels/colors, and whether a report can show up.
  bool get isLabOnly => kind.isNotEmpty
      ? kind == 'lab'
      : (items.isNotEmpty && items.every((i) => i.categoryKind == 'lab'));

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
      serviceId: _str(j['service_id']),
      dayCount: j['day_count'] != null ? _int(j['day_count']) : 1,
      bookingGroupId: _str(j['booking_group_id']),
      groupTotalAmount: _int(j['group_total_amount']),
      paidAmount: _int(j['paid_amount']),
      patientProfileId: _str(j['patient_profile_id']),
      referralNote: _str(j['referral_note']),
      items: PhysioAppointmentItem.listFrom(j['items']),
      kind: _str(j['kind']),
      reportUrl: _str(j['report_url']),
      reportUploadedAt: j['report_uploaded_at'] == null
          ? null
          : DateTime.tryParse(_str(j['report_uploaded_at'])),
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
