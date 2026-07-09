import 'dart:convert';

dynamic _decode(dynamic src) => src is String ? jsonDecode(src) : src;

String _str(dynamic v) => v?.toString().trim() ?? '';
int _int(dynamic v) =>
    v is int ? v : int.tryParse(_str(v)) ?? (v is num ? v.toInt() : 0);
double? _dbl(dynamic v) => v == null
    ? null
    : (v is num ? v.toDouble() : double.tryParse(v.toString()));

/// An ambulance type/tier from `/api/v1/ambulance/types` (also embedded in the
/// available-ambulance and booking payloads under `type`).
class AmbulanceType {
  AmbulanceType({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.equipmentList,
    required this.baseFare,
    required this.perKmFare,
    required this.waitingFarePerMin,
    required this.freeWaitMinutes,
    required this.emergencySurcharge,
    required this.nightSurcharge,
    required this.taxRate,
    required this.sortOrder,
  });

  final String id;
  final String name;
  final String slug;
  final String description;
  final String equipmentList;
  final int baseFare;
  final int perKmFare;
  final int waitingFarePerMin;

  /// Minutes of waiting the customer gets free before [waitingFarePerMin]
  /// starts applying (server default: 45).
  final int freeWaitMinutes;
  final int emergencySurcharge;
  final int nightSurcharge;
  final int taxRate;
  final int sortOrder;

  /// Equipment as a clean list, e.g. ["Oxygen cylinder", "Stretcher", ...].
  List<String> get equipment => equipmentList
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  factory AmbulanceType.fromMap(Map<String, dynamic> json) {
    return AmbulanceType(
      id: _str(json['id']),
      name: _str(json['name']),
      slug: _str(json['slug']),
      description: _str(json['description']),
      equipmentList: _str(json['equipment_list']),
      baseFare: _int(json['base_fare']),
      perKmFare: _int(json['per_km_fare']),
      waitingFarePerMin: _int(json['waiting_fare_per_min']),
      freeWaitMinutes: _int(json['free_wait_minutes']),
      emergencySurcharge: _int(json['emergency_surcharge']),
      nightSurcharge: _int(json['night_surcharge']),
      taxRate: _int(json['tax_rate']),
      sortOrder: _int(json['sort_order']),
    );
  }

  static List<AmbulanceType> listFromResponse(dynamic src) {
    final decoded = _decode(src);
    final list = decoded is Map
        ? (decoded['data'] is List ? decoded['data'] as List : const [])
        : (decoded is List ? decoded : const []);
    return list
        .whereType<Map>()
        .map((e) => AmbulanceType.fromMap(e.cast<String, dynamic>()))
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }
}

/// An available ambulance vehicle from `/api/v1/ambulance/available`.
class Ambulance {
  Ambulance({
    required this.id,
    required this.providerId,
    required this.typeId,
    required this.registrationNo,
    required this.vehicleModel,
    required this.licensePlate,
    required this.capacity,
    required this.serviceArea,
    required this.availabilityStatus,
    this.currentLat,
    this.currentLng,
    this.type,
  });

  final String id;
  final String providerId;
  final String typeId;
  final String registrationNo;
  final String vehicleModel;
  final String licensePlate;
  final int capacity;
  final String serviceArea;
  final String availabilityStatus;
  final double? currentLat;
  final double? currentLng;
  final AmbulanceType? type;

  String get typeName => type?.name ?? 'Ambulance';
  int get baseFare => type?.baseFare ?? 0;
  int get perKmFare => type?.perKmFare ?? 0;
  bool get isAvailable => availabilityStatus.toLowerCase() == 'available';

  factory Ambulance.fromMap(Map<String, dynamic> json) {
    return Ambulance(
      id: _str(json['id']),
      providerId: _str(json['provider_id']),
      typeId: _str(json['type_id']),
      registrationNo: _str(json['registration_no']),
      vehicleModel: _str(json['vehicle_model']),
      licensePlate: _str(json['license_plate']),
      capacity: _int(json['capacity']),
      serviceArea: _str(json['service_area']),
      availabilityStatus: _str(json['availability_status']),
      currentLat: _dbl(json['current_lat']),
      currentLng: _dbl(json['current_lng']),
      type: json['type'] is Map
          ? AmbulanceType.fromMap((json['type'] as Map).cast<String, dynamic>())
          : null,
    );
  }

  static List<Ambulance> listFromResponse(dynamic src) {
    final decoded = _decode(src);
    final list = decoded is Map
        ? (decoded['data'] is List ? decoded['data'] as List : const [])
        : (decoded is List ? decoded : const []);
    return list
        .whereType<Map>()
        .map((e) => Ambulance.fromMap(e.cast<String, dynamic>()))
        .toList();
  }
}
