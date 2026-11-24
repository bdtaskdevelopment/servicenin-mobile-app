import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/values/app_colors.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/blood_controller.dart';
import '../widgets/blood_widgets.dart';

const _red = Color(0xFFE5383B);

class BloodRequestsView extends GetView<BloodController> {
  const BloodRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FA),
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
                        icon: const Icon(LucideIcons.chevronLeft,
                            size: 22, color: Color(0xFF0F172A)),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Blood requests near you'.tr,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A))),
                            const SizedBox(height: 1),
                            Text('${'Your group'.tr} ${con.donorGroup} · ${con.area}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 12, color: Color(0xFF94A3B8))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: AppColors.white,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Row(
                    children: [
                      _FilterChip(
                          label: 'All'.tr,
                          selected: con.requestFilter == 'all',
                          dot: null,
                          onTap: () => con.setRequestFilter('all')),
                      const SizedBox(width: 8),
                      _FilterChip(
                          label: 'Active'.tr,
                          selected: con.requestFilter == 'active',
                          dot: const Color(0xFF16A34A),
                          onTap: () => con.setRequestFilter('active')),
                      const SizedBox(width: 8),
                      _FilterChip(
                          label: 'Donation'.tr,
                          selected: con.requestFilter == 'donation',
                          dot: const Color(0xFF2563EB),
                          onTap: () => con.setRequestFilter('donation')),
                      const SizedBox(width: 8),
                      _FilterChip(
                          label: 'Reject'.tr,
                          selected: con.requestFilter == 'reject',
                          dot: const Color(0xFF94A3B8),
                          onTap: () => con.setRequestFilter('reject')),
                    ],
                  ),
                ),
                Expanded(child: _RequestsList(con: con)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip(
      {required this.label, required this.selected, required this.dot, required this.onTap});
  final String label;
  final bool selected;
  final Color? dot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0F172A) : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dot != null) ...[
              Container(
                  width: 6, height: 6, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
              const SizedBox(width: 6),
            ],
            Text(label,
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : const Color(0xFF334155))),
          ],
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

    final items = con.filteredRequestEntries;
    return RefreshIndicator(
      onRefresh: con.fetchRequests,
      color: _red,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          ...items.toList().asMap().entries.map((e) => FadeInUp(
                from: 18,
                duration: const Duration(milliseconds: 350),
                delay: Duration(milliseconds: 70 * (e.key < 6 ? e.key : 6)),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: BloodRequestApiCard(
                    req: e.value,
                    onView: () => con.viewRequest(e.value),
                  ),
                ),
              )),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Center(
                child: Text('No requests nearby'.tr,
                    style: const TextStyle(color: Color(0xFF94A3B8))),
              ),
            ),
        ],
      ),
    );
  }
}
