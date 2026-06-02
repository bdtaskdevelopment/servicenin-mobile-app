import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/matchmaking_controller.dart';

const _maroon = Color(0xFFB11D5C);
const _pink = Color(0xFFFBD9E8);

class BiodataDetailView extends GetView<MatchmakingController> {
  const BiodataDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final con = controller;
    final m = con.selected;
    final code = m?.code ?? 'SN-72841';
    final letter = m?.letter ?? 'A';
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 16, 4),
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
                      const Text('Biodata',
                          style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                      Text(code,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.bookmark_border_rounded,
                      color: Color(0xFF1A1A1A), size: 22),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                children: [
                  // Avatar + code
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 84,
                              height: 84,
                              decoration: BoxDecoration(
                                  color: _pink,
                                  borderRadius: BorderRadius.circular(22)),
                              alignment: Alignment.center,
                              child: Text(letter,
                                  style: const TextStyle(
                                      color: _maroon,
                                      fontSize: 34,
                                      fontWeight: FontWeight.w800)),
                            ),
                            Positioned(
                              right: 2,
                              bottom: 2,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                    color: _maroon,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: const Color(0xFFF7F8FA),
                                        width: 2.5)),
                                child: const Icon(Icons.check_rounded,
                                    size: 13, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(code,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A))),
                        const SizedBox(height: 3),
                        const Text('Photos shared after mutual interest',
                            style: TextStyle(
                                fontSize: 12.5, color: Color(0xFF94A3B8))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Looking for
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: const Color(0xFFFCEAF2),
                        borderRadius: BorderRadius.circular(14)),
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 13.5, color: _maroon),
                        children: [
                          TextSpan(
                              text: 'Looking for: ',
                              style: TextStyle(fontWeight: FontWeight.w800)),
                          TextSpan(text: 'Practising, family-oriented'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Detail rows
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEDEFF2))),
                    child: Column(
                      children: [
                        for (int i = 0; i < con.detailRows.length; i++) ...[
                          _row(con.detailRows[i]),
                          if (i != con.detailRows.length - 1)
                            const _DashedDivider(),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Guardian note
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: const Color(0xFFEAF1FB),
                        borderRadius: BorderRadius.circular(14)),
                    child: Row(
                      children: const [
                        Icon(Icons.verified_user_outlined,
                            size: 18, color: Color(0xFF2563EB)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                              'Guardian contact is exchanged only after both sides accept interest.',
                              style: TextStyle(
                                  fontSize: 12.5,
                                  height: 1.4,
                                  color: Color(0xFF2563EB))),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Bottom action bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  SizedBox(
                    width: 54,
                    height: 54,
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        padding: EdgeInsets.zero,
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Icon(Icons.close_rounded,
                          color: Color(0xFF334155)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: con.expressInterest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _maroon,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Express interest',
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

  Widget _row(MmDetailRow r) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(r.label,
                style: const TextStyle(
                    fontSize: 13.5, color: Color(0xFF64748B))),
            const SizedBox(width: 12),
            Expanded(
              child: Text(r.value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A))),
            ),
          ],
        ),
      );
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        const dash = 5.0;
        const gap = 4.0;
        final count = (c.maxWidth / (dash + gap)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            count,
            (_) => Container(
                width: dash, height: 1, color: const Color(0xFFEDEFF2)),
          ),
        );
      },
    );
  }
}
