// lib/features/blood/data/blood_api.dart
import 'package:dio/dio.dart';

class BloodRequest {
  final String id; final String group; final int units; final String hospital;
  final String urgency; final String status; final int responders;
  BloodRequest.fromJson(Map j)
      : id = '${j['id'] ?? ''}',
        group = (j['blood_group'] ?? j['group'] ?? '') as String,
        units = (j['units_needed'] ?? j['units'] ?? 1) as int,
        hospital = (j['hospital_name'] ?? j['hospital'] ?? '') as String,
        urgency = (j['urgency'] ?? 'routine') as String,
        status = (j['status'] ?? 'open') as String,
        responders = (j['responders'] ?? 0) as int;
}

class Donor {
  final String id; final String name; final String group; final bool available;
  Donor.fromJson(Map j)
      : id = '${j['id'] ?? ''}',
        name = (j['name'] ?? j['full_name'] ?? '') as String,
        group = (j['blood_group'] ?? '') as String,
        available = (j['is_available'] ?? true) as bool;
}

class BloodRepository {
  BloodRepository(this._dio);
  final Dio _dio;

  // Requester
  Future<BloodRequest> createRequest(Map<String, dynamic> body) async =>
      BloodRequest.fromJson(_unwrap(await _post('/blood/requests', body)));
  Future<List<BloodRequest>> requests() async =>
      _list(await _get('/blood/requests')).map((e) => BloodRequest.fromJson(e)).toList();
  Future<BloodRequest> request(String id) async =>
      BloodRequest.fromJson(_unwrap(await _get('/blood/requests/$id')));
  Future<void> respond(String id) => _dio.post('/blood/requests/$id/respond');
  Future<void> accept(String id) => _dio.post('/blood/requests/$id/accept');
  Future<void> dismiss(String id) => _dio.post('/blood/requests/$id/dismiss');

  // Donor
  Future<void> registerDonor(Map<String, dynamic> body) => _dio.post('/blood/donors/register', data: body);
  Future<void> verifyDonor(String otp) => _dio.post('/blood/donors/verify-otp', data: {'otp': otp});
  Future<List<Donor>> nearest() async => _list(await _get('/blood/donors/nearest')).map((e) => Donor.fromJson(e)).toList();
  Future<List<Donor>> leaderboard() async => _list(await _get('/blood/donors/leaderboard')).map((e) => Donor.fromJson(e)).toList();
  Future<Donor> me() async => Donor.fromJson(_unwrap(await _get('/blood/donors/me')));
  Future<void> setAvailability(bool v) => _dio.patch('/blood/donors/me/availability', data: {'is_available': v});
  Future<void> setNotifications(bool v) => _dio.patch('/blood/donors/me/notifications', data: {'notify_on_requests': v});

  // Fulfillment
  Future<void> confirmFulfillment(String id, String otp) => _dio.post('/blood/fulfillments/$id/confirm', data: {'otp': otp});
  Future<List> chat(String id) async => _list(await _get('/blood/fulfillments/$id/chat'));
  Future<void> sendChat(String id, String msg) => _dio.post('/blood/fulfillments/$id/chat', data: {'message': msg});
  Future<void> shareLocation(String id, double lat, double lng) => _dio.post('/blood/fulfillments/$id/location', data: {'lat': lat, 'lng': lng});

  Future _get(String p) async => (await _dio.get(p)).data;
  Future _post(String p, Map b) async => (await _dio.post(p, data: b)).data;
}

List<Map> _list(dynamic d) { final v = (d is Map && d['data'] != null) ? d['data'] : d; return (v is List) ? v.cast<Map>() : <Map>[]; }
Map _unwrap(dynamic d) => (d is Map && d['data'] is Map) ? d['data'] as Map : (d is Map ? d : {});
