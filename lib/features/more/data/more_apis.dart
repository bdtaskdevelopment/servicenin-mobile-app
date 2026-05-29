// lib/features/more/data/more_apis.dart
// Compact repositories for the lighter modules: Physio, Matchmaking, Jobs,
// Education, Nagarik, Info, Funeral. Each maps 1:1 to its API group.
import 'package:dio/dio.dart';

List<Map> _l(dynamic d) { final v = (d is Map && d['data'] != null) ? d['data'] : d; return (v is List) ? v.cast<Map>() : <Map>[]; }
Map _u(dynamic d) => (d is Map && d['data'] is Map) ? d['data'] as Map : (d is Map ? d : {});

class PhysioRepository {
  PhysioRepository(this._d); final Dio _d;
  Future<List<Map>> centers() async => _l((await _d.get('/physio/centers')).data);
  Future<Map> book({required String centerId, required String staffId, required String dateIso}) async =>
      _u((await _d.post('/physio/appointments', data: {'center_id': centerId, 'staff_id': staffId, 'scheduled_at': dateIso})).data);
  Future<List<Map>> myAppointments() async => _l((await _d.get('/physio/appointments/my')).data);
}

class MatchmakingRepository {
  MatchmakingRepository(this._d); final Dio _d;
  Future<List<Map>> profiles() async => _l((await _d.get('/matchmaking/profiles')).data);
  Future<Map> createProfile(Map<String, dynamic> b) async => _u((await _d.post('/matchmaking/profiles', data: b)).data);
  Future<List<Map>> receivedInterests() async => _l((await _d.get('/matchmaking/interests/received')).data);
}

class JobsRepository {
  JobsRepository(this._d); final Dio _d;
  Future<List<Map>> jobs() async => _l((await _d.get('/jobs')).data);
  Future<Map> job(String id) async => _u((await _d.get('/jobs/$id')).data);
  Future<void> apply(String id, String coverLetter) => _d.post('/jobs/$id/apply', data: {'cover_letter': coverLetter});
  Future<List<Map>> myApplications() async => _l((await _d.get('/jobs/applications/my')).data);
}

class EducationRepository {
  EducationRepository(this._d); final Dio _d;
  Future<List<Map>> centers() async => _l((await _d.get('/education/centers')).data);
  Future<Map> center(String id) async => _u((await _d.get('/education/centers/$id')).data);
  Future<List<Map>> courses(String id) async => _l((await _d.get('/education/centers/$id/courses')).data);
  Future<void> enquire(Map<String, dynamic> b) => _d.post('/education/interests', data: b);
}

class NagarikRepository {
  NagarikRepository(this._d); final Dio _d;
  Future<Map> createGrievance(Map<String, dynamic> b) async => _u((await _d.post('/nagarik/grievances', data: b)).data);
  Future<List<Map>> grievances() async => _l((await _d.get('/nagarik/grievances')).data);
  Future<Map> grievance(String id) async => _u((await _d.get('/nagarik/grievances/$id')).data);
  Future<Map> createTicket(Map<String, dynamic> b) async => _u((await _d.post('/nagarik/tickets', data: b)).data);
  Future<List<Map>> tickets() async => _l((await _d.get('/nagarik/tickets')).data);
  Future<List<Map>> ticketMessages(String id) async => _l((await _d.get('/nagarik/tickets/$id/messages')).data);
  Future<void> sendTicketMessage(String id, String msg) => _d.post('/nagarik/tickets/$id/messages', data: {'message': msg});
}

class InfoRepository {
  InfoRepository(this._d); final Dio _d;
  Future<List<Map>> articles() async => _l((await _d.get('/info')).data);
  Future<List<Map>> emergency() async => _l((await _d.get('/info/emergency')).data);
  Future<Map> article(String id) async => _u((await _d.get('/info/$id')).data);
}

class FuneralRepository {
  FuneralRepository(this._d); final Dio _d;
  Future<List<Map>> units() async => _l((await _d.get('/funeral/units')).data);
  Future<Map> request(Map<String, dynamic> b) async => _u((await _d.post('/funeral/requests', data: b)).data);
}
