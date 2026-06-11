import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/jobs_controller.dart';

const _orange = Color(0xFFC2410C);

class JobSeekerProfileView extends GetView<JobsController> {
  const JobSeekerProfileView({super.key});

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
                        Text('Job profile'.tr,
                            style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A))),
                        const SizedBox(height: 1),
                        Text('Employers see this when you apply'.tr,
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
                    _Label('FULL NAME'.tr),
                    _Input(con.seekerName, 'Your full name'.tr),
                    const SizedBox(height: 14),
                    _Label('PHONE'.tr),
                    _Input(con.seekerPhone, '+8801XXXXXXXXX',
                        kb: TextInputType.phone),
                    const SizedBox(height: 14),
                    _Label('EMAIL'.tr),
                    _Input(con.seekerEmail, 'you@email.com',
                        kb: TextInputType.emailAddress),
                    const SizedBox(height: 14),
                    _Label('ADDRESS'.tr),
                    _Input(con.seekerAddress, 'e.g. Dhanmondi, Dhaka'.tr),
                    const SizedBox(height: 14),
                    _Label('DISTRICT'.tr),
                    _Input(con.seekerDistrict, 'e.g. Dhaka'.tr),
                    const SizedBox(height: 14),
                    _Label('SKILLS'.tr),
                    _Input(con.seekerSkills, 'e.g. Go, Flutter, SQL'.tr),
                    const SizedBox(height: 14),
                    _Label('EXPERIENCE (YEARS)'.tr),
                    _Input(con.seekerExp, 'e.g. 4'.tr,
                        kb: TextInputType.number),
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
                        con.savingSeeker ? null : con.submitSeekerProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _orange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: con.savingSeeker
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.4, color: Colors.white),
                          )
                        : Text('Save job profile'.tr,
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
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF94A3B8),
                letterSpacing: 0.6)),
      );
}

class _Input extends StatelessWidget {
  const _Input(this.controller, this.hint, {this.kb = TextInputType.text});
  final TextEditingController controller;
  final String hint;
  final TextInputType kb;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
