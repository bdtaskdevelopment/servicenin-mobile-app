import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/donation_flow_controller.dart';

const _red = Color(0xFFE11D48);
const _navy = Color(0xFF1E2A4A);

class LeaderboardView extends GetView<DonationFlowController> {
  const LeaderboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final con = controller;
    final first = con.podium.firstWhere((e) => e.rank == 1);
    final second = con.podium.firstWhere((e) => e.rank == 2);
    final third = con.podium.firstWhere((e) => e.rank == 3);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Column(
        children: [
          // Red header
          Container(
            color: _red,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 16, 14),
                child: Row(
                  children: [
                    IconButton(
                      splashRadius: 22,
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 20, color: Colors.white),
                    ),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Donor leaderboard',
                            style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                        SizedBox(height: 1),
                        Text('This season · Dhaka',
                            style: TextStyle(
                                fontSize: 12, color: Color(0xFFFFD9DC))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Navy podium
          Container(
            width: double.infinity,
            color: _navy,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: _Podium(entry: second, height: 44)),
                const SizedBox(width: 10),
                Expanded(child: _Podium(entry: first, height: 64, crowned: true)),
                const SizedBox(width: 10),
                Expanded(child: _Podium(entry: third, height: 36)),
              ],
            ),
          ),
          // Ranking list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: con.ranking
                  .map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _RankRow(entry: e),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Podium extends StatelessWidget {
  const _Podium({required this.entry, required this.height, this.crowned = false});
  final LeaderboardEntry entry;
  final double height;
  final bool crowned;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: crowned ? 64 : 54,
          height: crowned ? 64 : 54,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: crowned ? const Color(0xFFF59E0B) : Colors.white24,
              width: crowned ? 3 : 2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(entry.initials,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: crowned ? 18 : 15,
                  fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 6),
        Text(entry.name,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700)),
        Text('${entry.points}',
            style: const TextStyle(
                color: Color(0xFFF59E0B),
                fontSize: 13,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          alignment: Alignment.center,
          child: Text('${entry.rank}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow({required this.entry});
  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: entry.isYou ? const Color(0xFFFDECEC) : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: entry.isYou
                ? const Color(0xFFFAD1D1)
                : const Color(0xFFEDEFF2)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: Text('${entry.rank}',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF94A3B8))),
          ),
          const SizedBox(width: 6),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: entry.color.withValues(alpha: 0.14),
                shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(entry.initials,
                style: TextStyle(
                    color: entry.color,
                    fontSize: 13,
                    fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.name,
                    style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text(entry.subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          Text('${entry.points}',
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800, color: _red)),
        ],
      ),
    );
  }
}
