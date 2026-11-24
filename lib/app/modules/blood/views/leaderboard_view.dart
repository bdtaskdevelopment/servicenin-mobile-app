import 'dart:convert';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/values/app_colors.dart';
import '../../../core/values/storage.dart';
import '../../../data/models/response/donor_response.dart';
import '../../../data/services/storage.service.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/donation_flow_controller.dart';

const _red = Color(0xFFE5383B);
const _maroon = Color(0xFF8E1B2C);
const _pinkTile = Color(0xFFFDECEC);
const _gold = Color(0xFFFBBF24);

String _displayName(DonorEntry d) =>
    d.fullName.isNotEmpty ? d.fullName : 'Donor'.tr;

/// The logged-in user's id, read from stored auth info — used to highlight
/// "আপনি" (you) in the ranked list below the podium.
String? _currentUserId() {
  final raw = StorageService.read(StorageConstants.userInfo);
  if (raw is String && raw.trim().isNotEmpty) {
    try {
      final map = jsonDecode(raw);
      if (map is Map) return map['id']?.toString();
    } catch (_) {}
  }
  return null;
}

class LeaderboardView extends GetView<DonationFlowController> {
  const LeaderboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FA),
      body: GetBuilder<DonationFlowController>(
        initState: (_) =>
            Get.find<DonationFlowController>().fetchLeaderboard(),
        builder: (con) {
          final list = con.leaderboard;
          return Column(
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
                          icon: const Icon(LucideIcons.chevronLeft,
                              size: 22, color: Colors.white),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Top donors (Blood heroes)'.tr,
                                style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white)),
                            const SizedBox(height: 1),
                            Text('Most donations by our donors'.tr,
                                style: const TextStyle(
                                    fontSize: 12, color: Color(0xFFFFD9DC))),
                          ],
                        ),
                        const Spacer(),
                        if (con.loadingLeaderboard && list.isNotEmpty)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.2, color: Colors.white),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (con.loadingLeaderboard && list.isEmpty)
                const Expanded(
                  child: SnListSkeleton(),
                )
              else if (list.isEmpty)
                Expanded(
                  child: Center(
                    child: Text('No donors on the leaderboard yet'.tr,
                        style: const TextStyle(color: Color(0xFF94A3B8))),
                  ),
                )
              else ...[
                // Maroon podium (top 3)
                FadeInDown(
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                  width: double.infinity,
                  color: _maroon,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: list.length > 1
                            ? _Podium(donor: list[1], rank: 2, height: 44)
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _Podium(
                            donor: list[0], rank: 1, height: 64, crowned: true),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: list.length > 2
                            ? _Podium(donor: list[2], rank: 3, height: 36)
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                ),
                // Ranking list (rank 4+)
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: con.fetchLeaderboard,
                    color: _red,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      children: [
                        for (var i = 3; i < list.length; i++)
                          FadeInUp(
                            from: 18,
                            duration: const Duration(milliseconds: 350),
                            delay: Duration(
                                milliseconds: 70 *
                                    ((i - 3) < 6 ? (i - 3) : 6)),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _RankRow(donor: list[i], rank: i + 1),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

// Gold / silver / bronze accents for the top three.
const Map<int, Color> _medal = {
  1: Color(0xFFFBBF24),
  2: Color(0xFFCBD5E1),
  3: Color(0xFFE08A4B),
};

class _Podium extends StatelessWidget {
  const _Podium(
      {required this.donor,
      required this.rank,
      required this.height,
      this.crowned = false});
  final DonorEntry donor;
  final int rank;
  final double height;
  final bool crowned;

  @override
  Widget build(BuildContext context) {
    final medal = _medal[rank] ?? Colors.white;
    return Column(
      children: [
        SizedBox(
          height: 22,
          child: crowned
              ? const Icon(LucideIcons.crown, color: _gold, size: 22)
              : null,
        ),
        Container(
          width: crowned ? 66 : 54,
          height: crowned ? 66 : 54,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [medal.withValues(alpha: 0.35), medal.withValues(alpha: 0.12)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            border: Border.all(color: medal, width: crowned ? 3 : 2),
            boxShadow: [
              BoxShadow(color: medal.withValues(alpha: 0.4), blurRadius: 12),
            ],
          ),
          alignment: Alignment.center,
          child: Text(donor.initials,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: crowned ? 19 : 15,
                  fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 6),
        Text(_displayName(donor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.droplet,
                size: 12, color: Color(0xFFFF6B81)),
            const SizedBox(width: 3),
            Text('${donor.totalDonations}',
                style: TextStyle(
                    color: medal, fontSize: 13, fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [medal.withValues(alpha: 0.30), medal.withValues(alpha: 0.06)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(10)),
          ),
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.only(top: 6),
          child: Text('$rank',
              style: TextStyle(
                  color: medal, fontSize: 20, fontWeight: FontWeight.w900)),
        ),
      ],
    );
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow({required this.donor, required this.rank});
  final DonorEntry donor;
  final int rank;

  @override
  Widget build(BuildContext context) {
    final isMe = donor.userId.isNotEmpty && donor.userId == _currentUserId();
    final subtitle = donor.bloodGroup.isNotEmpty
        ? '${donor.bloodGroup} donor'
        : 'Donor'.tr;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFFFFF4E8) : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isMe ? const Color(0xFFEA5A0C) : const Color(0xFFEDEFF2)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: Text('$rank',
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
                color: isMe ? const Color(0xFFEA5A0C) : _pinkTile, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(donor.initials,
                style: TextStyle(
                    color: isMe ? Colors.white : _red,
                    fontSize: 13,
                    fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isMe ? '${'You'.tr} · ${_displayName(donor)}' : _displayName(donor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _red.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.droplet, size: 13, color: _red),
                const SizedBox(width: 4),
                Text('${donor.totalDonations}',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800, color: _red)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
