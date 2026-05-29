// lib/features/healthcare/data/healthcare_api.dart
import 'package:dio/dio.dart';

class Doctor {
  final String id; final String name; final String specialty; final String degrees;
  final num fee; final String bmdc;
  Doctor.fromJson(Map j)
      : id = '${j['id'] ?? ''}',
        name = (j['full_name'] ?? j['name'] ?? '') as String,
        specialty = (j['specialty'] ?? '') as String,
        degrees = (j['qualifications'] ?? j['degrees'] ?? '') as String,
        fee = (j['fee'] ?? 0) as num,
        bmdc = '${j['bmdc'] ?? ''}';
}

class Venue {
  final String id; final String name; final String days; final String time;
  Venue.fromJson(Map j)
      : id = '${j['id'] ?? ''}',
        name = (j['name'] ?? '') as String,
        days = (j['days'] ?? '') as String,
        time = (j['time'] ?? '') as String;
}

class Appointment {
  final String id; final String status; final String? doctorName; final String? when;
  Appointment.fromJson(Map j)
      : id = '${j['id'] ?? ''}',
        status = (j['status'] ?? 'upcoming') as String,
        doctorName = j['doctor_name'] as String?,
        when = j['appointment_date'] as String?;
}

class HealthcareRepository {
  HealthcareRepository(this._dio);
  final Dio _dio;
  Future<List<Doctor>> doctors() async => _list(await _g('/healthcare/doctors')).map((e) => Doctor.fromJson(e)).toList();
  Future<Doctor> doctor(String id) async => Doctor.fromJson(_unwrap(await _g('/healthcare/doctors/$id')));
  Future<List<Venue>> venues(String id) async => _list(await _g('/healthcare/doctors/$id/venues')).map((e) => Venue.fromJson(e)).toList();
  Future<Appointment> book({required String doctorId, required String venueId, required String dateIso, String notes = ''}) async =>
      Appointment.fromJson(_unwrap(await _p('/healthcare/appointments',
          {'doctor_id': doctorId, 'venue_id': venueId, 'appointment_date': dateIso, 'notes': notes})));
  Future<List<Appointment>> myAppointments() async => _list(await _g('/healthcare/appointments/my')).map((e) => Appointment.fromJson(e)).toList();
  Future _g(String p) async => (await _dio.get(p)).data;
  Future _p(String p, Map b) async => (await _dio.post(p, data: b)).data;
}

List<Map> _list(dynamic d) { final v = (d is Map && d['data'] != null) ? d['data'] : d; return (v is List) ? v.cast<Map>() : <Map>[]; }
Map _unwrap(dynamic d) => (d is Map && d['data'] is Map) ? d['data'] as Map : (d is Map ? d : {});
