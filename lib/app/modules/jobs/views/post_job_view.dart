import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/jobs_controller.dart';

const _orange = Color(0xFFC2410C);
const _darkOrange = Color(0xFF9A3412);

String _humanize(String v) {
  final s = v.replaceAll('_', ' ');
  return s.isEmpty ? '' : s[0].toUpperCase() + s.substring(1);
}

class PostJobView extends GetView<JobsController> {
  const PostJobView({super.key});

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
                        Text('Post a job',
                            style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A))),
                        SizedBox(height: 1),
                        Text('Register as employer first',
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
                    GestureDetector(
                      onTap: con.openEmployerRegister,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [_darkOrange, _orange],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.apartment_rounded,
                                color: Colors.white, size: 26),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Employer registration',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800)),
                                  SizedBox(height: 2),
                                  Text('Tap to register your company',
                                      style: TextStyle(
                                          color: Color(0xFFFFE3D5),
                                          fontSize: 12)),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded,
                                color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const _FieldLabel('JOB TITLE'),
                    _Input(con.postTitle, 'e.g. Senior Go Engineer'),
                    const SizedBox(height: 14),
                    const _FieldLabel('CATEGORY'),
                    _Dropdown(
                      value: con.postCategory,
                      options: con.categories.where((c) => c != 'All').toList(),
                      onSelect: con.setPostCategory,
                    ),
                    const SizedBox(height: 14),
                    const _FieldLabel('JOB TYPE'),
                    _Dropdown(
                      value: con.postJobType,
                      options: con.jobTypes,
                      onSelect: con.setPostJobType,
                    ),
                    const SizedBox(height: 14),
                    const _FieldLabel('WORKPLACE'),
                    _Dropdown(
                      value: con.postWorkplace,
                      options: con.workplaceTypes,
                      onSelect: con.setPostWorkplace,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FieldLabel('LOCATION'),
                              _Input(con.postLocation, 'Dhaka'),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FieldLabel('DISTRICT'),
                              _Input(con.postDistrict, 'Dhaka'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FieldLabel('SALARY MIN'),
                              _Input(con.postSalaryMin, '80000',
                                  kb: TextInputType.number),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FieldLabel('SALARY MAX'),
                              _Input(con.postSalaryMax, '150000',
                                  kb: TextInputType.number),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FieldLabel('VACANCIES'),
                              _Input(con.postVacancy, '1',
                                  kb: TextInputType.number),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FieldLabel('DEADLINE'),
                              _Input(con.postDeadline, '2026-07-15'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const _FieldLabel('EXPERIENCE REQUIRED'),
                    _Input(con.postExperience, 'e.g. 3+ years'),
                    const SizedBox(height: 14),
                    const _FieldLabel('EDUCATION'),
                    _Input(con.postEducation, 'e.g. BSc in CSE'),
                    const SizedBox(height: 14),
                    const _FieldLabel('DESCRIPTION'),
                    _Input(con.postDescription, 'Short overview of the role…',
                        maxLines: 3),
                    const SizedBox(height: 14),
                    const _FieldLabel('REQUIREMENTS'),
                    _Input(con.postRequirements,
                        'e.g. 3+ years Go, PostgreSQL',
                        maxLines: 3),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: con.postingJob ? null : con.publishJob,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _orange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: con.postingJob
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.4, color: Colors.white),
                          )
                        : const Text('Publish job',
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

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
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
  const _Input(this.controller, this.hint,
      {this.maxLines = 1, this.kb = TextInputType.text});
  final TextEditingController controller;
  final String hint;
  final int maxLines;
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
        maxLines: maxLines,
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

class _Dropdown extends StatelessWidget {
  const _Dropdown(
      {required this.value, required this.options, required this.onSelect});
  final String value;
  final List<String> options;
  final void Function(String) onSelect;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pick(context),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEDEFF2))),
        child: Row(
          children: [
            Expanded(
              child: Text(value.isEmpty ? 'Select' : _humanize(value),
                  style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A))),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF64748B)),
          ],
        ),
      ),
    );
  }

  void _pick(BuildContext context) {
    if (options.isEmpty) return;
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 12),
            ...options.map((o) {
              final sel = o == value;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                onTap: () {
                  onSelect(o);
                  Get.back();
                },
                title: Text(_humanize(o),
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: sel ? FontWeight.w800 : FontWeight.w500,
                        color: sel ? _orange : const Color(0xFF334155))),
                trailing: sel
                    ? const Icon(Icons.check_rounded, color: _orange)
                    : null,
              );
            }),
          ],
        ),
      ),
    );
  }
}
