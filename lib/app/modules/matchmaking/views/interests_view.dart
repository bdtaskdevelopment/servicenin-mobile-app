import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/matchmaking_controller.dart';

const _maroon = Color(0xFFB11D5C);
const _pink = Color(0xFFFBD9E8);

class InterestsView extends GetView<MatchmakingController> {
  const InterestsView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
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
          title: Text('Interests'.tr,
              style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A))),
          bottom: TabBar(
            indicatorColor: _maroon,
            indicatorWeight: 2.5,
            labelColor: _maroon,
            unselectedLabelColor: const Color(0xFF94A3B8),
            labelStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
            unselectedLabelStyle:
                const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
            tabs: [
              Tab(text: 'Received'.tr),
              Tab(text: 'Sent'.tr),
              Tab(text: 'Matches'.tr),
            ],
          ),
        ),
        body: GetBuilder<MatchmakingController>(
          builder: (con) => TabBarView(
            children: [
              _ReceivedTab(con: con),
              _SentTab(con: con),
              _MatchesTab(con: con),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar(this.letter);
  final String letter;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
          color: _pink, borderRadius: BorderRadius.circular(12)),
      alignment: Alignment.center,
      child: Text(letter,
          style: const TextStyle(
              color: _maroon, fontSize: 17, fontWeight: FontWeight.w800)),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
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
        child: child,
      );
}

Widget _loaderOrEmpty(bool loading, bool empty, String emptyText) {
  if (loading) {
    return const SnListSkeleton();
  }
  return ListView(
    children: [
      const SizedBox(height: 140),
      Center(
          child: Text(emptyText,
              style: const TextStyle(color: Color(0xFF94A3B8)))),
    ],
  );
}

class _ReceivedTab extends StatelessWidget {
  const _ReceivedTab({required this.con});
  final MatchmakingController con;
  @override
  Widget build(BuildContext context) {
    if (con.received.isEmpty) {
      return _loaderOrEmpty(
          con.loadingReceived, true, 'No interests received.'.tr);
    }
    return RefreshIndicator(
      color: _maroon,
      onRefresh: con.fetchReceived,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: con.received.toList().asMap().entries.map((e) {
          final it = e.value;
          final s = it.sender;
          return FadeInUp(
            from: 18,
            duration: const Duration(milliseconds: 350),
            delay: Duration(milliseconds: 70 * e.key),
            child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _Card(
              child: Column(
                children: [
                  Row(
                    children: [
                      _Avatar(s?.letter ?? '?'),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s?.code ?? '',
                                style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFB45309))),
                            const SizedBox(height: 3),
                            Text(s?.summary ?? '',
                                style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A))),
                            if (it.message.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(it.message,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF94A3B8))),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (it.pending) ...[
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: OutlinedButton(
                              onPressed: con.responding
                                  ? null
                                  : () => con.respond(it, false),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: Color(0xFFE2E8F0)),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12)),
                              ),
                              child: Text('Decline'.tr,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF334155))),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: ElevatedButton(
                              onPressed: con.responding
                                  ? null
                                  : () => con.respond(it, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _maroon,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12)),
                              ),
                              child: Text('Accept & share'.tr,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _StatusChip(status: it.status),
                    ),
                  ],
                ],
              ),
            ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SentTab extends StatelessWidget {
  const _SentTab({required this.con});
  final MatchmakingController con;
  @override
  Widget build(BuildContext context) {
    if (con.sent.isEmpty) {
      return _loaderOrEmpty(con.loadingSent, true, 'No interests sent.'.tr);
    }
    return RefreshIndicator(
      color: _maroon,
      onRefresh: con.fetchSent,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: con.sent.toList().asMap().entries.map((e) {
          final it = e.value;
          final r = it.receiver;
          return FadeInUp(
            from: 18,
            duration: const Duration(milliseconds: 350),
            delay: Duration(milliseconds: 70 * e.key),
            child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _Avatar(r?.letter ?? '?'),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r?.code ?? '',
                                style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFB45309))),
                            const SizedBox(height: 3),
                            Text(r?.summary ?? '',
                                style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A))),
                          ],
                        ),
                      ),
                      _StatusChip(status: it.status),
                    ],
                  ),
                ],
              ),
            ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MatchesTab extends StatelessWidget {
  const _MatchesTab({required this.con});
  final MatchmakingController con;
  @override
  Widget build(BuildContext context) {
    if (con.matches.isEmpty) {
      return _loaderOrEmpty(con.loadingMatches, true, 'No matches yet.'.tr);
    }
    return RefreshIndicator(
      color: _maroon,
      onRefresh: con.fetchMatches,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: con.matches.toList().asMap().entries.map((e) {
          final m = e.value;
          final p = m.match;
          return FadeInUp(
            from: 18,
            duration: const Duration(milliseconds: 350),
            delay: Duration(milliseconds: 70 * e.key),
            child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _Card(
              child: Row(
                children: [
                  _Avatar(p.letter),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.code,
                            style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFB45309))),
                        const SizedBox(height: 3),
                        Text(p.summary,
                            style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A))),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () =>
                        con.openChat(m.interest.id, p.code),
                    icon: const Icon(Icons.chat_bubble_outline_rounded,
                        size: 16),
                    label: Text('Chat'.tr,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w800)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _maroon,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;
  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();
    final accepted = s == 'accepted';
    final declined = s == 'declined' || s == 'rejected';
    final bg = declined
        ? const Color(0xFFFEE2E2)
        : accepted
            ? const Color(0xFFDCFCE7)
            : const Color(0xFFFEF3C7);
    final fg = declined
        ? const Color(0xFFDC2626)
        : accepted
            ? const Color(0xFF15803D)
            : const Color(0xFFB45309);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(status.isEmpty ? 'Pending'.tr : mmHumanize(status),
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w800, color: fg)),
    );
  }
}
