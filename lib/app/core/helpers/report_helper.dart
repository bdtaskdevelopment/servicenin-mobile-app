import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import 'snack_helper.dart';

/// Downloads an already-accessible file URL (e.g. a signed lab/X-ray
/// report URL — see PhysioAppointment.reportUrl) to the device and opens
/// it with the device's own handler. Unlike InvoiceHelper, this is not a
/// relative path under this app's own API, so no base-URL prefix or
/// Bearer auth header is added — the URL is fetched exactly as given.
class ReportHelper {
  ReportHelper._();

  static bool _busy = false;

  static Future<void> download(String url, {String name = 'report'}) async {
    if (_busy) return;
    _busy = true;
    try {
      final clean = url.split('?').first;
      final ext = clean.contains('.') ? clean.split('.').last : 'pdf';
      final dir = await getTemporaryDirectory();
      final savePath = '${dir.path}/$name.$ext';
      await Dio().download(url, savePath);
      SnackHelper.success('Report downloaded'.tr);
      await OpenFilex.open(savePath);
    } catch (_) {
      SnackHelper.error('Could not download the report'.tr);
    } finally {
      _busy = false;
    }
  }
}
