import 'package:get/get.dart';

import '../../core/values/app_url.dart';
import '../models/response/settings_response.dart';
import '../providers/app.provider.dart';

/// Holds the server-driven app settings (`/api/v1/settings`): VAT rate, payment
/// toggles, SSLCommerz credentials, currency and contact info. Fetched once at
/// startup; falls back to sane defaults until then (and if the call fails).
class SettingsService extends GetxService {
  static SettingsService get to => Get.find();

  AppSettings settings = const AppSettings();
  bool loaded = false;

  AppProvider get _provider => Get.find<AppProvider>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    try {
      final res = await _provider.getData(ApiURL.settings);
      final body = res.body;
      final data = (body is Map && body['data'] is Map)
          ? body['data'] as Map
          : (body is Map ? body : null);
      if (data != null) {
        settings = AppSettings.fromMap(data);
        loaded = true;
      }
    } catch (_) {
      // Keep defaults on any failure — booking/payment still work.
    }
  }

  // ── Convenience getters used across the app ──────────────────────────
  /// VAT as a fraction (e.g. 0.05). 0 when VAT is disabled server-side.
  double get vatFraction => settings.vatFraction;

  /// Whole-number VAT percent for labels (e.g. "5").
  String get vatPercentLabel {
    final r = settings.servicesVatRate;
    return r == r.roundToDouble() ? r.toInt().toString() : r.toString();
  }

  bool get vatEnabled => settings.servicesVatEnabled;
  String get currencySymbol => settings.currencySymbol;
}
