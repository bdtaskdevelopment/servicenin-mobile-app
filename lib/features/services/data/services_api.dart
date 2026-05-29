// lib/features/services/data/services_api.dart  (Home Service marketplace)
import 'package:dio/dio.dart';

class ServiceCategory {
  final String id; final String name; final String nameBn;
  ServiceCategory.fromJson(Map j)
      : id = '${j['id'] ?? ''}',
        name = (j['name'] ?? '') as String,
        nameBn = (j['name_bn'] ?? j['name'] ?? '') as String;
}

class SubService {
  final String id; final String name; final num price; final int durationMin;
  SubService.fromJson(Map j)
      : id = '${j['id'] ?? ''}',
        name = (j['name'] ?? '') as String,
        price = (j['price'] ?? 0) as num,
        durationMin = (j['duration_min'] ?? 0) as int;
}

class ServiceBooking {
  final String id; final String status; final num total;
  ServiceBooking.fromJson(Map j)
      : id = '${j['id'] ?? ''}',
        status = (j['status'] ?? 'placed') as String,
        total = (j['total'] ?? 0) as num;
}

class ServicesRepository {
  ServicesRepository(this._dio);
  final Dio _dio;

  Future<List<ServiceCategory>> categories() async =>
      _list(await _g('/services/categories')).map((e) => ServiceCategory.fromJson(e)).toList();
  Future<List<SubService>> subServices(String categoryId) async =>
      _list(await _g('/services/categories/$categoryId/sub-services')).map((e) => SubService.fromJson(e)).toList();
  Future<List> providers() async => _list(await _g('/services/providers'));

  Future<ServiceBooking> book(Map<String, dynamic> body) async =>
      ServiceBooking.fromJson(_unwrap(await _p('/services/book', body)));
  Future<List<ServiceBooking>> myBookings() async =>
      _list(await _g('/services/bookings/my')).map((e) => ServiceBooking.fromJson(e)).toList();
  Future<ServiceBooking> booking(String id) async =>
      ServiceBooking.fromJson(_unwrap(await _g('/services/bookings/$id')));
  Future<List> timeline(String id) async => _list(await _g('/services/bookings/$id/timeline'));
  Future<void> rate(String id, int stars, String comment) =>
      _dio.post('/services/bookings/$id/rate', data: {'stars': stars, 'comment': comment});
  Future<void> dispute(String id, String reason, String desc) =>
      _dio.post('/services/bookings/$id/dispute', data: {'reason': reason, 'description': desc});

  // Subscriptions
  Future<List> plans() async => _list(await _g('/services/plans'));
  Future<void> subscribe(Map<String, dynamic> body) => _dio.post('/services/subscriptions', data: body);
  Future<List> mySubscriptions() async => _list(await _g('/services/subscriptions/my'));

  // Provider side
  Future<List> providerJobs() async => _list(await _g('/services/provider/jobs'));
  Future<Map> providerBalance() async => _unwrap(await _g('/services/provider/balance'));
  Future<void> withdraw(num amount, String method, String dest) =>
      _dio.post('/services/provider/withdrawals', data: {'amount': amount, 'method': method, 'destination': dest});

  Future _g(String p) async => (await _dio.get(p)).data;
  Future _p(String p, Map b) async => (await _dio.post(p, data: b)).data;
}

List<Map> _list(dynamic d) { final v = (d is Map && d['data'] != null) ? d['data'] : d; return (v is List) ? v.cast<Map>() : <Map>[]; }
Map _unwrap(dynamic d) => (d is Map && d['data'] is Map) ? d['data'] as Map : (d is Map ? d : {});
