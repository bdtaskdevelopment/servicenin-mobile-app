import 'dart:convert';

dynamic _decode(dynamic src) => src is String ? jsonDecode(src) : src;

String _str(dynamic v) => v?.toString().trim() ?? '';
int _int(dynamic v) =>
    v is int ? v : int.tryParse(_str(v)) ?? (v is num ? v.toInt() : 0);

/// Fare breakdown from `POST /api/v1/ambulance/fare/estimate`.
class FareEstimate {
  FareEstimate({
    required this.distanceKm,
    required this.routeType,
    required this.baseFare,
    required this.perKmFare,
    required this.mileageCharge,
    required this.emergencyCharge,
    required this.nightCharge,
    required this.subTotal,
    required this.taxRate,
    required this.taxAmount,
    required this.totalFare,
  });

  final int distanceKm;
  final String routeType;
  final int baseFare;
  final int perKmFare;
  final int mileageCharge;
  final int emergencyCharge;
  final int nightCharge;
  final int subTotal;
  final int taxRate;
  final int taxAmount;
  final int totalFare;

  static String fmt(int n) {
    final s = n.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return b.toString();
  }

  String get totalLabel => '৳${fmt(totalFare)}';
  String get baseLabel => '৳${fmt(baseFare)}';
  String get mileageLabel => '৳${fmt(mileageCharge)}';

  factory FareEstimate.fromMap(Map<String, dynamic> json) {
    return FareEstimate(
      distanceKm: _int(json['distance_km']),
      routeType: _str(json['route_type']),
      baseFare: _int(json['base_fare']),
      perKmFare: _int(json['per_km_fare']),
      mileageCharge: _int(json['mileage_charge']),
      emergencyCharge: _int(json['emergency_charge']),
      nightCharge: _int(json['night_charge']),
      subTotal: _int(json['sub_total']),
      taxRate: _int(json['tax_rate']),
      taxAmount: _int(json['tax_amount']),
      totalFare: _int(json['total_fare']),
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
