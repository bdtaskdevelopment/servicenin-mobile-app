import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/service_nav.dart';
import '../../../core/values/app_colors.dart';
import '../../../data/models/response/home_response.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/search_controller.dart';

class SearchView extends GetView<SnSearchController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Search bar row ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
              child: Row(
                children: [
                  _BackButton(),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded,
                              color: Color(0xFF94A3B8), size: 22),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: controller.textController,
                              onChanged: controller.onQueryChanged,
                              autofocus: true,
                              decoration: const InputDecoration(
                                hintText: 'Search services...',
                                hintStyle:
                                    TextStyle(color: Color(0xFF94A3B8)),
                                border: InputBorder.none,
                                isCollapsed: true,
                              ),
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            Expanded(
              child: GetBuilder<SnSearchController>(
                builder: (con) {
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    children: [
                      if (con.query.trim().isEmpty &&
                          con.trending.isNotEmpty) ...[
                        const _SectionLabel('TRENDING'),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: con.trending
                              .map((t) => _TrendingChip(
                                    label: t.name,
                                    onTap: () => con.applyChip(t.name),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 22),
                      ],
                      _SectionLabel(con.query.trim().isEmpty
                          ? 'ALL SERVICES'
                          : 'RESULTS'),
                      const SizedBox(height: 12),
                      if ((con.searching && con.searchResults.isEmpty) ||
                          (con.query.trim().isEmpty &&
                              con.loadingServices &&
                              con.allServices.isEmpty))
                        const SnListSkeleton(
                          count: 5,
                          padding: EdgeInsets.zero,
                          showTrailing: false,
                        )
                      else ...[
                        ...con.results.map((s) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _ServiceRow(service: s),
                            )),
                        if (con.results.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: Center(
                              child: Text('কোন সেবা পাওয়া যায়নি',
                                  style: TextStyle(color: Color(0xFF94A3B8))),
                            ),
                          ),
                      ],
                    ],
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

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.back(),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 18, color: Color(0xFF1A1A1A)),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Color(0xFF94A3B8),
        letterSpacing: 0.8,
      ),
    );
  }
}

class _TrendingChip extends StatelessWidget {
  const _TrendingChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
      ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({required this.service});
  final HomeService service;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => ServiceNav.openByKey(service.key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEDEFF2)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: service.color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(service.iconData, color: service.color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                service.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_right_rounded,
                color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }
}
