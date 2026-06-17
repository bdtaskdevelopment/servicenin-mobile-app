import 'dart:convert';

import '../../core/values/app_url.dart';
import '../providers/payment.provider.dart';

/// The SSLCommerz session returned by `/payments/sslcommerz/initiate`.
class SslcInitiation {
  const SslcInitiation({
    required this.tranId,
    required this.gatewayUrl,
    required this.sessionKey,
    required this.amount,
  });

  final String tranId;
  final String gatewayUrl;
  final String sessionKey;
  final double amount;

  factory SslcInitiation.fromMap(Map data) => SslcInitiation(
        tranId: (data['tran_id'] ?? '').toString(),
        gatewayUrl: (data['gateway_url'] ?? '').toString(),
        sessionKey: (data['sessionkey'] ?? '').toString(),
        amount: double.tryParse('${data['amount'] ?? 0}') ?? 0,
      );
}

class PaymentRepository {
  PaymentRepository({required this.provider});

  final PaymentProvider provider;

  Map _body(dynamic res) {
    final body = res.body;
    if (body is Map) return body;
    final raw = res.bodyString;
    if (raw is String && raw.trim().isNotEmpty) {
      final decoded = jsonDecode(raw);
      if (decoded is Map) return decoded;
    }
    throw Exception('সংযোগে সমস্যা — আবার চেষ্টা করুন');
  }

  /// POST /api/v1/payments/sslcommerz/initiate — create a checkout session.
  /// Only `amount` is required; the backend fills customer info and defaults
  /// for the *_url fields and auto-generates `tran_id` when blank.
  Future<SslcInitiation> initiate({
    required double amount,
    required String productName,
    required String category,
  }) async {
    final res = await provider.postData(ApiURL.paymentsSslcommerzInitiate, {
      'amount': amount,
      'product_name': productName,
      'product_category': category,
    });
    final body = _body(res);
    final data = body['data'] is Map ? body['data'] as Map : body;
    return SslcInitiation.fromMap(data);
  }
}
