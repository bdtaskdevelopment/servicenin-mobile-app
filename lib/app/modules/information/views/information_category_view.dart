import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/info_response.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/information_controller.dart';

const _purple = Color(0xFF6366F1);

/// One category's (or a search's) directory results — opened from a tap on
/// a grid tile / search submit on [InformationView]. Paginated, backed by
/// GET /api/v1/info?domain=&search=.
class InformationCategoryView extends GetView<InformationController> {
  const InformationCategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
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
                    color: _purple,
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
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 80),
                                  child: Center(
                                    child: Text(
                                      'No entries found.'.tr,
                                      style: const TextStyle(
                                          color: Color(0xFF94A3B8)),
                                    ),
                                  ),
                                ),
                              ],
                            )
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
                                            strokeWidth: 2.4, color: _purple)),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 16, 0),
      child: Row(
        children: [
          IconButton(
            splashRadius: 22,
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 20, color: Color(0xFF1A1A1A)),
          ),
          if (domain != null && domain.emoji.isNotEmpty) ...[
            Text(domain.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
          ],
          Text(con.categoryListTitle,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A))),
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
                    child: const Icon(Icons.close_rounded,
                        size: 18, color: Color(0xFF94A3B8)),
                  ),
          ),
        ],
      ),
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
    final domain = con.domainFor(entry.domain);
    final subtitle = [
      entry.typeLabel,
      entry.address,
    ].where((s) => s.isNotEmpty).join(' · ');
    return GestureDetector(
      onTap: () => con.openInfo(entry),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEDEFF2)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: entry.isEmergency
                    ? const Color(0xFFFDECEC)
                    : const Color(0xFFEEF0FB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: (domain?.emoji.isNotEmpty ?? false)
                  ? Text(domain!.emoji, style: const TextStyle(fontSize: 20))
                  : Icon(
                      entry.isEmergency
                          ? Icons.emergency_share_rounded
                          : Icons.account_balance_outlined,
                      color:
                          entry.isEmergency ? const Color(0xFFE8333A) : _purple,
                      size: 22,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (entry.callNumber.isNotEmpty)
              GestureDetector(
                onTap: () => con.callHotline(entry.callNumber),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9F7E6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.call_rounded,
                    size: 18,
                    color: Color(0xFF16A34A),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
