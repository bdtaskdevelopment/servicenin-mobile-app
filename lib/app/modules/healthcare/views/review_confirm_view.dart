import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
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
                      const Text('Review & confirm',
                          style: TextStyle(
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
                                'Today · 15 May · ${con.selectedTime} PM'),
                            const SizedBox(height: 10),
                            _line(Icons.person_outline_rounded,
                                '${con.patient.name} · General consultation'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      const _Label('FEE BREAKDOWN'),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(14)),
                        child: Column(
                          children: [
                            _fee('Consultation fee', con.consultationFee, false),
                            const Divider(height: 1, color: Color(0xFFF1F5F9)),
                            _fee('Platform fee', con.platformFee, false),
                            const Divider(height: 1, color: Color(0xFFF1F5F9)),
                            _fee('First-visit discount',
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
                            const Text('TOTAL PAYABLE',
                                style: TextStyle(
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
                      Row(
                        children: const [
                          _Label('PAYMENT METHOD'),
                          SizedBox(width: 8),
                          _V2Badge(),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                          'Current API books directly (no payment field) — pay at chamber. Online payment is planned for v2.',
                          style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                              height: 1.4)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                              child: _PayCard(
                                  icon: Icons.bolt_rounded,
                                  label: 'Cash at chamber',
                                  selected: con.selectedPay == 0,
                                  onTap: () => con.selectPay(0))),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _PayCard(
                                  icon: Icons.water_drop_rounded,
                                  label: 'bKash',
                                  selected: con.selectedPay == 1,
                                  onTap: () => con.selectPay(1))),
                        ],
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
                          const Text('Total',
                              style: TextStyle(
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
                            onPressed: con.confirmBooking,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _green,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Text('Confirm booking',
                                style: TextStyle(
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

class _V2Badge extends StatelessWidget {
  const _V2Badge();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(20)),
      child: const Text('● v2',
          style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFFB45309))),
    );
  }
}

class _PayCard extends StatelessWidget {
  const _PayCard(
      {required this.icon,
      required this.label,
      required this.selected,
      required this.onTap});
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selected ? _green : const Color(0xFFE2E8F0),
              width: selected ? 1.6 : 1.2),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF334155)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A))),
            ),
            if (selected)
              const Icon(Icons.check_circle, size: 18, color: _green),
          ],
        ),
      ),
    );
  }
}
