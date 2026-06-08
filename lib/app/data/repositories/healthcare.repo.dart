import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/values/app_config.dart';
import '../../core/values/app_url.dart';
import '../../core/values/storage.dart';
import '../models/response/auth_response.dart';
import '../models/response/healthcare_response.dart';
import '../providers/healthcare.provider.dart';
import '../services/storage.service.dart';

class HealthcareRepository {
  HealthcareRepository({required this.provider});

  final HealthcareProvider provider;

  dynamic _payload(dynamic res) {
    final body = res.body;
    if (body is Map) return body;
    final raw = res.bodyString;
    if (raw != null && raw.toString().trim().isNotEmpty) return raw;
    throw Exception('সংযোগে সমস্যা — আবার চেষ্টা করুন');
  }

  // ── Departments & doctors ───────────────────────────────────────────
  Future<List<Department>> fetchDepartments() async {
    final res = await provider.getData(ApiURL.hcDepartments);
    return Department.listFromResponse(_payload(res));
  }

  Future<List<Doctor>> fetchDoctors({String? specialization}) async {
    final url = (specialization == null || specialization.isEmpty)
        ? ApiURL.hcDoctors
        : ApiURL.hcDoctorsBySpecialization(specialization);
    final res = await provider.getData(url);
    return Doctor.listFromResponse(_payload(res));
  }

  Future<List<Doctor>> fetchAvailableToday() async {
    final res = await provider.getData(ApiURL.hcDoctorsAvailableToday);
    return Doctor.listFromResponse(_payload(res));
  }

  Future<DoctorProfile> fetchDoctorProfile(String id) async {
    final res = await provider.getData(ApiURL.hcDoctorProfile(id));
    return DoctorProfile.fromResponse(_payload(res));
  }

  // ── Reviews ─────────────────────────────────────────────────────────
  Future<List<DoctorReview>> fetchReviews(String doctorId) async {
    final res = await provider.getData(ApiURL.hcDoctorReviews(doctorId));
    return DoctorReview.listFromResponse(_payload(res));
  }

  Future<AuthSimpleResponse> submitReview(
      String doctorId, int rating, String comment) async {
    final res = await provider.postData(
        ApiURL.hcDoctorReviews(doctorId), {'rating': rating, 'comment': comment});
    return AuthSimpleResponse.fromMap(_payload(res));
  }

  // ── Family ──────────────────────────────────────────────────────────
  Future<List<HcFamilyMember>> fetchFamily() async {
    final res = await provider.getData(ApiURL.hcFamily);
    return HcFamilyMember.listFromResponse(_payload(res));
  }

  Future<HcFamilyMember> addFamilyMember(Map<String, dynamic> payload) async {
    final res = await provider.postData(ApiURL.hcFamily, payload);
    return HcFamilyMember.fromResponse(_payload(res));
  }

  // ── Booking: venues / dates / slots ─────────────────────────────────
  Future<List<Venue>> fetchVenues(String doctorId) async {
    final res = await provider.getData(ApiURL.hcDoctorVenues(doctorId));
    return Venue.listFromResponse(_payload(res));
  }

  Future<List<ScheduleDate>> fetchScheduleDates(
      String doctorId, String venueId) async {
    final res =
        await provider.getData(ApiURL.hcScheduleDates(doctorId, venueId));
    return ScheduleDate.listFromResponse(_payload(res));
  }

  Future<List<TimeSlot>> fetchTimeSlots(
      String doctorId, String venueId, String date) async {
    final res =
        await provider.getData(ApiURL.hcTimeSlots(doctorId, venueId, date));
    return TimeSlot.listFromResponse(_payload(res));
  }

  /// Uploads a report and returns the stored attachment URL.
  Future<String> uploadDocument(File file) async {
    final res = await provider.uploadFile(ApiURL.hcDocumentsUpload, file);
    final body = _payload(res);
    final data = body is Map ? body['data'] : null;
    if (data is Map) {
      return (data['url'] ?? data['attachment_url'] ?? data['file_url'] ?? '')
          .toString();
    }
    return data?.toString() ?? '';
  }

  // ── Appointments ────────────────────────────────────────────────────
  Future<HcAppointment> bookAppointment(Map<String, dynamic> payload) async {
    final res = await provider.postData(ApiURL.hcAppointments, payload);
    return HcAppointment.fromResponse(_payload(res));
  }

  Future<List<HcAppointment>> fetchMyAppointments() async {
    final res = await provider.getData(ApiURL.hcAppointmentsMy);
    return HcAppointment.listFromResponse(_payload(res));
  }

  Future<HcAppointment> fetchAppointment(String id) async {
    final res = await provider.getData(ApiURL.hcAppointmentById(id));
    return HcAppointment.fromResponse(_payload(res));
  }

  Future<QueueInfo> fetchQueue(String id) async {
    final res = await provider.getData(ApiURL.hcAppointmentQueue(id));
    return QueueInfo.fromResponse(_payload(res));
  }

  Future<AuthSimpleResponse> reschedule(
      String id, String scheduledAt, String venueId) async {
    final res = await provider.patchData(ApiURL.hcAppointmentReschedule(id),
        {'scheduled_at': scheduledAt, 'venue_id': venueId});
    return AuthSimpleResponse.fromMap(_payload(res));
  }

  // ── Prescriptions ───────────────────────────────────────────────────
  Future<Prescription> fetchLatestPrescription() async {
    final res = await provider.getData(ApiURL.hcPrescriptionLatest);
    return Prescription.fromResponse(_payload(res));
  }

  Future<List<Prescription>> fetchPrescriptionsByDoctor(
      String doctorId) async {
    final res =
        await provider.getData(ApiURL.hcPrescriptionsByDoctor(doctorId));
    return Prescription.listFromByDoctor(_payload(res));
  }

  /// Downloads the prescription PDF (auth required) to a temp file and
  /// returns its local path.
  Future<String> downloadPrescription(String id) async {
    final dir = await getTemporaryDirectory();
    final savePath = '${dir.path}/prescription_$id.pdf';
    final token = StorageService.read(StorageConstants.accessToken);
    final dio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl, headers: {
      if (token != null) 'Authorization': 'Bearer $token',
    }));
    await dio.download(ApiURL.hcPrescriptionDownload(id), savePath);
    return savePath;
  }
}
