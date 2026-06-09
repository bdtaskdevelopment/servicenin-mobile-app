import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/home_service_controller.dart';

const _darkTeal = Color(0xFF0E7C6B);

class BookingPlacedView extends GetView<HomeServiceController> {
  const BookingPlacedView({super.key});

  @override
  Widget build(BuildContext context) {
    final con = controller;
    return Scaffold(
      backgroundColor: const Color(0xFFEAF7F4),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 36, 20, 16),
                children: [
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                          color: _darkTeal, shape: BoxShape.circle),
                      child: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 40),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Center(
                    child: Text('Booking placed',
                        style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A))),
                  ),
                  const SizedBox(height: 6),
                  const Center(
                    child: Text('আমরা একজন দক্ষ টেকনিশিয়ান খুঁজছি…',
                        style:
                            TextStyle(fontSize: 13.5, color: Color(0xFF64748B))),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(18)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(con.bookingId,
                                style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF94A3B8))),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                  color: const Color(0xFFEDE9FE),
                                  borderRadius: BorderRadius.circular(20)),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.circle,
                                      size: 7, color: Color(0xFF7C3AED)),
                                  SizedBox(width: 4),
                                  Text('Finding pro',
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF7C3AED))),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(con.bookingSummary,
                            style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A))),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                        ),
                        _row(Icons.calendar_today_outlined, con.whenSummary),
                        const SizedBox(height: 10),
                        _row(Icons.location_on_outlined, con.address),
                        const SizedBox(height: 10),
                        _row(Icons.bolt_rounded,
                            'Pay after service · ৳${con.totalPaid}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: con.trackBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _darkTeal,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Track booking',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: con.backToHomeService,
                    child: const Text('Back to Home Service',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B))),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 18, color: _darkTeal),
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
}
