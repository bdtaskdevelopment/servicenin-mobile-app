import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/booking_controller.dart';

const _green = Color(0xFF0F7A52);
const _tile = Color(0xFFD9F7E6);

class AppointmentConfirmedView extends GetView<BookingController> {
  const AppointmentConfirmedView({super.key});

  @override
  Widget build(BuildContext context) {
    final con = controller;
    return Scaffold(
      backgroundColor: const Color(0xFFEAF7F0),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 16),
                children: [
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                          color: _green, shape: BoxShape.circle),
                      child: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 40),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: Text('Appointment confirmed'.tr,
                        style: const TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A))),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text('Your appointment is confirmed'.tr,
                        style: const
                            TextStyle(fontSize: 13.5, color: Color(0xFF64748B))),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(18)),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                  color: _tile,
                                  borderRadius: BorderRadius.circular(14)),
                              alignment: Alignment.center,
                              child: Text(con.doctorInitials,
                                  style: const TextStyle(
                                      color: _green,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(con.doctorName,
                                      style: const TextStyle(
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF0F172A))),
                                  const SizedBox(height: 2),
                                  Text(con.doctorSpecialty,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF94A3B8))),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Text('SERIAL'.tr,
                                    style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF94A3B8))),
                                Text(con.token,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: _green)),
                              ],
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                        ),
                        _row(Icons.calendar_today_outlined, 'Date & time'.tr,
                            con.whenSummary),
                        const SizedBox(height: 12),
                        _row(Icons.location_on_outlined, 'Venue'.tr, con.venueName),
                        const SizedBox(height: 12),
                        _row(Icons.person_outline_rounded, 'Patient'.tr,
                            con.patientName),
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
                      onPressed: con.viewAppointment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text('View appointment'.tr,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: con.backToHealthcareHome,
                    child: Text('Back to Healthcare home'.tr,
                        style: const TextStyle(
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

  Widget _row(IconData icon, String label, String value) => Row(
        children: [
          Icon(icon, size: 18, color: _green),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style:
                      const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
              const SizedBox(height: 1),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A))),
            ],
          ),
        ],
      );
}

