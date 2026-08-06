import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/education_response.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/education_controller.dart';

const _purple = Color(0xFF7C3AED);
const _tile = Color(0xFFEDE4FB);

class EducationCenterView extends GetView<EducationController> {
  const EducationCenterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: GetBuilder<EducationController>(
          builder: (con) {
            final center = con.center;
            if (center == null) {
              return const SizedBox.shrink();
            }
            return Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 16, 4),
                  child: Row(
                    children: [
                      IconButton(
                        splashRadius: 22,
                        onPressed: () => Get.back(),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      Text(
                        'Center'.tr,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    children: [
                      // Cover banner (new field)
                      if (center.coverUrl.isNotEmpty) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: AspectRatio(
                            aspectRatio: 16 / 8,
                            child: CachedNetworkImage(
                              imageUrl: center.coverUrl,
                              fit: BoxFit.cover,
                              placeholder: (_, __) =>
                                  Container(color: const Color(0xFFF1F5F9)),
                              errorWidget: (_, __, ___) =>
                                  Container(color: _tile),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                      // Identity
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: SizedBox(
                              width: 64,
                              height: 64,
                              child: center.logoUrl.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: center.logoUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) =>
                                          Container(color: _tile),
                                      errorWidget: (_, __, ___) =>
                                          const _LogoFallback(),
                                    )
                                  : const _LogoFallback(),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  center.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  [
                                    center.typeLabel,
                                    center.locationLabel,
                                  ].where((s) => s.isNotEmpty).join(' · '),
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                                if (center.targetGrades.isNotEmpty) ...[
                                  const SizedBox(height: 5),
                                  Text(
                                    'Grades: ${center.targetGrades}',
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: _purple,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Meta rows (established / owner / timing) — new fields
                      if (center.establishedYear > 0)
                        _MetaRow(Icons.event_available_rounded,
                            '${'Established'.tr} ${center.establishedYear}'),
                      if (center.ownerName.isNotEmpty)
                        _MetaRow(Icons.person_outline_rounded, center.ownerName),
                      if (center.officeTiming.isNotEmpty)
                        _MetaRow(Icons.schedule_rounded, center.officeTiming),
                      if (center.address.isNotEmpty)
                        _MetaRow(Icons.location_on_outlined, center.address),
                      if (center.description.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Text(
                          center.description,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ],
                      // Contact channels (new: whatsapp / facebook / website)
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          if (center.contactPhone.isNotEmpty)
                            _ContactChip(
                                icon: Icons.call_rounded,
                                label: 'Call'.tr,
                                color: const Color(0xFF16A34A),
                                onTap: () => con.callCenter(center.contactPhone)),
                          if (center.whatsapp.isNotEmpty)
                            _ContactChip(
                                icon: Icons.chat_rounded,
                                label: 'WhatsApp'.tr,
                                color: const Color(0xFF25D366),
                                onTap: () => con.whatsappCenter(center.whatsapp)),
                          if (center.facebookPage.isNotEmpty)
                            _ContactChip(
                                icon: Icons.facebook_rounded,
                                label: 'Facebook'.tr,
                                color: const Color(0xFF1877F2),
                                onTap: () => con.openLink(center.facebookPage)),
                          if (center.website.isNotEmpty)
                            _ContactChip(
                                icon: Icons.language_rounded,
                                label: 'Website'.tr,
                                color: _purple,
                                onTap: () => con.openLink(center.website)),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'Courses & batches'.tr,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${con.courses.length} available',
                        style: const TextStyle(fontSize: 12.5, color: _purple),
                      ),
                      const SizedBox(height: 14),
                      if (con.loadingCourses && con.courses.isEmpty)
                        const SnListSkeleton(padding: EdgeInsets.zero, count: 3)
                      else if (con.courses.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            'No courses listed yet.'.tr,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        )
                      else
                        ...con.courses.toList().asMap().entries.map(
                          (e) => FadeInUp(
                            from: 18,
                            duration: const Duration(milliseconds: 350),
                            delay: Duration(milliseconds: 70 * e.key),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _CourseCard(course: e.value, con: con),
                            ),
                          ),
                        ),
                      const SizedBox(height: 4),
                      // Note
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF1FB),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.verified_user_outlined,
                              size: 18,
                              color: Color(0xFF2563EB),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Register interest — the center calls you back to confirm seat & schedule. No online payment yet.'
                                    .tr,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  height: 1.4,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

class _LogoFallback extends StatelessWidget {
  const _LogoFallback();
  @override
  Widget build(BuildContext context) => Container(
        color: _tile,
        alignment: Alignment.center,
        child: const Icon(Icons.menu_book_rounded, color: _purple, size: 30),
      );
}

class _MetaRow extends StatelessWidget {
  const _MetaRow(this.icon, this.text);
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 12.5, color: Color(0xFF475569))),
          ),
        ],
      ),
    );
  }
}

class _ContactChip extends StatelessWidget {
  const _ContactChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.30)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 17, color: color),
            const SizedBox(width: 7),
            Text(label,
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course, required this.con});
  final EduCourse course;
  final EducationController con;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEFF2)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      [
                        course.instructor,
                        course.durationText,
                      ].where((s) => s.isNotEmpty).join(' · '),
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              if (course.targetClass.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _tile,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    course.targetClass,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _purple,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (course.schedule.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 15,
                  color: Color(0xFF94A3B8),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    course.schedule,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: _DashedDivider(),
          ),
          Row(
            children: [
              Text(
                course.feeLabel,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: () => con.enquire(course),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _purple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Register'.tr,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
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
              width: dash,
              height: 1,
              color: const Color(0xFFEDEFF2),
            ),
          ),
        );
      },
    );
  }
}
