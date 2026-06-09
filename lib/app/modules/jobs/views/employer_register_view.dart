import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/jobs_controller.dart';

const _orange = Color(0xFFC2410C);
const _darkOrange = Color(0xFF9A3412);

class EmployerRegisterView extends GetView<JobsController> {
  const EmployerRegisterView({super.key});

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
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Employer registration',
                            style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A))),
                        SizedBox(height: 1),
                        Text('Register your company to post jobs',
                            style: TextStyle(
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
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [_darkOrange, _orange],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.apartment_rounded,
                                color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Text(
                                'Reach thousands of verified candidates on ServiceNin',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    height: 1.35)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const _Label('COMPANY NAME'),
                    _Input(con.empCompany, 'e.g. Tanzil Tech Ltd'),
                    const SizedBox(height: 14),
                    const _Label('CONTACT PERSON'),
                    _Input(con.empContact, 'Full name'),
                    const SizedBox(height: 14),
                    const _Label('PHONE'),
                    _Input(con.empPhone, '+8801XXXXXXXXX',
                        kb: TextInputType.phone),
                    const SizedBox(height: 14),
                    const _Label('EMAIL'),
                    _Input(con.empEmail, 'hr@company.com',
                        kb: TextInputType.emailAddress),
                    const SizedBox(height: 14),
                    const _Label('ADDRESS'),
                    _Input(con.empAddress, 'e.g. Gulshan, Dhaka'),
                    const SizedBox(height: 14),
                    const _Label('INDUSTRY'),
                    _Input(con.empIndustry, 'e.g. Technology'),
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
                        con.registeringEmployer ? null : con.registerEmployer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _orange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: con.registeringEmployer
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.4, color: Colors.white),
                          )
                        : const Text('Register company',
                            style: TextStyle(
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
