import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/helpers/snack_helper.dart';
import '../../../data/models/response/healthcare_response.dart';
import '../../../data/repositories/healthcare.repo.dart';

/// "Telemedicine Call Center" — a small list of call/WhatsApp support desks
/// a citizen can contact directly, instead of booking a doctor slot.
class TelemedicineController extends GetxController {
  HealthcareRepository get _repo => Get.find<HealthcareRepository>();

  List<TelemedicineSupport> desks = [];
  bool loading = false;

  @override
  void onInit() {
    super.onInit();
    fetchDesks();
  }

  Future<void> fetchDesks() async {
    loading = true;
    update();
    try {
      desks = await _repo.fetchTelemedicineSupport();
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loading = false;
      update();
    }
  }

  Future<void> call(String phone) async {
    final digits = phone.trim();
    if (digits.isEmpty) return;
    try {
      await launchUrl(Uri.parse('tel:$digits'),
          mode: LaunchMode.externalApplication);
    } catch (_) {
      SnackHelper.error('ডায়াল করা যায়নি');
    }
  }

  Future<void> openWhatsApp(String url) async {
    if (url.trim().isEmpty) return;
    try {
      final ok = await launchUrl(Uri.parse(url.trim()),
          mode: LaunchMode.externalApplication);
      if (!ok) SnackHelper.error('WhatsApp খোলা যায়নি');
    } catch (_) {
      SnackHelper.error('WhatsApp খোলা যায়নি');
    }
  }
}
