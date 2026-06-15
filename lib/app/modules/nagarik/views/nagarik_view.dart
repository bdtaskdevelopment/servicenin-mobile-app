import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/nagarik_response.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/nagarik_controller.dart';

const _navy = Color(0xFF1E2A4A);
const _orange = Color(0xFFF15A24);
const _tile = Color(0xFFFCE6CB);

class NagarikView extends GetView<NagarikController> {
  const NagarikView({super.key});

  @override
  Widget build(BuildContext context) {
    final con = controller;
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
                        'Nagarik Sheba'.tr,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Dhaka North City · DNCC'.tr,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _openHotlinesSheet(con),
                    child: const Icon(
                      Icons.call_outlined,
                      color: Color(0xFF1A1A1A),
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GetBuilder<NagarikController>(
                builder: (con) => RefreshIndicator(
                  color: _orange,
                  onRefresh: () async {
                    await con.fetchHotlines();
                    await con.fetchCategories();
                    await con.fetchGrievances();
                  },
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      _Banner(con: con),
                      const SizedBox(height: 16),
                      _ActionCards(con: con),
                      const SizedBox(height: 22),
                      Text(
                        'Report by category'.tr,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _CategoryGrid(con: con),
                      const SizedBox(height: 22),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'My reports'.tr,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          GestureDetector(
                            onTap: con.openReports,
                            child: Text(
                              'See all →'.tr,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _MyReportsPreview(con: con),
                      const SizedBox(height: 22),
                      // ── My support tickets (surfaced like My reports) ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Support tickets'.tr,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          GestureDetector(
                            onTap: con.openTickets,
                            child: Text(
                              'See all →'.tr,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _MyTicketsPreview(con: con),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openHotlinesSheet(NagarikController con) {
    Get.bottomSheet(
      _HotlinesSheet(con: con),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.con});
  final NagarikController con;
  @override
  Widget build(BuildContext context) {
    final hotline = con.hotlines?.dnccHotline.isNotEmpty == true
        ? con.hotlines!.dnccHotline
        : '16106';
    return FadeInDown(
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_navy, Color(0xFF2D3E63)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -6,
              top: -8,
              child: Icon(
                Icons.account_balance_rounded,
                size: 80,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your city, your responsibility'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Report civic issues straight to DNCC officials · track to resolution'
                      .tr,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => con.callNumber(hotline),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.call_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              hotline,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'DNCC hotline'.tr,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCards extends StatelessWidget {
  const _ActionCards({required this.con});
  final NagarikController con;
  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: con.reportIssue,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_orange, Color(0xFFD2451A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.photo_camera_outlined,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Report an issue'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Roads · drains · garbage'.tr,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: con.newTicket,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFEDEFF2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: _tile,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: _orange,
                        size: 21,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Support ticket'.tr,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Tax · license · services'.tr,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.con});
  final NagarikController con;
  @override
  Widget build(BuildContext context) {
    if (con.loadingCategories && con.categories.isEmpty) {
      return const SnGridSkeleton(padding: EdgeInsets.zero, count: 6);
    }
    if (con.categories.isEmpty) return const SizedBox.shrink();
    return FadeInUp(
      from: 18,
      duration: const Duration(milliseconds: 350),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.0,
        children: con.categories
            .map(
              (c) => GestureDetector(
                onTap: () => con.openCategory(c.key),
                child: _CatTile(cat: c),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _CatTile extends StatelessWidget {
  const _CatTile({required this.cat});
  final NagarikReportCategory cat;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6),
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
            decoration: BoxDecoration(
              color: _tile,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              nagarikCategoryIcon(cat.icon),
              color: _orange,
              size: 24,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            cat.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}

class _MyReportsPreview extends StatelessWidget {
  const _MyReportsPreview({required this.con});
  final NagarikController con;
  @override
  Widget build(BuildContext context) {
    if (con.loadingGrievances && con.grievances.isEmpty) {
      return const SnListSkeleton(padding: EdgeInsets.zero, count: 3);
    }
    if (con.grievances.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEDEFF2)),
        ),
        child: Text(
          'No reports yet — file your first issue above.'.tr,
          style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
        ),
      );
    }
    return Column(
      children: con.grievances
          .take(2)
          .toList()
          .asMap()
          .entries
          .map(
            (e) => FadeInUp(
              from: 18,
              duration: const Duration(milliseconds: 350),
              delay: Duration(milliseconds: 70 * e.key),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => con.openGrievance(e.value),
                  child: ReportCard(report: e.value),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _MyTicketsPreview extends StatelessWidget {
  const _MyTicketsPreview({required this.con});
  final NagarikController con;
  @override
  Widget build(BuildContext context) {
    if (con.loadingTickets && con.tickets.isEmpty) {
      return const SnListSkeleton(padding: EdgeInsets.zero, count: 2);
    }
    if (con.tickets.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEDEFF2)),
        ),
        child: Text(
          'No support tickets yet.'.tr,
          style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
        ),
      );
    }
    return Column(
      children: con.tickets.take(2).toList().asMap().entries.map((e) {
        final t = e.value;
        return FadeInUp(
          from: 18,
          duration: const Duration(milliseconds: 350),
          delay: Duration(milliseconds: 70 * e.key),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => con.viewTicket(t),
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
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                          color: _tile,
                          borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.confirmation_number_outlined,
                          color: _orange, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.subject.isNotEmpty ? t.subject : t.categoryLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 2),
                          Text(t.createdLabel,
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF94A3B8))),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusPill(label: t.statusLabel, resolved: t.isResolved),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class ReportCard extends StatelessWidget {
  const ReportCard({super.key, required this.report});
  final NagarikGrievance report;
  @override
  Widget build(BuildContext context) {
    final resolved = report.isResolved;
    return Container(
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
            decoration: BoxDecoration(
              color: _tile,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              nagarikCategoryIcon(report.category),
              color: _orange,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  report.trackingCode,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 6),
                VerifiedBadge(report: report),
              ],
            ),
          ),
          const SizedBox(width: 8),
          StatusPill(label: report.statusLabel, resolved: resolved),
        ],
      ),
    );
  }
}

/// Small badge showing the citizen-verification state of a grievance.
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key, required this.report});
  final NagarikGrievance report;
  @override
  Widget build(BuildContext context) {
    late IconData icon;
    late String label;
    late Color bg, fg;
    if (report.verified) {
      icon = Icons.verified_rounded;
      label = 'Verified'.tr;
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF15803D);
    } else if (report.awaitingCitizenVerification) {
      icon = Icons.hourglass_bottom_rounded;
      label = 'Awaiting verification'.tr;
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFFB45309);
    } else {
      icon = Icons.shield_outlined;
      label = 'Not verified'.tr;
      bg = const Color(0xFFF1F5F9);
      fg = const Color(0xFF64748B);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
        ],
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.resolved});
  final String label;
  final bool resolved;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: resolved ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 7,
            color: resolved ? const Color(0xFF16A34A) : const Color(0xFFD97706),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: resolved
                  ? const Color(0xFF15803D)
                  : const Color(0xFFB45309),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hotlines bottom sheet (driven by /api/v1/nagarik/hotlines) ───────
class _HotlinesSheet extends StatelessWidget {
  const _HotlinesSheet({required this.con});
  final NagarikController con;
  @override
  Widget build(BuildContext context) {
    final list = con.hotlines?.hotlines ?? [];
    return Container(
      constraints: BoxConstraints(maxHeight: Get.height * 0.8),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Color(0xFFF7F8FA),
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
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Text(
            'Emergency & city hotlines'.tr,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          if (con.loadingHotlines && list.isEmpty)
            const SnListSkeleton(padding: EdgeInsets.zero, count: 5)
          else if (list.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No hotlines available.'.tr,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ),
            )
          else
            Flexible(
              child: FadeInUp(
                from: 18,
                duration: const Duration(milliseconds: 350),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final h = list[i];
                    return GestureDetector(
                      onTap: () => con.callNumber(h.number),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFEDEFF2)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: _tile,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.call_rounded,
                                color: _orange,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    h.label,
                                    style: const TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    h.number,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFE07A1F),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Color(0xFFD9F7E6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.call_rounded,
                                color: Color(0xFF16A34A),
                                size: 19,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
