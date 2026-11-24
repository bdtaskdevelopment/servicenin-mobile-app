import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/nagarik_response.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/nagarik_controller.dart';

const _green = Color(0xFF15803C);
const _greenTint = Color(0xFF3F965F);
const _greenLight = Color(0xFFE9F5ED);
const _orange = Color(0xFFF16621);

class NagarikView extends GetView<NagarikController> {
  const NagarikView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FA),
      body: SafeArea(
        // Wraps the header too, not just the list below — the header's
        // support icon reads con.hotlineNumber/hotlineWhatsappUrl, which are
        // null until fetchHotlines() resolves; without this they'd be baked
        // in from whatever was true at the first build and never update.
        child: GetBuilder<NagarikController>(
          builder: (con) => Column(
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
                    Text(
                      'Nagarik Sheba'.tr,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const Spacer(),
                    SupportIconButton(con: con),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  color: _green,
                  onRefresh: () async {
                    await con.fetchHotlines();
                    await con.fetchCategories();
                    await con.fetchGrievances();
                  },
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      _ReportBanner(con: con),
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
                                color: _green,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _MyReportsPreview(con: con),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Header support affordance — a single headset icon that opens a small
/// action sheet for Call / WhatsApp, preserving both existing hotline
/// behaviors (con.callNumber/con.openWhatsApp) behind the mockup's one icon.
class SupportIconButton extends StatelessWidget {
  const SupportIconButton({super.key, required this.con});
  final NagarikController con;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showSupportSheet(context, con),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: _greenLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(LucideIcons.headset, color: _green, size: 19),
      ),
    );
  }
}

void _showSupportSheet(BuildContext context, NagarikController con) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('DNCC hotline'.tr,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A))),
            const SizedBox(height: 4),
            Text(con.hotlineNumber,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700, color: _green)),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                      con.callNumber(con.hotlineNumber);
                    },
                    icon: const Icon(LucideIcons.phone, size: 18),
                    label: Text('Call'.tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                if (con.hotlineWhatsappUrl.isNotEmpty) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Get.back();
                        con.openWhatsApp(con.hotlineWhatsappUrl);
                      },
                      icon: const Icon(LucideIcons.messageCircle, size: 18),
                      label: Text('WhatsApp'.tr),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF25D366),
                        side: const BorderSide(color: Color(0xFF25D366)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _ReportBanner extends StatelessWidget {
  const _ReportBanner({required this.con});
  final NagarikController con;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: con.reportIssue,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        decoration: BoxDecoration(
          color: _green,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _greenTint,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                LucideIcons.megaphone,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Report an issue'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Roads · drains · garbage'.tr,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: _orange,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.plus,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
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
    final (bg, fg) = nagarikCategoryColor(cat.key);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6),
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
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              nagarikCategoryIcon(cat.key),
              color: fg,
              size: 22,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            cat.displayLabel,
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
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFEDF1F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(LucideIcons.fileText,
                  color: Color(0xFF64748B), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No reports yet — file your first issue above.'.tr,
                style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              ),
            ),
          ],
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

class ReportCard extends StatelessWidget {
  const ReportCard({super.key, required this.report});
  final NagarikGrievance report;
  @override
  Widget build(BuildContext context) {
    final resolved = report.isResolved;
    final (bg, fg) = nagarikCategoryColor(report.category);
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
              color: bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              nagarikCategoryIcon(report.category),
              color: fg,
              size: 21,
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
              color:
                  resolved ? const Color(0xFF15803D) : const Color(0xFFB45309),
            ),
          ),
        ],
      ),
    );
  }
}
