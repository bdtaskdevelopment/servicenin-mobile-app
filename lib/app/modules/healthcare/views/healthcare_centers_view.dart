import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../data/models/response/healthcare_response.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../../../routes/app_pages.dart';
import '../controllers/centers_controller.dart';

const _teal = Color(0xFF0D9383);
const _tealTint = Color(0xFFE6F5F4);
const _tealTile = Color(0xFF3FA99D);

class HealthcareCentersView extends GetView<HealthcareCentersController> {
  const HealthcareCentersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FA),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(8, 6, 16, 8),
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
                  return RefreshIndicator(
                    color: _teal,
                    onRefresh: con.fetchCenters,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount:
                          con.centers.isEmpty ? 2 : con.centers.length + 1,
                      itemBuilder: (_, i) {
                        if (i == 0) {
                          return const Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: _TelemedicineCard(),
                          );
                        }
                        if (con.centers.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: Center(
                              child: Text('No centers available.'.tr,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF94A3B8))),
                            ),
                          );
                        }
                        final ci = i - 1;
                        return FadeInUp(
                          from: 18,
                          duration: const Duration(milliseconds: 300),
                          delay: Duration(milliseconds: 60 * ci),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _CenterCard(
                              center: con.centers[ci],
                              onTap: () => con.openCenter(con.centers[ci]),
                            ),
                          ),
                        );
                      },
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

class _TelemedicineCard extends StatelessWidget {
  const _TelemedicineCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.HEALTHCARE_TELEMEDICINE),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _teal,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(14)),
              child: const Icon(LucideIcons.headset, color: _teal, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Telemedicine Call Center'.tr,
                      style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                  const SizedBox(height: 3),
                  Text('Call or WhatsApp a support desk directly'.tr,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.9))),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(LucideIcons.chevronRight, color: Colors.white, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterCard extends StatelessWidget {
  const _CenterCard({required this.center, required this.onTap});
  final HealthcareCenter center;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: _tealTint, borderRadius: BorderRadius.circular(14)),
              child: const Icon(LucideIcons.building2, color: _tealTile, size: 24),
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
                    Row(
                      children: [
                        const Icon(LucideIcons.mapPin,
                            size: 12, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(center.address,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 12.5, color: Color(0xFF94A3B8))),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: _tealTint,
                        borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.stethoscope,
                            size: 11, color: _teal),
                        const SizedBox(width: 4),
                        Text('${center.doctorCount} ${'doctors'.tr}',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _teal)),
                      ],
                    ),
                  ),
                ],
              ),
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
