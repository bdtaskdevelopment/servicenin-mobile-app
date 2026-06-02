import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/matchmaking_controller.dart';

const _maroon = Color(0xFFB11D5C);
const _darkMaroon = Color(0xFF8A1444);
const _pink = Color(0xFFFBD9E8);

class MatchmakingView extends GetView<MatchmakingController> {
  const MatchmakingView({super.key});

  @override
  Widget build(BuildContext context) {
    final con = controller;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    splashRadius: 22,
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20, color: Color(0xFF1A1A1A)),
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Marriage',
                          style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                      SizedBox(height: 1),
                      Text('Verified biodata · privacy-first',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: con.openInterests,
                    child: const Icon(Icons.favorite_rounded,
                        color: _maroon, size: 23),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GetBuilder<MatchmakingController>(
                builder: (con) => ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    // Banner
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [_darkMaroon, _maroon],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -4,
                            top: -6,
                            child: Icon(Icons.favorite_rounded,
                                size: 78,
                                color: Colors.white.withValues(alpha: 0.12)),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('সম্মানজনক পরিচয়, পরিবারের সম্মতিতে',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800)),
                              const SizedBox(height: 8),
                              Text(
                                  'NID-verified profiles · guardian-aware · your data stays private',
                                  style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.9),
                                      fontSize: 12.5)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Complete biodata card (dashed)
                    GestureDetector(
                      onTap: con.openBiodata,
                      child: _DashedBox(
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                  color: _pink,
                                  borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.person_outline_rounded,
                                  color: _maroon, size: 22),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Complete your biodata',
                                      style: TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF0F172A))),
                                  SizedBox(height: 2),
                                  Text('70% done · finish to send interests',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF94A3B8))),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded,
                                color: Color(0xFF94A3B8)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Filters
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: con.filters.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final sel = con.filterIndex == i;
                          return GestureDetector(
                            onTap: () => con.setFilter(i),
                            child: Container(
                              alignment: Alignment.center,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: sel ? _maroon : AppColors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: sel
                                        ? _maroon
                                        : const Color(0xFFE2E8F0)),
                              ),
                              child: Text(con.filters[i],
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: sel
                                          ? Colors.white
                                          : const Color(0xFF334155))),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Suggested matches',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A))),
                    const SizedBox(height: 2),
                    const Text('Based on your preferences',
                        style:
                            TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8))),
                    const SizedBox(height: 14),
                    ...con.matches.map((m) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GestureDetector(
                            onTap: () => con.openProfile(m),
                            child: _MatchCard(match: m),
                          ),
                        )),
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

class _DashedBox extends StatelessWidget {
  const _DashedBox({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: _maroon.withValues(alpha: 0.5),
            width: 1.2,
            strokeAlign: BorderSide.strokeAlignInside),
      ),
      child: child,
    );
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({required this.match});
  final MmMatch match;
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
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                    color: _pink, borderRadius: BorderRadius.circular(16)),
                alignment: Alignment.center,
                child: Text(match.letter,
                    style: const TextStyle(
                        color: _maroon,
                        fontSize: 22,
                        fontWeight: FontWeight.w800)),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                      color: _maroon,
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: AppColors.white, width: 2)),
                  child: const Icon(Icons.check_rounded,
                      size: 10, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(match.code,
                        style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFB45309))),
                    const SizedBox(width: 8),
                    if (match.nidVerified)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(6)),
                        child: const Text('NID verified',
                            style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF15803D))),
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Text('${match.age} · ${match.height} · ${match.profession}',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 3),
                Text('${match.education} · ${match.location}',
                    style: const TextStyle(
                        fontSize: 12.5, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
