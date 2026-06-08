import 'dart:convert';

import 'package:intl/intl.dart';

import 'ambulance_response.dart';

dynamic _decode(dynamic src) => src is String ? jsonDecode(src) : src;

String _str(dynamic v) => v?.toString().trim() ?? '';
int _int(dynamic v) =>
    v is int ? v : int.tryParse(_str(v)) ?? (v is num ? v.toInt() : 0);

/// A booking from `/api/v1/ambulance/bookings` (list + create response).
class AmbulanceBookingEntry {
  AmbulanceBookingEntry({
    required this.id,
    required this.bookingNo,
    required this.typeId,
    required this.bookingType,
    required this.customerPhone,
    required this.patientName,
    required this.pickupAddress,
    required this.pickupDivision,
    required this.pickupZilla,
    required this.destination,
    required this.dropDivision,
    required this.dropZilla,
    required this.distanceKm,
    required this.estimatedFare,
    required this.totalFare,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.status,
    this.createdAt,
    this.type,
  });

  final String id;
  final String bookingNo;
  final String typeId;
  final String bookingType;
  final String customerPhone;
  final String patientName;
  final String pickupAddress;
  final String pickupDivision;
  final String pickupZilla;
  final String destination;
  final String dropDivision;
  final String dropZilla;
  final int distanceKm;
  final int estimatedFare;
  final int totalFare;
  final String paymentMethod;
  final String paymentStatus;
  final String status;
  final DateTime? createdAt;
  final AmbulanceType? type;

  String get typeName => type?.name ?? 'Ambulance';

  /// "Munshiganj → Manikganj" style route summary.
  String get routeLabel {
    final from = pickupZilla.isNotEmpty ? pickupZilla : pickupAddress;
    final to = dropZilla.isNotEmpty ? dropZilla : destination;
    return '$from → $to';
  }

  /// A trip is "ongoing" until it's completed or cancelled.
  bool get ongoing {
    final s = status.toLowerCase();
    return s != 'completed' && s != 'cancelled' && s != 'canceled';
  }

  String get fareLabel => '৳${_fmt(totalFare > 0 ? totalFare : estimatedFare)}';

  String get dateAmount {
    final dt = createdAt?.toLocal();
    final date = dt == null ? '' : DateFormat('d MMM, h:mm a').format(dt);
    return [date, fareLabel].where((s) => s.isNotEmpty).join(' · ');
  }

  static String _fmt(int n) {
    final s = n.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return b.toString();
  }

  factory AmbulanceBookingEntry.fromMap(Map<String, dynamic> json) {
    final created = _str(json['created_at']);
    return AmbulanceBookingEntry(
      id: _str(json['id']),
      bookingNo: _str(json['booking_no']),
      typeId: _str(json['type_id']),
      bookingType: _str(json['booking_type']),
      customerPhone: _str(json['customer_phone']),
      patientName: _str(json['patient_name']),
      pickupAddress: _str(json['pickup_address']),
      pickupDivision: _str(json['pickup_division']),
      pickupZilla: _str(json['pickup_zilla']),
      destination: _str(json['destination']),
      dropDivision: _str(json['drop_division']),
      dropZilla: _str(json['drop_zilla']),
      distanceKm: _int(json['distance_km']),
      estimatedFare: _int(json['estimated_fare']),
      totalFare: _int(json['total_fare']),
      paymentMethod: _str(json['payment_method']),
      paymentStatus: _str(json['payment_status']),
      status: _str(json['status']),
      createdAt: created.isEmpty ? null : DateTime.tryParse(created),
      type: json['type'] is Map
          ? AmbulanceType.fromMap((json['type'] as Map).cast<String, dynamic>())
          : null,
    );
  }

  /// Parses a bare array or `{ success, message, data: [...] }`.
  static List<AmbulanceBookingEntry> listFromResponse(dynamic src) {
    final decoded = _decode(src);
    final list = decoded is Map
        ? (decoded['data'] is List ? decoded['data'] as List : const [])
        : (decoded is List ? decoded : const []);
    return list
        .whereType<Map>()
        .map((e) => AmbulanceBookingEntry.fromMap(e.cast<String, dynamic>()))
        .toList();
  }

  /// Parses the single-booking envelope `{ success, message, data }`.
  static AmbulanceBookingEntry fromResponse(dynamic src) {
    final decoded = _decode(src);
    final data = decoded is Map && decoded['data'] is Map
        ? decoded['data'] as Map
        : decoded as Map;
    return AmbulanceBookingEntry.fromMap(data.cast<String, dynamic>());
  }
}
