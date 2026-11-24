import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/values/app_colors.dart';
import '../../../core/values/app_url.dart';
import '../../../routes/app_pages.dart';
import '../../support/views/support_view.dart';
import '../controllers/blood_controller.dart';
import '../controllers/need_blood_controller.dart';

const _red = Color(0xFFE5383B);
const _pinkTile = Color(0xFFFDECEC);
const _maroon = Color(0xFF8E1B2C);
const _gold = Color(0xFFFBBF24);
const _orange = Color(0xFFEA5A0C);
const _green = Color(0xFF16A34A);

class BloodView extends GetView<BloodController> {
  const BloodView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FA),
      body: SafeArea(
        child: Column(
          children: [
            _Header(con: controller),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshHome,
                color: _red,
                child: GetBuilder<BloodController>(
                  builder: (con) => ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      // Hero: Need blood / Donate
                      SizedBox(
                        height: 130,
                        child: Row(
                          children: [
                            Expanded(
                              child: _HeroCard(
                                onTap: () {
                                  Get.find<NeedBloodController>().startNew();
                                  Get.toNamed(Routes.BLOOD_NEED);
                                },
                                isPrimary: true,
                                icon: LucideIcons.droplet,
                                title: 'Need blood'.tr,
                                subtitle: 'Send a blood request'.tr,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _HeroCard(
                                onTap: con.openDonate,
                                isPrimary: false,
                                icon: LucideIcons.heart,
                                title: 'Donate'.tr,
                                subtitle: 'Give blood · save lives'.tr,
                                badgeCount: con.openRequestsCount,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _ListTile(
                        icon: LucideIcons.userPlus,
                        iconBg: _pinkTile,
                        iconColor: _red,
                        title: (con.isDonor
                                ? 'Update donor profile'
                                : 'Become a donor')
                            .tr,
                        subtitle: (con.isDonor
                                ? 'Update your details · availability'
                                : 'Register & verify · get nearby requests')
                            .tr,
                        onTap: () => Get.toNamed(Routes.BLOOD_DONOR_REGISTER),
                      ),
                      const SizedBox(height: 12),
                      _ListTile(
                        icon: LucideIcons.users,
                        iconBg: const Color(0xFFDCFCE7),
                        iconColor: _green,
                        title: 'Become a volunteer'.tr,
                        subtitle: 'Join our volunteer team'.tr,
                        badge: 'New'.tr,
                        badgeColor: _orange,
                        onTap: () => Get.toNamed(Routes.BLOOD_VOLUNTEER_REGISTER),
                      ),
                      const SizedBox(height: 12),
                      _ListTile(
                        icon: LucideIcons.history,
                        iconBg: _pinkTile,
                        iconColor: _red,
                        title: 'My donations'.tr,
                        subtitle: 'How many times · upload photos'.tr,
                        onTap: con.openMyResponses,
                      ),
                      const SizedBox(height: 12),
                      _ListTile(
                        icon: LucideIcons.fileText,
                        iconBg: _pinkTile,
                        iconColor: _red,
                        title: 'My requests'.tr,
                        subtitle: 'Edit · widen reach · update donation'.tr,
                        count: con.myRequests.length,
                        onTap: con.openMyRequests,
                      ),
                      const SizedBox(height: 14),
                      GestureDetector(
                        onTap: con.openNearbyDonors,
                        child: _NearbyDonorsCard(
                            count: con.nearestDonors.length),
                      ),
                      const SizedBox(height: 14),
                      GestureDetector(
                        onTap: () => Get.toNamed(Routes.BLOOD_LEADERBOARD),
                        child: _LeaderboardCard(
                          rank: con.rank,
                          loading: con.loadingRank,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text('COMMUNITY'.tr,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF94A3B8),
                              letterSpacing: 0.8)),
                      const SizedBox(height: 12),
                      _EventsPreview(con: con),
                      const SizedBox(height: 12),
                      _ListTile(
                        icon: LucideIcons.calendarDays,
                        iconBg: const Color(0xFFDBEAFE),
                        iconColor: const Color(0xFF2563EB),
                        title: 'Events'.tr,
                        subtitle: 'Camps & upcoming programs'.tr,
                        badge: 'New'.tr,
                        badgeColor: _orange,
                        onTap: con.openEvents,
                      ),
                      const SizedBox(height: 12),
                      _ListTile(
                        icon: LucideIcons.building2,
                        iconBg: const Color(0xFFFEF3C7),
                        iconColor: const Color(0xFFB45309),
                        title: 'Other blood banks'.tr,
                        subtitle: 'Registered blood banks in Dhaka'.tr,
                        badge: 'New'.tr,
                        badgeColor: _orange,
                        onTap: con.openBanks,
                      ),
                      const SizedBox(height: 18),
                      _StatsCard(stats: con.communityStats),
                      const SizedBox(height: 22),
                      Text('LEARN & FAQ'.tr,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF94A3B8),
                              letterSpacing: 0.8)),
                      const SizedBox(height: 12),
                      _ListTile(
                        icon: LucideIcons.bookOpen,
                        iconBg: const Color(0xFFEDE9FE),
                        iconColor: const Color(0xFF7C3AED),
                        title: 'Blood donation blog'.tr,
                        subtitle: 'Tips & stories about donating'.tr,
                        onTap: () => Get.toNamed(Routes.BLOOD_BLOG),
                      ),
                      const SizedBox(height: 12),
                      _ListTile(
                        icon: LucideIcons.circleHelp,
                        iconBg: const Color(0xFFDBEAFE),
                        iconColor: const Color(0xFF0EA5E9),
                        title: 'Blood donation FAQ'.tr,
                        subtitle: 'Common questions answered'.tr,
                        onTap: () => Get.toNamed(Routes.BLOOD_FAQ),
                      ),
                      const SizedBox(height: 22),
                      Text('CONNECT WITH US'.tr,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF94A3B8),
                              letterSpacing: 0.8)),
                      const SizedBox(height: 12),
                      const _SocialLinksRow(),
                    ],
                  ),
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
      padding: const EdgeInsets.fromLTRB(8, 6, 16, 10),
      child: Row(
        children: [
          IconButton(
            splashRadius: 22,
            onPressed: () => Get.back(),
            icon: const Icon(LucideIcons.chevronLeft,
                size: 22, color: Color(0xFF0F172A)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Blood donation'.tr,
                  style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A))),
              const SizedBox(height: 1),
              Text('Donors near you'.tr,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
            ],
          ),
          const Spacer(),
          GetBuilder<BloodController>(
            builder: (c) => _AvailabilityToggleSwitch(con: c),
          ),
          const SizedBox(width: 8),
          SupportIconButton(
            title: 'Blood Support'.tr,
            endpoint: ApiURL.bloodHotlines,
          ),
        ],
      ),
    );
  }
}

class _AvailabilityToggleSwitch extends StatelessWidget {
  const _AvailabilityToggleSwitch({required this.con});
  final BloodController con;

  @override
  Widget build(BuildContext context) {
    if (!con.isDonor) return const SizedBox.shrink();
    final on = con.isAvailable;
    return Tooltip(
      message: on
          ? 'You\'ll receive nearby blood requests'.tr
          : 'You\'re paused — no requests for now'.tr,
      child: Transform.scale(
        scale: 0.8,
        child: Switch(
          value: on,
          onChanged: con.toggleAvailable,
          activeThumbColor: Colors.white,
          activeTrackColor: _green,
        ),
      ),
    );
  }
}

// ── Hero card (Need blood / Donate) ─────────────────────────────────
class _HeroCard extends StatelessWidget {
  const _HeroCard({
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
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isPrimary ? _red : AppColors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isPrimary
                        ? Colors.white.withValues(alpha: 0.22)
                        : _pinkTile,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon,
                      color: isPrimary ? Colors.white : _red, size: 20),
                ),
                const Spacer(),
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: isPrimary ? Colors.white : const Color(0xFF0F172A),
                        fontSize: 17,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: isPrimary
                            ? Colors.white.withValues(alpha: 0.85)
                            : const Color(0xFF94A3B8),
                        fontSize: 12)),
              ],
            ),
            if ((badgeCount ?? 0) > 0)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  constraints: const BoxConstraints(minWidth: 22),
                  decoration: BoxDecoration(
                    color: _red,
                    borderRadius: BorderRadius.circular(20),
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

// ── Generic white list-row tile used throughout the home screen ─────
class _ListTile extends StatelessWidget {
  const _ListTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.count,
    this.badge,
    this.badgeColor,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final int? count;
  final String? badge;
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration:
                  BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, size: 22, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A))),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                              color: (badgeColor ?? _orange).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6)),
                          child: Text(badge!,
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: badgeColor ?? _orange)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if ((count ?? 0) > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: _pinkTile, borderRadius: BorderRadius.circular(20)),
                child: Text('$count',
                    style: const TextStyle(
                        fontSize: 12.5, fontWeight: FontWeight.w800, color: _red)),
              ),
            const SizedBox(width: 6),
            const Icon(LucideIcons.chevronRight,
                size: 18, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}

// ── "কাছাকাছি ডোনার খুঁজুন" live card ────────────────────────────────
class _NearbyDonorsCard extends StatelessWidget {
  const _NearbyDonorsCard({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _red, width: 1.3),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: _red, shape: BoxShape.circle),
            child: const Icon(LucideIcons.radio, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Find nearby donors'.tr,
                    style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text(
                    count > 0
                        ? '${'Now'.tr} $count ${'donors online nearby'.tr}'
                        : 'See donors near your location'.tr,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.circle, size: 6, color: _green),
                const SizedBox(width: 4),
                Text('Live'.tr,
                    style: const TextStyle(
                        fontSize: 10.5, fontWeight: FontWeight.w800, color: _green)),
              ],
            ),
          ),
          const SizedBox(width: 4),
          const Icon(LucideIcons.chevronRight, size: 18, color: Color(0xFF94A3B8)),
        ],
      ),
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
    if (rank > 0) {
      return '${"You're #".tr}$rank${' this season · keep going!'.tr}';
    }
    return 'Donate to join the leaderboard'.tr;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _maroon,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: _gold.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(LucideIcons.trophy, color: _gold, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Top donors (Blood heroes)'.tr,
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _gold.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('#$rank',
                  style: const TextStyle(
                      color: _gold, fontSize: 14, fontWeight: FontWeight.w800)),
            ),
          const Icon(LucideIcons.chevronRight, color: Colors.white),
        ],
      ),
    );
  }
}

// ── Upcoming events preview carousel ─────────────────────────────────
class _EventsPreview extends StatelessWidget {
  const _EventsPreview({required this.con});
  final BloodController con;

  @override
  Widget build(BuildContext context) {
    final events = con.upcomingEvents.take(5).toList();
    if (con.loadingEvents && events.isEmpty) {
      return const SizedBox(
          height: 150,
          child: Center(
              child: SizedBox(
                  width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: _red))));
    }
    if (events.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: events.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final e = events[i];
          final banner = i.isEven ? _red : const Color(0xFF1E3A8A);
          return GestureDetector(
            onTap: () => con.openEvent(e),
            child: Container(
              width: 240,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3)),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 70,
                    width: double.infinity,
                    color: banner,
                    alignment: Alignment.center,
                    child: e.bannerUrl.isEmpty
                        ? Icon(LucideIcons.image,
                            color: Colors.white.withValues(alpha: 0.6), size: 22)
                        : Image.network(e.bannerUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                        const SizedBox(height: 4),
                        Text(e.dateLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Community impact stats ───────────────────────────────────────────
class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.stats});
  final Map<String, int> stats;

  String _fmt(int n) {
    final s = n.toString();
    if (s.length <= 3) return s;
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      final fromEnd = s.length - i;
      buf.write(s[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) buf.write(',');
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final donors = stats['donors'] ?? 0;
    final bags = stats['bags'] ?? 0;
    final camps = stats['camps'] ?? 0;
    final grouping = stats['grouping'] ?? 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _maroon, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Our impact so far'.tr,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w800)),
              ),
              const Icon(LucideIcons.heart, color: Colors.white, size: 20),
            ],
          ),
          const SizedBox(height: 2),
          Text('What we\'ve achieved together'.tr,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                  child: _StatTile(
                      icon: LucideIcons.users, value: _fmt(donors), label: 'Donors'.tr)),
              const SizedBox(width: 10),
              Expanded(
                  child: _StatTile(
                      icon: LucideIcons.droplet,
                      value: _fmt(bags),
                      label: 'Total donations (bags)'.tr)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: _StatTile(
                      icon: LucideIcons.calendarDays, value: _fmt(camps), label: 'Blood camps'.tr)),
              const SizedBox(width: 10),
              Expanded(
                  child: _StatTile(
                      icon: LucideIcons.droplets,
                      value: _fmt(grouping),
                      label: 'Blood grouping'.tr)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 11)),
        ],
      ),
    );
  }
}

// ── Social links (static — no backend-provided URLs exist yet) ──────
class _SocialLinksRow extends StatelessWidget {
  const _SocialLinksRow();

  void _notAvailable() {
    Get.snackbar(
      ''.tr,
      'Coming soon'.tr,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SocialButton(
            filled: true,
            label: 'Facebook Page'.tr,
            sublabel: 'Follow us'.tr,
            onTap: _notAvailable,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SocialButton(
            filled: false,
            label: 'Facebook Group'.tr,
            sublabel: 'Join the group'.tr,
            onTap: _notAvailable,
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.filled,
    required this.label,
    required this.sublabel,
    required this.onTap,
  });
  final bool filled;
  final String label;
  final String sublabel;
  final VoidCallback onTap;

  static const _fbBlue = Color(0xFF1877F2);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: filled ? _fbBlue : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: filled ? null : Border.all(color: _fbBlue, width: 1.3),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                  color: filled ? Colors.white.withValues(alpha: 0.2) : _fbBlue,
                  shape: BoxShape.circle),
              alignment: Alignment.center,
              child: const Text('f',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: filled ? Colors.white : _fbBlue,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800)),
                  Text(sublabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: filled ? Colors.white.withValues(alpha: 0.85) : _fbBlue.withValues(alpha: 0.7),
                          fontSize: 10.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
