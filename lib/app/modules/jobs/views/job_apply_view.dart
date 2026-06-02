import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/jobs_controller.dart';

const _orange = Color(0xFFC2410C);
const _tile = Color(0xFFFCE6CB);

class JobApplyView extends GetView<JobsController> {
  const JobApplyView({super.key});

  @override
  Widget build(BuildContext context) {
    final con = controller;
    final j = con.selected;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Apply',
                          style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                      Text(j?.title ?? 'Frontend Engineer',
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                children: [
                  const _Label('YOUR PROFILE'),
                  const SizedBox(height: 10),
                  // Profile card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFEDEFF2))),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                              color: _tile,
                              borderRadius: BorderRadius.circular(12)),
                          alignment: Alignment.center,
                          child: const Text('TA',
                              style: TextStyle(
                                  color: _orange,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800)),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Tanzil Ahmed',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A))),
                              SizedBox(height: 2),
                              Text('From ServiceNin profile · +880 1711-***123',
                                  style: TextStyle(
                                      fontSize: 11.5,
                                      color: Color(0xFF94A3B8))),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.circle,
                                  size: 7, color: Color(0xFF16A34A)),
                              SizedBox(width: 4),
                              Text('CV attached',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF15803D))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Resume card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFEDEFF2))),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                              color: const Color(0xFFEDEFF2),
                              borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.description_outlined,
                              color: Color(0xFF64748B), size: 21),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Resume_Tanzil.pdf',
                                  style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A))),
                              SizedBox(height: 2),
                              Text('Tap to replace',
                                  style: TextStyle(
                                      fontSize: 12, color: Color(0xFF94A3B8))),
                            ],
                          ),
                        ),
                        const Icon(Icons.check_rounded,
                            color: Color(0xFF16A34A), size: 22),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const _Label('COVER LETTER'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFEDEFF2))),
                    child: TextField(
                      maxLines: 6,
                      style: const TextStyle(
                          fontSize: 13.5,
                          height: 1.5,
                          color: Color(0xFF475569)),
                      decoration: const InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                      ),
                      controller: TextEditingController(
                          text:
                              'Dear Hiring Manager,\n\nI\'m excited to apply for the ${j?.title ?? 'Frontend Engineer'} role at ${j?.company ?? 'Bdtask Limited'}. With hands-on experience in modern web development, I\'d love to contribute to your team.'),
                    ),
                  ),
                ],
              ),
            ),
            // Submit
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: con.submitApplication,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _orange,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Submit application',
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
