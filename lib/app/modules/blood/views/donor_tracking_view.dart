import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/donation_flow_controller.dart';
import '../widgets/confirm_otp_sheet.dart';

const _red = Color(0xFFE11D48);

class DonorTrackingView extends GetView<DonationFlowController> {
  const DonorTrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    final con = controller;
    final donor = con.selected;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // ── Fake map ────────────────────────────────────────
          const _FakeMap(),
          // Back + hospital chip
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _circle(Icons.arrow_back_ios_new_rounded, () => Get.back()),
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
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                              color: _red, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Text(con.hospital,
                            style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ── Bottom sheet panel ──────────────────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 20)
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(4)),
                      ),
                      const SizedBox(height: 14),
                      // Status + ETA row
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                                color: Color(0xFF22C55E),
                                shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          const Text('Donor on the way',
                              style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF16A34A))),
                          const Spacer(),
                          Text('ETA ${con.eta}',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: _red)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Donor row
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                                color: _red.withValues(alpha: 0.14),
                                shape: BoxShape.circle),
                            alignment: Alignment.center,
                            child: Text(donor?.initials ?? 'TA',
                                style: const TextStyle(
                                    color: _red,
                                    fontWeight: FontWeight.w800)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(donor?.name ?? 'Tanvir Ahmed',
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF0F172A))),
                                const SizedBox(height: 2),
                                Text(
                                    '${donor?.group ?? 'O+'} · ${donor?.donations ?? 12} donations · ${donor?.distance ?? '0.8'} km away',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF94A3B8))),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                                color: const Color(0xFFFDE4E4),
                                borderRadius: BorderRadius.circular(20)),
                            child: Text(donor?.group ?? 'O+',
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: _red)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                              child: _ActionBtn(
                                  icon: Icons.chat_bubble_outline_rounded,
                                  label: 'Chat',
                                  onTap: con.openChat)),
                          const SizedBox(width: 10),
                          const Expanded(
                              child: _ActionBtn(
                                  icon: Icons.call_outlined,
                                  label: 'Voice call')),
                          const SizedBox(width: 10),
                          const Expanded(
                              child: _ActionBtn(
                                  icon: Icons.share_outlined,
                                  label: 'Live location')),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _StatusSteps(step: con.statusStep, hospital: con.hospital),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: ConfirmOtpSheet.show,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _red,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('Confirm donation · enter OTP',
                              style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w700)),
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

  Widget _circle(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)
          ],
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF1A1A1A)),
      ),
    );
  }
}

// ── Stylised map background ─────────────────────────────────────────
class _FakeMap extends StatelessWidget {
  const _FakeMap();

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(painter: _MapPainter()),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFFE9EEF3);
    canvas.drawRect(Offset.zero & size, bg);

    // Roads
    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 18;
    canvas.drawLine(
        Offset(0, size.height * 0.38), Offset(size.width, size.height * 0.30), road);
    canvas.drawLine(
        Offset(size.width * 0.45, 0), Offset(size.width * 0.55, size.height), road);

    // Blocks
    final block = Paint()..color = const Color(0xFFDDE5EC);
    void b(double x, double y, double w, double h) => canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, w, h), const Radius.circular(8)),
        block);
    b(size.width * 0.08, size.height * 0.08, 70, 55);
    b(size.width * 0.62, size.height * 0.10, 80, 50);
    b(size.width * 0.10, size.height * 0.45, 75, 60);
    b(size.width * 0.64, size.height * 0.42, 78, 60);

    // Dashed route
    final route = Paint()
      ..color = const Color(0xFFE11D48)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final start = Offset(size.width * 0.12, size.height * 0.44);
    final end = Offset(size.width * 0.82, size.height * 0.16);
    const dashes = 26;
    for (int i = 0; i < dashes; i += 2) {
      final t1 = i / dashes;
      final t2 = (i + 1) / dashes;
      canvas.drawLine(
        Offset.lerp(start, end, t1)!,
        Offset.lerp(start, end, t2)!,
        route,
      );
    }

    // Donor marker (mid)
    final mid = Offset.lerp(start, end, 0.5)!;
    canvas.drawCircle(
        mid, 22, Paint()..color = const Color(0x33E11D48));
    canvas.drawCircle(mid, 11, Paint()..color = const Color(0xFFE11D48));
    canvas.drawCircle(mid, 4, Paint()..color = Colors.white);

    // Hospital marker (end)
    canvas.drawCircle(end, 13, Paint()..color = const Color(0xFFE11D48));
    canvas.drawCircle(end, 5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Action button ───────────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  const _ActionBtn({required this.icon, required this.label, this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEDEFF2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: _red, size: 22),
            const SizedBox(height: 6),
            Text(label,
                style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155))),
          ],
        ),
      ),
    );
  }
}

// ── Status steps ────────────────────────────────────────────────────
class _StatusSteps extends StatelessWidget {
  const _StatusSteps({required this.step, required this.hospital});
  final int step;
  final String hospital;

  @override
  Widget build(BuildContext context) {
    final steps = [
      'Donor accepted the request',
      'En route to $hospital',
      'Arrived & donating',
      'Donation confirmed (OTP)',
    ];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: List.generate(steps.length, (i) {
          final done = i < step;
          final active = i == step;
          final color = done
              ? const Color(0xFF22C55E)
              : active
                  ? _red
                  : const Color(0xFFCBD5E1);
          return Padding(
            padding: EdgeInsets.only(bottom: i == steps.length - 1 ? 0 : 12),
            child: Row(
              children: [
                Icon(
                  done
                      ? Icons.check_circle
                      : active
                          ? Icons.radio_button_checked
                          : Icons.circle_outlined,
                  size: 20,
                  color: color,
                ),
                const SizedBox(width: 10),
                Text(steps[i],
                    style: TextStyle(
                        fontSize: 13.5,
                        fontWeight:
                            active || done ? FontWeight.w700 : FontWeight.w500,
                        color: (active || done)
                            ? const Color(0xFF0F172A)
                            : const Color(0xFF94A3B8))),
              ],
            ),
          );
        }),
      ),
    );
  }
}
