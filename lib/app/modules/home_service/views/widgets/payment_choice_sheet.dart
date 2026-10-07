import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/values/app_colors.dart';

/// The payment experience shown when a provider marks a job complete and a
/// balance is still owed. Three small, self-contained overlays:
///
///  * [PaymentChoiceSheet.show]  — the celebratory "choose how to pay" sheet
///    (Cash vs Online). Driven by the live `payment_prompt` WS event and by a
///    tapped "Payment due" notification.
///  * [showCashPendingDialog]    — confirmation after the customer picks Cash.
///  * [showPaymentSuccessDialog] — success acknowledgement (e.g. the provider
///    confirmed the cash, or an online payment went through).
///
/// All use Get overlays so they can be summoned from anywhere — including the
/// notification socket, which has no BuildContext of its own.
class PaymentChoiceSheet {
  PaymentChoiceSheet._();

  static bool isOpen = false;

  /// Shows the method chooser. [onOnline]/[onCash] run after the sheet closes.
  static Future<void> show({
    required double amount,
    required Future<void> Function() onOnline,
    required Future<void> Function() onCash,
  }) async {
    if (isOpen) return;
    isOpen = true;
    try {
      await Get.bottomSheet(
        _ChoiceSheet(amount: amount, onOnline: onOnline, onCash: onCash),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        isDismissible: true,
        enableDrag: true,
      );
    } finally {
      isOpen = false;
    }
  }
}

class _ChoiceSheet extends StatelessWidget {
  const _ChoiceSheet({
    required this.amount,
    required this.onOnline,
    required this.onCash,
  });

  final double amount;
  final Future<void> Function() onOnline;
  final Future<void> Function() onCash;

  String get _amt => '৳${amount.toStringAsFixed(amount % 1 == 0 ? 0 : 2)}';

  @override
  Widget build(BuildContext context) {
    final teal = AppColors.primaryColor;
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 10, 22, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 4),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(4)),
              ),
              const SizedBox(height: 20),
              // Celebratory badge
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  color: teal.withOpacity(.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.verified_rounded, color: teal, size: 38),
              ),
              const SizedBox(height: 14),
              Text(
                'Service complete!'.tr,
                style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 4),
              Text(
                'Choose how you’d like to pay'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13.5, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              // Amount due card
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                decoration: BoxDecoration(
                  color: teal.withOpacity(.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: teal.withOpacity(.18)),
                ),
                child: Column(
                  children: [
                    Text('Amount due'.tr,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: .4,
                            color: Color(0xFF64748B))),
                    const SizedBox(height: 2),
                    Text(_amt,
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: teal)),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _OptionCard(
                filled: true,
                accent: teal,
                icon: Icons.credit_card_rounded,
                title: 'Pay Online'.tr,
                subtitle: 'Card, bKash, Nagad & more — pay now securely'.tr,
                onTap: () async {
                  Get.back();
                  await onOnline();
                },
              ),
              const SizedBox(height: 12),
              _OptionCard(
                filled: false,
                accent: teal,
                icon: Icons.payments_rounded,
                title: 'Pay Cash'.tr,
                subtitle: 'Hand cash to your provider — he’ll confirm it'.tr,
                onTap: () async {
                  Get.back();
                  await onCash();
                },
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () => Get.back(),
                child: Text('Maybe later'.tr,
                    style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF94A3B8))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.filled,
    required this.accent,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool filled;
  final Color accent;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = filled ? Colors.white : const Color(0xFF0F172A);
    final sub = filled ? Colors.white.withOpacity(.85) : const Color(0xFF64748B);
    return Material(
      color: filled ? accent : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: filled
                ? null
                : Border.all(color: const Color(0xFFE2E8F0), width: 1.3),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: filled
                      ? Colors.white.withOpacity(.18)
                      : accent.withOpacity(.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: filled ? Colors.white : accent, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: fg)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(fontSize: 12.5, color: sub)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 15, color: filled ? Colors.white70 : accent),
            ],
          ),
        ),
      ),
    );
  }
}

/// Confirmation after the customer chooses to pay in cash. Reassures them the
/// provider has been told and will confirm receipt.
Future<void> showCashPendingDialog(double amount) async {
  final teal = AppColors.primaryColor;
  final amt = '৳${amount.toStringAsFixed(amount % 1 == 0 ? 0 : 2)}';
  await Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration:
                  BoxDecoration(color: teal.withOpacity(.10), shape: BoxShape.circle),
              child: Icon(Icons.payments_rounded, color: teal, size: 34),
            ),
            const SizedBox(height: 14),
            Text('${'Pay'.tr} $amt ${'in cash'.tr}',
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              '${'Please hand'.tr} $amt ${'to your service provider. He’ll confirm it in his app, and you’ll get a receipt notification.'.tr}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13.5, height: 1.4, color: Color(0xFF475569)),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: teal,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Got it'.tr,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: true,
  );
}

/// Success acknowledgement — e.g. the provider confirmed the cash payment, or
/// an online payment completed.
Future<void> showPaymentSuccessDialog({
  required String title,
  required String message,
}) async {
  const green = Color(0xFF16A34A);
  await Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                  color: green.withOpacity(.12), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_rounded,
                  color: green, size: 36),
            ),
            const SizedBox(height: 14),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13.5, height: 1.4, color: Color(0xFF475569))),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Done'.tr,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: true,
  );
}
