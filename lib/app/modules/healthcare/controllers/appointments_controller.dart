import 'package:get/get.dart';

import '../../../core/helpers/snack_helper.dart';
import '../../../data/models/response/healthcare_response.dart';
import '../../../data/repositories/healthcare.repo.dart';
import '../../../global_widget/pdf_preview_view.dart';
import '../../../routes/app_pages.dart';
import 'healthcare_controller.dart';

class AppointmentsController extends GetxController {
  HealthcareRepository get _repo => Get.find<HealthcareRepository>();
  String? get _centerId => Get.find<HealthcareController>().selectedCenter?.id;

  List<HcAppointment> all = [];
  bool loading = false;

  List<HcAppointment> get upcoming => all.where((a) => a.upcoming).toList();
  List<HcAppointment> get completed => all.where((a) => !a.upcoming).toList();

  // Selected appointment + its live queue + the doctor's prescriptions.
  HcAppointment? selected;
  QueueInfo? queue;
  bool loadingQueue = false;
  List<Prescription> doctorPrescriptions = [];
  bool loadingPrescriptions = false;

  @override
  void onInit() {
    super.onInit();
    fetchMine();
  }

  // The my-appointments list omits the doctor's name (it lives in the
  // doctor's user.profile). We resolve names by doctor_id and cache them.
  final Map<String, String> _doctorNames = {};

  String doctorNameFor(HcAppointment a) {
    final n = a.doctor?.fullName ?? '';
    if (n.isNotEmpty) return a.doctorName;
    final cached = _doctorNames[a.doctorId] ?? '';
    return cached.isNotEmpty ? cached : 'Doctor';
  }

  String doctorInitialsFor(HcAppointment a) {
    final name = doctorNameFor(a);
    if (name.isEmpty || name == 'Doctor') return 'D';
    final clean = name.replaceAll(
        RegExp(r'^(Dr\.?|ডা\.?)\s*', caseSensitive: false), '');
    final parts =
        clean.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'D';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  Future<void> fetchMine() async {
    loading = true;
    update();
    try {
      all = await _repo.fetchMyAppointments(centerId: _centerId);
      _resolveDoctorNames();
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loading = false;
      update();
    }
  }

  /// Fetches the name for each unique doctor whose name is missing from the
  /// appointments list, via the doctor profile endpoint (which includes it).
  Future<void> _resolveDoctorNames() async {
    final ids = <String>{};
    for (final a in all) {
      if ((a.doctor?.fullName ?? '').isEmpty &&
          a.doctorId.isNotEmpty &&
          !_doctorNames.containsKey(a.doctorId)) {
        ids.add(a.doctorId);
      }
    }
    if (ids.isEmpty) return;
    for (final id in ids) {
      try {
        final profile = await _repo.fetchDoctorProfile(id);
        final name = profile.doctor.fullName;
        if (name.isNotEmpty) _doctorNames[id] = name;
      } catch (_) {}
    }
    update();
  }

  void openAppointment(HcAppointment a) {
    selected = a;
    queue = null;
    doctorPrescriptions = [];
    update();
    fetchDetail(a.id);
    fetchQueue(a.id);
    fetchDoctorPrescriptions(a.doctorId);
    Get.toNamed(Routes.HC_QUEUE);
  }

  Future<void> fetchDetail(String id) async {
    try {
      selected = await _repo.fetchAppointment(id);
      update();
    } catch (_) {}
  }

  Future<void> fetchQueue(String id) async {
    loadingQueue = true;
    update();
    try {
      queue = await _repo.fetchQueue(id);
    } catch (_) {
    } finally {
      loadingQueue = false;
      update();
    }
  }

  Future<void> fetchDoctorPrescriptions(String doctorId) async {
    if (doctorId.isEmpty) return;
    loadingPrescriptions = true;
    update();
    try {
      doctorPrescriptions = await _repo.fetchPrescriptionsByDoctor(doctorId);
    } catch (_) {
    } finally {
      loadingPrescriptions = false;
      update();
    }
  }

  /// Currently-serving serial = my serial − people ahead of me.
  String get nowServingLabel {
    final q = queue;
    if (q == null) return '—';
    final serving = q.serialNo - q.aheadCount;
    return serving > 0 ? '$serving' : '—';
  }

  int get aheadCount => queue?.aheadCount ?? 0;
  int get estimatedWaitMin => queue?.estimatedWaitMin ?? 0;

  void openPrescription() => Get.toNamed(Routes.HEALTHCARE_PRESCRIPTION);

  bool downloading = false;

  /// Opens the prescription PDF in-app (view), from where the citizen can
  /// save or share it via the preview screen's built-in actions — no
  /// dependency on a device-installed PDF viewer.
  Future<void> downloadPrescription(String id) async {
    if (downloading) return;
    downloading = true;
    update();
    try {
      final bytes = await _repo.fetchPrescriptionPdfBytes(id);
      Get.to(() => PdfPreviewView(bytes: bytes, title: 'Prescription'.tr));
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      downloading = false;
      update();
    }
  }
}
