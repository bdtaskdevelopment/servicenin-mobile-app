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

  /// Opt-in per module (Get.arguments 'whatsapp': true) — adds a WhatsApp
  /// button beside the call button on each row.
  bool showWhatsApp = false;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      title = (args['title'] ?? title).toString();
      endpoint = (args['endpoint'] ?? '').toString();
      showWhatsApp = args['whatsapp'] == true;
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

  /// wa.me needs the international form with no '+' or leading zero, but the
  /// admin enters local Bangladeshi numbers ("01878889930") — 01… → 8801….
  static String whatsappDigits(String number) {
    final d = number.replaceAll(RegExp(r'[^0-9]'), '');
    if (d.startsWith('880')) return d;
    if (d.startsWith('0')) return '880${d.substring(1)}';
    if (d.length == 10 && d.startsWith('1')) return '880$d';
    return d;
  }

  /// Short codes / partial numbers can't be on WhatsApp, so the button is
  /// hidden for them rather than opening a chat that goes nowhere.
  static bool canWhatsApp(String number) => whatsappDigits(number).length >= 10;

  /// Opens the WhatsApp chat with [number] (falls back to the browser's
  /// wa.me page when the app isn't installed).
  Future<void> whatsapp(String number) async {
    final digits = whatsappDigits(number);
    if (digits.length < 10) return;
    try {
      final ok = await launchUrl(Uri.parse('https://wa.me/$digits'),
          mode: LaunchMode.externalApplication);
      if (!ok) SnackHelper.error('WhatsApp খোলা যায়নি');
    } catch (_) {
      SnackHelper.error('WhatsApp খোলা যায়নি');
    }
  }
}
