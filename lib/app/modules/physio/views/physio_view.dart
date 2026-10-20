import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../core/values/app_url.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../../support/views/support_view.dart';
import '../controllers/physio_controller.dart';
import '../physio_palette.dart';

const _brown = Color(0xFF8A3E12);

class PhysioView extends GetView<PhysioController> {
  const PhysioView({super.key});

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
                  const Spacer(),
                  GestureDetector(
                    onTap: con.openSessions,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_brown, Color(0xFFC2571E)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: _brown.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3)),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text('My Booking'.tr,
                              style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Support center — admin-configured numbers for this module.
                  SupportIconButton(
                    title: 'Physiotherapy Support'.tr,
                    endpoint: ApiURL.physioHotlines,
                  ),
                ],
              ),
            ),
            Expanded(
              child: GetBuilder<PhysioController>(
                builder: (_) => RefreshIndicator(
                  color: _brown,
                  onRefresh: con.fetchCenters,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      if (con.loadingCenters && con.centers.isEmpty)
                        const SnListSkeleton(count: 3, padding: EdgeInsets.zero)
                      else if (con.centers.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text('No centers found.'.tr,
                              style: const TextStyle(
                                  fontSize: 13, color: Color(0xFF94A3B8))),
                        )
                      else
                        ...con.centers
                            .toList()
                            .asMap()
                            .entries
                            .map((e) => FadeInUp(
                                  from: 18,
                                  duration: const Duration(milliseconds: 350),
                                  delay: Duration(milliseconds: 70 * e.key),
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: GestureDetector(
                                      onTap: () => con.openCenter(e.value),
                                      child: _CenterCard(center: e.value),
                                    ),
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

class _CenterCard extends StatelessWidget {
  const _CenterCard({required this.center});
  final PhysioCenter center;
  @override
  Widget build(BuildContext context) {
    final style = physioStyleFor(center.id);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: style.accent.withValues(alpha: 0.16)),
        boxShadow: [
          BoxShadow(
              color: style.accent.withValues(alpha: 0.10),
              blurRadius: 14,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [style.accent, style.accent.withValues(alpha: 0.75)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(13),
              boxShadow: [
                BoxShadow(
                    color: style.accent.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: Icon(style.icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(center.name,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 14, color: style.accent.withValues(alpha: 0.8)),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(center.area,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12.5, color: Color(0xFF94A3B8))),
                    ),
                  ],
                ),
                if (center.wardNo.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: style.tile,
                        borderRadius: BorderRadius.circular(8)),
                    child: Text('Ward ${center.wardNo}',
                        style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: style.accent)),
                  ),
                ],
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: style.accent.withValues(alpha: 0.6)),
        ],
      ),
    );
  }
}
