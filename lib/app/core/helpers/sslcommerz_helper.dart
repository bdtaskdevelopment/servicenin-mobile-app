import 'package:flutter_sslcommerz/model/SSLCSdkType.dart';
import 'package:flutter_sslcommerz/model/SSLCTransactionInfoModel.dart';
import 'package:flutter_sslcommerz/model/SSLCommerzInitialization.dart';
import 'package:flutter_sslcommerz/model/SSLCurrencyType.dart';
import 'package:flutter_sslcommerz/sslcommerz.dart';

/// Thin wrapper around the SSLCommerz SDK (sandbox / TESTBOX).
class SslcommerzPay {
  SslcommerzPay._();

  // ── Sandbox credentials ──────────────────────────────────────────────
  static const String _storeId = 'bdtas5e772deb8ff87';
  static const String _storePasswd = 'bdtas5e772deb8ff87@ssl';

  /// Whether a payment-method key should route through the online gateway.
  static bool isOnline(String key) {
    final k = key.toLowerCase().trim();
    return k == 'sslcommerz' || k == 'online' || k == 'card';
  }

  /// Opens the SSLCommerz checkout and returns true on a successful
  /// (VALID / VALIDATED) payment.
  /// Throws if the SDK can't launch (e.g. plugin not registered / no native
  /// build) so callers can surface the real reason instead of a generic
  /// "payment failed". Returns false when the user cancels or the gateway
  /// reports a non-success status.
  static Future<bool> pay({
    required double amount,
    required String tranId,
    String category = 'service',
  }) async {
    if (amount <= 0) return false;
    final sslcommerz = Sslcommerz(
      initializer: SSLCommerzInitialization(
        store_id: _storeId,
        store_passwd: _storePasswd,
        total_amount: amount,
        currency: SSLCurrencyType.BDT,
        tran_id: tranId,
        product_category: category,
        sdkType: SSLCSdkType.TESTBOX, // sandbox
      ),
    );
    final SSLCTransactionInfoModel res = await sslcommerz.payNow();
    final status = (res.status ?? '').toUpperCase();
    return status == 'VALID' ||
        status == 'VALIDATED' ||
        status == 'SUCCESS';
  }
}
