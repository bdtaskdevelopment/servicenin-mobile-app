import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../core/values/app_url.dart';
import '../../../global_widget/invoice_actions.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/physio_controller.dart';

const _orange = Color(0xFFB45309);
const _tile = Color(0xFFFCE6CB);

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
        title: Text('My sessions'.tr,
            style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A))),
      ),
      body: RefreshIndicator(
        color: _orange,
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

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.group});
  final List<PhysioSession> group;

  @override
  Widget build(BuildContext context) {
    final first = group.first;
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
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3)),
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
                    color: _tile, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.directions_run_rounded,
                    color: _orange, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(first.doctor,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A))),
                        ),
                        if (group.length > 1) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                                color: _tile,
                                borderRadius: BorderRadius.circular(6)),
                            child: Text(
                                '${'Day'.tr} ${headlineIndex + 1}/${group.length}',
                                style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: _orange)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(first.center,
                        style: const TextStyle(
                            fontSize: 12.5, color: Color(0xFF94A3B8))),
                    if (group.length > 1) ...[
                      const SizedBox(height: 3),
                      Text(
                          '$completedCount/${group.length} ${'days completed'.tr}',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF16A34A))),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusPill(status: headline.status),
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
                      color: _tile, borderRadius: BorderRadius.circular(8)),
                  child: Text(headline.progress!,
                      style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: _orange)),
                ),
            ],
          ),
          if (first.id.isNotEmpty) ...[
            const SizedBox(height: 12),
            InvoiceActions(
              // Any single day's appointment id resolves the whole group's
              // invoice on the backend, so day 1's id is enough here.
              viewPath: ApiURL.physioInvoicePdf(first.id),
              downloadPath: ApiURL.physioInvoicePdfDownload(first.id),
              fileName: 'invoice-${first.id}',
              accent: _orange,
            ),
          ],
        ],
      ),
    );
  }
}

// Status pill — mirrors the admin web panel's badge colors 1:1 so the
// app never shows a different state than what the admin set:
// pending=amber, assigned=indigo, in_progress=blue, completed=emerald,
// cancelled=rose.
class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final String status;

  static const _labels = {
    'pending': 'Pending',
    'assigned': 'Assigned',
    'in_progress': 'In progress',
    'completed': 'Completed',
    'cancelled': 'Cancelled',
  };

  static const _bg = {
    'pending': Color(0xFFFEF3C7),
    'assigned': Color(0xFFE0E7FF),
    'in_progress': Color(0xFFDBEAFE),
    'completed': Color(0xFFDCFCE7),
    'cancelled': Color(0xFFFFE4E6),
  };

  static const _fg = {
    'pending': Color(0xFF92400E),
    'assigned': Color(0xFF3730A3),
    'in_progress': Color(0xFF1D4ED8),
    'completed': Color(0xFF15803D),
    'cancelled': Color(0xFFBE123C),
  };

  @override
  Widget build(BuildContext context) {
    final key = status.toLowerCase();
    final label = _labels[key] ?? status;
    final bg = _bg[key] ?? const Color(0xFFEDF1EE);
    final fg = _fg[key] ?? const Color(0xFF475569);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 7, color: fg),
          const SizedBox(width: 4),
          Text(label.tr,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
        ],
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
