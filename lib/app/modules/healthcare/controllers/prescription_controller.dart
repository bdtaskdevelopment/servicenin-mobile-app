import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';

import '../../../core/helpers/snack_helper.dart';
import '../../../data/models/response/healthcare_response.dart';
import '../../../data/repositories/healthcare.repo.dart';

class Medicine {
  const Medicine(this.name, this.dose, this.duration, this.timing);
  final String name;
  final String dose;
  final String duration;
  final String timing;
}

class PrescriptionController extends GetxController {
  HealthcareRepository get _repo => Get.find<HealthcareRepository>();

  Prescription? rx;
  bool loading = false;
  bool downloading = false;

  @override
  void onInit() {
    super.onInit();
    fetchLatest();
  }

  Future<void> fetchLatest() async {
    loading = true;
    update();
    try {
      rx = await _repo.fetchLatestPrescription();
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loading = false;
      update();
    }
  }

  // View-facing getters (names kept stable for the existing view).
  String get apptId => 'Latest Rx';
  String get date => rx?.dateLabel ?? '';
  String get doctor => (rx?.doctorName.isNotEmpty ?? false) ? rx!.doctorName : 'Doctor';
  String get degree => rx?.doctorSpecialty ?? '';
  String get patient => rx?.patientName ?? '';
  String get diagnosis => rx?.diagnosis ?? '';
  String get advice => rx?.advice ?? '';

  List<Medicine> get meds => (rx?.items ?? []).map((it) {
        final name = [it.tradeName, it.strength]
            .where((s) => s.isNotEmpty)
            .join(' ');
        return Medicine(
          name.isNotEmpty ? name : it.genericName,
          it.dosage,
          it.duration,
          it.frequency,
        );
      }).toList();

  Future<void> download() async {
    final id = rx?.id;
    if (id == null || id.isEmpty || downloading) return;
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
