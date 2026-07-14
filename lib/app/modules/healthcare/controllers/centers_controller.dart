import 'package:get/get.dart';

import '../../../core/helpers/snack_helper.dart';
import '../../../data/models/response/healthcare_response.dart';
import '../../../data/repositories/healthcare.repo.dart';
import '../../../routes/app_pages.dart';
import 'healthcare_controller.dart';

/// Lists the healthcare centers a citizen can pick from before browsing
/// doctors — the entry point tapping "স্বাস্থ্যসেবা" from Home now lands on.
class HealthcareCentersController extends GetxController {
  HealthcareRepository get _repo => Get.find<HealthcareRepository>();

  List<HealthcareCenter> centers = [];
  bool loading = false;

  @override
  void onInit() {
    super.onInit();
    fetchCenters();
  }

  Future<void> fetchCenters() async {
    loading = true;
    update();
    try {
      centers = await _repo.fetchCenters();
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loading = false;
      update();
    }
  }

  /// Scopes the shared Healthcare home screen to this center, then opens it.
  void openCenter(HealthcareCenter c) {
    Get.find<HealthcareController>().selectCenter(c);
    Get.toNamed(Routes.HEALTHCARE);
  }
}
