import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/booking_controller.dart';
import '../widgets/booking_stepper.dart';

const _green = Color(0xFF0F7A52);
const _tile = Color(0xFFD9F7E6);

class ReviewConfirmView extends GetView<BookingController> {
  const ReviewConfirmView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: GetBuilder<BookingController>(
          builder: (con) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 16, 4),
                  child: Row(
                    children: [
                      IconButton(
                        splashRadius: 22,
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 20, color: Color(0xFF1A1A1A)),
                      ),
                      Text('Review & confirm'.tr,
                          style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                    ],
                  ),
                ),
                const BookingStepper(current: 2),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                    children: [
                      // Summary card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                      color: _tile,
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                  alignment: Alignment.center,
                                  child: Text(con.doctorInitials,
                                      style: const TextStyle(
                                          color: _green,
                                          fontWeight: FontWeight.w800)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(con.doctorName,
                                          style: const TextStyle(
                                              fontSize: 15.5,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF0F172A))),
                                      const SizedBox(height: 2),
                                      Text('${con.doctorSpecialty} · MBBS',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF94A3B8))),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child:
                                  Divider(height: 1, color: Color(0xFFF1F5F9)),
                            ),
                            _line(Icons.location_on_outlined, con.venueName),
                            const SizedBox(height: 10),
                            _line(Icons.calendar_today_outlined,
                                con.whenSummary),
                            const SizedBox(height: 10),
                            _line(Icons.person_outline_rounded,
                                '${con.patientName} · ${'General consultation'.tr}'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      _Label('FEE BREAKDOWN'.tr),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(14)),
                        child: Column(
                          children: [
                            _fee('Consultation fee'.tr, con.consultationFee, false),
                            const Divider(height: 1, color: Color(0xFFF1F5F9)),
                            _fee('Platform fee'.tr, con.platformFee, false),
                            if (con.vatApplies) ...[
                              const Divider(
                                  height: 1, color: Color(0xFFF1F5F9)),
                              _fee('${'VAT'.tr} (${con.vatPercentLabel}%)',
                                  con.vatLabel, false),
                            ],
                            const Divider(height: 1, color: Color(0xFFF1F5F9)),
                            _fee('First-visit discount'.tr,
                                con.firstVisitDiscount, true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF7F0),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _green),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('TOTAL PAYABLE'.tr,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A))),
                            Text(con.totalPayable,
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: _green)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      _Label('PAYMENT METHOD'.tr),
                      const SizedBox(height: 12),
                      if (con.loadingMethods && con.methods.isEmpty)
                        const SnListSkeleton(
                          count: 2,
                          padding: EdgeInsets.zero,
                          showTrailing: false,
                        )
                      else
                        Column(
                          children: con.enabledMethods
                              .map((m) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _PayCard(
                                      icon: _hcPayIcon(m.key),
                                      label: m.label,
                                      description: m.description,
                                      selected: con.selectedMethodKey == m.key,
                                      onTap: () => con.selectMethod(m.key),
                                    ),
                                  ))
                              .toList(),
                        ),
                    ],
                  ),
                ),
                Container(
                  color: AppColors.white,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Total'.tr,
                              style: const TextStyle(
                                  fontSize: 11.5, color: Color(0xFF94A3B8))),
                          Text(con.totalPayable,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A))),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            onPressed:
                                con.booking ? null : con.confirmBooking,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _green,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  _green.withValues(alpha: 0.6),
                              disabledForegroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            child: con.booking
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                        valueColor: AlwaysStoppedAnimation(
                                            Colors.white)),
                                  )
                                : Text('Confirm booking'.tr,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _line(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 18, color: _green),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155))),
          ),
        ],
      );

  Widget _fee(String label, String amount, bool discount) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style:
                    const TextStyle(fontSize: 13.5, color: Color(0xFF475569))),
            Text(amount,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: discount
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF0F172A))),
          ],
        ),
      );
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF94A3B8),
          letterSpacing: 0.6));
}

/// Icon for a payment method, chosen from its server key.
IconData _hcPayIcon(String key) {
  switch (key) {
    case 'cash':
      return Icons.payments_outlined;
    case 'sslcommerz':
    case 'card':
      return Icons.credit_card_rounded;
    case 'bkash':
    case 'nagad':
      return Icons.account_balance_wallet_outlined;
    default:
      return Icons.payment_rounded;
  }
}

class _PayCard extends StatelessWidget {
  const _PayCard(
      {required this.icon,
      required this.label,
      required this.selected,
      required this.onTap,
      this.description = ''});
  final IconData icon;
  final String label;
  final String description;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selected ? _green : const Color(0xFFE2E8F0),
              width: selected ? 1.6 : 1.2),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: selected ? _green : const Color(0xFF334155)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A))),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(description,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF94A3B8))),
                  ],
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, size: 18, color: _green),
          ],
        ),
      ),
    );
  }
}
