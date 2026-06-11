import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';

import '../../../core/helpers/snack_helper.dart';
import '../../../data/models/response/healthcare_response.dart';
import '../../../data/repositories/healthcare.repo.dart';
import '../../../routes/app_pages.dart';

class AppointmentsController extends GetxController {
  HealthcareRepository get _repo => Get.find<HealthcareRepository>();

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

  Future<void> fetchMine() async {
    loading = true;
    update();
    try {
      all = await _repo.fetchMyAppointments();
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loading = false;
      update();
    }
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

  Future<void> reschedule(String scheduledAtIso) async {
    final a = selected;
    if (a == null) return;
    try {
      final res = await _repo.reschedule(a.id, scheduledAtIso, a.venueId);
      SnackHelper.success(res.message.isNotEmpty ? res.message : 'Rescheduled');
      await fetchDetail(a.id);
      await fetchMine();
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void openPrescription() => Get.toNamed(Routes.HEALTHCARE_PRESCRIPTION);

  bool downloading = false;
  Future<void> downloadPrescription(String id) async {
    if (downloading) return;
    downloading = true;
    update();
    try {
      SnackHelper.success('প্রেসক্রিপশন ডাউনলোড হচ্ছে…');
      final path = await _repo.downloadPrescription(id);
      final result = await OpenFilex.open(path);
      if (result.type != ResultType.done) {
        SnackHelper.error(result.type == ResultType.noAppToOpen
            ? 'PDF খোলার কোনো অ্যাপ পাওয়া যায়নি'
            : 'ফাইলটি খোলা যায়নি');
      }
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      downloading = false;
      update();
    }
  }
}
