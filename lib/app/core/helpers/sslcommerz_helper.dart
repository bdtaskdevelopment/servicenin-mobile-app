import 'package:flutter_sslcommerz/model/SSLCSdkType.dart';
import 'package:flutter_sslcommerz/model/SSLCTransactionInfoModel.dart';
import 'package:flutter_sslcommerz/model/SSLCommerzInitialization.dart';
import 'package:flutter_sslcommerz/model/SSLCurrencyType.dart';
import 'package:flutter_sslcommerz/sslcommerz.dart';
import 'package:get/get.dart';

import '../../data/models/response/settings_response.dart';
import '../../data/repositories/payment.repo.dart';
import '../../data/services/settings.service.dart';

/// Result of an SSLCommerz checkout. On success, [valId] and [tranId] are the
/// values the booking APIs expect as `val_id` and `tran_id`.
class SslcResult {
  const SslcResult({this.success = false, this.valId = '', this.tranId = ''});
  final bool success;
  final String valId;
  final String tranId;
}

/// Thin wrapper around the SSLCommerz SDK (sandbox / TESTBOX).
class SslcommerzPay {
  SslcommerzPay._();

  // ── Credentials ──────────────────────────────────────────────────────
  // Prefer server-driven values from /api/v1/settings; fall back to the
  // sandbox store so checkout still works before settings load.
  static const String _fallbackStoreId = 'bdtas5e772deb8ff87';
  static const String _fallbackStorePasswd = 'bdtas5e772deb8ff87@ssl';

  static AppSettings? get _settings =>
      Get.isRegistered<SettingsService>() ? SettingsService.to.settings : null;

  static String get _storeId {
    final id = _settings?.sslcommerzStoreId ?? '';
    return id.isNotEmpty ? id : _fallbackStoreId;
  }

  static String get _storePasswd {
    final pwd = _settings?.sslcommerzStorePassword ?? '';
    return pwd.isNotEmpty ? pwd : _fallbackStorePasswd;
  }

  static bool get _isLive => _settings?.sslcommerzIsLive ?? false;

  /// Whether a payment-method key should route through the online gateway.
  static bool isOnline(String key) {
    final k = key.toLowerCase().trim();
    return k == 'sslcommerz' || k == 'online' || k == 'card';
  }

  /// Two-step checkout used by every paid booking:
  ///   1. `POST /payments/sslcommerz/initiate` → the backend creates a session
  ///      and returns the `tran_id` to use.
  ///   2. Open the SSLCommerz checkout with that `tran_id` → on success the
  ///      gateway returns a `val_id`.
  /// The returned [SslcResult] carries `val_id` + `tran_id` so the caller can
  /// add them (with `payment_method: "sslcommerz"`) to the booking payload.
  ///
  /// Throws if the SDK can't launch (e.g. plugin not registered / no native
  /// build) so callers can surface the real reason. Returns
  /// `success == false` when the user cancels or the gateway reports a
  /// non-success status.
  static Future<SslcResult> checkout({
    required double amount,
    required String productName,
    required String category,
  }) async {
    if (amount <= 0) return const SslcResult();

    // 1. Ask the backend to create a payment session (server tran_id).
    String tranId = '';
    try {
      final init = await Get.find<PaymentRepository>().initiate(
        amount: amount,
        productName: productName,
        category: category,
      );
      tranId = init.tranId;
    } catch (_) {
      // If initiate fails we fall back to a locally generated id below so the
      // user can still pay; the gateway is the source of truth for val_id.
    }
    if (tranId.isEmpty) {
      tranId = 'SN-${DateTime.now().millisecondsSinceEpoch}';
    }

    // 2. Open the SSLCommerz checkout with that tran_id.
    final sslcommerz = Sslcommerz(
      initializer: SSLCommerzInitialization(
        store_id: _storeId,
        store_passwd: _storePasswd,
        total_amount: amount,
        currency: SSLCurrencyType.BDT,
        tran_id: tranId,
        product_category: category,
        sdkType: _isLive ? SSLCSdkType.LIVE : SSLCSdkType.TESTBOX,
      ),
    );
    final SSLCTransactionInfoModel res = await sslcommerz.payNow();
    final status = (res.status ?? '').toUpperCase();
    final ok =
        status == 'VALID' || status == 'VALIDATED' || status == 'SUCCESS';
    return SslcResult(
      success: ok,
      valId: res.valId ?? '',
      tranId: (res.tranId?.isNotEmpty ?? false) ? res.tranId! : tranId,
    );
  }
}
