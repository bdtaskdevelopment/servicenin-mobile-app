import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/home_service_controller.dart';

const _teal = Color(0xFF0E9F8E);
const _darkTeal = Color(0xFF0E7C6B);
const _tile = Color(0xFFCDEDE6);

class HsTrackingView extends GetView<HomeServiceController> {
  const HsTrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    final con = controller;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          const Positioned.fill(child: CustomPaint(painter: _MapPainter())),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  _round(Icons.arrow_back_ios_new_rounded, () => Get.back()),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8)
                        ]),
                    child: const Text('Your home · Gulshan-2',
                        style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A))),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              constraints: BoxConstraints(maxHeight: Get.height * 0.6),
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)],
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                            width: 42,
                            height: 4,
                            decoration: BoxDecoration(
                                color: const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(4))),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                  color: Color(0xFF22C55E),
                                  shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          const Text('Technician on the way',
                              style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF16A34A))),
                          const Spacer(),
                          const Text('ETA 12 min',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: _darkTeal)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                                color: _tile, shape: BoxShape.circle),
                            alignment: Alignment.center,
                            child: Text(con.techInitials,
                                style: const TextStyle(
                                    color: _darkTeal,
                                    fontWeight: FontWeight.w800)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(con.techName,
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A))),
                                const SizedBox(height: 2),
                                Text(
                                    '★ ${con.techRating} · AC specialist · ${con.techJobs}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF94A3B8))),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 5),
                            decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(20)),
                            child: const Text('Verified',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF15803D))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: const [
                          Expanded(
                              child: _ActionBtn(
                                  icon: Icons.chat_bubble_outline_rounded,
                                  label: 'Chat')),
                          SizedBox(width: 10),
                          Expanded(
                              child: _ActionBtn(
                                  icon: Icons.call_outlined, label: 'Call')),
                          SizedBox(width: 10),
                          Expanded(
                              child: _ActionBtn(
                                  icon: Icons.bookmark_border_rounded,
                                  label: 'Details')),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                            color: const Color(0xFFF7F8FA),
                            borderRadius: BorderRadius.circular(14)),
                        child: Column(
                          children: [
                            _step('Booking confirmed', done: true),
                            _step('Technician assigned · Jamal', done: true),
                            _step('On the way to your home', active: true),
                            _step('Service in progress'),
                            _step('Completed & paid', last: true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: con.viewBookingDetails,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('View booking details',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A))),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _round(IconData icon, VoidCallback onTap) => InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)
              ]),
          child: Icon(icon, size: 18, color: const Color(0xFF1A1A1A)),
        ),
      );

  Widget _step(String label,
      {bool done = false, bool active = false, bool last = false}) {
    final color = done
        ? const Color(0xFF22C55E)
        : active
            ? _darkTeal
            : const Color(0xFFCBD5E1);
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 14),
      child: Row(
        children: [
          Icon(
              done
                  ? Icons.check_circle
                  : active
                      ? Icons.radio_button_checked
                      : Icons.circle_outlined,
              size: 20,
              color: color),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(
                  fontSize: 13.5,
                  fontWeight:
                      (done || active) ? FontWeight.w700 : FontWeight.w500,
                  color: (done || active)
                      ? const Color(0xFF0F172A)
                      : const Color(0xFF94A3B8))),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEDEFF2))),
      child: Column(
        children: [
          Icon(icon, color: _teal, size: 22),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155))),
        ],
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  const _MapPainter();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xFFDDE6EE));
    final block = Paint()..color = const Color(0xFFE9EEF3);
    void b(double x, double y, double w, double h) => canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, w, h), const Radius.circular(8)),
        block);
    b(size.width * 0.05, size.height * 0.10, 70, 50);
    b(size.width * 0.62, size.height * 0.12, 80, 48);
    b(size.width * 0.10, size.height * 0.30, 70, 46);
    b(size.width * 0.66, size.height * 0.34, 70, 50);

    final route = Paint()
      ..color = _darkTeal
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final start = Offset(size.width * 0.12, size.height * 0.5);
    final end = Offset(size.width * 0.82, size.height * 0.16);
    for (int i = 0; i < 20; i += 2) {
      canvas.drawLine(Offset.lerp(start, end, i / 20)!,
          Offset.lerp(start, end, (i + 1) / 20)!, route);
    }
    final mid = Offset.lerp(start, end, 0.5)!;
    canvas.drawCircle(mid, 18, Paint()..color = _darkTeal);
    canvas.drawCircle(end, 16, Paint()..color = const Color(0x330E7C6B));
    canvas.drawCircle(end, 8, Paint()..color = _darkTeal);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
