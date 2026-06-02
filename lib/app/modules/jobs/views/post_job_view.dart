import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/jobs_controller.dart';

const _orange = Color(0xFFC2410C);
const _darkOrange = Color(0xFF9A3412);

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
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Post a job',
                            style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A))),
                        SizedBox(height: 1),
                        Text('Reach thousands of candidates',
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
                    // Banner
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [_darkOrange, _orange],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.business_center_outlined,
                                color: Colors.white, size: 22),
                          ),
                          const SizedBox(height: 14),
                          const Text('Hire faster on ServiceNin',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Text('Free for first 3 posts · verified candidates',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 12.5)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const _FieldLabel('JOB TITLE'),
                    const _InputField(hint: 'e.g. Frontend Engineer'),
                    const SizedBox(height: 14),
                    _FieldLabel('CATEGORY'),
                    _DropdownField(
                      value: con.postCategories[con.postCategoryIndex],
                      onTap: () => _pick(
                        title: 'Category',
                        options: con.postCategories,
                        selected: con.postCategoryIndex,
                        onSelect: con.setPostCategory,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _FieldLabel('JOB TYPE'),
                    _DropdownField(
                      value: con.postTypes[con.postTypeIndex],
                      onTap: () => _pick(
                        title: 'Job type',
                        options: con.postTypes,
                        selected: con.postTypeIndex,
                        onSelect: con.setPostType,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const _FieldLabel('LOCATION'),
                    const _InputField(hint: 'e.g. Gulshan, Dhaka'),
                    const SizedBox(height: 14),
                    const _FieldLabel('SALARY RANGE (৳)'),
                    const _InputField(hint: '60,000 – 100,000'),
                    const SizedBox(height: 14),
                    const _FieldLabel('DEADLINE'),
                    const _InputField(
                        hint: 'dd/mm/yyyy',
                        trailing: Icons.calendar_today_outlined),
                    const SizedBox(height: 14),
                    const _FieldLabel('DESCRIPTION'),
                    const _InputField(
                        hint: 'Describe responsibilities & requirements…',
                        maxLines: 4),
                  ],
                ),
              ),
              // Publish
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: con.publishJob,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _orange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Publish job',
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

  void _pick({
    required String title,
    required List<String> options,
    required int selected,
    required void Function(int) onSelect,
  }) {
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
            const SizedBox(height: 14),
            Text(title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A))),
            const SizedBox(height: 8),
            ...List.generate(options.length, (i) {
              final sel = i == selected;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                onTap: () {
                  onSelect(i);
                  Get.back();
                },
                title: Text(options[i],
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: sel ? FontWeight.w800 : FontWeight.w500,
                        color: sel
                            ? _orange
                            : const Color(0xFF334155))),
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

class _InputField extends StatelessWidget {
  const _InputField(
      {required this.hint, this.maxLines = 1, this.trailing});
  final String hint;
  final int maxLines;
  final IconData? trailing;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEDEFF2))),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              maxLines: maxLines,
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
          ),
          if (trailing != null)
            Icon(trailing, size: 19, color: const Color(0xFF94A3B8)),
        ],
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({required this.value, required this.onTap});
  final String value;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
              child: Text(value,
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
}
