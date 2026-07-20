import 'package:get/get.dart';

import '../../../data/models/response/blood_content_response.dart';
import '../../../data/repositories/blood.repo.dart';
import '../../../routes/app_pages.dart';

/// Drives the blood-bank "FAQ" list + detail screens. The API returns the
/// full answer text in the list response, so opening a FAQ never needs a
/// second network call — [selected] is just handed over.
class BloodFaqController extends GetxController {
  BloodRepository get _repo => Get.find<BloodRepository>();

  List<BloodFaq> faqs = [];
  bool loading = false;

  BloodFaq? selected;

  @override
  void onInit() {
    super.onInit();
    fetchFaqs();
  }

  Future<void> fetchFaqs() async {
    loading = true;
    update();
    try {
      faqs = await _repo.fetchFaqs();
    } catch (_) {
    } finally {
      loading = false;
      update();
    }
  }

  void openFaq(BloodFaq f) {
    selected = f;
    update();
    Get.toNamed(Routes.BLOOD_FAQ_DETAIL);
  }
}
