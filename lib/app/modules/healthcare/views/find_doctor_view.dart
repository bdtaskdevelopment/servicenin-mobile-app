import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/values/app_colors.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/doctors_controller.dart';
import '../controllers/healthcare_controller.dart';

const _teal = Color(0xFF0D9383);
const _tealTint = Color(0xFFE6F5F4);
const _green = Color(0xFF12A14F);

class FindDoctorView extends GetView<DoctorsController> {
  const FindDoctorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FA),
      body: SafeArea(
        child: GetBuilder<DoctorsController>(
          builder: (con) {
            return Column(
              children: [
                // Header
                Container(
                  color: AppColors.white,
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
                          Text('Find a doctor'.tr,
                              style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A))),
                          const SizedBox(height: 1),
                          Text(
                              '${'This center has'.tr} ${con.filtered.length} ${'doctors'.tr}',
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
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEDEFF2))),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.search,
                            size: 19, color: Color(0xFF94A3B8)),
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
                            child: const Icon(LucideIcons.x,
                                size: 18, color: Color(0xFF94A3B8)),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Filter chips
                Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: 38,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: con.filters.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 10),
                          itemBuilder: (_, i) {
                            final sel = con.selectedFilter == i;
                            return GestureDetector(
                              onTap: () => con.selectFilter(i),
                              child: Container(
                                alignment: Alignment.center,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: sel ? _teal : AppColors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: sel
                                          ? _teal
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
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16, left: 10),
                      child: Text(
                          '${con.filtered.length} ${'doctors'.tr}',
                          style: const TextStyle(
                              fontSize: 12.5, color: Color(0xFF94A3B8))),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
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
                                            strokeWidth: 2.4, color: _teal),
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

  Widget _initialsBox() => Container(
        color: _tealTint,
        alignment: Alignment.center,
        child: Text(doctor.initials,
            style: const TextStyle(
                color: _teal, fontSize: 16, fontWeight: FontWeight.w800)),
      );
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipOval(
                    child: SizedBox(
                      width: 52,
                      height: 52,
                      child: doctor.photo.isNotEmpty
                          ? Image.network(
                              doctor.photo,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _initialsBox(),
                              loadingBuilder: (_, child, progress) =>
                                  progress == null ? child : _initialsBox(),
                            )
                          : _initialsBox(),
                    ),
                  ),
                  const Positioned(
                    right: -2,
                    bottom: -2,
                    child: CircleAvatar(
                      radius: 9,
                      backgroundColor: Colors.white,
                      child:
                          Icon(LucideIcons.badgeCheck, size: 16, color: _teal),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(doctor.name,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A))),
                        ),
                        Text(doctor.fee,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: _teal)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('${doctor.specialty} · ${doctor.degree}',
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF94A3B8))),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: const Color(0xFFE7F6ED),
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.circle, size: 6, color: _green),
                          const SizedBox(width: 5),
                          Text(doctor.slot,
                              style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: _green)),
                        ],
                      ),
                    ),
                    if (doctor.video) ...[
                      const SizedBox(height: 6),
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
              ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: onTap,
            child: Container(
              height: 40,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _tealTint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.calendarPlus, size: 16, color: _teal),
                  const SizedBox(width: 8),
                  Text('Take an appointment'.tr,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _teal)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
