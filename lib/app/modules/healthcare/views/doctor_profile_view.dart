import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/values/app_colors.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/booking_controller.dart';

const _teal = Color(0xFF0D9383);
const _tealTint = Color(0xFFE6F5F4);
const _green = Color(0xFF12A14F);
const _orange = Color(0xFFF16621);

/// Initials avatar shown while the photo loads, on error, or when none is set.
Widget _profileInitials(String initials) => Container(
      color: _tealTint,
      alignment: Alignment.center,
      child: Text(initials,
          style: const TextStyle(
              color: _teal, fontSize: 24, fontWeight: FontWeight.w800)),
    );

class DoctorProfileView extends GetView<BookingController> {
  const DoctorProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final con = controller;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FA),
      body: SafeArea(
        child: Column(
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
                  Text('Doctor profile'.tr,
                      style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A))),
                ],
              ),
            ),
            Expanded(
              child: GetBuilder<BookingController>(
                builder: (_) => con.loadingProfile && con.profile == null
                    ? const _ProfileSkeleton()
                    : FadeInUp(
                        from: 18,
                        duration: const Duration(milliseconds: 350),
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          children: [
                            // Doctor head card
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black
                                          .withValues(alpha: 0.03),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2)),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      ClipOval(
                                        child: SizedBox(
                                          width: 72,
                                          height: 72,
                                          child: con.doctorPhoto.isNotEmpty
                                              ? Image.network(
                                                  con.doctorPhoto,
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (_, __, ___) =>
                                                          _profileInitials(
                                                              con.doctorInitials),
                                                  loadingBuilder: (_, child,
                                                          progress) =>
                                                      progress == null
                                                          ? child
                                                          : _profileInitials(
                                                              con.doctorInitials),
                                                )
                                              : _profileInitials(
                                                  con.doctorInitials),
                                        ),
                                      ),
                                      Positioned(
                                        right: -2,
                                        bottom: -2,
                                        child: Container(
                                          width: 22,
                                          height: 22,
                                          alignment: Alignment.center,
                                          decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle),
                                          child: const Icon(
                                              LucideIcons.badgeCheck,
                                              size: 20,
                                              color: _teal),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(con.doctorName,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF0F172A))),
                                  const SizedBox(height: 3),
                                  Text(
                                      '${con.doctorSpecialty} · ${con.fullDegree}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 12.5,
                                          color: Color(0xFF94A3B8))),
                                  const SizedBox(height: 8),
                                  _pill('● ${con.bmdc}', const Color(0xFFE7F6ED),
                                      _green),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      _stat(LucideIcons.briefcase,
                                          con.experience, 'Experience'.tr),
                                      const SizedBox(width: 8),
                                      _stat(LucideIcons.badgeDollarSign,
                                          con.doctorFee, 'Consult fee'.tr),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                            _Head('About'.tr),
                            const SizedBox(height: 8),
                            _Card(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(con.about,
                                      style: const TextStyle(
                                          fontSize: 13.5,
                                          color: Color(0xFF334155),
                                          height: 1.5)),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Icon(LucideIcons.languages,
                                          size: 14, color: Color(0xFF94A3B8)),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(con.speaks,
                                            style: const TextStyle(
                                                fontSize: 12.5,
                                                color: Color(0xFF94A3B8))),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                            _Head('Chambers & schedule'.tr),
                            const SizedBox(height: 4),
                            Text('Doctor rotates venues — pick one when booking'.tr,
                                style: const TextStyle(
                                    fontSize: 12, color: Color(0xFF94A3B8))),
                            const SizedBox(height: 12),
                            ...con.venues.map((v) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _VenueCard(
                                      name: v.venueName,
                                      schedule: v.scheduleLabel),
                                )),
                          ],
                        ),
                      ),
              ),
            ),
            // Bottom CTA
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('CONSULT FEE'.tr,
                          style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF94A3B8),
                              letterSpacing: 0.5)),
                      Text(con.doctorFee,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: _teal)),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: con.bookAppointment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _orange,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text('Take an appointment'.tr,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String t, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Text(t,
            style: TextStyle(
                fontSize: 10.5, fontWeight: FontWeight.w700, color: fg)),
      );

  Widget _stat(IconData icon, String value, String label) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
              color: const Color(0xFFF4F5FA),
              borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              Icon(icon, size: 16, color: _teal),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A))),
              const SizedBox(height: 2),
              Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 10.5, color: Color(0xFF94A3B8))),
            ],
          ),
        ),
      );
}

class _Head extends StatelessWidget {
  const _Head(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: Color(0xFF0F172A)));
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }
}

class _VenueCard extends StatelessWidget {
  const _VenueCard({required this.name, required this.schedule});
  final String name;
  final String schedule;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
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
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: _tealTint, borderRadius: BorderRadius.circular(10)),
            child: const Icon(LucideIcons.mapPin, color: _teal, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text(schedule,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          const Icon(LucideIcons.chevronRight,
              size: 18, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }
}

// ── Loading skeleton for the doctor profile ─────────────────────────
class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();
  @override
  Widget build(BuildContext context) {
    return SnShimmer(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(18)),
            child: Column(
              children: const [
                SnBone(width: 72, height: 72, radius: 36),
                SizedBox(height: 10),
                SnBone(width: 180, height: 18),
                SizedBox(height: 8),
                SnBone(width: 140, height: 12),
                SizedBox(height: 12),
                SnBone(width: 160, height: 22, radius: 20),
                SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: SnBone(height: 70, radius: 12)),
                    SizedBox(width: 8),
                    Expanded(child: SnBone(height: 70, radius: 12)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const SnBone(width: 90, height: 16),
          const SizedBox(height: 12),
          const SnBone(height: 70, radius: 16),
          const SizedBox(height: 18),
          const SnBone(width: 160, height: 16),
          const SizedBox(height: 12),
          ...List.generate(
            2,
            (_) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: SnBone(height: 64, radius: 14),
            ),
          ),
        ],
      ),
    );
  }
}
