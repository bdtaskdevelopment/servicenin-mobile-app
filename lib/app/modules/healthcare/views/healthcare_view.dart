import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../../../routes/app_pages.dart';
import '../controllers/booking_controller.dart';
import '../controllers/healthcare_controller.dart';
import '../widgets/hc_doctor_card.dart';

const _green = Color(0xFF16A34A);
const _darkGreen = Color(0xFF0F7A52);
const _tile = Color(0xFFEAF7F0);

class HealthcareView extends GetView<HealthcareController> {
  const HealthcareView({super.key});

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
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20, color: Color(0xFF1A1A1A)),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PRAC Healthcare'.tr,
                          style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                      const SizedBox(height: 1),
                      Text('Verified BMDC doctors · Dhaka'.tr,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Get.toNamed(Routes.HEALTHCARE_APPOINTMENTS),
                    child: const Icon(Icons.calendar_today_outlined,
                        color: Color(0xFF1A1A1A), size: 20),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GetBuilder<HealthcareController>(
                builder: (con) {
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      _Hero(),
                      const SizedBox(height: 14),
                      // In-person / Video consult toggle hidden for now.
                      // _ModeToggle(con: con),
                      // const SizedBox(height: 14),
                      const _QuickGrid(),
                      const SizedBox(height: 14),
                      // Upcoming-appointment card hidden for now.
                      // GestureDetector(
                      //   onTap: () =>
                      //       Get.toNamed(Routes.HEALTHCARE_APPOINTMENTS),
                      //   child: const _UpcomingCard(),
                      // ),
                      // const SizedBox(height: 22),
                      GestureDetector(
                        onTap: () => Get.toNamed(Routes.HC_DOCTORS),
                        child: _SectionHeader(
                            title: 'Departments'.tr, action: 'See all →'.tr),
                      ),
                      const SizedBox(height: 12),
                      if (con.loadingDepartments && con.departments.isEmpty)
                        const SnGridSkeleton(
                          count: 8,
                          crossAxisCount: 4,
                          childAspectRatio: 0.86,
                          padding: EdgeInsets.zero,
                        )
                      else
                        FadeInUp(
                          from: 18,
                          duration: const Duration(milliseconds: 350),
                          child: GridView.count(
                            crossAxisCount: 4,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.86,
                            children: con.departments
                                .map((d) => GestureDetector(
                                      onTap: () => con.openDepartment(d),
                                      child: _DeptTile(dept: d),
                                    ))
                                .toList(),
                          ),
                        ),
                      const SizedBox(height: 22),
                      GestureDetector(
                        onTap: () =>
                            Get.toNamed(Routes.HC_AVAILABLE_TODAY),
                        child: _SectionHeader(
                            title: 'Available today'.tr, action: 'All →'.tr),
                      ),
                      const SizedBox(height: 12),
                      if (con.loadingDoctors && con.doctors.isEmpty)
                        const SnListSkeleton(
                          count: 4,
                          padding: EdgeInsets.zero,
                        )
                      else if (con.doctors.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text('No doctors available today.'.tr,
                              style: const TextStyle(
                                  fontSize: 13, color: Color(0xFF94A3B8))),
                        )
                      else
                        ...con.doctors.take(5).toList().asMap().entries.map(
                              (e) => FadeInUp(
                                from: 18,
                                duration: const Duration(milliseconds: 350),
                                delay: Duration(milliseconds: 70 * e.key),
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: GestureDetector(
                                    onTap: () {
                                      Get.find<BookingController>()
                                          .setDoctor(e.value);
                                      Get.toNamed(Routes.HC_DOCTOR_PROFILE);
                                    },
                                    child: HcDoctorCard(doctor: e.value),
                                  ),
                                ),
                              ),
                            ),
                      // ── All doctors ──────────────────────────────
                      const SizedBox(height: 22),
                      GestureDetector(
                        onTap: () => Get.toNamed(Routes.HC_DOCTORS),
                        child: _SectionHeader(
                            title: 'All doctors'.tr, action: 'See all →'.tr),
                      ),
                      const SizedBox(height: 12),
                      if (con.loadingAllDoctors && con.allDoctors.isEmpty)
                        const SnListSkeleton(
                          count: 4,
                          padding: EdgeInsets.zero,
                        )
                      else if (con.allDoctors.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text('No doctors found.'.tr,
                              style: const TextStyle(
                                  fontSize: 13, color: Color(0xFF94A3B8))),
                        )
                      else
                        ...con.allDoctors.take(5).toList().asMap().entries.map(
                              (e) => FadeInUp(
                                from: 18,
                                duration: const Duration(milliseconds: 350),
                                delay: Duration(milliseconds: 70 * e.key),
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: GestureDetector(
                                    onTap: () {
                                      Get.find<BookingController>()
                                          .setDoctor(e.value);
                                      Get.toNamed(Routes.HC_DOCTOR_PROFILE);
                                    },
                                    child: HcDoctorCard(doctor: e.value),
                                  ),
                                ),
                              ),
                            ),
                    ],
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

// ── Hero ────────────────────────────────────────────────────────────
class _Hero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_darkGreen, Color(0xFF0B5E3F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            top: -8,
            child: Icon(Icons.medical_services_outlined,
                size: 84, color: Colors.white.withValues(alpha: 0.10)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Find a doctor, book a visit'.tr,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text('In-person & video consults · transparent fees · BMDC-verified'.tr,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12.5,
                      height: 1.4)),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Get.toNamed(Routes.HC_DOCTORS),
                child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 10),
                    Text('Search doctor, specialty, symptom…'.tr,
                        style: const TextStyle(
                            color: Color(0xFF94A3B8), fontSize: 13.5)),
                  ],
                ),
              ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Mode toggle (hidden for now) ────────────────────────────────────
// ignore: unused_element
class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.con});
  final HealthcareController con;

  @override
  Widget build(BuildContext context) {
    Widget seg(int i, IconData icon, String label) {
      final sel = con.mode == i;
      return Expanded(
        child: GestureDetector(
          onTap: () => con.setMode(i),
          child: Container(
            height: 50,
            margin: EdgeInsets.only(right: i == 0 ? 6 : 0, left: i == 1 ? 6 : 0),
            decoration: BoxDecoration(
              color: sel ? _green : AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: sel ? _green : const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                    size: 18,
                    color: sel ? Colors.white : const Color(0xFF334155)),
                const SizedBox(width: 8),
                Text(label,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: sel ? Colors.white : const Color(0xFF334155))),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        seg(0, Icons.location_on_outlined, 'In-person'.tr),
        seg(1, Icons.videocam_outlined, 'Video consult'.tr),
      ],
    );
  }
}

// ── Quick grid ──────────────────────────────────────────────────────
class _QuickGrid extends StatelessWidget {
  const _QuickGrid();

  static const _items = [
    (Icons.medical_services_outlined, 'Doctors', false),
    (Icons.calendar_today_outlined, 'Appointment', false),
    (Icons.bookmark_border_rounded, 'Rx', true),
    (Icons.groups_outlined, 'Family', false),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _items.map((it) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: GestureDetector(
              onTap: () => _open(it.$2),
              child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFEDEFF2)),
              ),
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                            color: _tile,
                            borderRadius: BorderRadius.circular(12)),
                        child: Icon(it.$1, color: _green, size: 22),
                      ),
                      if (it.$3)
                        const Positioned(
                          right: -2,
                          top: -2,
                          child: Icon(Icons.circle,
                              size: 9, color: Color(0xFFF15A24)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Auto-fit so long labels (e.g. "Appointment") shrink to fit
                  // on slim devices instead of breaking.
                  SizedBox(
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(it.$2.tr,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF334155))),
                    ),
                  ),
                ],
              ),
            ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _open(String label) {
    switch (label) {
      case 'Doctors':
        Get.toNamed(Routes.HC_DOCTORS);
        break;
      case 'Appointment':
        Get.toNamed(Routes.HEALTHCARE_APPOINTMENTS);
        break;
      case 'Rx':
        Get.toNamed(Routes.HEALTHCARE_PRESCRIPTION);
        break;
      case 'Family':
        Get.toNamed(Routes.HEALTHCARE_FAMILY);
        break;
    }
  }
}

// ── Upcoming card (hidden for now) ──────────────────────────────────
// ignore: unused_element
class _UpcomingCard extends StatelessWidget {
  const _UpcomingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDEFF2)),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
                color: _tile, borderRadius: BorderRadius.circular(12)),
            child: const Column(
              children: [
                Text('TODAY',
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF15803D))),
                SizedBox(height: 2),
                Text('3:40',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF15803D))),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dr. Salma Akter · Cardiology',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A))),
                SizedBox(height: 2),
                Text('Popular Diagnostic, Gulshan-2 · Serial #14',
                    style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(20)),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 7, color: Color(0xFF16A34A)),
                SizedBox(width: 4),
                Text('Upcoming',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF15803D))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section header ──────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.action});
  final String title;
  final String action;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A))),
        Text(action,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.brandOrange)),
      ],
    );
  }
}

// ── Department tile (matches home "All Services" tile) ──────────────
class _DeptTile extends StatelessWidget {
  const _DeptTile({required this.dept});
  final HcDepartment dept;
  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEFF2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(dept.icon, color: dept.color, size: 26),
          const SizedBox(height: 6),
          Flexible(
            child: LayoutBuilder(
              builder: (context, c) => FittedBox(
                fit: BoxFit.scaleDown,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: c.maxWidth),
                  child: Text(
                    dept.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                      height: 1.1,
                    ),
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
