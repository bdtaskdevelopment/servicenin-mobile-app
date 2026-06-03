import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/nagarik_controller.dart';

const _orange = Color(0xFFF15A24);
const _tile = Color(0xFFFCE6CB);

class NagarikReportsView extends GetView<NagarikController> {
  const NagarikReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    final con = controller;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
          title: const Text('My reports',
              style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A))),
          bottom: TabBar(
            indicatorColor: _orange,
            indicatorWeight: 2.5,
            labelColor: _orange,
            unselectedLabelColor: const Color(0xFF94A3B8),
            labelStyle: const TextStyle(
                fontSize: 14.5, fontWeight: FontWeight.w800),
            unselectedLabelStyle: const TextStyle(
                fontSize: 14.5, fontWeight: FontWeight.w600),
            tabs: [
              Tab(text: 'Grievances (${con.grievances.length})'),
              Tab(text: 'Tickets (${con.tickets.length})'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: con.grievances
                  .map((g) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () => con.openGrievance(g),
                          child: _GrievanceCard(g: g),
                        ),
                      ))
                  .toList(),
            ),
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: con.tickets
                  .map((t) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () => con.openTicket(t),
                          child: _TicketCard(t: t),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final ReportStatus status;
  @override
  Widget build(BuildContext context) {
    final resolved = status == ReportStatus.resolved;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: resolved
              ? const Color(0xFFDCFCE7)
              : const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle,
              size: 7,
              color: resolved
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFD97706)),
          const SizedBox(width: 5),
          Text(resolved ? 'Resolved' : 'In progress',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: resolved
                      ? const Color(0xFF15803D)
                      : const Color(0xFFB45309))),
        ],
      ),
    );
  }
}

class _GrievanceCard extends StatelessWidget {
  const _GrievanceCard({required this.g});
  final Grievance g;
  @override
  Widget build(BuildContext context) {
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
          ]),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
                color: _tile, borderRadius: BorderRadius.circular(12)),
            child: Icon(g.icon, color: _orange, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(g.title,
                    style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text('${g.ref}  ·  ${g.ago}',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _StatusPill(status: g.status),
        ],
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.t});
  final Ticket t;
  @override
  Widget build(BuildContext context) {
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
          ]),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
                color: _tile, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.chat_bubble_outline_rounded,
                color: _orange, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.title,
                    style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text('${t.code}  ·  ${t.dept}  ·  ${t.ago}',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _StatusPill(status: t.status),
        ],
      ),
    );
  }
}
