import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/info_response.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/information_controller.dart';
import 'information_view.dart' show InfoSupportIconButton;

const _blue = Color(0xFF0183C7);

/// One category's (or a search's) directory results — opened from a tap on
/// a grid tile / search submit on [InformationView]. Paginated, backed by
/// GET /api/v1/info?domain=&search=.
class InformationCategoryView extends GetView<InformationController> {
  const InformationCategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FA),
      body: SafeArea(
        child: Column(
          children: [
            GetBuilder<InformationController>(
              builder: (con) => _Header(con: con),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SearchBar(con: controller),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GetBuilder<InformationController>(
                builder: (con) {
                  if (con.loadingDirectory && con.directoryEntries.isEmpty) {
                    return const SnListSkeleton();
                  }
                  return RefreshIndicator(
                    color: _blue,
                    onRefresh: () => con.fetchDirectory(reset: true),
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (n) {
                        if (n.metrics.pixels >=
                            n.metrics.maxScrollExtent - 200) {
                          con.loadMoreDirectory();
                        }
                        return false;
                      },
                      child: con.directoryCards.isEmpty
                          ? const _EmptyResults()
                          : ListView(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 0, 16, 24),
                              children: [
                                ...con.directoryCards.asMap().entries.map(
                                  (e) => FadeInUp(
                                    from: 18,
                                    duration:
                                        const Duration(milliseconds: 350),
                                    delay: Duration(milliseconds: 60 * e.key),
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: _InfoCard(entry: e.value, con: con),
                                    ),
                                  ),
                                ),
                                if (con.loadingMoreDirectory)
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 12),
                                    child: Center(
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2.4, color: _blue)),
                                  ),
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

class _Header extends StatelessWidget {
  const _Header({required this.con});
  final InformationController con;

  @override
  Widget build(BuildContext context) {
    final domain = con.selectedDomainForList;
    final isPureSearch = domain == null && con.search.isNotEmpty;
    final (bg, fg) = infoDomainColor(domain?.key);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 16, 0),
      child: Row(
        children: [
          IconButton(
            splashRadius: 22,
            onPressed: () => Get.back(),
            icon: const Icon(LucideIcons.chevronLeft,
                size: 22, color: Color(0xFF0F172A)),
          ),
          if (!isPureSearch) ...[
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(infoDomainIcon(domain?.key), color: fg, size: 17),
            ),
          ],
          Expanded(
            child: Text(con.categoryListTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A))),
          ),
          const InfoSupportIconButton(),
        ],
      ),
    );
  }
}

// ── Search bar (refines the current category/search in place) ───────
class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.con});
  final InformationController con;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
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
              onChanged: con.onSearchChanged,
              onSubmitted: con.onSearchSubmitted,
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
                    onTap: con.clearSearch,
                    child: const Icon(LucideIcons.x,
                        size: 18, color: Color(0xFF94A3B8)),
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 100),
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _blue,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                    color: _blue.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6)),
              ],
            ),
            child: const Icon(LucideIcons.searchX,
                color: Colors.white, size: 28),
          ),
        ),
        const SizedBox(height: 18),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'No entries found.'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155)),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Directory entry card (tap → detail page) ────────────────────────
class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.entry, required this.con});
  final InfoEntry entry;
  final InformationController con;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = infoDomainColor(entry.domain);
    return GestureDetector(
      onTap: () => con.openInfo(entry),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(infoDomainIcon(entry.domain), color: fg, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      entry.tagLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: fg,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (entry.callNumber.isNotEmpty)
              GestureDetector(
                onTap: () => con.callHotline(entry.callNumber),
                child: Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: _blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.phone,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
