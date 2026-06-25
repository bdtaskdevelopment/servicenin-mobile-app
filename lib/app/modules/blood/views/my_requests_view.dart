import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/blood_request_response.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/blood_controller.dart';
import '../widgets/blood_widgets.dart';

const _red = Color(0xFFE11D48);

/// My blood requests (`GET /api/v1/blood/requests/my`). Tap one to see the
/// donors who responded.
class MyRequestsView extends GetView<BloodController> {
  const MyRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: GetBuilder<BloodController>(
          builder: (con) {
            return Column(
              children: [
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
                      Text('My requests'.tr,
                          style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                    ],
                  ),
                ),
                Expanded(
                  child: con.loadingMyRequests && con.myRequests.isEmpty
                      ? const SnListSkeleton(
                          padding: EdgeInsets.fromLTRB(16, 12, 16, 24))
                      : RefreshIndicator(
                          onRefresh: con.fetchMyRequests,
                          color: _red,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding:
                                const EdgeInsets.fromLTRB(16, 12, 16, 24),
                            children: [
                              if (con.myRequests.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 80),
                                  child: Center(
                                    child: Text('No requests yet'.tr,
                                        style: const TextStyle(
                                            color: Color(0xFF94A3B8))),
                                  ),
                                )
                              else
                                ...con.myRequests
                                    .asMap()
                                    .entries
                                    .map((e) => FadeInUp(
                                          from: 18,
                                          duration: const Duration(
                                              milliseconds: 350),
                                          delay: Duration(
                                              milliseconds: 70 *
                                                  (e.key < 6 ? e.key : 6)),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 12),
                                            child: _MyRequestCard(
                                              req: e.value,
                                              onTap: () => con
                                                  .openResponders(e.value),
                                            ),
                                          ),
                                        )),
                            ],
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MyRequestCard extends StatelessWidget {
  const _MyRequestCard({required this.req, required this.onTap});
  final BloodRequestEntry req;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hospital = [req.hospitalName, req.hospitalAddress]
        .where((s) => s.isNotEmpty)
        .join(' · ');
    final fulfilled = req.isFulfilled;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEDEFF2)),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BloodGroupBadge(group: req.bloodGroup),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '${req.unitsNeeded} unit${req.unitsNeeded > 1 ? 's' : ''} · ${req.bloodGroup}',
                          style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                      const SizedBox(height: 3),
                      Text(hospital.isNotEmpty ? hospital : 'Hospital not set'.tr,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12.5, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _StatusPill(label: req.statusLabel, fulfilled: fulfilled),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1, color: Color(0xFFF1F5F9)),
            ),
            Row(
              children: [
                const Icon(Icons.volunteer_activism_outlined,
                    size: 16, color: Color(0xFF94A3B8)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                      '${req.responseCount} ${'responders'.tr}',
                      style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B))),
                ),
                Text('View responders →'.tr,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _red)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.fulfilled});
  final String label;
  final bool fulfilled;
  @override
  Widget build(BuildContext context) {
    final bg = fulfilled ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7);
    final fg = fulfilled ? const Color(0xFF15803D) : const Color(0xFFB45309);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label.isEmpty ? 'Open' : label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w800, color: fg)),
    );
  }
}
