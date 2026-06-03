import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/booking_controller.dart';

const _green = Color(0xFF0F7A52);

class AppointmentDetailView extends GetView<BookingController> {
  const AppointmentDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final con = controller;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.zero,
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
                      const Text('Appointment',
                          style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                      Text(con.apptId,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.chat_bubble_outline_rounded,
                      color: Color(0xFF1A1A1A), size: 22),
                ],
              ),
            ),
            // Green hero
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [_green, Color(0xFF0B5E3F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20)),
                        child: const Text('Confirmed · Today',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('YOUR SERIAL',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700)),
                          Text(con.token,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12)),
                        alignment: Alignment.center,
                        child: Text(con.doctorInitials,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(con.doctorName,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800)),
                            Text('${con.doctorSpecialty} · MBBS',
                                style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _heroStat('Date', 'Today · ${con.selectedTime} PM'),
                      const SizedBox(width: 20),
                      _heroStat('Now serving', con.nowServing),
                    ],
                  ),
                ],
              ),
            ),
            // Queue progress
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFEDEFF2))),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text('Queue progress',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A))),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(20)),
                        child: const Text('● v2',
                            style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFB45309))),
                      ),
                      const Spacer(),
                      Text('${con.aheadOfYou} ahead of you',
                          style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: _green)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: const LinearProgressIndicator(
                      value: 0.62,
                      minHeight: 7,
                      backgroundColor: Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation(_green),
                    ),
                  ),
                ],
              ),
            ),
            // Venue
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Venue',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A))),
                  const SizedBox(height: 2),
                  Text(con.venueName,
                      style: const TextStyle(
                          fontSize: 12.5, color: Color(0xFF2563EB))),
                ],
              ),
            ),
            // Map + address
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEDEFF2))),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: SizedBox(
                      height: 120,
                      child: CustomPaint(painter: _MiniMapPainter()),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${con.venueName}-2',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A))),
                              const SizedBox(height: 2),
                              Text(con.venueAddress,
                                  style: const TextStyle(
                                      fontSize: 12, color: Color(0xFF94A3B8))),
                            ],
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                              color: const Color(0xFFD9F7E6),
                              borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.location_on_outlined,
                              color: _green, size: 20),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _ActionRow(
                icon: Icons.call_outlined,
                title: 'Call chamber',
                sub: 'Reschedule, queries'),
            _ActionRow(
                icon: Icons.calendar_month_outlined,
                title: 'Reschedule',
                sub: 'Move to another slot · free'),
            _ActionRow(
                icon: Icons.bookmark_border_rounded,
                title: 'Past prescriptions',
                sub: '2 records for this patient'),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel appointment',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFDC2626))),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _heroStat(String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8), fontSize: 11)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800)),
        ],
      );
}

class _ActionRow extends StatelessWidget {
  const _ActionRow(
      {required this.icon, required this.title, required this.sub});
  final IconData icon;
  final String title;
  final String sub;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEDEFF2))),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF334155), size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text(sub,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }
}

class _MiniMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xFFE3EAF1));
    final block = Paint()..color = const Color(0xFFD7E0E9);
    void b(double x, double y, double w, double h) => canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, w, h), const Radius.circular(5)),
        block);
    b(size.width * 0.62, size.height * 0.18, 50, 26);
    b(size.width * 0.78, size.height * 0.20, 40, 26);
    b(size.width * 0.10, size.height * 0.55, 44, 24);
    b(size.width * 0.30, size.height * 0.58, 44, 24);
    // dotted road
    final dot = Paint()..color = const Color(0xFFF59E0B);
    for (double x = 6; x < size.width; x += 16) {
      canvas.drawCircle(Offset(x, size.height * 0.46), 2, dot);
    }
    // marker
    canvas.drawCircle(Offset(size.width * 0.52, size.height * 0.36), 14,
        Paint()..color = const Color(0x33167A52));
    canvas.drawCircle(Offset(size.width * 0.52, size.height * 0.36), 8,
        Paint()..color = const Color(0xFF0F7A52));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
