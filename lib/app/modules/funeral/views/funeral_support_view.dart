import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/funeral_response.dart';
import '../controllers/funeral_controller.dart';

const _forest = Color(0xFF2E6A5E);
const _mint = Color(0xFFE7F0ED);
const _navy = Color(0xFF0F172A);
const _subtitle = Color(0xFF6B7A99);

/// Funeral's own support screen — the generic cross-module `SupportView`
/// doesn't match this module's mockup (a forest banner + one card per
/// hotline with its own call button), so this is a dedicated screen
/// instead of changing the shared widget every other module still uses.
class FuneralSupportView extends GetView<FuneralController> {
  const FuneralSupportView({super.key});

  @override
  Widget build(BuildContext context) {
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
                    onPressed: () => Get.back(),
                    icon: const Icon(LucideIcons.chevronLeft,
                        size: 22, color: Color(0xFF1A1A1A)),
                  ),
                  Text(
                    'Funeral Support'.tr,
                    style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: _navy),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GetBuilder<FuneralController>(
                builder: (con) {
                  if (con.loadingHotlines && con.hotlines.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                          strokeWidth: 2.4, color: _forest),
                    );
                  }
                  if (con.hotlines.isEmpty) {
                    return Center(
                      child: Text(
                        'No support numbers available right now.'.tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, color: _subtitle),
                      ),
                    );
                  }
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _forest,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(LucideIcons.headset,
                                  color: Colors.white, size: 19),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Call us now for immediate assistance.'.tr,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      ...con.hotlines.map(
                        (h) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _HotlineCard(hotline: h, controller: con),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HotlineCard extends StatelessWidget {
  const _HotlineCard({required this.hotline, required this.controller});
  final FuneralHotline hotline;
  final FuneralController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEFF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _mint,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Icon(LucideIcons.headset, color: _forest, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotline.label,
                      style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: _navy),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hotline.number,
                      style: const TextStyle(fontSize: 12, color: _subtitle),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton(
              onPressed: () => controller.call(hotline.number),
              style: OutlinedButton.styleFrom(
                foregroundColor: _forest,
                side: const BorderSide(color: _forest, width: 1.2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.phone, size: 16),
                  const SizedBox(width: 8),
                  Text('Call'.tr,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
