import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/jobs_controller.dart';

const _orange = Color(0xFFC2410C);

class JobApplyView extends GetView<JobsController> {
  const JobApplyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: GetBuilder<JobsController>(
          builder: (con) => Column(
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Apply'.tr,
                            style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A))),
                        Text(con.selected?.title ?? '',
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
                    // "Your job profile" entry hidden for now.
                    // GestureDetector(
                    //   onTap: con.openSeekerProfile,
                    //   child: Container(
                    //     padding: const EdgeInsets.all(14),
                    //     decoration: BoxDecoration(
                    //         color: AppColors.white,
                    //         borderRadius: BorderRadius.circular(14),
                    //         border: Border.all(
                    //             color: _orange.withValues(alpha: 0.4))),
                    //     child: Row(
                    //       children: [
                    //         const Icon(Icons.person_outline_rounded,
                    //             color: _orange, size: 22),
                    //         const SizedBox(width: 12),
                    //         Expanded(
                    //           child: Column(
                    //             crossAxisAlignment: CrossAxisAlignment.start,
                    //             children: [
                    //               Text('Your job profile'.tr,
                    //                   style: const TextStyle(
                    //                       fontSize: 14.5,
                    //                       fontWeight: FontWeight.w800,
                    //                       color: Color(0xFF0F172A))),
                    //               const SizedBox(height: 2),
                    //               Text('Set up name, skills & experience'.tr,
                    //                   style: const TextStyle(
                    //                       fontSize: 12,
                    //                       color: Color(0xFF94A3B8))),
                    //             ],
                    //           ),
                    //         ),
                    //         const Icon(Icons.chevron_right_rounded,
                    //             color: Color(0xFF94A3B8)),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(height: 18),
                    _Label('${'RESUME'.tr} *'),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: con.uploadingResume
                          ? null
                          : con.pickAndUploadResume,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: const Color(0xFFEDEFF2))),
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      con.resumeName.isNotEmpty
                                          ? con.resumeName
                                          : 'Upload your resume'.tr,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF0F172A))),
                                  const SizedBox(height: 2),
                                  Text(
                                      con.resumeName.isNotEmpty
                                          ? 'Tap to replace'.tr
                                          : 'PDF, DOC or DOCX'.tr,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF94A3B8))),
                                ],
                              ),
                            ),
                            con.uploadingResume
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2.2, color: _orange),
                                  )
                                : Icon(
                                    con.resumeUrl.isNotEmpty
                                        ? Icons.check_rounded
                                        : Icons.upload_file_rounded,
                                    color: con.resumeUrl.isNotEmpty
                                        ? const Color(0xFF16A34A)
                                        : _orange,
                                    size: 22),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _Label('EXPECTED SALARY'.tr),
                    const SizedBox(height: 10),
                    _Field(con.expectedSalary, 'e.g. 70000'.tr,
                        kb: TextInputType.number, boxed: true),
                    const SizedBox(height: 14),
                    _Label('AVAILABILITY'.tr),
                    const SizedBox(height: 10),
                    _Field(con.availability, 'e.g. Immediate / 1 month'.tr,
                        boxed: true),
                    const SizedBox(height: 14),
                    _Label('COVER LETTER'.tr),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(14),
                          border:
                              Border.all(color: const Color(0xFFEDEFF2))),
                      child: TextField(
                        controller: con.coverLetter,
                        maxLines: 5,
                        style: const TextStyle(
                            fontSize: 13.5,
                            height: 1.5,
                            color: Color(0xFF475569)),
                        decoration: InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          hintText:
                              'Tell the employer why you are a great fit…'.tr,
                          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                        ),
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
                    onPressed:
                        con.applying ? null : con.submitApplication,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _orange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: con.applying
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.4, color: Colors.white),
                          )
                        : Text('Submit application'.tr,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
            ],
          ),
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

class _Field extends StatelessWidget {
  const _Field(this.controller, this.hint,
      {this.kb = TextInputType.text, this.boxed = false});
  final TextEditingController controller;
  final String hint;
  final TextInputType kb;
  final bool boxed;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: boxed ? 0 : 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEDEFF2))),
        child: TextField(
          controller: controller,
          keyboardType: kb,
          style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A)),
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            hintStyle: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFFB8C0CC)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }
}
