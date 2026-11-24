import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../core/values/app_url.dart';
import '../../../data/models/response/education_response.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../../../routes/app_pages.dart';
import '../controllers/education_controller.dart';

const _violet = Color(0xFF7C3AED);
const _violetDark = Color(0xFF6D28D9);
const _tile = Color(0xFFF3EEFC);
const _amberBg = Color(0xFFFEF3C7);
const _amberText = Color(0xFFB45309);

/// Icons for the filter sheet rows — index 0 is "All"; the rest line up with
/// the 6 canonical institute-type slugs the backend seeds on boot.
const Map<String, IconData> _typeIcons = {
  'training_center': Icons.school_rounded,
  'private_batch': Icons.groups_rounded,
  'admission_coaching': Icons.auto_stories_rounded,
  'skill_development': Icons.build_rounded,
  'language_center': Icons.translate_rounded,
  'online_academy': Icons.laptop_mac_rounded,
};

/// Flat pastel palette for a center's avatar fallback, picked by its
/// position in the list — the mockup uses a different flat color per card
/// rather than tying color to institute type.
const List<Color> _avatarPalette = [
  Color(0xFF2563EB),
  Color(0xFFF97316),
  Color(0xFF0D9488),
  Color(0xFF7C3AED),
  Color(0xFFDB2777),
  Color(0xFF16A34A),
];

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
            Container(
              color: AppColors.white,
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
                        'Training centers & courses'.tr,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  _HeaderIconButton(
                    icon: Icons.receipt_long_outlined,
                    onTap: controller.openMyInterests,
                  ),
                  const SizedBox(width: 10),
                  _HeaderIconButton(
                    icon: Icons.headset_mic_rounded,
                    onTap: () => Get.toNamed(
                      Routes.EDUCATION_SUPPORT,
                      arguments: {
                        'title': 'Training Support'.tr,
                        'endpoint': ApiURL.trainingHotlines,
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Filter — a single button that opens a picker sheet.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
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
                                ? _violet
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.tune_rounded,
                                size: 16,
                                color: selected
                                    ? _violetDark
                                    : const Color(0xFF64748B)),
                            const SizedBox(width: 6),
                            Text(
                              selected ? con.typeLabel(con.typeIndex) : 'Filter'.tr,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: selected
                                    ? _violetDark
                                    : const Color(0xFF334155),
                              ),
                            ),
                            if (selected) ...[
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () => con.setInstituteType(0),
                                child: const Icon(Icons.close_rounded,
                                    size: 15, color: _violetDark),
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
                    color: _violet,
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
                          const _EmptyState()
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
                                  child: _CenterCard(
                                      center: e.value, index: e.key),
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
      isScrollControlled: true,
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
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  itemCount: 1 + con.instituteTypes.length,
                  itemBuilder: (_, i) {
                    final sel = con.typeIndex == i;
                    final icon = i == 0
                        ? Icons.grid_view_rounded
                        : (_typeIcons[con.instituteTypes[i - 1].slug] ??
                            Icons.school_rounded);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            con.setInstituteType(i);
                            Navigator.pop(ctx);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: sel ? _tile : Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: sel
                                        ? _violet
                                        : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(icon,
                                      size: 18,
                                      color: sel
                                          ? Colors.white
                                          : const Color(0xFF64748B)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(con.typeLabel(i),
                                      style: TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: sel
                                              ? FontWeight.w800
                                              : FontWeight.w600,
                                          color: sel
                                              ? _violetDark
                                              : const Color(0xFF334155))),
                                ),
                                if (sel)
                                  const Icon(Icons.check_circle_rounded,
                                      color: _violet, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 6),
            ],
          ),
        );
      },
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: _tile,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 19, color: _violet),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: _violet,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.apartment_rounded,
                color: Colors.white, size: 30),
          ),
          const SizedBox(height: 16),
          Text(
            'No training centers of this type found.'.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try choosing a different type.'.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }
}

class _CenterCard extends StatelessWidget {
  const _CenterCard({required this.center, required this.index});
  final EduCenter center;
  final int index;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEFF2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
                          errorWidget: (_, __, ___) =>
                              _InitialsAvatar(center: center, index: index),
                        )
                      : _InitialsAvatar(center: center, index: index),
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
                              color: _amberBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded,
                                    size: 12, color: _amberText),
                                const SizedBox(width: 2),
                                Text(
                                  'Featured'.tr,
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: _amberText,
                                  ),
                                ),
                              ],
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
                          color: _violetDark,
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

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.center, required this.index});
  final EduCenter center;
  final int index;

  String get _initials {
    final words = center.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) return words.first[0].toUpperCase();
    return (words[0][0] + words[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final color = _avatarPalette[index % _avatarPalette.length];
    return Container(
      color: color.withValues(alpha: 0.14),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}
