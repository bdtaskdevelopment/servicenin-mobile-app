import 'dart:convert';

import 'package:intl/intl.dart';

dynamic _dec(dynamic src) => src is String ? jsonDecode(src) : src;
String _str(dynamic v) => v?.toString().trim() ?? '';
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

  String get displayName => name; // English name shown across the app
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
class ServiceBookingItem {
  ServiceBookingItem({
    required this.subServiceId,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    required this.name,
  });
  final String subServiceId;
  final int quantity;
  final int unitPrice;
  final int lineTotal;
  final String name;

  factory ServiceBookingItem.fromMap(Map<String, dynamic> j) {
    final sub = j['sub_service'] is Map ? j['sub_service'] as Map : const {};
    return ServiceBookingItem(
      subServiceId: _str(j['sub_service_id']),
      quantity: _int(j['quantity']),
      unitPrice: _int(j['unit_price']),
      lineTotal: _int(j['line_total']),
      name: _str(sub['name']),
    );
  }
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
  final DateTime? scheduledAt;
  final DateTime? createdAt;

  String get amountLabel => '৳$amount';
  String get subtotalLabel => '৳$subtotal';
  String get vatLabel => '৳$vatAmount';

  String get title => subServiceName.isNotEmpty
      ? subServiceName
      : (categoryName.isNotEmpty ? categoryName : 'Service');

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

  factory ServiceBooking.fromMap(Map<String, dynamic> j) {
    final cat = j['category'] is Map ? j['category'] as Map : const {};
    final sub = j['sub_service'] is Map ? j['sub_service'] as Map : const {};
    final itemsRaw = j['items'] is List ? j['items'] as List : const [];
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
      items: itemsRaw
          .whereType<Map>()
          .map((e) => ServiceBookingItem.fromMap(e.cast<String, dynamic>()))
          .toList(),
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
