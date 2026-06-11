import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/funeral_controller.dart';

const _charcoal = Color(0xFF332F2C);
const _greenTile = Color(0xFFD6F5E3);
const _grayTile = Color(0xFFE8EAED);
const _checkText = Color(0xFFB45309);

class FuneralDoneView extends GetView<FuneralController> {
  const FuneralDoneView({super.key});

  @override
  Widget build(BuildContext context) {
    final con = controller;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F4),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 36, 20, 16),
                children: [
                  Center(
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: const BoxDecoration(
                          color: _charcoal, shape: BoxShape.circle),
                      child: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 42),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: Text('Request received'.tr,
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A))),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                        'May Allah grant you patience. A coordinator is being assigned and will call you shortly.'
                            .tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13.5,
                            height: 1.5,
                            color: Colors.black.withValues(alpha: 0.5))),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(18)),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                  color: _grayTile,
                                  borderRadius: BorderRadius.circular(12)),
                              alignment: Alignment.center,
                              child: const Icon(Icons.receipt_long_outlined,
                                  color: Color(0xFF334155), size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      con.lastRequest?.registrationNo.isNotEmpty ==
                                              true
                                          ? con.lastRequest!.registrationNo
                                          : 'Funeral request'.tr,
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF0F172A))),
                                  const SizedBox(height: 2),
                                  Text(
                                      con.lastRequest?.deceasedName.isNotEmpty ==
                                              true
                                          ? con.lastRequest!.deceasedName
                                          : 'A coordinator is being assigned'.tr,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF94A3B8))),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                  color: _greenTile,
                                  borderRadius: BorderRadius.circular(20)),
                              child: Text(
                                  con.lastRequest?.statusLabel ?? 'Pending'.tr,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF15803D))),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: _DashedDivider(),
                        ),
                        _check('Your request has been registered'.tr),
                        const SizedBox(height: 12),
                        _check('A coordinator will call you shortly'.tr),
                        const SizedBox(height: 12),
                        _check(
                            'Track progress anytime from “My requests”'.tr),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Done
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: con.done,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _charcoal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Done'.tr,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _check(String text) => Row(
        children: [
          const Icon(Icons.check_rounded, size: 18, color: _charcoal),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: _checkText)),
          ),
        ],
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
