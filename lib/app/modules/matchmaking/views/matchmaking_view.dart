import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/matchmaking_response.dart';
import '../../../global_widget/sn_shimmer.dart';
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
                builder: (con) => RefreshIndicator(
                  color: _maroon,
                  onRefresh: () async {
                    await con.fetchSuggestions();
                    await con.fetchMyProfile();
                  },
                  child: ListView(
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
                                    'Verified profiles · guardian-aware · your data stays private',
                                    style: TextStyle(
                                        color: Colors.white
                                            .withValues(alpha: 0.9),
                                        fontSize: 12.5)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Biodata card
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
                                child: const Icon(
                                    Icons.person_outline_rounded,
                                    color: _maroon,
                                    size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        con.hasProfile
                                            ? 'My biodata'
                                            : 'Complete your biodata',
                                        style: const TextStyle(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF0F172A))),
                                    const SizedBox(height: 2),
                                    Text(
                                        con.hasProfile
                                            ? '${con.completion}% complete · tap to edit'
                                            : 'Create one to send interests',
                                        style: const TextStyle(
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
                      const SizedBox(height: 20),
                      const Text('Suggested matches',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                      const SizedBox(height: 2),
                      const Text('Based on your preferences',
                          style: TextStyle(
                              fontSize: 12.5, color: Color(0xFF94A3B8))),
                      const SizedBox(height: 14),
                      if (con.loadingSuggestions && con.suggestions.isEmpty)
                        const SnListSkeleton(
                            count: 3, padding: EdgeInsets.zero)
                      else if (con.suggestions.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text('No suggestions yet.',
                              style: TextStyle(
                                  fontSize: 13, color: Color(0xFF94A3B8))),
                        )
                      else
                        ...con.suggestions.map((s) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GestureDetector(
                                onTap: () => con.openProfile(s.profile),
                                child: _MatchCard(suggestion: s),
                              ),
                            )),
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
  const _MatchCard({required this.suggestion});
  final MmSuggestion suggestion;
  @override
  Widget build(BuildContext context) {
    final p = suggestion.profile;
    final showPhoto = p.photoVisible && p.photoUrl.isNotEmpty;
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
          Container(
            width: 56,
            height: 56,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
                color: _pink, borderRadius: BorderRadius.circular(16)),
            alignment: Alignment.center,
            child: showPhoto
                ? CachedNetworkImage(
                    imageUrl: p.photoUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _letter(p.letter),
                  )
                : _letter(p.letter),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(p.code,
                        style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFB45309))),
                    const SizedBox(width: 8),
                    if (suggestion.score > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(6)),
                        child: Text('Match ${suggestion.score}',
                            style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF15803D))),
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(p.summary,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 3),
                Text(p.eduLocation,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12.5, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _letter(String letter) => Text(letter,
      style: const TextStyle(
          color: _maroon, fontSize: 22, fontWeight: FontWeight.w800));
}
