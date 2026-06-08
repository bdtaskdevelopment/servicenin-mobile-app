import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/donor_response.dart';
import '../controllers/donation_flow_controller.dart';

const _red = Color(0xFFE11D48);
const _navy = Color(0xFF1E2A4A);

const List<Color> _palette = [
  Color(0xFFE11D48),
  Color(0xFFF59E0B),
  Color(0xFF6366F1),
  Color(0xFF14B8A6),
  Color(0xFFEC4899),
  Color(0xFF0EA5E9),
];

String _displayName(DonorEntry d) =>
    d.fullName.isNotEmpty ? d.fullName : 'Donor';

class LeaderboardView extends GetView<DonationFlowController> {
  const LeaderboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
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
                            Text('Top donors · ServiceNin',
                                style: TextStyle(
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
                  child: Center(
                    child: CircularProgressIndicator(
                        strokeWidth: 2.6, color: _red),
                  ),
                )
              else if (list.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text('No donors on the leaderboard yet',
                        style: TextStyle(color: Color(0xFF94A3B8))),
                  ),
                )
              else ...[
                // Navy podium (top 3)
                Container(
                  width: double.infinity,
                  color: _navy,
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
                // Ranking list (rank 4+)
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: con.fetchLeaderboard,
                    color: _red,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      children: [
                        for (var i = 3; i < list.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _RankRow(donor: list[i], rank: i + 1),
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
          child: Text(donor.initials,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: crowned ? 18 : 15,
                  fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 6),
        Text(_displayName(donor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700)),
        Text('${donor.totalDonations}',
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
          child: Text('$rank',
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
  const _RankRow({required this.donor, required this.rank});
  final DonorEntry donor;
  final int rank;

  @override
  Widget build(BuildContext context) {
    final color = _palette[rank % _palette.length];
    final subtitle = donor.bloodGroup.isNotEmpty
        ? '${donor.bloodGroup} donor'
        : 'Donor';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEFF2)),
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
                color: color.withValues(alpha: 0.14), shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(donor.initials,
                style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_displayName(donor),
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
          Text('${donor.totalDonations}',
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800, color: _red)),
        ],
      ),
    );
  }
}
