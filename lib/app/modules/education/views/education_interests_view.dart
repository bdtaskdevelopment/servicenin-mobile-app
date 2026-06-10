import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/education_response.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/education_controller.dart';

const _purple = Color(0xFF7C3AED);
const _tile = Color(0xFFEDE4FB);
const _subtitle = Color(0xFF6B7A99);

class EducationInterestsView extends GetView<EducationController> {
  const EducationInterestsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
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
                  const Text('My enrollments',
                      style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A))),
                ],
              ),
            ),
            Expanded(
              child: GetBuilder<EducationController>(
                builder: (con) {
                  if (con.loadingInterests && con.myInterests.isEmpty) {
                    return const SnListSkeleton();
                  }
                  if (con.myInterests.isEmpty) {
                    return const _Empty();
                  }
                  return RefreshIndicator(
                    color: _purple,
                    onRefresh: con.fetchMyInterests,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: con.myInterests.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (_, i) =>
                          _InterestCard(item: con.myInterests[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 120),
        Icon(Icons.menu_book_rounded,
            size: 56, color: Colors.black.withValues(alpha: 0.18)),
        const SizedBox(height: 14),
        const Center(
          child: Text('No enrollments yet',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A))),
        ),
        const SizedBox(height: 6),
        const Center(
          child: Text('Courses you register interest in appear here.',
              style: TextStyle(fontSize: 13, color: _subtitle)),
        ),
      ],
    );
  }
}

class _InterestCard extends StatelessWidget {
  const _InterestCard({required this.item});
  final EduInterest item;

  bool get _isPending => item.status == 'pending';

  @override
  Widget build(BuildContext context) {
    final courseTitle = item.course?.title ?? '';
    final centerName = item.center?.name ?? '';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEDEFF2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                    color: _tile, borderRadius: BorderRadius.circular(11)),
                child: const Icon(Icons.menu_book_rounded,
                    color: _purple, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(courseTitle.isNotEmpty ? courseTitle : 'Course',
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A))),
                    if (centerName.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(centerName,
                          style: const TextStyle(
                              fontSize: 12.5, color: _subtitle)),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: _isPending
                        ? const Color(0xFFFEF3C7)
                        : const Color(0xFFD6F5E3),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(item.statusLabel,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _isPending
                            ? const Color(0xFFB45309)
                            : const Color(0xFF15803D))),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                _row('Student', item.studentName),
                if (item.subjectNeeded.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _row('Subject', item.subjectNeeded),
                ],
                if (item.preferredTime.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _row('Time', item.preferredTime),
                ],
                if (item.parentContact.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _row('Contact', item.parentContact),
                ],
              ],
            ),
          ),
          if (item.createdLabel.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text('Requested ${item.createdLabel}',
                style: const TextStyle(fontSize: 11.5, color: _subtitle)),
          ],
        ],
      ),
    );
  }

  Widget _row(String k, String v) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(k,
                style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: _subtitle)),
          ),
          Expanded(
            child: Text(v,
                style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A))),
          ),
        ],
      );
}
