import 'package:animate_do/animate_do.dart';
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
            _Header(con: controller),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshHome,
                color: const Color(0xFFE11D48),
                child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
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
                            title: 'Need blood'.tr,
                            subtitle: 'Send a blood request'.tr,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GetBuilder<BloodController>(
                            builder: (con) => _ActionCard(
                              onTap: con.openDonate,
                              isPrimary: false,
                              icon: Icons.favorite_rounded,
                              title: 'Donate'.tr,
                              subtitle: 'Give blood · save lives'.tr,
                              badgeCount: con.openRequestsCount,
                            ),
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
                    builder: (con) => GestureDetector(
                      onTap: con.openMyResponses,
                      child: _MyResponsesCard(count: con.myResponses.length),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GetBuilder<BloodController>(
                    builder: (con) => GestureDetector(
                      onTap: con.openMyRequests,
                      child: _MyRequestsCard(count: con.myRequests.length),
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
                  const SizedBox(height: 22),
                  Text('LEARN & FAQ'.tr,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF94A3B8),
                          letterSpacing: 0.8)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 124,
                    child: Row(
                      children: [
                        Expanded(
                          child: _ActionCard(
                            onTap: () => Get.toNamed(Routes.BLOOD_BLOG),
                            isPrimary: false,
                            icon: Icons.menu_book_rounded,
                            title: 'Blog'.tr,
                            subtitle: 'Tips & stories about donating'.tr,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionCard(
                            onTap: () => Get.toNamed(Routes.BLOOD_FAQ),
                            isPrimary: false,
                            icon: Icons.quiz_rounded,
                            title: 'FAQ'.tr,
                            subtitle: 'Common questions answered'.tr,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
  const _Header({required this.con});
  final BloodController con;

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
            children: [
              Text('Blood Bank'.tr,
                  style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A))),
              const SizedBox(height: 1),
              Text('Donors near you · ServiceNin'.tr,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
            ],
          ),
          const Spacer(),
          GetBuilder<BloodController>(
            builder: (c) => _AvailabilityToggleSwitch(con: c),
          ),
        ],
      ),
    );
  }
}

// ── Available-for-donation toggle (header, top-right) ───────────────
class _AvailabilityToggleSwitch extends StatelessWidget {
  const _AvailabilityToggleSwitch({required this.con});
  final BloodController con;

  @override
  Widget build(BuildContext context) {
    final on = con.isAvailable;
    return Tooltip(
      message: on
          ? 'You\'ll receive nearby blood requests'.tr
          : 'You\'re paused — no requests for now'.tr,
      child: Transform.scale(
        scale: 0.85,
        child: Switch(
          value: on,
          onChanged: con.toggleAvailable,
          activeThumbColor: Colors.white,
          activeTrackColor: const Color(0xFF16A34A),
        ),
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
    this.badgeCount,
  });

  final VoidCallback onTap;
  final bool isPrimary;
  final IconData icon;
  final String title;
  final String subtitle;

  /// Small count badge in the top-right corner — e.g. how many open blood
  /// requests are waiting for a donor. Hidden when null or 0.
  final int? badgeCount;

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
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon,
                    color: isPrimary ? Colors.white : const Color(0xFF0F172A),
                    size: isPrimary ? 26 : 24),
                const Spacer(),
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: isPrimary
                            ? Colors.white
                            : const Color(0xFF0F172A),
                        fontSize: 17,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: isPrimary
                            ? const Color(0xFFFFE0E2)
                            : const Color(0xFF94A3B8),
                        fontSize: 12)),
              ],
            ),
            if ((badgeCount ?? 0) > 0)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 3),
                  constraints: const BoxConstraints(minWidth: 22),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE11D48),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Text(
                    badgeCount! > 99 ? '99+' : '$badgeCount',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
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
                Text("You're a registered donor".tr,
                    style: const TextStyle(
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
              children: [
                const Icon(Icons.check_circle, size: 13, color: Color(0xFF16A34A)),
                const SizedBox(width: 4),
                Text(
                    Get.locale?.languageCode == 'bn'
                        ? 'অ্যাভেইলেবল'
                        : 'Available',
                    style: const TextStyle(
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Become a donor'.tr,
                    style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text('Register & verify · get nearby requests'.tr,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('My responses'.tr,
                    style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text('Requests you responded to · chat or call'.tr,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
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

// ── My requests card ────────────────────────────────────────────────
class _MyRequestsCard extends StatelessWidget {
  const _MyRequestsCard({required this.count});
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
            child: const Icon(Icons.assignment_outlined,
                size: 22, color: Color(0xFFE11D48)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('My requests'.tr,
                    style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text('Your blood requests · view responders'.tr,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF94A3B8))),
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
          children: [
            Text('Requests near you'.tr,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A))),
            const SizedBox(height: 2),
            Text('Matching your group & area'.tr,
                style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: onSeeAll,
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text('See all →'.tr,
                style: const TextStyle(
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
        child: Text('No donors near you right now.'.tr,
            style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
      );
    }

    // Show the closest few here; the rest live on the "See all" screen.
    final shown = con.nearestDonors.take(3).toList();
    return Column(
      children: [
        ...shown.asMap().entries.map((e) => FadeInUp(
              from: 18,
              duration: const Duration(milliseconds: 350),
              delay: Duration(milliseconds: 70 * e.key),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DonorCard(
                  donor: e.value,
                  onView: () => con.viewDonor(e.value),
                  onCall: () => con.callPhone(e.value.phone),
                ),
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
    if (loading && rank == 0) return 'Finding your position…'.tr;
    if (rank > 0) return "You're #$rank this season · keep going!";
    return 'Donate to join the leaderboard'.tr;
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
                Text('Donor leaderboard'.tr,
                    style: const TextStyle(
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
