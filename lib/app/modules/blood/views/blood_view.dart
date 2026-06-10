import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../global_widget/sn_shimmer.dart';
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
                            onTap: controller.openDonate,
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
                  // Registered-donor card — commented out for now.
                  // _DonorCard(con: controller),
                  // const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => Get.toNamed(Routes.BLOOD_DONOR_REGISTER),
                    child: const _RegisterDonorCard(),
                  ),
                  const SizedBox(height: 12),
                  GetBuilder<BloodController>(
                    builder: (con) => _AvailabilityCard(con: con),
                  ),
                  const SizedBox(height: 12),
                  GetBuilder<BloodController>(
                    builder: (con) => GestureDetector(
                      onTap: con.openMyResponses,
                      child: _MyResponsesCard(count: con.myResponses.length),
                    ),
                  ),
                  const SizedBox(height: 22),
                  _RequestsHeader(onSeeAll: controller.openAllDonors),
                  const SizedBox(height: 12),
                  GetBuilder<BloodController>(
                    builder: (con) => _NearestDonors(con: con),
                  ),
                  const SizedBox(height: 6),
                  GetBuilder<BloodController>(
                    builder: (con) => GestureDetector(
                      onTap: () => Get.toNamed(Routes.BLOOD_LEADERBOARD),
                      child: _LeaderboardCard(
                        rank: con.rank,
                        loading: con.loadingRank,
                      ),
                    ),
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

// ── Available-for-donation switch card ──────────────────────────────
class _AvailabilityCard extends StatelessWidget {
  const _AvailabilityCard({required this.con});
  final BloodController con;

  @override
  Widget build(BuildContext context) {
    final on = con.isAvailable;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEFF2)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: on ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              on ? Icons.volunteer_activism_rounded : Icons.pause_circle_outline,
              color: on ? const Color(0xFF16A34A) : const Color(0xFF94A3B8),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Available for donation',
                    style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text(
                  on
                      ? 'You\'ll receive nearby blood requests'
                      : 'You\'re paused — no requests for now',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
          Switch(
            value: on,
            onChanged: con.toggleAvailable,
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFF16A34A),
          ),
        ],
      ),
    );
  }
}

// ── Registered donor card ───────────────────────────────────────────
// ignore: unused_element
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

// ── Register-as-donor card ──────────────────────────────────────────
class _RegisterDonorCard extends StatelessWidget {
  const _RegisterDonorCard();

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
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFDE4E4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.volunteer_activism_rounded,
                size: 22, color: Color(0xFFE11D48)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Become a donor',
                    style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A))),
                SizedBox(height: 2),
                Text('Register & verify · get nearby requests',
                    style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }
}

// ── My connected donors card (hidden for now) ───────────────────────
/*
class _MyDonorsCard extends StatelessWidget {
  const _MyDonorsCard({required this.count});
  final int count;

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
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFDE4E4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.groups_outlined,
                size: 22, color: Color(0xFFE11D48)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('My donors',
                    style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A))),
                SizedBox(height: 2),
                Text('Stay in touch · call or message anytime',
                    style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFDE4E4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('$count',
                style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFE11D48))),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }
}
*/

// ── My responses card (GET /api/v1/blood/responses/my) ──────────────
class _MyResponsesCard extends StatelessWidget {
  const _MyResponsesCard({required this.count});
  final int count;

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
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFDE4E4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.favorite_rounded,
                size: 22, color: Color(0xFFE11D48)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('My responses',
                    style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A))),
                SizedBox(height: 2),
                Text('Requests you responded to · chat or call',
                    style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (count > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFFDE4E4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('$count',
                  style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFE11D48))),
            ),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
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

// ── Nearest donors (GET /api/v1/blood/donors/nearest) ───────────────
class _NearestDonors extends StatelessWidget {
  const _NearestDonors({required this.con});
  final BloodController con;

  @override
  Widget build(BuildContext context) {
    if (con.loadingNearest && con.nearestDonors.isEmpty) {
      return const SnListSkeleton(count: 3, padding: EdgeInsets.zero);
    }

    if (con.nearestDonors.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEDEFF2)),
        ),
        child: const Text('No donors near you right now.',
            style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
      );
    }

    // Show the closest few here; the rest live on the "See all" screen.
    final shown = con.nearestDonors.take(3).toList();
    return Column(
      children: [
        ...shown.map((d) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DonorCard(
                donor: d,
                onView: () => con.viewDonor(d),
                onCall: () => con.callPhone(d.phone),
              ),
            )),
      ],
    );
  }
}

// ── Leaderboard ─────────────────────────────────────────────────────
class _LeaderboardCard extends StatelessWidget {
  const _LeaderboardCard({required this.rank, this.loading = false});
  final int rank;
  final bool loading;

  String get _subtitle {
    if (loading && rank == 0) return 'Finding your position…';
    if (rank > 0) return "You're #$rank this season · keep going!";
    return 'Donate to join the leaderboard';
  }

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
                Text(_subtitle,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 12.5)),
              ],
            ),
          ),
          if (rank > 0)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFBBF24).withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('#$rank',
                  style: const TextStyle(
                      color: Color(0xFFFBBF24),
                      fontSize: 14,
                      fontWeight: FontWeight.w800)),
            ),
          const Icon(Icons.chevron_right_rounded, color: Colors.white),
        ],
      ),
    );
  }
}
