import 'dart:convert';

import '../../core/values/app_url.dart';
import '../models/response/ambulance_booking_response.dart';
import '../models/response/ambulance_response.dart';
import '../models/response/auth_response.dart';
import '../models/response/fare_estimate_response.dart';
import '../providers/ambulance.provider.dart';

class AmbulanceRepository {
  AmbulanceRepository({required this.provider});

  final AmbulanceProvider provider;

  /// Returns the decoded JSON whether it's in `res.body` or `res.bodyString`,
  /// so the exact API `message` is preserved on both success and error.
  dynamic _payload(dynamic res) {
    final body = res.body;
    if (body is Map) {
      // Reject backend errors (HTTP 4xx/5xx or {success:false}) instead of
      // parsing the error body as a successful result.
      final code = res.statusCode;
      final failed = body['success'] == false || (code is int && code >= 400);
      if (failed) {
        final msg = (body['message'] ?? '').toString().trim();
        throw Exception(msg.isNotEmpty ? msg : 'অনুরোধটি সম্পন্ন করা যায়নি');
      }
      return body;
    }
    final raw = res.bodyString;
    if (raw != null && raw.toString().trim().isNotEmpty) return raw;
    throw Exception('সংযোগে সমস্যা — আবার চেষ্টা করুন');
  }

  /// GET /api/v1/ambulance/available — available ambulance vehicles.
  Future<List<Ambulance>> fetchAvailable() async {
    final res = await provider.getData(ApiURL.ambulanceAvailable);
    return Ambulance.listFromResponse(_payload(res));
  }

  /// GET /api/v1/ambulance/bookings — the user's bookings.
  Future<List<AmbulanceBookingEntry>> fetchBookings() async {
    final res = await provider.getData(ApiURL.ambulanceBookings);
    return AmbulanceBookingEntry.listFromResponse(_payload(res));
  }

  /// GET /api/v1/ambulance/types — ambulance tiers.
  Future<List<AmbulanceType>> fetchTypes() async {
    final res = await provider.getData(ApiURL.ambulanceTypes);
    return AmbulanceType.listFromResponse(_payload(res));
  }

  /// GET /api/v1/locations/divisions — division names.
  Future<List<String>> fetchDivisions() async {
    final res = await provider.getData(ApiURL.locationDivisions);
    return _stringList(_payload(res), 'divisions');
  }

  /// GET /api/v1/locations/districts?division=… — district names.
  Future<List<String>> fetchDistricts(String division) async {
    final res = await provider.getData(ApiURL.locationDistricts(division));
    return _stringList(_payload(res), 'districts');
  }

  /// POST /api/v1/ambulance/fare/estimate — fare breakdown for a trip.
  Future<FareEstimate> estimateFare(Map<String, dynamic> payload) async {
    final res = await provider.postData(ApiURL.ambulanceFareEstimate, payload);
    return FareEstimate.fromResponse(_payload(res));
  }

  /// GET /api/v1/ambulance/payment-methods — payment options.
  Future<List<PaymentMethodOption>> fetchPaymentMethods() async {
    final res = await provider.getData(ApiURL.ambulancePaymentMethods);
    return PaymentMethodOption.listFromResponse(_payload(res));
  }

  /// The server's default payment method key.
  Future<String> fetchDefaultPaymentMethod() async {
    final res = await provider.getData(ApiURL.ambulancePaymentMethods);
    return PaymentMethodOption.defaultKey(_payload(res));
  }

  /// POST /api/v1/ambulance/bookings — create a booking.
  Future<AmbulanceBookingEntry> createBooking(
      Map<String, dynamic> payload) async {
    final res = await provider.postData(ApiURL.ambulanceBookings, payload);
    return AmbulanceBookingEntry.fromResponse(_payload(res));
  }

  /// POST /api/v1/ambulance/bookings/:id/rate — rate a completed trip, or
  /// flag it as a complaint.
  Future<AuthSimpleResponse> rateBooking(
    String id, {
    required int driverRating,
    required int ambulanceConditionRating,
    required int serviceRating,
    String comment = '',
    bool isComplaint = false,
    String complaintNote = '',
  }) async {
    final res = await provider.postData(ApiURL.ambulanceBookingRate(id), {
      'driver_rating': driverRating,
      'ambulance_condition_rating': ambulanceConditionRating,
      'service_rating': serviceRating,
      'comment': comment,
      'is_complaint': isComplaint,
      'complaint_note': complaintNote,
    });
    return AuthSimpleResponse.fromMap(_payload(res));
  }

  /// Parses `{ data: { <key>: [..] } }` (or a bare list) into a string list.
  List<String> _stringList(dynamic src, String key) {
    final decoded = src is String ? jsonDecode(src) : src;
    final data = decoded is Map && decoded['data'] is Map
        ? decoded['data'] as Map
        : (decoded is Map ? decoded : const {});
    final list = data[key] is List
        ? data[key] as List
        : (decoded is List ? decoded : const []);
    return list.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
  }
}
