import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/response/healthcare_response.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/centers_controller.dart';

/// One accent per card — (card background, icon-tile/badge background, icon
/// & badge text color). Four medical-themed tints, cycled by index so
/// consecutive centers in the list are visually distinct.
const _cardAccents = [
  (Color(0xFFEAF2FF), Color(0xFFD6E7FF), Color(0xFF1D4ED8)), // clinical blue
  (Color(0xFFE8F8F2), Color(0xFFCFF1E4), Color(0xFF0F766E)), // wellness mint
  (Color(0xFFF1EEFB), Color(0xFFE3DBF7), Color(0xFF6D28D9)), // pharmacy lavender
  (Color(0xFFFDECEC), Color(0xFFFBD9D9), Color(0xFFDC2626)), // cardio coral
];

class HealthcareCentersView extends GetView<HealthcareCentersController> {
  const HealthcareCentersView({super.key});

  @override
  Widget build(BuildContext context) {
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Healthcare'.tr,
                          style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                      const SizedBox(height: 1),
                      Text('Choose a center to continue'.tr,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: GetBuilder<HealthcareCentersController>(
                builder: (con) {
                  if (con.loading && con.centers.isEmpty) {
                    return const SnListSkeleton(count: 5);
                  }
                  if (con.centers.isEmpty) {
                    return Center(
                      child: Text('No centers available.'.tr,
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xFF94A3B8))),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: con.fetchCenters,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: con.centers.length,
                      itemBuilder: (_, i) => FadeInUp(
                        from: 18,
                        duration: const Duration(milliseconds: 300),
                        delay: Duration(milliseconds: 60 * i),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _CenterCard(
                            center: con.centers[i],
                            accent: _cardAccents[i % _cardAccents.length],
                            onTap: () => con.openCenter(con.centers[i]),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterCard extends StatelessWidget {
  const _CenterCard(
      {required this.center, required this.accent, required this.onTap});
  final HealthcareCenter center;
  final (Color, Color, Color) accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (cardColor, tileColor, accentColor) = accent;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentColor.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                  color: tileColor, borderRadius: BorderRadius.circular(14)),
              child: Icon(Icons.local_hospital_rounded,
                  color: accentColor, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(center.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A))),
                  if (center.address.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(center.address,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12.5, color: Color(0xFF94A3B8))),
                  ],
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: tileColor,
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(
                        '${center.doctorCount} ${'doctors'.tr}',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: accentColor)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}
