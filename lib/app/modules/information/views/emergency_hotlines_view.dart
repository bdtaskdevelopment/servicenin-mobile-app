import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/info_response.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/information_controller.dart';

class EmergencyHotlinesView extends GetView<InformationController> {
  const EmergencyHotlinesView({super.key});

  @override
  Widget build(BuildContext context) {
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
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Emergency hotlines'.tr,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Tap to call'.tr,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: GetBuilder<InformationController>(
                builder: (con) {
                  final hero = con.nationalEmergency;
                  final rows = con.emergencyCards;
                  if (con.loadingEmergency && rows.isEmpty && hero == null) {
                    return const SnListSkeleton();
                  }
                  return RefreshIndicator(
                    color: const Color(0xFFE8333A),
                    onRefresh: con.fetchEmergency,
                    child: FadeInUp(
                      from: 18,
                      duration: const Duration(milliseconds: 350),
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        children: [
                          // National emergency hero
                          GestureDetector(
                            onTap: () => con.callHotline(
                              hero?.hotline.isNotEmpty == true
                                  ? hero!.hotline
                                  : '999',
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFE8333A),
                                    Color(0xFFC2182B),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.call_rounded,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          hero?.hotline.isNotEmpty == true
                                              ? hero!.hotline
                                              : '999',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.w800,
                                            height: 1.1,
                                          ),
                                        ),
                                        Text(
                                          hero?.title.isNotEmpty == true
                                              ? hero!.title
                                              : 'National Emergency · Police · Fire · Ambulance'
                                                    .tr,
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.9,
                                            ),
                                            fontSize: 11.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          if (rows.isEmpty && !con.loadingEmergency)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 30),
                              child: Center(
                                child: Text(
                                  'No hotlines available.'.tr,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ),
                            )
                          else
                            ...rows.map(
                              (e) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _HotlineRow(entry: e, con: con),
                              ),
                            ),
                        ],
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

class _HotlineRow extends StatelessWidget {
  const _HotlineRow({required this.entry, required this.con});
  final InfoEntry entry;
  final InformationController con;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => con.callHotline(entry.callNumber),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEDEFF2)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFFDECEC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.emergency_share_rounded,
                color: Color(0xFFE8333A),
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  if (entry.titleBn.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      entry.titleBn,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                  if (entry.callNumber.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      entry.callNumber,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFE07A1F),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFD9F7E6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.call_rounded,
                color: Color(0xFF16A34A),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
