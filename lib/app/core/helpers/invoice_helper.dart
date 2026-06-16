import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/services/storage.service.dart';
import '../values/app_config.dart';
import '../values/storage.dart';
import 'snack_helper.dart';

/// Fetches an invoice PDF (auth-protected) and opens it in the device viewer.
/// Used by the booking-detail screens across modules.
class InvoiceHelper {
  InvoiceHelper._();

  static bool _busy = false;

  static String _fullUrl(String relPath) {
    final base = AppConfig.baseUrl.endsWith('/')
        ? AppConfig.baseUrl.substring(0, AppConfig.baseUrl.length - 1)
        : AppConfig.baseUrl;
    final path = relPath.startsWith('/') ? relPath : '/$relPath';
    return '$base$path';
  }

  /// Opens the invoice PDF inline (view endpoint).
  static Future<void> view(String relPath, {String name = 'invoice'}) =>
      _fetchAndOpen(relPath, name, isDownload: false);

  /// Downloads the invoice PDF (attachment endpoint) and opens it.
  static Future<void> download(String relPath, {String name = 'invoice'}) =>
      _fetchAndOpen(relPath, name, isDownload: true);

  static Future<void> _fetchAndOpen(
    String relPath,
    String name, {
    required bool isDownload,
  }) async {
    if (_busy) return;
    _busy = true;
    try {
      final dir = await getTemporaryDirectory();
      final savePath = '${dir.path}/$name.pdf';
      final token = StorageService.read(StorageConstants.accessToken);
      final dio = Dio(BaseOptions(headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      }));
      await dio.download(_fullUrl(relPath), savePath);
      if (isDownload) SnackHelper.success('ইনভয়েস ডাউনলোড হয়েছে');
      await OpenFilex.open(savePath);
    } catch (_) {
      SnackHelper.error('ইনভয়েস আনতে সমস্যা হয়েছে');
    } finally {
      _busy = false;
    }
  }
}
