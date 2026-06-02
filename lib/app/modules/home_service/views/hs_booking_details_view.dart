import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/home_service_controller.dart';

const _teal = Color(0xFF0E9F8E);
const _darkTeal = Color(0xFF0E7C6B);
const _tile = Color(0xFFE0F2EF);

class HsBookingDetailsView extends GetView<HomeServiceController> {
  const HsBookingDetailsView({super.key});

  static const _timeline = [
    ('Placed', '9:40 AM'),
    ('Assigned to Jamal Uddin', '9:52 AM'),
    ('Arrived', '2:58 PM'),
    ('Service completed', '4:10 PM'),
  ];

  @override
  Widget build(BuildContext context) {
    final con = controller;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
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
                      const Text('Booking details',
                          style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                      Text(con.bookingId,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.share_outlined,
                      color: Color(0xFF1A1A1A), size: 22),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                children: [
                  // Service card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                              color: _tile,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.ac_unit_rounded,
                              color: _teal, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(con.bookingSummary,
                                  style: const TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A))),
                              const SizedBox(height: 2),
                              Text(
                                  '${con.techName} · ${con.whenSummary}',
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
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(20)),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.circle,
                                  size: 7, color: Color(0xFFD97706)),
                              SizedBox(width: 4),
                              Text('In progress',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFB45309))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const _Label('STATUS TIMELINE'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                    decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: List.generate(_timeline.length, (i) {
                        final t = _timeline[i];
                        final last = i == _timeline.length - 1;
                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  const Icon(Icons.check_circle,
                                      size: 20, color: _darkTeal),
                                  if (!last)
                                    Expanded(
                                      child: Container(
                                          width: 2,
                                          color: const Color(0xFFB6E0D7)),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Padding(
                                padding: EdgeInsets.only(bottom: last ? 8 : 18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(t.$1,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF0F172A))),
                                    const SizedBox(height: 1),
                                    Text(t.$2,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFFE07A1F))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: const [
                      _Label('WORK PROOF'),
                      SizedBox(width: 8),
                      Text('before · after',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: const [
                      Expanded(child: _ProofBox(label: 'Before', tinted: false)),
                      SizedBox(width: 12),
                      Expanded(child: _ProofBox(label: 'After', tinted: true)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const _Label('INVOICE'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        _fee('Service charge', '৳${con.totalPrice}'),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        _fee('Parts', '৳0'),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        _fee('VAT (5%)', '৳${con.vat}'),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        _fee('Total paid', '৳${con.totalPaid}', bold: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Bottom actions
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: con.rateService,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _darkTeal,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Text('Rate service',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              side:
                                  const BorderSide(color: Color(0xFFE2E8F0)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Text('Rebook',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A))),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Report an issue (dispute)',
                        style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFDC2626))),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fee(String label, String amount, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: bold ? 15 : 13.5,
                    fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
                    color: bold
                        ? const Color(0xFF0F172A)
                        : const Color(0xFF475569))),
            Text(amount,
                style: TextStyle(
                    fontSize: bold ? 16 : 14,
                    fontWeight: FontWeight.w800,
                    color: bold ? _darkTeal : const Color(0xFF0F172A))),
          ],
        ),
      );
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

class _ProofBox extends StatelessWidget {
  const _ProofBox({required this.label, required this.tinted});
  final String label;
  final bool tinted;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 110,
          decoration: BoxDecoration(
              color: tinted ? _tile : const Color(0xFFE9EDF1),
              borderRadius: BorderRadius.circular(14)),
          child: Icon(Icons.photo_camera_outlined,
              color: tinted ? _teal : const Color(0xFF94A3B8), size: 30),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF334155))),
      ],
    );
  }
}
