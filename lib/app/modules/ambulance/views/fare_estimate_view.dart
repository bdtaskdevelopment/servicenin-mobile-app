import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/fare_controller.dart';

const _navy = Color(0xFF1E2A4A);
const _red = Color(0xFFE23744);

class FareEstimateView extends GetView<FareController> {
  const FareEstimateView({super.key});

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
                      Text('Fare estimate',
                          style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                      SizedBox(height: 1),
                      Text('Cash on completion · No advance',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: GetBuilder<FareController>(
                builder: (con) {
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    children: [
                      _MapCard(con: con),
                      const SizedBox(height: 14),
                      _VehicleCard(con: con),
                      const SizedBox(height: 14),
                      _BreakdownCard(con: con),
                      const SizedBox(height: 14),
                      _TotalCard(con: con),
                      const SizedBox(height: 18),
                      const _Label('PAYMENT METHOD'),
                      const SizedBox(height: 12),
                      GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.55,
                        children: List.generate(con.methods.length, (i) {
                          return _PayCard(
                            method: con.methods[i],
                            selected: con.selectedMethod == i,
                            onTap: () => con.selectMethod(i),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                      _PromoCard(),
                    ],
                  );
                },
              ),
            ),
            // Bottom
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: controller.confirmDispatch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _navy,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Confirm & dispatch',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF94A3B8),
          letterSpacing: 0.6));
}

class _MapCard extends StatelessWidget {
  const _MapCard({required this.con});
  final FareController con;
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 150,
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _FareMapPainter())),
            Positioned(
              left: 10,
              top: 10,
              child: _pill(con.area, const Color(0xFF0F172A)),
            ),
            Positioned(
              right: 10,
              top: 10,
              child: _pill('🏥 ${con.hospital}', _red),
            ),
            Positioned(
              left: 10,
              bottom: 10,
              child: _pill(con.pickupDistance, const Color(0xFF1E2A4A)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
            color: AppColors.white, borderRadius: BorderRadius.circular(20)),
        child: Text(text,
            style: TextStyle(
                fontSize: 11.5, fontWeight: FontWeight.w700, color: color)),
      );
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({required this.con});
  final FareController con;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDEFF2)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: _red.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.airport_shuttle_rounded,
                color: _red, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(con.vehicle,
                    style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text(con.vehicleSub,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(20)),
            child: Text(con.eta,
                style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF15803D))),
          ),
        ],
      ),
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard({required this.con});
  final FareController con;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDEFF2)),
      ),
      child: Column(
        children: List.generate(con.lines.length, (i) {
          final l = con.lines[i];
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.label,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A))),
                          const SizedBox(height: 1),
                          Text(l.sub,
                              style: const TextStyle(
                                  fontSize: 11.5, color: Color(0xFF94A3B8))),
                        ],
                      ),
                    ),
                    Text(l.amount,
                        style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: l.discount
                                ? const Color(0xFF16A34A)
                                : const Color(0xFF0F172A))),
                  ],
                ),
              ),
              if (i != con.lines.length - 1)
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
            ],
          );
        }),
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.con});
  final FareController con;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _navy, width: 1.4),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('ESTIMATED TOTAL',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: 0.5)),
                SizedBox(height: 2),
                Text('আনুমানিক ডাটা · final may vary ±5%',
                    style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          Text(con.total,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w800, color: _navy)),
        ],
      ),
    );
  }
}

class _PayCard extends StatelessWidget {
  const _PayCard(
      {required this.method, required this.selected, required this.onTap});
  final PayMethod method;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selected ? _navy : const Color(0xFFE2E8F0),
              width: selected ? 1.6 : 1.2),
        ),
        child: Stack(
          children: [
            if (selected)
              const Positioned(
                right: 0,
                top: 0,
                child: Icon(Icons.check_circle, size: 16, color: _navy),
              ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(method.name,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: method.color)),
                  const SizedBox(height: 2),
                  Text(method.sub,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF94A3B8))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFCE3A8)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: AppColors.brandOrange,
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.percent_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Apply promo code',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFB45309))),
                SizedBox(height: 2),
                Text('3 codes available for you',
                    style: TextStyle(fontSize: 12, color: Color(0xFFB45309))),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFFB45309)),
        ],
      ),
    );
  }
}

class _FareMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xFFE3EAF1));
    final block = Paint()..color = const Color(0xFFD7E0E9);
    void b(double x, double y, double w, double h) => canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, w, h), const Radius.circular(6)),
        block);
    b(size.width * 0.06, size.height * 0.16, 56, 36);
    b(size.width * 0.40, size.height * 0.12, 60, 36);
    b(size.width * 0.74, size.height * 0.45, 56, 36);
    b(size.width * 0.10, size.height * 0.60, 56, 34);

    final route = Paint()
      ..color = const Color(0xFF1E2A4A)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final start = Offset(size.width * 0.40, size.height * 0.55);
    final end = Offset(size.width * 0.88, size.height * 0.18);
    for (int i = 0; i < 18; i += 2) {
      canvas.drawLine(Offset.lerp(start, end, i / 18)!,
          Offset.lerp(start, end, (i + 1) / 18)!, route);
    }
    // pickup pulse
    canvas.drawCircle(start, 20, Paint()..color = const Color(0x33E23744));
    canvas.drawCircle(start, 9, Paint()..color = const Color(0xFFE23744));
    canvas.drawCircle(start, 3.5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
