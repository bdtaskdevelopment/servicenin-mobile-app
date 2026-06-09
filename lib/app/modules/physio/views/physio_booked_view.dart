import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/physio_controller.dart';

const _brown = Color(0xFF8A3E12);

class PhysioBookedView extends GetView<PhysioController> {
  const PhysioBookedView({super.key});

  @override
  Widget build(BuildContext context) {
    final con = controller;
    final t = con.therapist;
    final center = con.center;
    return Scaffold(
      backgroundColor: const Color(0xFFFDF5EC),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 16),
                children: [
                  Center(
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: const BoxDecoration(
                          color: _brown, shape: BoxShape.circle),
                      child: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 42),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text('Session booked',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A))),
                  ),
                  const SizedBox(height: 6),
                  const Center(
                    child: Text('আপনার ফিজিও সেশন নিশ্চিত রয়েছে',
                        style: TextStyle(
                            fontSize: 13.5, color: Color(0xFF64748B))),
                  ),
                  const SizedBox(height: 26),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(18)),
                    child: Column(
                      children: [
                        _row(Icons.person_outline_rounded,
                            con.lastAppointment?.staffName.isNotEmpty == true
                                ? con.lastAppointment!.staffName
                                : (t?.name ?? '')),
                        const SizedBox(height: 14),
                        _row(Icons.meeting_room_outlined,
                            center?.name ?? ''),
                        const SizedBox(height: 14),
                        _row(
                            Icons.calendar_today_outlined,
                            con.lastAppointment?.whenLabel.isNotEmpty == true
                                ? con.lastAppointment!.whenLabel
                                : '${con.selectedDateLabel} · ${con.selectedTime}'),
                        const SizedBox(height: 14),
                        _row(
                            Icons.bolt_rounded,
                            con.sessionType == 1
                                ? 'Home visit · ${con.selectedPaymentKey}'
                                : 'At center · ${con.selectedPaymentKey}'),
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
                      onPressed: con.viewMySessions,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _brown,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('View my sessions',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: con.backToPhysioHome,
                    child: const Text('Back to Physio home',
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

  Widget _row(IconData icon, String value) => Row(
        children: [
          Icon(icon, size: 19, color: _brown),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A))),
          ),
        ],
      );
}
