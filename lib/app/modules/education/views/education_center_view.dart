import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/education_response.dart';
import '../../../global_widget/rich_html_text.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/education_controller.dart';

const _orange = AppColors.brandOrange;
const _darkOrange = AppColors.brandOrangeDark;
const _tile = Color(0xFFFFEDE4);

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
                                      color: _orange,
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
                                color: _orange,
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
                        style: const TextStyle(fontSize: 12.5, color: _orange),
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
                          color: _tile,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              size: 18,
                              color: _darkOrange,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Register interest — the center calls you back to confirm seat & schedule. No online payment yet.'
                                    .tr,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  height: 1.4,
                                  color: _darkOrange,
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
        child: const Icon(Icons.menu_book_rounded, color: _orange, size: 30),
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
    return GestureDetector(
      onTap: () => con.openCourseDetails(course),
      child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEFF2)),
      ),
      child: Column(
        children: [
          if (course.displayThumbnail.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 8,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: course.displayThumbnail,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: _tile),
                      errorWidget: (_, __, ___) => Container(color: _tile),
                    ),
                    if (course.hasVideo)
                      Container(
                        color: Colors.black.withValues(alpha: 0.18),
                        alignment: Alignment.center,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.play_arrow_rounded,
                              color: _darkOrange, size: 26),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
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
                      color: _orange,
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
          if (course.description.isNotEmpty) ...[
            const SizedBox(height: 10),
            RichHtmlText(
              course.description,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.5,
                color: Color(0xFF475569),
              ),
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
              Text(
                'View details'.tr,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _darkOrange,
                ),
              ),
              const SizedBox(width: 2),
              const Icon(Icons.chevron_right_rounded,
                  size: 18, color: _darkOrange),
            ],
          ),
        ],
      ),
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
