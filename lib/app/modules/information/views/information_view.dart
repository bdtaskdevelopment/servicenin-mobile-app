import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/information_controller.dart';

const _purple = Color(0xFF6366F1);

/// Information home — search + a grid of categories ("domains"). Tapping a
/// tile (or submitting a search) opens [InformationCategoryView] with the
/// matching paginated list; tapping an entry there opens the full detail
/// page.
class InformationView extends GetView<InformationController> {
  const InformationView({super.key});

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
                        'Information'.tr,
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
                    color: _purple,
                    onRefresh: () => con.fetchDomains(),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      children: [
                        Text('CATEGORIES'.tr,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF94A3B8),
                                letterSpacing: 0.8)),
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
        color: const Color(0xFFEDEFF2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
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
                    child: const Icon(Icons.close_rounded,
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
          emoji: '📋',
          label: 'All'.tr,
          onTap: con.openAllInfo,
        ),
        ...con.domains.map((d) => _CategoryTile(
              emoji: d.emoji.isNotEmpty ? d.emoji : '📌',
              label: d.label,
              onTap: () => con.openInfoCategory(d),
            )),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.emoji,
    required this.label,
    required this.onTap,
  });
  final String emoji;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEDEFF2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF0FB),
                shape: BoxShape.circle,
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 22)),
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
