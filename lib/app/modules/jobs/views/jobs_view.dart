import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/jobs_response.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/jobs_controller.dart';

const _orange = Color(0xFFC2410C);
const _tile = Color(0xFFFCE6CB);

class JobsView extends GetView<JobsController> {
  const JobsView({super.key});

  @override
  Widget build(BuildContext context) {
    final con = controller;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      // "Post a job" hidden for now.
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: con.openPostJob,
      //   backgroundColor: _orange,
      //   foregroundColor: Colors.white,
      //   elevation: 2,
      //   icon: const Icon(Icons.add_rounded, size: 22),
      //   label: Text('Post a job'.tr,
      //       style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
      // ),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Jobs'.tr,
                          style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                      const SizedBox(height: 1),
                      Text('Find your next role'.tr,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
                  const Spacer(),
                  // User (seeker profile) icon hidden for now.
                  // GestureDetector(
                  //   onTap: con.openSeekerProfile,
                  //   child: const Icon(Icons.person_outline_rounded,
                  //       color: Color(0xFF1A1A1A), size: 22),
                  // ),
                  // const SizedBox(width: 16),
                  GestureDetector(
                    onTap: con.openApplications,
                    child: const Icon(Icons.business_center_outlined,
                        color: Color(0xFF1A1A1A), size: 22),
                  ),
                ],
              ),
            ),
            // Search
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                    color: const Color(0xFFEDEFF2),
                    borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: con.searchCtrl,
                        onChanged: con.onSearchChanged,
                        onSubmitted: con.onSearchSubmitted,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: 'Search title, company, skill'.tr,
                          hintStyle: const TextStyle(
                              color: Color(0xFF94A3B8), fontSize: 13.5),
                          border: InputBorder.none,
                          isCollapsed: true,
                        ),
                        style: const TextStyle(
                            fontSize: 13.5, color: Color(0xFF0F172A)),
                      ),
                    ),
                    GetBuilder<JobsController>(
                      builder: (con) => con.search.isEmpty
                          ? const SizedBox.shrink()
                          : GestureDetector(
                              onTap: con.clearSearch,
                              child: const Icon(Icons.close_rounded,
                                  size: 18, color: Color(0xFF94A3B8)),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            // Categories
            GetBuilder<JobsController>(
              builder: (con) {
                if (con.loadingCategories && con.categories.length <= 1) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SnChipsSkeleton(count: 5),
                    ),
                  );
                }
                return SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: con.categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final sel = con.categoryIndex == i;
                    return GestureDetector(
                      onTap: () => con.setCategory(i),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: sel ? _orange : AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color:
                                  sel ? _orange : const Color(0xFFE2E8F0)),
                        ),
                        child: Text(con.categories[i],
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: sel
                                    ? Colors.white
                                    : const Color(0xFF334155))),
                      ),
                    );
                  },
                ),
              );
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GetBuilder<JobsController>(
                builder: (con) {
                  if (con.loadingJobs && con.jobs.isEmpty) {
                    return const SnListSkeleton();
                  }
                  return RefreshIndicator(
                    color: _orange,
                    onRefresh: () => con.fetchJobs(reset: true),
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (n) {
                        if (n.metrics.pixels >=
                            n.metrics.maxScrollExtent - 200) {
                          con.loadMore();
                        }
                        return false;
                      },
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                        children: [
                          // "For employers" registration card hidden for now.
                          // GestureDetector(
                          //   onTap: con.openEmployerRegister,
                          //   child: _EmployerCard(),
                          // ),
                          // const SizedBox(height: 12),
                          if (con.jobs.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                  child: Text('No jobs found.'.tr,
                                      style: const TextStyle(
                                          color: Color(0xFF94A3B8)))),
                            )
                          else ...[
                            ...con.jobs.toList().asMap().entries.map((e) => FadeInUp(
                                  from: 18,
                                  duration: const Duration(milliseconds: 350),
                                  delay: Duration(milliseconds: 70 * e.key),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 12),
                                    child: GestureDetector(
                                      onTap: () => con.openJob(e.value),
                                      child: _JobCard(job: e.value),
                                    ),
                                  ),
                                )),
                            if (con.loadingMore)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Center(
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2.4, color: _orange)),
                              ),
                          ],
                        ],
                      ),
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

// Kept for when the employer/post-job feature is re-enabled.
// ignore: unused_element
class _EmployerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _orange.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
                color: _tile, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.apartment_rounded,
                color: _orange, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('For employers'.tr,
                    style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text('Register your company to post jobs'.tr,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({required this.job});
  final Job job;
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                    color: _tile, borderRadius: BorderRadius.circular(12)),
                alignment: Alignment.center,
                child: Text(job.badge,
                    style: const TextStyle(
                        color: _orange,
                        fontSize: 15,
                        fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job.title,
                        style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A))),
                    const SizedBox(height: 2),
                    Text(job.companyName.isNotEmpty ? job.companyName : job.category,
                        style: const TextStyle(
                            fontSize: 12.5, color: Color(0xFF94A3B8))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (job.jobTypeLabel.isNotEmpty) _Tag(job.jobTypeLabel, neutral: true),
              if (job.location.isNotEmpty) _Tag(job.location, neutral: true),
              if (job.isRemote) _Tag('Remote OK'.tr),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: _DashedDivider(),
          ),
          Row(
            children: [
              Text(job.salaryLabel,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _orange)),
              const Spacer(),
              Text(
                  [job.postedLabel, '${job.totalApplications} applied']
                      .where((s) => s.isNotEmpty)
                      .join(' · '),
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFFC2410C))),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.text, {this.neutral = false});
  final String text;
  final bool neutral;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: neutral ? const Color(0xFFEDEFF2) : _tile,
          borderRadius: BorderRadius.circular(8)),
      child: Text(text,
          style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: neutral ? const Color(0xFF475569) : _orange)),
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
