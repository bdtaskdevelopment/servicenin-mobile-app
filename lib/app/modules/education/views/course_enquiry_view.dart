import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/education_controller.dart';

const _purple = Color(0xFF7C3AED);
const _tileSel = Color(0xFFEDE4FB);

class CourseEnquiryView extends GetView<EducationController> {
  const CourseEnquiryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: GetBuilder<EducationController>(
          builder: (con) {
            final course = con.course;
            return Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 16, 8),
                  child: Row(
                    children: [
                      IconButton(
                        splashRadius: 22,
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 20, color: Color(0xFF1A1A1A)),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Enroll'.tr,
                                style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A))),
                            Text(course?.title ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 12, color: Color(0xFF94A3B8))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                    children: [
                      _Label('STUDENT GRADE'.tr),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: List.generate(con.grades.length, (i) {
                          final sel = con.gradeIndex == i;
                          return GestureDetector(
                            onTap: () => con.setGrade(i),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 10),
                              decoration: BoxDecoration(
                                color: sel ? _tileSel : AppColors.white,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                    color: sel
                                        ? _purple
                                        : const Color(0xFFE2E8F0),
                                    width: sel ? 1.6 : 1.2),
                              ),
                              child: Text(con.grades[i]['label']!,
                                  style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: sel
                                          ? _purple
                                          : const Color(0xFF334155))),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 18),
                      _InputCard(
                          controller: con.studentName,
                          label: 'STUDENT NAME'.tr,
                          hint: 'Full name'.tr),
                      const SizedBox(height: 12),
                      _InputCard(
                          controller: con.parentContact,
                          label: 'PARENT / GUARDIAN CONTACT'.tr,
                          hint: '+880 1XXXXXXXXX',
                          keyboard: TextInputType.phone),
                      const SizedBox(height: 12),
                      _InputCard(
                          controller: con.subjectNeeded,
                          label: 'SUBJECT NEEDED'.tr,
                          hint: 'e.g. Physics, Chemistry'.tr),
                      const SizedBox(height: 12),
                      _InputCard(
                          controller: con.preferredTime,
                          label: 'PREFERRED TIME'.tr,
                          hint: 'e.g. Evening (5-7 PM)'.tr),
                      const SizedBox(height: 12),
                      _InputCard(
                          controller: con.notes,
                          label: 'NOTES (OPTIONAL)'.tr,
                          hint: 'Anything the center should know…'.tr,
                          maxLines: 3),
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
                      onPressed:
                          con.submitting ? null : con.submitEnquiry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _purple,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: con.submitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.4, color: Colors.white),
                            )
                          : Text('Register interest'.tr,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800)),
                    ),
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

class _InputCard extends StatelessWidget {
  const _InputCard({
    required this.controller,
    required this.label,
    this.hint,
    this.maxLines = 1,
    this.keyboard,
  });
  final TextEditingController controller;
  final String label;
  final String? hint;
  final int maxLines;
  final TextInputType? keyboard;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEDEFF2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.6)),
          TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboard,
            style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFB8C0CC)),
            ),
          ),
        ],
      ),
    );
  }
}
