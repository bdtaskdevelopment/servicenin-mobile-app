import 'package:flutter_sslcommerz/model/SSLCSdkType.dart';
import 'package:flutter_sslcommerz/model/SSLCTransactionInfoModel.dart';
import 'package:flutter_sslcommerz/model/SSLCommerzInitialization.dart';
import 'package:flutter_sslcommerz/model/SSLCurrencyType.dart';
import 'package:flutter_sslcommerz/sslcommerz.dart';
import 'package:get/get.dart';

import '../../data/models/response/settings_response.dart';
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

  /// Opens the native SSLCommerz checkout widget directly. On success the
  /// gateway returns a `val_id`; the returned [SslcResult] carries it plus
  /// `tran_id` so the caller can add them (with `payment_method:
  /// "sslcommerz"`) to the booking payload — the backend re-verifies val_id
  /// against SSLCommerz before settling.
  ///
  /// IMPORTANT: this does NOT call `POST /payments/sslcommerz/initiate`
  /// first. That endpoint creates its own SSLCommerz session server-side
  /// (meant for a hosted-checkout/WebView flow this app doesn't use) — if
  /// you reuse its `tran_id` here, the native SDK below creates a SECOND,
  /// colliding session for the same tran_id. In practice that was the cause
  /// of "bKash deducted the money but the app never showed a success page":
  /// the customer was paying against one session while the SDK's status
  /// check landed on the other. Always mint a fresh, local tran_id for the
  /// single session created here.
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

    final tranId = 'SN-${DateTime.now().millisecondsSinceEpoch}';

    // Open the SSLCommerz checkout with that tran_id — the only session
    // created for this payment.
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
    final valId = (res.valId ?? '').trim();
    // Success requires BOTH a success status AND a usable val_id. A cancelled
    // or closed session (status "closed"/"FAILED") carries no val_id, so even
    // if the SDK ever misreports the status, the absence of a val_id keeps us
    // from recording a payment the gateway never actually completed. The
    // backend re-verifies this val_id against SSLCommerz before settling.
    final ok = (status == 'VALID' ||
            status == 'VALIDATED' ||
            status == 'SUCCESS') &&
        valId.isNotEmpty;
    return SslcResult(
      success: ok,
      valId: valId,
      tranId: (res.tranId?.isNotEmpty ?? false) ? res.tranId! : tranId,
    );
  }
}
