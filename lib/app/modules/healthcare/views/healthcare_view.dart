import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../routes/app_pages.dart';
import '../controllers/booking_controller.dart';
import '../controllers/healthcare_controller.dart';

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
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PRAC Healthcare',
                          style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                      SizedBox(height: 1),
                      Text('Verified BMDC doctors · Dhaka',
                          style: TextStyle(
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
                      _ModeToggle(con: con),
                      const SizedBox(height: 14),
                      const _QuickGrid(),
                      const SizedBox(height: 14),
                      GestureDetector(
                        onTap: () =>
                            Get.toNamed(Routes.HEALTHCARE_APPOINTMENTS),
                        child: const _UpcomingCard(),
                      ),
                      const SizedBox(height: 22),
                      GestureDetector(
                        onTap: () => Get.toNamed(Routes.HC_DOCTORS),
                        child: _SectionHeader(
                            title: 'Departments', action: 'See all →'),
                      ),
                      const SizedBox(height: 12),
                      GridView.count(
                        crossAxisCount: 4,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.86,
                        children: con.departments
                            .map((d) => GestureDetector(
                                  onTap: () => Get.toNamed(Routes.HC_DOCTORS),
                                  child: _DeptTile(dept: d),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 22),
                      _SectionHeader(title: 'Available today', action: 'All →'),
                      const Padding(
                        padding: EdgeInsets.only(top: 2, bottom: 12),
                        child: Text('In-person · near Gulshan',
                            style: TextStyle(
                                fontSize: 12.5, color: Color(0xFF94A3B8))),
                      ),
                      ...con.doctors.map((d) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () {
                                Get.find<BookingController>().setDoctor(d);
                                Get.toNamed(Routes.HC_DOCTOR_PROFILE);
                              },
                              child: _DoctorCard(doctor: d),
                            ),
                          )),
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
              const Text('ডাক্তার খুঁজুন, বুক করুন',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text('In-person & video consults · transparent fees · BMDC-verified',
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
                  children: const [
                    Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
                    SizedBox(width: 10),
                    Text('Search doctor, specialty, symptom…',
                        style: TextStyle(
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

// ── Mode toggle ─────────────────────────────────────────────────────
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
        seg(0, Icons.location_on_outlined, 'In-person'),
        seg(1, Icons.videocam_outlined, 'Video consult'),
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
                  Text(it.$2,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF334155))),
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

// ── Upcoming card ───────────────────────────────────────────────────
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
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEFF2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(dept.icon, color: dept.color, size: 28),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              dept.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
                height: 1.15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Doctor card ─────────────────────────────────────────────────────
class _DoctorCard extends StatelessWidget {
  const _DoctorCard({required this.doctor});
  final HcDoctor doctor;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEFF2)),
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
                    style: TextStyle(
                        color: doctor.color,
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
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
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
                        child: const Text('Video',
                            style: TextStyle(
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
    );
  }
}
