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
                children: con.sessions
                    .map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _SessionCard(session: s),
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
  const _SessionCard({required this.session});
  final PhysioSession session;

  @override
  Widget build(BuildContext context) {
    final upcoming = session.status == SessionStatus.upcoming;
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
                    Text(session.doctor,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A))),
                    const SizedBox(height: 2),
                    Text(session.center,
                        style: const TextStyle(
                            fontSize: 12.5, color: Color(0xFF94A3B8))),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusPill(upcoming: upcoming),
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
              Text(session.when,
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: upcoming
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF64748B))),
              const Spacer(),
              if (session.progress != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: _tile, borderRadius: BorderRadius.circular(8)),
                  child: Text(session.progress!,
                      style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: _orange)),
                ),
            ],
          ),
          if (session.id.isNotEmpty) ...[
            const SizedBox(height: 12),
            InvoiceActions(
              viewPath: ApiURL.physioInvoicePdf(session.id),
              downloadPath: ApiURL.physioInvoicePdfDownload(session.id),
              fileName: 'invoice-${session.id}',
              accent: _orange,
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.upcoming});
  final bool upcoming;
  @override
  Widget build(BuildContext context) {
    if (upcoming) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.circle, size: 7, color: Color(0xFF16A34A)),
            const SizedBox(width: 4),
            Text('Upcoming'.tr,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF15803D))),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: const Color(0xFFEDF1EE),
          borderRadius: BorderRadius.circular(20)),
      child: Text('Completed'.tr,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF475569))),
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
