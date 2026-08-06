import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/helpers/snack_helper.dart';
import '../../../data/models/response/support_response.dart';
import '../../../data/repositories/support.repo.dart';

/// Drives the shared support screen for whichever module opened it.
///
/// The module is chosen by the caller through Get.arguments — {'title': …,
/// 'endpoint': 'api/v1/blood/hotlines'} — so home service, blood, info,
/// training and funeral all reuse one controller and one screen instead of
/// five copies that drift apart.
class SupportController extends GetxController {
  SupportRepository get _repo => Get.find<SupportRepository>();

  String title = 'Support Center';
  String endpoint = '';
  List<SupportHotline> hotlines = [];
  bool loading = false;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      title = (args['title'] ?? title).toString();
      endpoint = (args['endpoint'] ?? '').toString();
    }
    fetch();
  }

  Future<void> fetch() async {
    if (endpoint.isEmpty) return;
    loading = true;
    update();
    try {
      hotlines = await _repo.fetchHotlines(endpoint);
    } catch (_) {
      // Silent: an empty support screen already says "nothing to call",
      // and an error toast on top of that helps nobody.
    } finally {
      loading = false;
      update();
    }
  }

  Future<void> call(String number) async {
    final digits = number.trim();
    if (digits.isEmpty) return;
    try {
      await launchUrl(Uri.parse('tel:$digits'),
          mode: LaunchMode.externalApplication);
    } catch (_) {
      SnackHelper.error('ডায়াল করা যায়নি');
    }
  }
}
