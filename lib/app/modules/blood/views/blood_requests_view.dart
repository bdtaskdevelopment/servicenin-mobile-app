import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/blood_controller.dart';
import '../widgets/blood_widgets.dart';

class BloodRequestsView extends GetView<BloodController> {
  const BloodRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: GetBuilder<BloodController>(
          builder: (con) {
            return Column(
              children: [
                // ── Header ──────────────────────────────────────
                Container(
                  color: AppColors.white,
                  padding: const EdgeInsets.fromLTRB(8, 6, 16, 10),
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
                          const Text('Requests near you',
                              style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A))),
                          const SizedBox(height: 1),
                          Text('Your group ${con.donorGroup} · ${con.area}',
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF94A3B8))),
                        ],
                      ),
                      const Spacer(),
                      // Filter icon hidden for now.
                      // const Icon(Icons.filter_alt_outlined,
                      //     color: Color(0xFF1A1A1A), size: 22),
                    ],
                  ),
                ),
                // ── Compatible-only toggle (hidden for now) ─────
                // Container(
                //   color: AppColors.white,
                //   padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                //   child: Row(
                //     children: [
                //       Switch.adaptive(
                //         value: con.compatibleOnly,
                //         onChanged: con.toggleCompatible,
                //         activeTrackColor: AppColors.brandOrange,
                //         activeThumbColor: AppColors.white,
                //       ),
                //       const SizedBox(width: 6),
                //       const Text('Show compatible groups only',
                //           style: TextStyle(
                //               fontSize: 14,
                //               fontWeight: FontWeight.w700,
                //               color: Color(0xFF0F172A))),
                //     ],
                //   ),
                // ),
                const SizedBox(height: 4),
                // ── List ────────────────────────────────────────
                Expanded(
                  child: _RequestsList(con: con),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RequestsList extends StatelessWidget {
  const _RequestsList({required this.con});
  final BloodController con;

  @override
  Widget build(BuildContext context) {
    if (con.loadingRequests && con.requestList.isEmpty) {
      return const SnListSkeleton(padding: EdgeInsets.fromLTRB(16, 8, 16, 24));
    }

    final items = con.visibleRequestEntries;
    return RefreshIndicator(
      onRefresh: con.fetchRequests,
      color: const Color(0xFFE11D48),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          ...items.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: BloodRequestApiCard(
                  req: r,
                  onView: () => con.viewRequest(r),
                ),
              )),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 60),
              child: Center(
                child: Text('কাছাকাছি কোন অনুরোধ নেই',
                    style: TextStyle(color: Color(0xFF94A3B8))),
              ),
            ),
        ],
      ),
    );
  }
}
