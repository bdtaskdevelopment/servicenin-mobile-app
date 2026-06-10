import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/activity_response.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/account_controller.dart';

class MyActivityView extends GetView<AccountController> {
  const MyActivityView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F6),
      body: SafeArea(
        child: GetBuilder<AccountController>(
          builder: (con) => Column(
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
                        Text('My activity',
                            style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A))),
                        SizedBox(height: 1),
                        Text('Across all ServiceNin services',
                            style: TextStyle(
                                fontSize: 12, color: Color(0xFF94A3B8))),
                      ],
                    ),
                    const Spacer(),
                    if (con.loadingActivity && con.activities.isNotEmpty)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.2, color: Color(0xFF1E2A4A)),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => con.fetchActivity(days: con.activityDays),
                  child: _body(con),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(AccountController con) {
    if (con.loadingActivity && con.activities.isEmpty) {
      return const SnListSkeleton();
    }

    if (con.activities.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _banner(),
          const SizedBox(height: 60),
          Icon(Icons.history_rounded,
              size: 56, color: Colors.black.withValues(alpha: 0.12)),
          const SizedBox(height: 12),
          Text('No activity in the last ${con.activityDays} days',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF94A3B8))),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _banner(),
        const SizedBox(height: 16),
        ...con.activities.map((a) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ActivityCard(entry: a),
            )),
      ],
    );
  }

  Widget _banner() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: const Color(0xFFE3E7F5),
            borderRadius: BorderRadius.circular(14)),
        child: const Text(
            'Everything you do across the 12 modules shows here — one history, one identity.',
            style: TextStyle(
                fontSize: 12.5, height: 1.45, color: Color(0xFF475569))),
      );
}

// ── Per-module icon + accent colour ─────────────────────────────────
({IconData icon, Color color}) _moduleStyle(String module) {
  switch (module.toLowerCase()) {
    case 'blood':
      return (icon: Icons.water_drop_rounded, color: const Color(0xFFE11D48));
    case 'ambulance':
      return (
        icon: Icons.airport_shuttle_rounded,
        color: const Color(0xFF3B82F6)
      );
    case 'healthcare':
      return (
        icon: Icons.medical_services_rounded,
        color: const Color(0xFF14B8A6)
      );
    case 'home_service':
    case 'home-service':
      return (
        icon: Icons.home_repair_service_rounded,
        color: const Color(0xFF0E9F8E)
      );
    case 'nagarik':
      return (
        icon: Icons.account_balance_rounded,
        color: const Color(0xFFF15A24)
      );
    case 'physio':
      return (
        icon: Icons.accessibility_new_rounded,
        color: const Color(0xFF8B5CF6)
      );
    case 'education':
      return (icon: Icons.school_rounded, color: const Color(0xFF6366F1));
    case 'jobs':
      return (icon: Icons.work_outline_rounded, color: const Color(0xFF0EA5E9));
    case 'matchmaking':
      return (icon: Icons.favorite_rounded, color: const Color(0xFFEC4899));
    case 'funeral':
      return (icon: Icons.spa_rounded, color: const Color(0xFF64748B));
    default:
      return (icon: Icons.history_rounded, color: const Color(0xFF1E2A4A));
  }
}

// ── Status badge colours ────────────────────────────────────────────
({Color bg, Color fg, String label}) _statusStyle(String? status, String type) {
  final s = (status ?? '').toLowerCase();
  if (s.isEmpty) {
    return (
      bg: const Color(0xFFEEF2F7),
      fg: const Color(0xFF475569),
      label: _pretty(type)
    );
  }
  switch (s) {
    case 'completed':
    case 'done':
    case 'resolved':
    case 'fulfilled':
    case 'closed':
      return (
        bg: const Color(0xFFDCFCE7),
        fg: const Color(0xFF15803D),
        label: _pretty(s)
      );
    case 'open':
    case 'upcoming':
    case 'pending':
    case 'requested':
      return (
        bg: const Color(0xFFDBEAFE),
        fg: const Color(0xFF2563EB),
        label: _pretty(s)
      );
    case 'in_progress':
    case 'processing':
    case 'matched':
    case 'accepted':
      return (
        bg: const Color(0xFFFEF3C7),
        fg: const Color(0xFFB45309),
        label: _pretty(s)
      );
    case 'cancelled':
    case 'canceled':
    case 'rejected':
    case 'expired':
      return (
        bg: const Color(0xFFFEE2E2),
        fg: const Color(0xFFDC2626),
        label: _pretty(s)
      );
    default:
      return (
        bg: const Color(0xFFEEF2F7),
        fg: const Color(0xFF475569),
        label: _pretty(s)
      );
  }
}

String _pretty(String s) => s
    .split(RegExp(r'[_\s]+'))
    .where((w) => w.isNotEmpty)
    .map((w) => w[0].toUpperCase() + w.substring(1))
    .join(' ');

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.entry});
  final ActivityItem entry;
  @override
  Widget build(BuildContext context) {
    final m = _moduleStyle(entry.module);
    final st = _statusStyle(entry.status, entry.type);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
                color: m.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(m.icon, color: m.color, size: 23),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_pretty(entry.module).toUpperCase(),
                    style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                        color: m.color)),
                const SizedBox(height: 3),
                Text(entry.title,
                    style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A))),
                if (entry.displayTime.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(entry.displayTime,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF94A3B8))),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
                color: st.bg, borderRadius: BorderRadius.circular(20)),
            child: Text(st.label,
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700, color: st.fg)),
          ),
        ],
      ),
    );
  }
}
