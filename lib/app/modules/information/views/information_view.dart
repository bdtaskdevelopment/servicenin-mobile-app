import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/values/app_colors.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../../../routes/app_pages.dart';
import '../controllers/information_controller.dart';

const _blue = Color(0xFF0183C7);
const _blueTint = Color(0xFFE6F4FA);

/// Information home — search + a grid of categories ("domains"). Tapping a
/// tile (or submitting a search) opens [InformationCategoryView] with the
/// matching paginated list; tapping an entry there opens the full detail
/// page.
class InformationView extends GetView<InformationController> {
  const InformationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FA),
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
                      LucideIcons.chevronLeft,
                      size: 22,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Information (directory)'.tr,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Hotlines & civic directory'.tr,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  InfoSupportIconButton(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SearchBar(con: controller),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GetBuilder<InformationController>(
                builder: (con) {
                  if (con.loadingDomains && con.domains.isEmpty) {
                    return const SnListSkeleton();
                  }
                  return RefreshIndicator(
                    color: _blue,
                    onRefresh: () => con.fetchDomains(),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      children: [
                        Text('CATEGORIES'.tr,
                            style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A))),
                        const SizedBox(height: 12),
                        _CategoryGrid(con: con),
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
}

/// Header support affordance — a single headset icon that opens a dedicated
/// Information support screen (admin-configured numbers), reusing the same
/// shared SupportController the generic support screen uses.
class InfoSupportIconButton extends StatelessWidget {
  const InfoSupportIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        Routes.INFORMATION_SUPPORT,
        arguments: {
          'title': 'Information Support'.tr,
          'endpoint': 'api/v1/info/hotlines',
        },
      ),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: _blueTint,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(LucideIcons.headset, color: _blue, size: 19),
      ),
    );
  }
}

// ── Search bar — submitting navigates to the category-list page ─────
class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.con});
  final InformationController con;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEDEFF2)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.search, size: 19, color: Color(0xFF94A3B8)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: con.searchCtrl,
              onChanged: con.onMainSearchChanged,
              onSubmitted: (_) => con.openSearchResults(),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search hospitals, offices, hotlines…'.tr,
                hintStyle: const TextStyle(
                    color: Color(0xFF94A3B8), fontSize: 13.5),
                border: InputBorder.none,
                isCollapsed: true,
              ),
              style:
                  const TextStyle(fontSize: 13.5, color: Color(0xFF0F172A)),
            ),
          ),
          GetBuilder<InformationController>(
            builder: (con) => con.search.isEmpty
                ? const SizedBox.shrink()
                : GestureDetector(
                    onTap: con.searchCtrl.clear,
                    child: const Icon(LucideIcons.x,
                        size: 18, color: Color(0xFF94A3B8)),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Category grid — GET /api/v1/info/domains ─────────────────────────
class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.con});
  final InformationController con;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.95,
      children: [
        _CategoryTile(
          icon: infoDomainIcon(null),
          color: infoDomainColor(null),
          label: 'All'.tr,
          onTap: con.openAllInfo,
        ),
        ...con.domains.map((d) => _CategoryTile(
              icon: infoDomainIcon(d.key),
              color: infoDomainColor(d.key),
              label: d.displayLabel,
              onTap: () => con.openInfoCategory(d),
            )),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final (Color, Color) color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = color;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Icon(icon, color: fg, size: 22),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A))),
            ),
          ],
        ),
      ),
    );
  }
}
