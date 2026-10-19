import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../core/values/app_url.dart';
import '../../../data/models/response/education_response.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../../support/views/support_view.dart';
import '../controllers/education_controller.dart';

const _orange = AppColors.brandOrange;
const _darkOrange = AppColors.brandOrangeDark;
const _tile = Color(0xFFFFEDE4);

class EducationView extends GetView<EducationController> {
  const EducationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 16, 8),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Training'.tr,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Coaching centers & tutors'.tr,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: controller.openMyInterests,
                    child: const Icon(
                      Icons.receipt_long_outlined,
                      color: Color(0xFF1A1A1A),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Support center — admin-configured numbers for this module.
                  SupportIconButton(
                    title: 'Training Support'.tr,
                    endpoint: ApiURL.trainingHotlines,
                  ),
                ],
              ),
            ),
            // Filter — a single button that opens a picker sheet, not a
            // row of always-visible tag chips.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerRight,
                child: GetBuilder<EducationController>(
                  builder: (con) {
                    if (con.loadingInstituteTypes &&
                        con.instituteTypes.isEmpty) {
                      return const SnChipsSkeleton(count: 1);
                    }
                    final selected = con.typeIndex > 0;
                    return GestureDetector(
                      onTap: () => _showFilterSheet(context, con),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          color: selected ? _tile : AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? _orange
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.tune_rounded,
                                size: 16,
                                color: selected
                                    ? _darkOrange
                                    : const Color(0xFF64748B)),
                            const SizedBox(width: 6),
                            Text(
                              selected ? con.typeLabel(con.typeIndex) : 'Filter'.tr,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: selected
                                    ? _darkOrange
                                    : const Color(0xFF334155),
                              ),
                            ),
                            if (selected) ...[
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () => con.setInstituteType(0),
                                child: const Icon(Icons.close_rounded,
                                    size: 15, color: _darkOrange),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GetBuilder<EducationController>(
                builder: (con) {
                  final list = con.centers;
                  return RefreshIndicator(
                    color: _orange,
                    onRefresh: con.fetchCentersNear,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      children: [
                        if (con.loadingCenters && con.centers.isEmpty)
                          const SnListSkeleton(
                            padding: EdgeInsets.zero,
                            count: 4,
                          )
                        else if (list.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Text(
                                'No centers found.'.tr,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ),
                          )
                        else
                          ...list.toList().asMap().entries.map(
                            (e) => FadeInUp(
                              from: 18,
                              duration: const Duration(milliseconds: 350),
                              delay: Duration(milliseconds: 70 * e.key),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: GestureDetector(
                                  onTap: () => con.openCenter(e.value),
                                  child: _CenterCard(center: e.value),
                                ),
                              ),
                            ),
                          ),
                      ],
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

  void _showFilterSheet(BuildContext context, EducationController con) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Filter by type'.tr,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A))),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: const Icon(Icons.close_rounded,
                          color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.55),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  itemCount: 1 + con.instituteTypes.length,
                  itemBuilder: (_, i) {
                    final sel = con.typeIndex == i;
                    return ListTile(
                      onTap: () {
                        con.setInstituteType(i);
                        Navigator.pop(ctx);
                      },
                      title: Text(con.typeLabel(i),
                          style: TextStyle(
                              fontSize: 14.5,
                              fontWeight:
                                  sel ? FontWeight.w800 : FontWeight.w600,
                              color: sel ? _darkOrange : const Color(0xFF334155))),
                      trailing: sel
                          ? const Icon(Icons.check_circle_rounded,
                              color: _orange, size: 20)
                          : null,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CenterCard extends StatelessWidget {
  const _CenterCard({required this.center});
  final EduCenter center;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _orange.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: _orange.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: center.logoUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: center.logoUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(color: _tile),
                          errorWidget: (_, __, ___) => const _CenterLogoIcon(),
                        )
                      : const _CenterLogoIcon(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            center.name,
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        if (center.featured)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Featured'.tr,
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFB45309),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            [
                              center.typeLabel,
                              center.locationLabel,
                            ].where((s) => s.isNotEmpty).join(' · '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: Color(0xFFCBD5E1)),
            ],
          ),
          if (center.subjectTags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: center.subjectTags
                  .take(5)
                  .map(
                    (t) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _tile,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        t,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: _darkOrange,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _CenterLogoIcon extends StatelessWidget {
  const _CenterLogoIcon();
  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_orange, _darkOrange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.menu_book_rounded,
            color: Colors.white, size: 23),
      );
}
