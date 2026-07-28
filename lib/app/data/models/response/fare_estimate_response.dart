import 'dart:convert';

import '../../../core/helpers/app_helper.dart';

dynamic _decode(dynamic src) => src is String ? jsonDecode(src) : src;

String _str(dynamic v) => v?.toString().trim() ?? '';
int _int(dynamic v) =>
    v is int ? v : int.tryParse(_str(v)) ?? (v is num ? v.toInt() : 0);
double _money(dynamic v) =>
    v is num ? v.toDouble() : double.tryParse(_str(v)) ?? 0;

/// Fare breakdown from `POST /api/v1/ambulance/fare/estimate`.
class FareEstimate {
  FareEstimate({
    required this.distanceKm,
    required this.routeType,
    required this.baseFare,
    required this.perKmFare,
    required this.mileageCharge,
    required this.estimatedWaitMinutes,
    required this.waitingFreeMinutes,
    required this.waitingRatePerMin,
    required this.waitingCharge,
    required this.emergencyCharge,
    required this.nightCharge,
    required this.subTotal,
    required this.taxRate,
    required this.taxAmount,
    required this.totalFare,
  });

  final int distanceKm;
  final String routeType;
  final double baseFare;
  final double perKmFare;
  final double mileageCharge;
  final int estimatedWaitMinutes;
  final int waitingFreeMinutes;
  final double waitingRatePerMin;
  final double waitingCharge;
  final double emergencyCharge;
  final double nightCharge;
  final double subTotal;
  final int taxRate;
  final double taxAmount;
  final double totalFare;

  /// "1,059.00" style — two decimal places, matching the web app.
  static String fmt(double n) => Helpers.format(n);

  String get totalLabel => '৳${fmt(totalFare)}';
  String get baseLabel => '৳${fmt(baseFare)}';
  String get perKmFareLabel => '৳${fmt(perKmFare)}';
  String get mileageLabel => '৳${fmt(mileageCharge)}';
  String get waitingLabel => '৳${fmt(waitingCharge)}';
  String get waitingRatePerMinLabel => '৳${fmt(waitingRatePerMin)}';
  String get emergencyLabel => '৳${fmt(emergencyCharge)}';
  String get nightLabel => '৳${fmt(nightCharge)}';
  String get taxLabel => '৳${fmt(taxAmount)}';

  factory FareEstimate.fromMap(Map<String, dynamic> json) {
    return FareEstimate(
      distanceKm: _int(json['distance_km']),
      routeType: _str(json['route_type']),
      baseFare: _money(json['base_fare']),
      perKmFare: _money(json['per_km_fare']),
      mileageCharge: _money(json['mileage_charge']),
      estimatedWaitMinutes: _int(json['estimated_wait_minutes']),
      waitingFreeMinutes: _int(json['waiting_free_minutes']),
      waitingRatePerMin: _money(json['waiting_rate_per_min']),
      waitingCharge: _money(json['waiting_charge']),
      emergencyCharge: _money(json['emergency_charge']),
      nightCharge: _money(json['night_charge']),
      subTotal: _money(json['sub_total']),
      taxRate: _int(json['tax_rate']),
      taxAmount: _money(json['tax_amount']),
      totalFare: _money(json['total_fare']),
    );
  }

  static FareEstimate fromResponse(dynamic src) {
    final decoded = _decode(src);
    final data = decoded is Map && decoded['data'] is Map
        ? decoded['data'] as Map
        : decoded as Map;
    return FareEstimate.fromMap(data.cast<String, dynamic>());
  }
}

/// A payment option from `/api/v1/ambulance/payment-methods`.
class PaymentMethodOption {
  PaymentMethodOption({
    required this.key,
    required this.label,
    required this.description,
    required this.enabled,
  });

  final String key;
  final String label;
  final String description;
  final bool enabled;

  factory PaymentMethodOption.fromMap(Map<String, dynamic> json) {
    return PaymentMethodOption(
      key: _str(json['key']),
      label: _str(json['label']),
      description: _str(json['description']),
      enabled: json['enabled'] == true,
    );
  }

  /// Parses `{ data: { default, methods: [...] } }` into a list.
  static List<PaymentMethodOption> listFromResponse(dynamic src) {
    final decoded = _decode(src);
    final data = decoded is Map && decoded['data'] is Map
        ? decoded['data'] as Map
        : (decoded is Map ? decoded : const {});
    final methods = data['methods'] is List ? data['methods'] as List : const [];
    return methods
        .whereType<Map>()
        .map((e) => PaymentMethodOption.fromMap(e.cast<String, dynamic>()))
        .toList();
  }

  /// The server's default method key (e.g. "cash").
  static String defaultKey(dynamic src) {
    final decoded = _decode(src);
    final data = decoded is Map && decoded['data'] is Map
        ? decoded['data'] as Map
        : (decoded is Map ? decoded : const {});
    return _str(data['default']);
  }
}
