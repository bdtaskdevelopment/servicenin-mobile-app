import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../controllers/funeral_controller.dart';

const _forest = Color(0xFF2E6A5E);
const _mint = Color(0xFFE7F0ED);
const _navy = Color(0xFF0F172A);

class FuneralDoneView extends GetView<FuneralController> {
  const FuneralDoneView({super.key});

  @override
  Widget build(BuildContext context) {
    final con = controller;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    splashRadius: 22,
                    onPressed: con.done,
                    icon: const Icon(LucideIcons.x,
                        size: 22, color: Color(0xFF1A1A1A)),
                  ),
                  Expanded(
                    child: Text(
                      'Funeral request header'.tr,
                      style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: _navy),
                    ),
                  ),
                  GestureDetector(
                    onTap: con.openSupport,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: _mint,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      alignment: Alignment.center,
                      child:
                          const Icon(LucideIcons.headset, size: 19, color: _forest),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 16),
                children: [
                  Center(
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: const BoxDecoration(
                          color: _mint, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                            color: _forest, shape: BoxShape.circle),
                        child: const Icon(LucideIcons.check,
                            color: Colors.white, size: 32),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Center(
                    child: Text('Request received'.tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: _navy)),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                        'May Allah grant you patience. A coordinator is being assigned and will call you shortly.'
                            .tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 12.5,
                            height: 1.5,
                            color: Color(0xFF64748B))),
                  ),
                  const SizedBox(height: 22),
                  Center(
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                      decoration: BoxDecoration(
                        color: _mint,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.shieldCheck,
                              size: 16, color: _forest),
                          const SizedBox(width: 8),
                          Text(
                              'No online payment is required for this service.'
                                  .tr,
                              style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: _forest)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: con.viewLastBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF26921),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.receiptText, size: 18),
                          const SizedBox(width: 8),
                          Text('View my booking'.tr,
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton(
                      onPressed: con.hotlines.isEmpty
                          ? null
                          : () => con.call(con.hotlines.first.number),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _forest,
                        side: const BorderSide(color: _forest, width: 1.4),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.phone, size: 18),
                          const SizedBox(width: 8),
                          Text('Call support center'.tr,
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w800)),
                        ],
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
}
