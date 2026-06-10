import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/nagarik_response.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/nagarik_controller.dart';
import 'nagarik_view.dart' show StatusPill, ReportCard;

const _orange = Color(0xFFF15A24);
const _tile = Color(0xFFFCE6CB);

class NagarikReportsView extends GetView<NagarikController> {
  const NagarikReportsView({super.key});

  @override
  Widget build(BuildContext context) {
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
          bottom: const TabBar(
            indicatorColor: _orange,
            indicatorWeight: 2.5,
            labelColor: _orange,
            unselectedLabelColor: Color(0xFF94A3B8),
            labelStyle:
                TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
            unselectedLabelStyle:
                TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
            tabs: [
              Tab(text: 'Grievances'),
              Tab(text: 'Tickets'),
            ],
          ),
        ),
        body: GetBuilder<NagarikController>(
          builder: (con) => TabBarView(
            children: [
              _GrievanceTab(con: con),
              _TicketTab(con: con),
            ],
          ),
        ),
      ),
    );
  }
}

class _GrievanceTab extends StatelessWidget {
  const _GrievanceTab({required this.con});
  final NagarikController con;
  @override
  Widget build(BuildContext context) {
    if (con.loadingGrievances && con.grievances.isEmpty) {
      return const SnListSkeleton(padding: EdgeInsets.fromLTRB(16, 16, 16, 24));
    }
    if (con.grievances.isEmpty) {
      return const _Empty('No grievances filed yet.');
    }
    return RefreshIndicator(
      color: _orange,
      onRefresh: con.fetchGrievances,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: con.grievances
            .map((g) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () => con.openGrievance(g),
                    child: ReportCard(report: g),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _TicketTab extends StatelessWidget {
  const _TicketTab({required this.con});
  final NagarikController con;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (con.loadingTickets && con.tickets.isEmpty)
          const SnListSkeleton(padding: EdgeInsets.fromLTRB(16, 16, 16, 90))
        else if (con.tickets.isEmpty)
          const _Empty('No support tickets yet.')
        else
          RefreshIndicator(
            color: _orange,
            onRefresh: con.fetchTickets,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
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
          ),
        Positioned(
          right: 16,
          bottom: 20,
          child: FloatingActionButton.extended(
            onPressed: con.newTicket,
            backgroundColor: _orange,
            foregroundColor: Colors.white,
            elevation: 2,
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('New ticket',
                style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 140),
        Center(
          child: Text(text,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF94A3B8))),
        ),
      ],
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.t});
  final NagarikTicket t;
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
                Text(t.subject.isNotEmpty ? t.subject : t.categoryLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text(
                    [t.categoryLabel, t.createdLabel]
                        .where((s) => s.isNotEmpty)
                        .join('  ·  '),
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          const SizedBox(width: 8),
          StatusPill(label: t.statusLabel, resolved: t.isResolved),
        ],
      ),
    );
  }
}
