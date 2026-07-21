import 'dart:convert';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

dynamic _dec(dynamic src) => src is String ? jsonDecode(src) : src;
String _str(dynamic v) => v?.toString().trim() ?? '';

/// Picks the Bangla text when the app language is Bangla (falling back to the
/// English value), otherwise the English text.
String _localized(String en, String bn) {
  final isBn = Get.locale?.languageCode == 'bn';
  if (isBn && bn.isNotEmpty) return bn;
  return en.isNotEmpty ? en : bn;
}
int _int(dynamic v) =>
    v is int ? v : int.tryParse(_str(v)) ?? (v is num ? v.toInt() : 0);
double? _dbl(dynamic v) =>
    v == null ? null : (v is num ? v.toDouble() : double.tryParse(v.toString()));

dynamic _data(dynamic src) {
  final d = _dec(src);
  return d is Map && d.containsKey('data') ? d['data'] : d;
}

// ── Category ────────────────────────────────────────────────────────
class ServiceCategory {
  ServiceCategory({
    required this.id,
    required this.name,
    required this.nameBn,
    required this.iconUrl,
    required this.description,
    required this.basePrice,
    required this.bookingCount,
  });

  final String id;
  final String name;
  final String nameBn;
  final String iconUrl;
  final String description;
  final int basePrice;
  final int bookingCount;

  String get displayName => _localized(name, nameBn);
  String get priceLabel => '৳$basePrice';

  factory ServiceCategory.fromMap(Map<String, dynamic> j) => ServiceCategory(
        id: _str(j['id']),
        name: _str(j['name']),
        nameBn: _str(j['name_bn']),
        iconUrl: _str(j['icon_url']),
        description: _str(j['description']),
        basePrice: _int(j['base_price']),
        bookingCount: _int(j['booking_count']),
      );

  static List<ServiceCategory> listFromResponse(dynamic src) {
    final d = _data(src);
    final list = d is List ? d : const [];
    return list
        .whereType<Map>()
        .map((e) => ServiceCategory.fromMap(e.cast<String, dynamic>()))
        .toList();
  }

  /// Parses the popular envelope `{ data: { services: [...] } }`.
  static List<ServiceCategory> popularFromResponse(dynamic src) {
    final d = _data(src);
    final list = d is Map && d['services'] is List
        ? d['services'] as List
        : (d is List ? d : const []);
    return list
        .whereType<Map>()
        .map((e) => ServiceCategory.fromMap(e.cast<String, dynamic>()))
        .toList();
  }
}

// ── Sub-service ─────────────────────────────────────────────────────
class SubService {
  SubService({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.nameBn,
    required this.description,
    required this.price,
    required this.durationMin,
  });

  final String id;
  final String categoryId;
  final String name;
  final String nameBn;
  final String description;
  final int price;
  final int durationMin;

  String get displayName => _localized(name, nameBn);
  String get durationLabel => durationMin > 0 ? '$durationMin min' : '';

  factory SubService.fromMap(Map<String, dynamic> j) => SubService(
        id: _str(j['id']),
        categoryId: _str(j['category_id']),
        name: _str(j['name']),
        nameBn: _str(j['name_bn']),
        description: _str(j['description']),
        price: _int(j['price']),
        durationMin: _int(j['duration_min']),
      );

  static List<SubService> listFromResponse(dynamic src) {
    final d = _data(src);
    final list = d is List ? d : const [];
    return list
        .whereType<Map>()
        .map((e) => SubService.fromMap(e.cast<String, dynamic>()))
        .toList();
  }
}

// ── Search result ───────────────────────────────────────────────────
class ServiceSearchResult {
  ServiceSearchResult({required this.categories, required this.subServices});
  final List<ServiceCategory> categories;
  final List<SubService> subServices;

  factory ServiceSearchResult.fromResponse(dynamic src) {
    final d = _data(src);
    final map = d is Map ? d : const {};
    final cats = map['categories'] is List ? map['categories'] as List : const [];
    final subs =
        map['sub_services'] is List ? map['sub_services'] as List : const [];
    return ServiceSearchResult(
      categories: cats
          .whereType<Map>()
          .map((e) => ServiceCategory.fromMap(e.cast<String, dynamic>()))
          .toList(),
      subServices: subs
          .whereType<Map>()
          .map((e) => SubService.fromMap(e.cast<String, dynamic>()))
          .toList(),
    );
  }
}

// ── Schedule date ───────────────────────────────────────────────────
class ServiceScheduleDate {
  ServiceScheduleDate(
      {required this.date, required this.day, required this.label});
  final String date; // 2026-06-09
  final String day; // Tue
  final String label; // Today

  factory ServiceScheduleDate.fromMap(Map<String, dynamic> j) =>
      ServiceScheduleDate(
        date: _str(j['date']),
        day: _str(j['day']),
        label: _str(j['label']),
      );

  static List<ServiceScheduleDate> listFromResponse(dynamic src) {
    final d = _data(src);
    final list = d is Map && d['dates'] is List ? d['dates'] as List : const [];
    return list
        .whereType<Map>()
        .map((e) => ServiceScheduleDate.fromMap(e.cast<String, dynamic>()))
        .toList();
  }
}

// ── Time slot ───────────────────────────────────────────────────────
class ServiceTimeSlot {
  ServiceTimeSlot(
      {required this.key, required this.label, required this.available});
  final String key;
  final String label;
  final bool available;

  factory ServiceTimeSlot.fromMap(Map<String, dynamic> j) => ServiceTimeSlot(
        key: _str(j['key']),
        label: _str(j['label']),
        available: j['available'] == true,
      );

  static List<ServiceTimeSlot> listFromResponse(dynamic src) {
    final d = _data(src);
    final list = d is Map && d['slots'] is List ? d['slots'] as List : const [];
    return list
        .whereType<Map>()
        .map((e) => ServiceTimeSlot.fromMap(e.cast<String, dynamic>()))
        .toList();
  }
}

// ── Payment method ──────────────────────────────────────────────────
class ServicePaymentMethod {
  ServicePaymentMethod({
    required this.key,
    required this.label,
    required this.description,
    required this.enabled,
  });
  final String key;
  final String label;
  final String description;
  final bool enabled;

  factory ServicePaymentMethod.fromMap(Map<String, dynamic> j) =>
      ServicePaymentMethod(
        key: _str(j['key']),
        label: _str(j['label']),
        description: _str(j['description']),
        enabled: j['enabled'] == true,
      );

  static List<ServicePaymentMethod> listFromResponse(dynamic src) {
    final d = _data(src);
    final list =
        d is Map && d['methods'] is List ? d['methods'] as List : const [];
    return list
        .whereType<Map>()
        .map((e) => ServicePaymentMethod.fromMap(e.cast<String, dynamic>()))
        .toList();
  }

  static String defaultKey(dynamic src) {
    final d = _data(src);
    return d is Map ? _str(d['default']) : '';
  }
}

// ── Booking ─────────────────────────────────────────────────────────

/// One service job on a booking (a sub-service line, e.g. "AC servicing ×2").
///
/// `id` is what the edit endpoints address — `PATCH`/`DELETE
/// /bookings/{id}/items/{itemId}` take this, not `subServiceId`.
class ServiceBookingItem {
  ServiceBookingItem({
    required this.id,
    required this.subServiceId,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    required this.name,
    required this.status,
    required this.notes,
    required this.addedByRole,
    required this.settled,
    required this.createdAt,
  });
  final String id;
  final String subServiceId;
  final int quantity;
  final int unitPrice;
  final int lineTotal;
  final String name;

  /// Per-job lifecycle, independent of the booking's own status: a
  /// provider can be mid-way through one job while another is still
  /// pending.
  final String status;
  final String notes;

  /// Empty for jobs placed with the original order; `customer`,
  /// `provider` or `admin` for anything added afterwards.
  final String addedByRole;
  final bool settled;
  final DateTime? createdAt;

  bool get addedLater => addedByRole.isNotEmpty;

  /// Mirrors the server's `taskEditable` guard. Once a provider starts a
  /// job it is frozen — changing the quantity underneath them would
  /// rewrite work already done. Kept in sync with serviceitem_repo.go.
  bool get editable {
    if (settled) return false;
    switch (status) {
      case '':
      case 'pending':
      case 'assigned':
      case 'declined':
        return true;
      default:
        return false;
    }
  }

  factory ServiceBookingItem.fromMap(Map<String, dynamic> j) {
    final sub = j['sub_service'] is Map ? j['sub_service'] as Map : const {};
    return ServiceBookingItem(
      id: _str(j['id']),
      subServiceId: _str(j['sub_service_id']),
      quantity: _int(j['quantity']),
      unitPrice: _int(j['unit_price']),
      lineTotal: _int(j['line_total']),
      name: _str(sub['name']),
      status: _str(j['status']),
      notes: _str(j['notes']),
      addedByRole: _str(j['added_by_role']),
      settled: _str(j['settled_at']).isNotEmpty,
      createdAt: DateTime.tryParse(_str(j['created_at'])),
    );
  }
}

/// A stock-tracked part or consumable attached to a booking (engine oil,
/// screws, water). Distinct from [ServiceBookingItem]: those are labour,
/// these are materials drawn from the `ServiceItem` inventory catalogue.
///
/// Quantity is fractional because parts are sold by litre/metre/kg.
class ServiceBookingExtraItem {
  ServiceBookingExtraItem({
    required this.id,
    required this.itemId,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    required this.name,
    required this.unit,
    required this.addedByRole,
    required this.createdAt,
  });
  final String id;
  final String itemId;
  final double quantity;
  final int unitPrice;
  final int lineTotal;
  final String name;
  final String unit;
  final String addedByRole;
  final DateTime? createdAt;

  /// Drops the trailing `.0` on whole quantities so "2 litre" doesn't
  /// render as "2.0 litre".
  String get quantityLabel =>
      quantity == quantity.roundToDouble() ? '${quantity.round()}' : '$quantity';

  String get quantityWithUnit =>
      unit.isEmpty ? quantityLabel : '$quantityLabel $unit';

  factory ServiceBookingExtraItem.fromMap(Map<String, dynamic> j) {
    final it = j['item'] is Map ? j['item'] as Map : const {};
    return ServiceBookingExtraItem(
      id: _str(j['id']),
      itemId: _str(j['item_id']),
      quantity: _dbl(j['quantity']) ?? 0,
      unitPrice: _int(j['unit_price']),
      lineTotal: _int(j['line_total']),
      name: _str(it['name']),
      unit: _str(it['unit']),
      addedByRole: _str(j['added_by_role']),
      createdAt: DateTime.tryParse(_str(j['created_at'])),
    );
  }
}

/// Imposes a stable display order on booking lines.
///
/// The server preloads items without an ORDER BY, and every line created
/// in the original booking shares one `created_at` (they are inserted in a
/// single transaction). Postgres therefore returns them in heap order,
/// which shifts when a row is UPDATEd — so changing one line's quantity
/// can reorder the list. On a screen with per-row +/− buttons that is
/// dangerous: the row under the user's finger moves between taps and the
/// next tap edits a different service.
///
/// Sorting by (createdAt, id) is a total order that never changes, since
/// id breaks the created_at tie deterministically.
List<T> _stableOrder<T>(
  List<T> items,
  DateTime? Function(T) createdAt,
  String Function(T) id,
) {
  final sorted = [...items];
  sorted.sort((a, b) {
    final ca = createdAt(a), cb = createdAt(b);
    if (ca != null && cb != null) {
      final c = ca.compareTo(cb);
      if (c != 0) return c;
    } else if (ca != null) {
      return -1;
    } else if (cb != null) {
      return 1;
    }
    return id(a).compareTo(id(b));
  });
  return sorted;
}

/// A row in the parts catalogue, offered when adding materials to a
/// booking. `stockQty` is live inventory — the server rejects an add that
/// exceeds it, so the picker greys these out rather than letting the
/// request fail.
class ServiceItem {
  ServiceItem({
    required this.id,
    required this.name,
    required this.unit,
    required this.unitPrice,
    required this.stockQty,
  });
  final String id;
  final String name;
  final String unit;
  final int unitPrice;
  final double stockQty;

  bool get inStock => stockQty > 0;

  factory ServiceItem.fromMap(Map<String, dynamic> j) => ServiceItem(
        id: _str(j['id']),
        name: _str(j['name']),
        unit: _str(j['unit']),
        unitPrice: _int(j['unit_price']),
        stockQty: _dbl(j['stock_qty']) ?? 0,
      );

  static List<ServiceItem> listFromResponse(dynamic src) {
    final d = _data(src);
    final list = d is List ? d : const [];
    return list
        .whereType<Map>()
        .map((e) => ServiceItem.fromMap(e.cast<String, dynamic>()))
        .toList();
  }
}

/// The provider assigned to a booking (present once `status == assigned`).
class ServiceBookingProvider {
  ServiceBookingProvider({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.photoUrl,
    required this.rating,
    required this.totalJobs,
    required this.skills,
  });

  final String id;
  final String fullName;
  final String phone;
  final String photoUrl;
  final double rating;
  final int totalJobs;
  final String skills;

  String get displayName => fullName.isNotEmpty ? fullName : 'Service provider';
  String get ratingLabel => rating > 0 ? rating.toStringAsFixed(1) : '—';

  String get initials {
    final parts =
        displayName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return 'SP';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  factory ServiceBookingProvider.fromMap(Map<String, dynamic> j) =>
      ServiceBookingProvider(
        id: _str(j['id']),
        fullName: _str(j['full_name']),
        phone: _str(j['phone']),
        photoUrl: _str(j['photo_url']),
        rating: _dbl(j['rating']) ?? 0,
        totalJobs: _int(j['total_jobs']),
        skills: _str(j['skills']),
      );
}

class ServiceBooking {
  ServiceBooking({
    required this.id,
    required this.categoryId,
    required this.subServiceId,
    required this.address,
    required this.timeSlot,
    required this.status,
    required this.amount,
    required this.subtotal,
    required this.vatRate,
    required this.vatAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.invoiceNo,
    required this.joinCode,
    required this.categoryName,
    required this.subServiceName,
    required this.items,
    required this.extraItems,
    required this.baseAmount,
    required this.promoDiscount,
    required this.settled,
    required this.servicesSummary,
    required this.categoryNames,
    required this.isMultiCategory,
    this.provider,
    this.providerLat,
    this.providerLng,
    this.locationUpdatedAt,
    this.scheduledAt,
    this.createdAt,
  });

  final String id;
  final String categoryId;
  final String subServiceId;
  final String address;
  final String timeSlot;
  final String status;
  final int amount;
  final int subtotal;
  final int vatRate;
  final int vatAmount;
  final String paymentMethod;
  final String paymentStatus;
  final String invoiceNo;
  final String joinCode;
  final String categoryName;
  final String subServiceName;
  final List<ServiceBookingItem> items;
  final List<ServiceBookingExtraItem> extraItems;

  /// Flat call-out fee charged before any line items, frozen at booking
  /// time. Part of the subtotal but not attributable to a job or part.
  final int baseAmount;
  final int promoDiscount;
  final bool settled;
  final String servicesSummary;
  final List<String> categoryNames;
  final bool isMultiCategory;
  final ServiceBookingProvider? provider;
  final double? providerLat;
  final double? providerLng;
  final DateTime? locationUpdatedAt;
  final DateTime? scheduledAt;
  final DateTime? createdAt;

  /// True when the provider has shared a GPS location for live tracking.
  bool get hasProviderLocation => providerLat != null && providerLng != null;

  String get amountLabel => '৳$amount';
  String get subtotalLabel => '৳$subtotal';
  String get vatLabel => '৳$vatAmount';

  String get title => subServiceName.isNotEmpty
      ? subServiceName
      : (categoryName.isNotEmpty ? categoryName : 'Service');

  /// All services on the booking — uses the server `services_summary`
  /// (e.g. "Gas Refill (R-32), Wall cleaning") so multi-category bookings show
  /// every service, falling back to the single title.
  String get servicesLabel =>
      servicesSummary.isNotEmpty ? servicesSummary : title;

  /// Comma-joined category names (e.g. "AC Repair · Home Cleaning").
  String get categoriesLabel => categoryNames.join(' · ');

  String get whenLabel {
    final dt = scheduledAt?.toLocal();
    final date = dt == null ? '' : DateFormat('d MMM, yyyy').format(dt);
    return [date, _slotLabel(timeSlot)].where((s) => s.isNotEmpty).join(' · ');
  }

  static String _slotLabel(String key) {
    switch (key) {
      case 'morning':
        return 'Morning';
      case 'afternoon':
        return 'Afternoon';
      case 'evening':
        return 'Evening';
      default:
        return key;
    }
  }

  bool get ongoing {
    final s = status.toLowerCase();
    return s != 'completed' && s != 'cancelled' && s != 'canceled';
  }

  /// Mirrors the server's `ServiceBooking.IsLocked()`. The server enforces
  /// this regardless; the app checks it only to decide whether to offer
  /// the edit affordance at all, rather than letting the user compose a
  /// change that is guaranteed to be rejected.
  ///
  /// Note payment is deliberately *not* a lock: a fully-paid booking can
  /// still grow, and the balance simply re-derives.
  bool get locked {
    if (settled) return true;
    switch (status.toLowerCase()) {
      case 'completed':
      case 'closed':
      case 'cancelled':
      case 'canceled':
      case 'declined':
        return true;
      default:
        return false;
    }
  }

  /// Why the order can't be changed, for display next to a disabled
  /// button. Empty when it is editable.
  String get lockReason {
    if (!locked) return '';
    if (settled) return 'This order has been settled and can no longer be changed.';
    switch (status.toLowerCase()) {
      case 'completed':
      case 'closed':
        return 'This order is complete. Contact support if something is wrong.';
      case 'cancelled':
      case 'canceled':
        return 'This order was cancelled.';
      case 'declined':
        return 'This order was declined.';
      default:
        return 'This order can no longer be changed.';
    }
  }

  /// What the customer still owes. The server exposes paid/outstanding
  /// only on a separate payments endpoint, so bookings list screens
  /// derive it from the status they already have.
  bool get fullyPaid => paymentStatus == 'paid';
  bool get partiallyPaid => paymentStatus == 'partial';

  factory ServiceBooking.fromMap(Map<String, dynamic> j) {
    final cat = j['category'] is Map ? j['category'] as Map : const {};
    final sub = j['sub_service'] is Map ? j['sub_service'] as Map : const {};
    final itemsRaw = j['items'] is List ? j['items'] as List : const [];
    final extrasRaw =
        j['extra_items'] is List ? j['extra_items'] as List : const [];
    final catNamesRaw =
        j['category_names'] is List ? j['category_names'] as List : const [];
    final prov = j['provider'] is Map ? j['provider'] as Map : null;
    final locUpdated = _str(j['location_updated_at']);
    final sched = _str(j['scheduled_at']);
    final created = _str(j['created_at']);
    return ServiceBooking(
      id: _str(j['id']),
      categoryId: _str(j['category_id']),
      subServiceId: _str(j['sub_service_id']),
      address: _str(j['address']),
      timeSlot: _str(j['time_slot']),
      status: _str(j['status']),
      amount: _int(j['amount']),
      subtotal: _int(j['subtotal']),
      vatRate: _int(j['vat_rate']),
      vatAmount: _int(j['vat_amount']),
      paymentMethod: _str(j['payment_method']),
      paymentStatus: _str(j['payment_status']),
      invoiceNo: _str(j['invoice_no']),
      joinCode: _str(j['join_code']),
      categoryName: _str(cat['name']),
      subServiceName: _str(sub['name']),
      items: _stableOrder(
        itemsRaw
            .whereType<Map>()
            .map((e) => ServiceBookingItem.fromMap(e.cast<String, dynamic>()))
            .toList(),
        (i) => i.createdAt,
        (i) => i.id,
      ),
      extraItems: _stableOrder(
        extrasRaw
            .whereType<Map>()
            .map((e) =>
                ServiceBookingExtraItem.fromMap(e.cast<String, dynamic>()))
            .toList(),
        (i) => i.createdAt,
        (i) => i.id,
      ),
      baseAmount: _int(j['base_amount']),
      promoDiscount: _int(j['promo_discount']),
      settled: _str(j['settled_at']).isNotEmpty,
      servicesSummary: _str(j['services_summary']),
      categoryNames:
          catNamesRaw.map((e) => _str(e)).where((s) => s.isNotEmpty).toList(),
      isMultiCategory: j['is_multi_category'] == true,
      provider:
          prov == null ? null : ServiceBookingProvider.fromMap(prov.cast<String, dynamic>()),
      providerLat: _dbl(j['provider_lat']),
      providerLng: _dbl(j['provider_lng']),
      locationUpdatedAt:
          locUpdated.isEmpty ? null : DateTime.tryParse(locUpdated),
      scheduledAt: sched.isEmpty ? null : DateTime.tryParse(sched),
      createdAt: created.isEmpty ? null : DateTime.tryParse(created),
    );
  }

  static ServiceBooking fromResponse(dynamic src) =>
      ServiceBooking.fromMap((_data(src) as Map).cast<String, dynamic>());

  static List<ServiceBooking> listFromResponse(dynamic src) {
    final d = _data(src);
    final list = d is List ? d : const [];
    return list
        .whereType<Map>()
        .map((e) => ServiceBooking.fromMap(e.cast<String, dynamic>()))
        .toList();
  }
}

// ── Payment ledger / outstanding balance ───────────────────────────
//
// The booking response itself only carries a categorical payment_status
// (paid|partial|unpaid|refunded) — no numeric paid-so-far figure. This
// wraps GET .../bookings/:id/payments, the one endpoint that actually
// computes "how much is still owed" (server-side, from the full payment
// ledger — cash the provider collected, deposits, refunds, everything).
class ServicePaymentSummary {
  ServicePaymentSummary({
    required this.amount,
    required this.paidSoFar,
    required this.outstanding,
    this.discountTotal = 0,
    this.cashReceived = 0,
  });

  final double amount;

  /// Everything that has settled the invoice — money received PLUS any
  /// discount the provider/admin granted at payment time. Shown on its own
  /// it reads as though the customer paid the full amount, so the invoice
  /// uses [discountTotal] and [cashReceived] instead:
  ///   cashReceived + discountTotal = paidSoFar
  final double paidSoFar;
  final double outstanding;

  /// Forgiven at payment time (provider at cash collection, or an admin).
  /// Unlike a promo code this never changes the invoice total — it reduces
  /// what the customer actually hands over.
  final double discountTotal;
  final double cashReceived;

  bool get hasOutstanding => outstanding > 0.005;
  bool get hasDiscount => discountTotal > 0.005;

  static ServicePaymentSummary fromResponse(dynamic src) {
    final d = (_data(src) as Map).cast<String, dynamic>();
    double asDouble(dynamic v) => (v as num?)?.toDouble() ?? 0.0;
    final paid = asDouble(d['paid_so_far']);
    return ServicePaymentSummary(
      amount: asDouble(d['amount']),
      paidSoFar: paid,
      outstanding: asDouble(d['outstanding']),
      discountTotal: asDouble(d['discount_total']),
      // Older responses (and the pay-online path) omit cash_received —
      // fall back to the full settled figure rather than showing zero.
      cashReceived:
          d['cash_received'] == null ? paid : asDouble(d['cash_received']),
    );
  }
}

// ── Timeline ────────────────────────────────────────────────────────
class ServiceTimelineEntry {
  ServiceTimelineEntry({
    required this.status,
    required this.actorRole,
    required this.note,
    this.createdAt,
    this.lat,
    this.lng,
  });
  final String status;
  final String actorRole;
  final String note;
  final DateTime? createdAt;
  final double? lat;
  final double? lng;

  String get timeLabel {
    final dt = createdAt?.toLocal();
    return dt == null ? '' : DateFormat('d MMM · h:mm a').format(dt);
  }

  String get statusLabel {
    if (status.isEmpty) return '';
    return status[0].toUpperCase() + status.substring(1).replaceAll('_', ' ');
  }

  factory ServiceTimelineEntry.fromMap(Map<String, dynamic> j) {
    final created = _str(j['created_at']);
    return ServiceTimelineEntry(
      status: _str(j['status']),
      actorRole: _str(j['actor_role']),
      note: _str(j['note']),
      createdAt: created.isEmpty ? null : DateTime.tryParse(created),
      lat: _dbl(j['lat']),
      lng: _dbl(j['lng']),
    );
  }

  static List<ServiceTimelineEntry> listFromResponse(dynamic src) {
    final d = _data(src);
    final list = d is List ? d : const [];
    return list
        .whereType<Map>()
        .map((e) => ServiceTimelineEntry.fromMap(e.cast<String, dynamic>()))
        .toList();
  }
}

// ── Chat ────────────────────────────────────────────────────────────
class ServiceChatMessage {
  ServiceChatMessage({
    required this.id,
    required this.senderId,
    required this.message,
    required this.senderName,
    this.createdAt,
  });
  final String id;
  final String senderId;
  final String message;
  final String senderName;
  final DateTime? createdAt;

  String get timeLabel {
    final dt = createdAt?.toLocal();
    return dt == null ? '' : DateFormat('h:mm a').format(dt);
  }

  factory ServiceChatMessage.fromMap(Map<String, dynamic> j) {
    final sender = j['sender'] is Map ? j['sender'] as Map : const {};
    final profile = sender['profile'] is Map ? sender['profile'] as Map : const {};
    final created = _str(j['created_at']);
    return ServiceChatMessage(
      id: _str(j['id']),
      senderId: _str(j['sender_id']),
      message: _str(j['message']),
      senderName: _str(profile['full_name']),
      createdAt: created.isEmpty ? null : DateTime.tryParse(created),
    );
  }

  static List<ServiceChatMessage> listFromResponse(dynamic src) {
    final d = _data(src);
    final list = d is List ? d : const [];
    return list
        .whereType<Map>()
        .map((e) => ServiceChatMessage.fromMap(e.cast<String, dynamic>()))
        .toList();
  }
}
