// lib/features/ambulance/data/ambulance_api.dart
import 'package:dio/dio.dart';

class AmbType {
  final String id; final String name; final String description;
  final num baseFare; final num perKm; final int available;
  AmbType.fromJson(Map j)
      : id = '${j['id'] ?? ''}',
        name = (j['name'] ?? j['type'] ?? '') as String,
        description = (j['description'] ?? '') as String,
        baseFare = (j['base_fare'] ?? j['base'] ?? 0) as num,
        perKm = (j['per_km'] ?? 0) as num,
        available = (j['available'] ?? j['count'] ?? 0) as int;
}

class FareEstimate {
  final num total; final num distanceKm;
  FareEstimate.fromJson(Map j)
      : total = (j['total'] ?? j['fare'] ?? 0) as num,
        distanceKm = (j['distance_km'] ?? j['distance'] ?? 0) as num;
}

class AmbBooking {
  final String id; final String status; final String? typeName; final String? patientName;
  AmbBooking.fromJson(Map j)
      : id = '${j['id'] ?? ''}',
        status = (j['status'] ?? 'requested') as String,
        typeName = j['type_name'] as String?,
        patientName = j['patient_name'] as String?;
}

class AmbulanceRepository {
  AmbulanceRepository(this._dio);
  final Dio _dio;

  Future<List<AmbType>> types() async {
    final r = await _dio.get('/ambulance/types');
    return _list(r.data).map((e) => AmbType.fromJson(e)).toList();
  }

  Future<int> availableCount() async {
    final r = await _dio.get('/ambulance/available');
    final d = r.data;
    if (d is List) return d.length;
    return (d['count'] ?? d['available'] ?? 0) as int;
  }

  Future<FareEstimate> estimate({required String typeId, required double pLat, required double pLng, required double dLat, required double dLng}) async {
    final r = await _dio.post('/ambulance/fare/estimate', data: {
      'type_id': typeId, 'pickup_lat': pLat, 'pickup_lng': pLng, 'drop_lat': dLat, 'drop_lng': dLng,
    });
    return FareEstimate.fromJson(r.data is Map ? r.data : {});
  }

  Future<AmbBooking> book(Map<String, dynamic> body) async {
    final r = await _dio.post('/ambulance/bookings', data: body);
    return AmbBooking.fromJson(_unwrap(r.data));
  }

  Future<List<AmbBooking>> myBookings() async {
    final r = await _dio.get('/ambulance/bookings');
    return _list(r.data).map((e) => AmbBooking.fromJson(e)).toList();
  }
}

// ── shared response helpers ──
List<Map> _list(dynamic d) {
  final v = (d is Map && d['data'] != null) ? d['data'] : d;
  return (v is List) ? v.cast<Map>() : <Map>[];
}
Map _unwrap(dynamic d) => (d is Map && d['data'] is Map) ? d['data'] as Map : (d is Map ? d : {});
