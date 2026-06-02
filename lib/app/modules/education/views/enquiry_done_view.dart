import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/education_controller.dart';

const _purple = Color(0xFF7C3AED);

class EnquiryDoneView extends GetView<EducationController> {
  const EnquiryDoneView({super.key});

  @override
  Widget build(BuildContext context) {
    final con = controller;
    final course = con.course;
    final center = con.center;
    return Scaffold(
      backgroundColor: const Color(0xFFF3EEFC),
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
                          color: _purple, shape: BoxShape.circle),
                      child: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 42),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text('Enquiry submitted',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A))),
                  ),
                  const SizedBox(height: 6),
                  const Center(
                    child: Text('সেন্টার শীঘ্রই আপনাকে কল করবে',
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
                        _row(Icons.menu_book_rounded,
                            course?.title ?? 'HSC Physics (Batch 2026)'),
                        const SizedBox(height: 14),
                        _row(Icons.account_balance_outlined,
                            center?.name ?? 'Mentors Coaching Center'),
                        const SizedBox(height: 14),
                        _row(Icons.call_rounded,
                            'Center calls back within 24 hours'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: con.backToEducation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _purple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Back to Education',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String value) => Row(
        children: [
          Icon(icon, size: 19, color: _purple),
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
