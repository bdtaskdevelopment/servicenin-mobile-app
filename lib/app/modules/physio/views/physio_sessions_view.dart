import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../core/values/app_url.dart';
import '../../../global_widget/invoice_actions.dart';
import '../../../global_widget/report_actions.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/physio_controller.dart';
import '../physio_palette.dart';

class PhysioSessionsView extends GetView<PhysioController> {
  const PhysioSessionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: Color(0xFF1A1A1A)),
        ),
        title: Text('My Booking'.tr,
            style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A))),
      ),
      body: RefreshIndicator(
        color: const Color(0xFFB45309),
        onRefresh: controller.fetchMySessions,
        child: GetBuilder<PhysioController>(
          builder: (con) {
            if (con.loadingSessions && con.sessions.isEmpty) {
              return const SnListSkeleton();
            }
            if (con.sessions.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 140),
                  Center(
                    child: Text('No sessions yet.'.tr,
                        style: const TextStyle(color: Color(0xFF94A3B8))),
                  ),
                ],
              );
            }
            return FadeInUp(
              from: 18,
              duration: const Duration(milliseconds: 350),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: con.sessionGroups
                    .map((g) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _SessionCard(group: g),
                        ))
                    .toList(),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SessionCard extends StatefulWidget {
  const _SessionCard({required this.group});
  final List<PhysioSession> group;

  @override
  State<_SessionCard> createState() => _SessionCardState();
}

class _SessionCardState extends State<_SessionCard> {
  // Collapsed by default — the headline + "(completed/total)" badge is
  // enough at a glance; the full day-by-day roadmap is opt-in detail.
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    final first = group.first;
    final style = physioStyleFor(first.centerId);
    // A group is still "open" as a whole as long as any day in it is —
    // the card only reflects a finished state once every day is done.
    final upcoming = group.any((s) => s.isOpen);
    // The day to headline: the first not-yet-finished one, or the last
    // day if the whole group is done.
    final current = group.indexWhere((s) => s.isOpen);
    final headlineIndex = current == -1 ? group.length - 1 : current;
    final headline = group[headlineIndex];
    final completedCount =
        group.where((s) => s.status.toLowerCase() == 'completed').length;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: style.accent.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
              color: style.accent.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      style.accent,
                      style.accent.withValues(alpha: 0.75)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(style.icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                              first.awaitingAssignment
                                  ? 'Awaiting assignment'.tr
                                  : first.staffName,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  fontStyle: first.awaitingAssignment
                                      ? FontStyle.italic
                                      : FontStyle.normal,
                                  color: first.awaitingAssignment
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF0F172A))),
                        ),
                        if (group.length > 1) ...[
                          const SizedBox(width: 6),
                          // Counts completed days, not which day is being
                          // shown — an "X/Y" fraction reads as progress to
                          // anyone glancing at it, so it has to mean that.
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                                color: style.tile,
                                borderRadius: BorderRadius.circular(6)),
                            child: Text('$completedCount/${group.length}',
                                style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: style.accent)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Flexible(
                          child: Text(first.center,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 12.5, color: Color(0xFF94A3B8))),
                        ),
                        const SizedBox(width: 6),
                        Text('·',
                            style: TextStyle(
                                fontSize: 12.5,
                                color: style.accent.withValues(alpha: 0.5))),
                        const SizedBox(width: 6),
                        // A pure lab request is a booking for a test, not
                        // a therapy session — only patient-care items
                        // (or a legacy no-items booking, always
                        // therapist-based) use "Session".
                        Text(first.isLabOnly ? 'Booking'.tr : 'Session'.tr,
                            style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: style.accent)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusPill(status: headline.status, isLabOnly: first.isLabOnly),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: _DashedDivider(),
          ),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 15, color: Color(0xFF94A3B8)),
              const SizedBox(width: 6),
              Text(headline.when,
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: upcoming
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF64748B))),
              const Spacer(),
              if (headline.progress != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: style.tile,
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(headline.progress!,
                      style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: style.accent)),
                ),
            ],
          ),
          if (group.length > 1) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Row(
                children: [
                  Text(
                      _expanded
                          ? 'Hide schedule'.tr
                          : 'View schedule (${group.length} sessions)'.tr,
                      style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: style.accent)),
                  const SizedBox(width: 4),
                  Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: style.accent),
                ],
              ),
            ),
            if (_expanded) ...[
              const SizedBox(height: 8),
              ...group.asMap().entries.map((entry) {
                final i = entry.key;
                final s = entry.value;
                final done = !s.isOpen;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(
                          done
                              ? Icons.check_circle_rounded
                              : Icons.schedule_rounded,
                          size: 16,
                          color: done
                              ? const Color(0xFF15803D)
                              : const Color(0xFF94A3B8)),
                      const SizedBox(width: 8),
                      Text('${i + 1}.',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF94A3B8))),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(s.when,
                            style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF334155))),
                      ),
                      _StatusPill(status: s.status, isLabOnly: s.isLabOnly),
                    ],
                  ),
                );
              }),
            ],
          ],
          if (first.items.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(first.items.map((i) => i.serviceName).join(' · '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          ],
          if (headline.paymentStatus.isNotEmpty) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: _PaymentPill(status: headline.paymentStatus),
            ),
          ],
          if (headline.reportUrl.isNotEmpty) ...[
            const SizedBox(height: 12),
            ReportActions(
              reportUrl: headline.reportUrl,
              fileName: 'report-${headline.id}',
              accent: style.accent,
            ),
          ],
          if (first.id.isNotEmpty) ...[
            const SizedBox(height: 12),
            InvoiceActions(
              // Any single day's appointment id resolves the whole group's
              // invoice on the backend, so day 1's id is enough here.
              viewPath: ApiURL.physioInvoicePdf(first.id),
              downloadPath: ApiURL.physioInvoicePdfDownload(first.id),
              fileName: 'invoice-${first.id}',
              accent: style.accent,
            ),
          ],
        ],
      ),
    );
  }
}

// Status pill — mirrors the admin web panel's badge colors 1:1 (see
// physioStatusBadgeClasses/physioStatusLabel server-side) so the app never
// shows a different state than what the admin set. Therapy pipeline:
// pending=amber, assigned=indigo, in_progress=blue, completed=emerald,
// cancelled=rose. Lab/X-ray pipeline shares those same bookend colors,
// plus sample_collected=cyan and report_ready=orange for its two extra
// diagnostic-delivery steps.
class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status, this.isLabOnly = false});
  final String status;
  // For a lab/X-ray booking, "assigned" reads "Accepted" (assigning staff
  // IS how the booking gets accepted) and "completed" reads "Report
  // delivered" (the report has been handed to the patient).
  final bool isLabOnly;

  static const _labels = {
    'pending': 'Pending',
    'assigned': 'Assigned',
    'sample_collected': 'Sample collected',
    'in_progress': 'In progress',
    'report_ready': 'Report ready',
    'completed': 'Completed',
    'cancelled': 'Cancelled',
  };

  static const _labLabels = {
    'assigned': 'Accepted',
    'completed': 'Report delivered',
  };

  static const _bg = {
    'pending': Color(0xFFFEF3C7),
    'assigned': Color(0xFFE0E7FF),
    'sample_collected': Color(0xFFCFFAFE),
    'in_progress': Color(0xFFDBEAFE),
    'report_ready': Color(0xFFFFEDD5),
    'completed': Color(0xFFDCFCE7),
    'cancelled': Color(0xFFFFE4E6),
  };

  static const _fg = {
    'pending': Color(0xFF92400E),
    'assigned': Color(0xFF3730A3),
    'sample_collected': Color(0xFF0E7490),
    'in_progress': Color(0xFF1D4ED8),
    'report_ready': Color(0xFFC2410C),
    'completed': Color(0xFF15803D),
    'cancelled': Color(0xFFBE123C),
  };

  @override
  Widget build(BuildContext context) {
    final key = status.toLowerCase();
    final label = (isLabOnly ? _labLabels[key] : null) ?? _labels[key] ?? status;
    final bg = _bg[key] ?? const Color(0xFFEDF1EE);
    final fg = _fg[key] ?? const Color(0xFF475569);
    // 'Assigned' is a shared .tr key (Home Service's own status chip reads
    // the same key via homeServiceStatusLabel()) — overriding its Bangla
    // text here would silently change Home Service's wording too. Physio's
    // own Bangla wording is given directly instead, bypassing that key.
    final text = (key == 'assigned' &&
            !isLabOnly &&
            Get.locale?.languageCode == 'bn')
        ? 'অ্যাসাইনড'
        : label.tr;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 7, color: fg),
          const SizedBox(width: 4),
          Text(text,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
        ],
      ),
    );
  }
}

class _PaymentPill extends StatelessWidget {
  const _PaymentPill({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    late final String text;
    late final Color fg;
    late final Color bg;
    switch (status.toLowerCase()) {
      case 'paid':
        text = 'Paid'.tr;
        fg = const Color(0xFF047857);
        bg = const Color(0xFFECFDF5);
        break;
      case 'partial':
        text = 'Partially paid'.tr;
        fg = const Color(0xFFB45309);
        bg = const Color(0xFFFFFBEB);
        break;
      case 'free':
        text = 'Free treatment'.tr;
        fg = const Color(0xFF0369A1);
        bg = const Color(0xFFF0F9FF);
        break;
      default:
        text = 'Payment due'.tr;
        fg = const Color(0xFF475569);
        bg = const Color(0xFFF1F5F9);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(text,
          style:
              TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        const dash = 5.0;
        const gap = 4.0;
        final count = (c.maxWidth / (dash + gap)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            count,
            (_) => Container(
                width: dash, height: 1, color: const Color(0xFFE2E8F0)),
          ),
        );
      },
    );
  }
}
