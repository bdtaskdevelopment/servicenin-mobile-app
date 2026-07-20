import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/services/storage.service.dart';
import '../../global_widget/pdf_viewer_page.dart';
import '../values/app_config.dart';
import '../values/storage.dart';
import 'snack_helper.dart';

/// Fetches an invoice PDF (auth-protected). "View" renders it in-app; the
/// "download" endpoint saves it and hands off to the device's own viewer.
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

  static Dio _authedDio() {
    final token = StorageService.read(StorageConstants.accessToken);
    return Dio(BaseOptions(headers: {
      if (token != null) 'Authorization': 'Bearer $token',
    }));
  }

  /// Fetches the invoice PDF and shows it inline via [PdfViewerPage] —
  /// no dependency on the device having an external PDF viewer installed.
  static Future<void> view(String relPath, {String name = 'invoice'}) async {
    if (_busy) return;
    _busy = true;
    try {
      final response = await _authedDio().get<List<int>>(
        _fullUrl(relPath),
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) throw Exception('empty invoice');
      Get.to(() => PdfViewerPage(bytes: Uint8List.fromList(bytes), title: name));
    } catch (_) {
      SnackHelper.error('ইনভয়েস আনতে সমস্যা হয়েছে');
    } finally {
      _busy = false;
    }
  }

  /// Downloads the invoice PDF (attachment endpoint) and opens it with the
  /// device's default handler.
  static Future<void> download(String relPath, {String name = 'invoice'}) async {
    if (_busy) return;
    _busy = true;
    try {
      final dir = await getTemporaryDirectory();
      final savePath = '${dir.path}/$name.pdf';
      await _authedDio().download(_fullUrl(relPath), savePath);
      SnackHelper.success('ইনভয়েস ডাউনলোড হয়েছে');
      await OpenFilex.open(savePath);
    } catch (_) {
      SnackHelper.error('ইনভয়েস আনতে সমস্যা হয়েছে');
    } finally {
      _busy = false;
    }
  }
}
