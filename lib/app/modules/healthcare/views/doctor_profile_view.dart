import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/booking_controller.dart';

const _green = Color(0xFF0F7A52);
const _tile = Color(0xFFD9F7E6);

class DoctorProfileView extends GetView<BookingController> {
  const DoctorProfileView({super.key});

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
                  const Text('Doctor profile',
                      style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A))),
                  const Spacer(),
                  const Icon(Icons.share_outlined,
                      color: Color(0xFF1A1A1A), size: 22),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                children: [
                  // Doctor head
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                                color: _tile,
                                borderRadius: BorderRadius.circular(16)),
                            alignment: Alignment.center,
                            child: Text(con.doctorInitials,
                                style: const TextStyle(
                                    color: _green,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800)),
                          ),
                          const Positioned(
                            right: -2,
                            bottom: -2,
                            child: CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.check_circle,
                                  size: 18, color: Color(0xFF16A34A)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(con.doctorName,
                                style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A))),
                            const SizedBox(height: 2),
                            Text('${con.doctorSpecialty} · ${con.fullDegree}',
                                style: const TextStyle(
                                    fontSize: 12.5,
                                    color: Color(0xFF94A3B8))),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _pill('● ${con.bmdc}', const Color(0xFFDCFCE7),
                                    const Color(0xFF15803D)),
                                const SizedBox(width: 8),
                                _pill('Video available',
                                    const Color(0xFFEDE9FE),
                                    const Color(0xFF7C3AED)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Stats
                  Row(
                    children: [
                      _stat(con.experience, 'Experience'),
                      _stat('4.9', '${con.reviewsCount} reviews'),
                      _stat(con.doctorFee, 'Consult fee'),
                      _stat(con.avgWait, 'Avg wait'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const _Head('About'),
                  const SizedBox(height: 8),
                  Text(con.about,
                      style: const TextStyle(
                          fontSize: 13.5,
                          color: Color(0xFF334155),
                          height: 1.5)),
                  const SizedBox(height: 8),
                  Text(con.speaks,
                      style: const TextStyle(
                          fontSize: 12.5, color: Color(0xFF94A3B8))),
                  const SizedBox(height: 20),
                  const _Head('Chambers & schedule'),
                  const SizedBox(height: 4),
                  const Text('Doctor rotates venues — pick one when booking',
                      style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                  const SizedBox(height: 12),
                  ...con.venues.map((v) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _VenueCard(name: v.name, schedule: v.schedule),
                      )),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      _Head('Patient reviews'),
                      Text('See all →',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.brandOrange)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...con.docReviews.map((r) => _ReviewCard(review: r)),
                ],
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
                      const Text('CONSULT FEE',
                          style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF94A3B8),
                              letterSpacing: 0.5)),
                      Text(con.doctorFee,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: con.bookAppointment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _green,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Book appointment',
                            style: TextStyle(
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

  Widget _stat(String value, String label) => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEDEFF2))),
          child: Column(
            children: [
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
          border: Border.all(color: const Color(0xFFEDEFF2))),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: _tile, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.location_on_outlined,
                color: _green, size: 20),
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
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});
  final DocReview review;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEDEFF2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                    color: _tile, borderRadius: BorderRadius.circular(10)),
                alignment: Alignment.center,
                child: Text(review.initials,
                    style: const TextStyle(
                        color: _green,
                        fontSize: 12,
                        fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 10),
              Text(review.name,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A))),
              const Spacer(),
              const Icon(Icons.star_rounded, size: 18, color: Color(0xFF0F172A)),
            ],
          ),
          const SizedBox(height: 8),
          Text(review.text,
              style: const TextStyle(
                  fontSize: 12.5, color: Color(0xFF475569), height: 1.4)),
        ],
      ),
    );
  }
}
