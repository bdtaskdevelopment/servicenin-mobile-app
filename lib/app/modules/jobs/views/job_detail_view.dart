import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/jobs_controller.dart';

const _orange = Color(0xFFC2410C);
const _tile = Color(0xFFFCE6CB);

class JobDetailView extends GetView<JobsController> {
  const JobDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: GetBuilder<JobsController>(
          builder: (con) {
            final j = con.selected;
            if (j == null) return const SizedBox.shrink();
            return Column(
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
                      Text('Job detail'.tr,
                          style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                    ],
                  ),
                ),
                Expanded(
                  child: FadeInUp(
                    from: 18,
                    duration: const Duration(milliseconds: 350),
                    child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                                color: _tile,
                                borderRadius: BorderRadius.circular(14)),
                            alignment: Alignment.center,
                            child: Text(j.badge,
                                style: const TextStyle(
                                    color: _orange,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(j.title,
                                    style: const TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A))),
                                const SizedBox(height: 3),
                                Text(
                                    [j.companyName, j.location]
                                        .where((s) => s.isNotEmpty)
                                        .join(' · '),
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF94A3B8))),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _Stat(value: j.salaryLabel, label: 'Salary'.tr),
                          const SizedBox(width: 12),
                          _Stat(
                              value: j.experienceRequired.isNotEmpty
                                  ? j.experienceRequired
                                  : '—',
                              label: 'Experience'.tr),
                          const SizedBox(width: 12),
                          _Stat(value: j.jobTypeLabel, label: 'Type'.tr),
                        ],
                      ),
                      const SizedBox(height: 22),
                      _Head('About the role'.tr),
                      const SizedBox(height: 8),
                      Text(
                          j.description.isNotEmpty
                              ? j.description
                              : 'No description provided.'.tr,
                          style: const TextStyle(
                              fontSize: 13.5,
                              height: 1.5,
                              color: Color(0xFF475569))),
                      if (j.skills.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _Head('Requirements'.tr),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: j.skills
                              .map((s) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 7),
                                    decoration: BoxDecoration(
                                        color: _tile,
                                        borderRadius:
                                            BorderRadius.circular(8)),
                                    child: Text(s,
                                        style: const TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w700,
                                            color: _orange)),
                                  ))
                              .toList(),
                        ),
                      ],
                      if (j.education.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        _Head('Education'.tr),
                        const SizedBox(height: 8),
                        Text(j.education,
                            style: const TextStyle(
                                fontSize: 13.5, color: Color(0xFF475569))),
                      ],
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: const Color(0xFFEDEFF2))),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_rounded,
                                size: 20, color: _orange),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    j.deadline.isNotEmpty
                                        ? '${'Apply by'.tr} ${j.deadline}'
                                        : 'Open until filled'.tr,
                                    style: const TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A))),
                                const SizedBox(height: 2),
                                Text(
                                    '${j.totalApplications} people have applied · ${j.vacancyCount} vacancy',
                                    style: const TextStyle(
                                        fontSize: 12.5,
                                        color: Color(0xFF94A3B8))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: con.selectedAlreadyApplied
                        ? OutlinedButton.icon(
                            onPressed: null,
                            icon: const Icon(Icons.check_circle_rounded,
                                size: 20, color: Color(0xFF16A34A)),
                            label: Text('Already applied'.tr,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF15803D))),
                            style: OutlinedButton.styleFrom(
                              disabledForegroundColor: const Color(0xFF15803D),
                              backgroundColor: const Color(0xFFDCFCE7),
                              side: const BorderSide(color: Color(0xFFBBF7D0)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: con.applyToJob,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _orange,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            child: Text('Apply now'.tr,
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

class _Head extends StatelessWidget {
  const _Head(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: Color(0xFF0F172A)));
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
            color: const Color(0xFFEFF1F4),
            borderRadius: BorderRadius.circular(14)),
        child: Column(
          children: [
            Text(value.isNotEmpty ? value : '—',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A))),
            const SizedBox(height: 3),
            Text(label,
                style: const TextStyle(
                    fontSize: 11.5, color: Color(0xFF94A3B8))),
          ],
        ),
      ),
    );
  }
}
