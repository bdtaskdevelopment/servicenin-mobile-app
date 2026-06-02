import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/home_service_controller.dart';

const _teal = Color(0xFF0E9F8E);
const _darkTeal = Color(0xFF0E7C6B);
const _tile = Color(0xFFE0F2EF);

class ConfirmBookingView extends GetView<HomeServiceController> {
  const ConfirmBookingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: GetBuilder<HomeServiceController>(
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
                      const Text('Confirm booking',
                          style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                    ],
                  ),
                ),
                const _Stepper(current: 1),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                    children: [
                      // Cart summary
                      ...con.cartItems.map((s) => Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(14)),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${s.name} ×${con.qtyOf(s)}',
                                    style: const TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF0F172A))),
                                Text('৳${s.price * con.qtyOf(s)}',
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A))),
                              ],
                            ),
                          )),
                      const SizedBox(height: 10),
                      const _Label('SERVICE ADDRESS'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(14)),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                  color: _tile,
                                  borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.location_on_outlined,
                                  color: _teal, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(con.address,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF0F172A))),
                                  const SizedBox(height: 2),
                                  const Text('From your profile · GPS pinned',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF94A3B8))),
                                ],
                              ),
                            ),
                            const Text('Change',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.brandOrange)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      const _Label('WHEN?'),
                      const SizedBox(height: 10),
                      Row(
                        children: List.generate(con.bookingDates.length, (i) {
                          final sel = con.selectedBookingDate == i;
                          final d = con.bookingDates[i];
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  right: i == con.bookingDates.length - 1
                                      ? 0
                                      : 10),
                              child: GestureDetector(
                                onTap: () => con.selectBookingDate(i),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: sel ? _darkTeal : AppColors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: sel
                                            ? _darkTeal
                                            : const Color(0xFFE2E8F0)),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(d.$1,
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: sel
                                                  ? Colors.white
                                                  : const Color(0xFF64748B))),
                                      const SizedBox(height: 2),
                                      Text(d.$2,
                                          style: TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w800,
                                              color: sel
                                                  ? Colors.white
                                                  : const Color(0xFF0F172A))),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 12),
                      GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 2.4,
                        children: con.bookingTimes.map((t) {
                          final sel = con.selectedBookingTime == t;
                          return GestureDetector(
                            onTap: () => con.selectBookingTime(t),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: sel ? _darkTeal : AppColors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: sel
                                        ? _darkTeal
                                        : const Color(0xFFE2E8F0)),
                              ),
                              child: Text(t,
                                  style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: sel
                                          ? Colors.white
                                          : const Color(0xFF0F172A))),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),
                      const _Label('PAYMENT'),
                      const SizedBox(height: 10),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 3.0,
                        children: List.generate(con.payments.length, (i) {
                          final p = con.payments[i];
                          final sel = con.selectedPayment == i;
                          return GestureDetector(
                            onTap: () => con.selectPayment(i),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: sel
                                        ? _teal
                                        : const Color(0xFFE2E8F0),
                                    width: sel ? 1.6 : 1.2),
                              ),
                              child: Row(
                                children: [
                                  Icon(p.$2, color: p.$3, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(p.$1,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF0F172A))),
                                  ),
                                  if (sel)
                                    const Icon(Icons.check_circle,
                                        size: 16, color: _teal),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                // Bottom
                Container(
                  color: AppColors.white,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Total - pay after',
                              style: TextStyle(
                                  fontSize: 11.5, color: Color(0xFF94A3B8))),
                          Text('৳${con.totalPrice}',
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
                            onPressed: con.placeBooking,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _darkTeal,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Text('Place booking',
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

class _Stepper extends StatelessWidget {
  const _Stepper({required this.current});
  final int current;
  static const _labels = ['Services', 'Schedule', 'Confirm'];
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF7F8FA),
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
      child: Row(
        children: List.generate(_labels.length, (i) {
          final done = i < current;
          final active = i == current;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                      color: (done || active)
                          ? _darkTeal
                          : const Color(0xFFE2E8F0),
                      shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: done
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : Text('${i + 1}',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: active
                                  ? Colors.white
                                  : const Color(0xFF94A3B8))),
                ),
                const SizedBox(width: 6),
                Text(_labels[i],
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: (done || active)
                            ? _darkTeal
                            : const Color(0xFF94A3B8))),
                if (i != _labels.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      color: done ? _darkTeal : const Color(0xFFE2E8F0),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
