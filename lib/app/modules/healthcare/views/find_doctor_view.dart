import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/doctors_controller.dart';
import '../controllers/healthcare_controller.dart';

const _green = Color(0xFF0F7A52);
const _tile = Color(0xFFD9F7E6);

class FindDoctorView extends GetView<DoctorsController> {
  const FindDoctorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: GetBuilder<DoctorsController>(
          builder: (con) {
            return Column(
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Find a doctor'.tr,
                              style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A))),
                          const SizedBox(height: 1),
                          Text('4 available near you'.tr,
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF94A3B8))),
                        ],
                      ),
                    ],
                  ),
                ),
                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                        color: const Color(0xFFEFF1F4),
                        borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded,
                            color: Color(0xFF94A3B8)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: con.searchCtrl,
                            onChanged: con.onSearchChanged,
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              isCollapsed: true,
                              border: InputBorder.none,
                              hintText: 'Doctor, specialty or symptom'.tr,
                              hintStyle: const TextStyle(
                                  color: Color(0xFF94A3B8), fontSize: 13.5),
                            ),
                            style: const TextStyle(
                                fontSize: 14, color: Color(0xFF0F172A)),
                          ),
                        ),
                        if (con.query.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              con.searchCtrl.clear();
                              con.onSearchChanged('');
                            },
                            child: const Icon(Icons.close_rounded,
                                size: 18, color: Color(0xFF94A3B8)),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Filter chips
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: con.filters.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (_, i) {
                      final sel = con.selectedFilter == i;
                      return GestureDetector(
                        onTap: () => con.selectFilter(i),
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: sel ? _green : AppColors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: sel
                                    ? _green
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
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('${con.filtered.length} doctors',
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF94A3B8))),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: con.loading && con.filtered.isEmpty
                      ? const SnListSkeleton(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 20))
                      : con.filtered.isEmpty
                          ? ListView(
                              children: [
                                const SizedBox(height: 120),
                                Center(
                                  child: Text('No doctors found'.tr,
                                      style: const TextStyle(
                                          color: Color(0xFF94A3B8))),
                                ),
                              ],
                            )
                          : ListView(
                              controller: con.scrollCtrl,
                              padding:
                                  const EdgeInsets.fromLTRB(16, 0, 16, 20),
                              children: [
                                ...con.filtered
                                    .toList()
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
                                            child: _DoctorCard(
                                                doctor: e.value,
                                                onTap: () =>
                                                    con.openDoctor(e.value)),
                                          ),
                                        )),
                                if (con.loadingMore)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Center(
                                      child: SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2.4, color: _green),
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
}

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({required this.doctor, required this.onTap});
  final HcDoctor doctor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
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
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                      color: _tile, borderRadius: BorderRadius.circular(14)),
                  alignment: Alignment.center,
                  child: Text(doctor.initials,
                      style: const TextStyle(
                          color: _green,
                          fontSize: 16,
                          fontWeight: FontWeight.w800)),
                ),
                const Positioned(
                  right: -2,
                  bottom: -2,
                  child: CircleAvatar(
                    radius: 9,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.check_circle,
                        size: 16, color: Color(0xFF16A34A)),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(doctor.name,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A))),
                  const SizedBox(height: 2),
                  Text('${doctor.specialty} · ${doctor.degree}',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF94A3B8))),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 15, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 2),
                      Text(doctor.rating,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF334155))),
                      Text(' (${doctor.reviews})',
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF94A3B8))),
                      if (doctor.video) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                              color: const Color(0xFFEDE9FE),
                              borderRadius: BorderRadius.circular(6)),
                          child: Text('Video'.tr,
                              style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF7C3AED))),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(doctor.fee,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF15803D))),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(doctor.slot,
                      style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF15803D))),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
