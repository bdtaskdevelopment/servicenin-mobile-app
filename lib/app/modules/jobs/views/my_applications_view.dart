import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/jobs_response.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/jobs_controller.dart';

const _orange = Color(0xFFC2410C);
const _tile = Color(0xFFFCE6CB);

class MyApplicationsView extends GetView<JobsController> {
  const MyApplicationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: Color(0xFF1A1A1A)),
        ),
        title: Text('My applications'.tr,
            style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A))),
      ),
      body: RefreshIndicator(
        color: _orange,
        onRefresh: controller.fetchMyApplications,
        child: GetBuilder<JobsController>(
          builder: (con) {
            if (con.loadingApplications && con.applications.isEmpty) {
              return const SnListSkeleton();
            }
            if (con.applications.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 140),
                  Center(
                    child: Text('No applications yet.'.tr,
                        style: const TextStyle(color: Color(0xFF94A3B8))),
                  ),
                ],
              );
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: con.applications
                  .toList()
                  .asMap()
                  .entries
                  .map((e) => FadeInUp(
                        from: 18,
                        duration: const Duration(milliseconds: 350),
                        delay: Duration(milliseconds: 70 * e.key),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GestureDetector(
                            onTap: () => con.openApplicationJob(e.value),
                            child: _AppCard(app: e.value),
                          ),
                        ),
                      ))
                  .toList(),
            );
          },
        ),
      ),
    );
  }
}

class _AppCard extends StatelessWidget {
  const _AppCard({required this.app});
  final JobApplicationModel app;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: _tile, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.business_center_outlined,
                    color: _orange, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(app.title,
                        style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A))),
                    const SizedBox(height: 2),
                    Text(
                        [app.company, app.appliedLabel]
                            .where((s) => s.isNotEmpty)
                            .join(' · '),
                        style: const TextStyle(
                            fontSize: 12.5, color: Color(0xFF94A3B8))),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: _DashedDivider(),
          ),
          Row(
            children: [
              _StatusPill(status: app.status),
              const Spacer(),
              if (app.expectedSalary.isNotEmpty)
                Text('${'Expected'.tr} ৳${app.expectedSalary}',
                    style: const TextStyle(
                        fontSize: 12.5, color: Color(0xFF94A3B8))),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final String status;
  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();
    late Color bg, dot, fg;
    late String label;
    if (s == 'shortlisted' || s == 'accepted' || s == 'hired') {
      bg = const Color(0xFFDCFCE7);
      dot = const Color(0xFF16A34A);
      fg = const Color(0xFF15803D);
    } else if (s == 'rejected' || s == 'not_selected') {
      bg = const Color(0xFFFEE2E2);
      dot = const Color(0xFFDC2626);
      fg = const Color(0xFFDC2626);
    } else {
      bg = const Color(0xFFE6E7FB);
      dot = const Color(0xFF6366F1);
      fg = const Color(0xFF4F46E5);
    }
    label = status.isEmpty
        ? 'Pending'.tr
        : status[0].toUpperCase() + status.substring(1).replaceAll('_', ' ');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 7, color: dot),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
        ],
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        const dash = 5.0;
        const gap = 4.0;
        final count = (c.maxWidth / (dash + gap)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            count,
            (_) => Container(
                width: dash, height: 1, color: const Color(0xFFE2E8F0)),
          ),
        );
      },
    );
  }
}
