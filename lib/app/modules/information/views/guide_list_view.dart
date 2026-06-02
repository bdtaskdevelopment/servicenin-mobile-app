import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/information_controller.dart';

const _purple = Color(0xFF6366F1);
const _tile = Color(0xFFEEF0FB);

class GuideListView extends GetView<InformationController> {
  const GuideListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: GetBuilder<InformationController>(
          builder: (con) {
            final guides = con.categoryGuides;
            return Column(
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
                          Text(con.selectedCategory?.name ?? 'Guides',
                              style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A))),
                          Text('${guides.length} guides',
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF94A3B8))),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: guides.isEmpty
                      ? const Center(
                          child: Text('No guides yet',
                              style: TextStyle(color: Color(0xFF94A3B8))))
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          children: guides
                              .map((g) => Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 12),
                                    child: _GuideCard(
                                        guide: g,
                                        onRead: () => con.openGuide(g)),
                                  ))
                              .toList(),
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

class _GuideCard extends StatelessWidget {
  const _GuideCard({required this.guide, required this.onRead});
  final Guide guide;
  final VoidCallback onRead;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRead,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEDEFF2))),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                      color: _tile, borderRadius: BorderRadius.circular(12)),
                  child: Icon(guide.icon, color: _purple, size: 21),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(guide.title,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                      const SizedBox(height: 2),
                      Text(guide.source,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: _DashedDivider(),
            ),
            Row(
              children: [
                const Icon(Icons.access_time_rounded,
                    size: 15, color: Color(0xFF94A3B8)),
                const SizedBox(width: 6),
                Text(guide.meta,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFFE07A1F))),
                const Spacer(),
                const Text('Read →',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: _purple)),
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
        const dash = 5.0, gap = 4.0;
        final count = (c.maxWidth / (dash + gap)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
              count,
              (_) => Container(
                  width: dash, height: 1, color: const Color(0xFFE2E8F0))),
        );
      },
    );
  }
}
