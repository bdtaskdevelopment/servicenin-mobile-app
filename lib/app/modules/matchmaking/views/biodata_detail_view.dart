import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/matchmaking_response.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/matchmaking_controller.dart';

const _maroon = Color(0xFFB11D5C);
const _pink = Color(0xFFFBD9E8);

class BiodataDetailView extends GetView<MatchmakingController> {
  const BiodataDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: GetBuilder<MatchmakingController>(
          builder: (con) {
            final p = con.selected;
            if (p == null) return const SizedBox.shrink();
            final showPhoto = p.photoVisible && p.photoUrl.isNotEmpty;
            final rows = _rowsFor(p);
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 16, 4),
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
                          Text('Biodata'.tr,
                              style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A))),
                          Text(p.code,
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF94A3B8))),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: con.loadingSelected
                      ? const _BiodataDetailSkeleton()
                      : FadeInUp(
                    from: 18,
                    duration: const Duration(milliseconds: 350),
                    child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 84,
                              height: 84,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                  color: _pink,
                                  borderRadius: BorderRadius.circular(22)),
                              alignment: Alignment.center,
                              child: showPhoto
                                  ? CachedNetworkImage(
                                      imageUrl: p.photoUrl,
                                      width: 84,
                                      height: 84,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) =>
                                          _letter(p.letter),
                                    )
                                  : _letter(p.letter),
                            ),
                            const SizedBox(height: 12),
                            Text(p.code,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A))),
                            if (!p.photoVisible) ...[
                              const SizedBox(height: 3),
                              Text(
                                  'Photos shared after mutual interest'.tr,
                                  style: const TextStyle(
                                      fontSize: 12.5,
                                      color: Color(0xFF94A3B8))),
                            ],
                          ],
                        ),
                      ),
                      if (p.bio.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                              color: const Color(0xFFFCEAF2),
                              borderRadius: BorderRadius.circular(14)),
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                  fontSize: 13.5, color: _maroon),
                              children: [
                                TextSpan(
                                    text: '${'About'.tr}: ',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800)),
                                TextSpan(text: p.bio),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: const Color(0xFFEDEFF2))),
                        child: Column(
                          children: [
                            for (int i = 0; i < rows.length; i++) ...[
                              _row(rows[i].$1, rows[i].$2),
                              if (i != rows.length - 1) const _DashedDivider(),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 54,
                        height: 54,
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppColors.white,
                            padding: EdgeInsets.zero,
                            side:
                                const BorderSide(color: Color(0xFFE2E8F0)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Icon(Icons.close_rounded,
                              color: Color(0xFF334155)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            onPressed: con.sendingInterest
                                ? null
                                : con.expressInterest,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _maroon,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            child: con.sendingInterest
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                        color: Colors.white),
                                  )
                                : Text('Express interest'.tr,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<(String, String)> _rowsFor(MmProfile p) {
    final out = <(String, String)>[];
    void add(String label, String value) {
      if (value.isNotEmpty && value != '0') out.add((label, value));
    }

    add('Age'.tr, p.age > 0 ? '${p.age} ${'years'.tr}' : '');
    add('Height'.tr, p.heightCm > 0 ? '${p.heightCm} cm' : '');
    add('Gender'.tr, mmHumanize(p.gender));
    add('Marital status'.tr, mmHumanize(p.maritalStatus));
    add('Religion'.tr, p.religion);
    add('Profession'.tr, p.profession);
    add('Education'.tr, p.education);
    add('Income'.tr, mmHumanize(p.incomeRange));
    add('Location'.tr, p.location);
    add('Birth place'.tr, p.birthPlace);
    add('Date of birth'.tr, p.dateOfBirth);
    add('Family type'.tr, mmHumanize(p.familyType));
    add('Language'.tr, p.language);
    add('Lifestyle'.tr, p.lifestyle);
    add('Nationality'.tr, p.nationality);
    return out;
  }

  Widget _letter(String letter) => Text(letter,
      style: const TextStyle(
          color: _maroon, fontSize: 34, fontWeight: FontWeight.w800));

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style:
                    const TextStyle(fontSize: 13.5, color: Color(0xFF64748B))),
            const SizedBox(width: 12),
            Expanded(
              child: Text(value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A))),
            ),
          ],
        ),
      );
}

class _BiodataDetailSkeleton extends StatelessWidget {
  const _BiodataDetailSkeleton();
  @override
  Widget build(BuildContext context) {
    return SnShimmer(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          const Center(
            child: Column(
              children: [
                SnBone(width: 84, height: 84, radius: 22),
                SizedBox(height: 12),
                SnBone(width: 120, height: 14),
                SizedBox(height: 8),
                SnBone(width: 180, height: 11),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const SnBone(width: double.infinity, height: 72, radius: 14),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEDEFF2))),
            child: Column(
              children: List.generate(
                7,
                (_) => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SnBone(width: 90, height: 12),
                      SnBone(width: 110, height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        const dash = 5.0;
        const gap = 4.0;
        final count = (c.maxWidth / (dash + gap)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            count,
            (_) => Container(
                width: dash, height: 1, color: const Color(0xFFEDEFF2)),
          ),
        );
      },
    );
  }
}
