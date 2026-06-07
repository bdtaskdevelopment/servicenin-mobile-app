import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/info_response.dart';
import '../../../routes/app_pages.dart';
import '../controllers/information_controller.dart';

const _purple = Color(0xFF6366F1);
// const _tile = Color(0xFFEEF0FB); // used by the commented-out cards below

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
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20, color: Color(0xFF1A1A1A)),
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Information',
                          style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                      SizedBox(height: 1),
                      Text('Hotlines & civic guides',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Get.toNamed(Routes.INFORMATION_HOTLINES),
                    child: const Icon(Icons.call_outlined,
                        color: Color(0xFF1A1A1A), size: 22),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GetBuilder<InformationController>(
                builder: (con) => ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  // National emergency + live entries (driven by /api/v1/info)
                  _NationalEmergencyCard(con: con),
                  const SizedBox(height: 18),
                  _InfoEntriesSection(con: con),
                  // ── Hidden for now: Emergency hotlines, Browse guides,
                  //    Popular guides (static placeholder content) ──────────
                  /*
                  const SizedBox(height: 22),
                  GestureDetector(
                    onTap: () => Get.toNamed(Routes.INFORMATION_HOTLINES),
                    child: _SectionHeader(
                        title: 'Emergency hotlines', action: 'All →'),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.5,
                    children:
                        con.hotlines.map((h) => _HotlineCard(hotline: h)).toList(),
                  ),
                  const SizedBox(height: 22),
                  const Text('Browse guides',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A))),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.55,
                    children: con.categories
                        .map((c) => GestureDetector(
                              onTap: () => con.openCategory(c),
                              child: _CategoryCard(category: c),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 22),
                  const Text('Popular guides',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A))),
                  const SizedBox(height: 12),
                  ...con.popular.map((g) => GestureDetector(
                        onTap: () => con.openGuideByTitle(g.title),
                        child: _PopularCard(guide: g),
                      )),
                  */
                ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── National emergency hero card (driven by /api/v1/info) ───────────
class _NationalEmergencyCard extends StatelessWidget {
  const _NationalEmergencyCard({required this.con});
  final InformationController con;

  @override
  Widget build(BuildContext context) {
    final entry = con.nationalEmergency;
    final label = (entry?.title.isNotEmpty ?? false)
        ? entry!.title.toUpperCase()
        : 'NATIONAL EMERGENCY';
    final number = (entry?.hotline.isNotEmpty ?? false) ? entry!.hotline : '999';
    final subtitle = (entry?.descriptionBn.isNotEmpty ?? false)
        ? entry!.descriptionBn
        : 'পুলিশ · ফায়ার · আম্বুলেন্স';

    return GestureDetector(
      onTap: () => con.callHotline(number),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFFE8333A), Color(0xFFC2182B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.6), width: 2),
              ),
              child: const Icon(Icons.call_rounded,
                  color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: Color(0xFFFFDADE),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5)),
                  Text(number,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          height: 1.1)),
                  Text(subtitle,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.call_rounded, color: Colors.white, size: 22),
          ],
        ),
      ),
    );
  }
}

// ── Live info entries listed under the national-emergency card ──────
class _InfoEntriesSection extends StatelessWidget {
  const _InfoEntriesSection({required this.con});
  final InformationController con;

  @override
  Widget build(BuildContext context) {
    final cards = con.infoCards;

    if (con.loadingInfo && cards.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: _purple),
          ),
        ),
      );
    }

    if (cards.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Emergency services',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A))),
        const SizedBox(height: 12),
        ...cards.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _InfoCard(entry: e, con: con),
            )),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.entry, required this.con});
  final InfoEntry entry;
  final InformationController con;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final detail = await con.fetchInfoById(entry.id);
        if (detail != null) {
          Get.bottomSheet(
            _InfoDetailSheet(entry: detail, con: con),
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEDEFF2))),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: const Color(0xFFFDECEC),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(
                  entry.isEmergency
                      ? Icons.emergency_share_rounded
                      : Icons.info_outline_rounded,
                  color: const Color(0xFFE8333A),
                  size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(entry.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A))),
                      ),
                      if (entry.verified) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.verified_rounded,
                            size: 15, color: Color(0xFF16A34A)),
                      ],
                    ],
                  ),
                  if (entry.description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(entry.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF94A3B8))),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (entry.hotline.isNotEmpty)
              GestureDetector(
                onTap: () => con.callHotline(entry.hotline),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                      color: const Color(0xFFFDECEC),
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.call_rounded,
                          size: 14, color: Color(0xFFE8333A)),
                      const SizedBox(width: 5),
                      Text(entry.hotline,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFE8333A))),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Detail bottom sheet (driven by /api/v1/info/{id}) ───────────────
class _InfoDetailSheet extends StatelessWidget {
  const _InfoDetailSheet({required this.entry, required this.con});
  final InfoEntry entry;
  final InformationController con;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 42,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(4)),
            ),
          ),
          Row(
            children: [
              if (entry.isEmergency)
                _Tag('Emergency', const Color(0xFFFDECEC),
                    const Color(0xFFE8333A)),
              if (entry.verified) ...[
                const SizedBox(width: 8),
                _Tag('Verified', const Color(0xFFDCFCE7),
                    const Color(0xFF15803D)),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(entry.title,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A))),
          if (entry.titleBn.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(entry.titleBn,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B))),
          ],
          if (entry.description.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(entry.description,
                style: const TextStyle(
                    fontSize: 14, height: 1.5, color: Color(0xFF334155))),
          ],
          if (entry.descriptionBn.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(entry.descriptionBn,
                style: const TextStyle(
                    fontSize: 13.5, height: 1.5, color: Color(0xFF64748B))),
          ],
          const SizedBox(height: 20),
          if (entry.hotline.isNotEmpty)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => con.callHotline(entry.hotline),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8333A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.call_rounded, size: 20),
                label: Text('Call ${entry.hotline}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.text, this.bg, this.fg);
  final String text;
  final Color bg;
  final Color fg;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(text,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}

// ── Unused while the hotlines/guides sections above are commented out ──
/*
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.action});
  final String title;
  final String action;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A))),
        Text(action,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.brandOrange)),
      ],
    );
  }
}

class _HotlineCard extends StatelessWidget {
  const _HotlineCard({required this.hotline});
  final Hotline hotline;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEDEFF2))),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
                color: _tile, borderRadius: BorderRadius.circular(10)),
            child: Icon(hotline.icon, color: _purple, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hotline.number,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A))),
                Text(hotline.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 11.5, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category});
  final GuideCategory category;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEDEFF2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
                color: _tile, borderRadius: BorderRadius.circular(12)),
            child: Icon(category.icon, color: _purple, size: 22),
          ),
          const Spacer(),
          Text(category.name,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A))),
          const SizedBox(height: 2),
          Text('${category.count} guides',
              style: const TextStyle(fontSize: 12, color: Color(0xFFE07A1F))),
        ],
      ),
    );
  }
}

class _PopularCard extends StatelessWidget {
  const _PopularCard({required this.guide});
  final PopularGuide guide;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEDEFF2))),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
                color: _tile, borderRadius: BorderRadius.circular(12)),
            child: Icon(guide.icon, color: _purple, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(guide.title,
                    style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text(guide.subtitle,
                    style:
                        const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }
}
*/
