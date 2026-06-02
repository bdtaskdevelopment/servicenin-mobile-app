import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../routes/app_pages.dart';
import '../controllers/blood_controller.dart';
import '../widgets/blood_widgets.dart';

class BloodView extends GetView<BloodController> {
  const BloodView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            _Header(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  // Need blood / Donate — both tappable
                  SizedBox(
                    height: 124,
                    child: Row(
                      children: [
                        Expanded(
                          child: _ActionCard(
                            onTap: () => Get.toNamed(Routes.BLOOD_NEED),
                            isPrimary: true,
                            icon: Icons.water_drop_rounded,
                            title: 'Need blood',
                            subtitle: 'রক্তের অনুরোধ পাঠান',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionCard(
                            onTap: () => Get.toNamed(Routes.BLOOD_REQUESTS),
                            isPrimary: false,
                            icon: Icons.favorite_rounded,
                            title: 'Donate',
                            subtitle: 'রক্ত দিন · জীবন বাঁচান',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _DonorCard(con: controller),
                  const SizedBox(height: 22),
                  _RequestsHeader(
                      onSeeAll: () => Get.toNamed(Routes.BLOOD_REQUESTS)),
                  const SizedBox(height: 12),
                  ...controller.requests.map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: BloodRequestCard(
                          req: r,
                          onView: () {
                            controller.selectRequest(r);
                            Get.toNamed(Routes.BLOOD_REQUEST_DETAIL);
                          },
                        ),
                      )),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => Get.toNamed(Routes.BLOOD_LEADERBOARD),
                    child: _LeaderboardCard(rank: controller.rank),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ──────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(8, 6, 12, 10),
      child: Row(
        children: [
          IconButton(
            splashRadius: 22,
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 20, color: Color(0xFF1A1A1A)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Blood Bank',
                  style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A))),
              SizedBox(height: 1),
              Text('Donors near you · ServiceNin',
                  style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Get.toNamed(Routes.BLOOD_LEADERBOARD),
            child: const Icon(Icons.emoji_events_rounded,
                color: Color(0xFF1A1A1A), size: 24),
          ),
        ],
      ),
    );
  }
}

// ── Action card (Need blood / Donate) ───────────────────────────────
class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.onTap,
    required this.isPrimary,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final VoidCallback onTap;
  final bool isPrimary;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isPrimary
              ? const LinearGradient(
                  colors: [Color(0xFFE8333A), Color(0xFFC81E2A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isPrimary ? null : AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: isPrimary
              ? null
              : Border.all(color: const Color(0xFFEDEFF2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon,
                color: isPrimary ? Colors.white : const Color(0xFF0F172A),
                size: isPrimary ? 26 : 24),
            const Spacer(),
            Text(title,
                style: TextStyle(
                    color: isPrimary ? Colors.white : const Color(0xFF0F172A),
                    fontSize: 17,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(subtitle,
                style: TextStyle(
                    color: isPrimary
                        ? const Color(0xFFFFE0E2)
                        : const Color(0xFF94A3B8),
                    fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// ── Registered donor card ───────────────────────────────────────────
class _DonorCard extends StatelessWidget {
  const _DonorCard({required this.con});
  final BloodController con;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEFF2)),
      ),
      child: Row(
        children: [
          BloodGroupBadge(group: con.donorGroup),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("You're a registered donor",
                    style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 3),
                Text(
                  '${con.donations} donations · saved ~${con.livesSaved} lives · rank #${con.rank}',
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.check_circle, size: 13, color: Color(0xFF16A34A)),
                SizedBox(width: 4),
                Text('Available',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF15803D))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Requests header ─────────────────────────────────────────────────
class _RequestsHeader extends StatelessWidget {
  const _RequestsHeader({required this.onSeeAll});
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Requests near you',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A))),
            SizedBox(height: 2),
            Text('Matching your group & area',
                style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: onSeeAll,
          child: const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Text('See all →',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brandOrange)),
          ),
        ),
      ],
    );
  }
}

// ── Leaderboard ─────────────────────────────────────────────────────
class _LeaderboardCard extends StatelessWidget {
  const _LeaderboardCard({required this.rank});
  final int rank;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E2A4A), Color(0xFF2A3A60)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events_rounded,
              color: Color(0xFFFBBF24), size: 30),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Donor leaderboard',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text("You're #$rank this season · keep going!",
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 12.5)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.white),
        ],
      ),
    );
  }
}
