import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/funeral_response.dart';
import '../controllers/funeral_controller.dart';

const _forest = Color(0xFF2E6A5E);
const _mint = Color(0xFFE7F0ED);
const _navy = Color(0xFF0F172A);
const _labelColor = Color(0xFF64748B);
const _statusBg = Color(0xFFFFF4DE);
const _statusText = Color(0xFFB45309);

class FuneralRequestDetailView extends GetView<FuneralController> {
  const FuneralRequestDetailView({super.key});

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
                  Expanded(
                    child: Text(
                      'My booking'.tr,
                      style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: _navy),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.find<FuneralController>().openSupport(),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: _mint,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(LucideIcons.headset,
                          size: 19, color: _forest),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GetBuilder<FuneralController>(
                builder: (con) {
                  if (con.loadingRequestDetail) {
                    return const Center(
                      child: CircularProgressIndicator(
                          strokeWidth: 2.4, color: _forest),
                    );
                  }
                  final req = con.viewingRequest;
                  if (req == null) {
                    return Center(
                      child: Text('Booking not found.'.tr,
                          style: const TextStyle(
                              fontSize: 12.5, color: _labelColor)),
                    );
                  }
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFEDEFF2)),
                        ),
                        child: Column(
                          children: [
                            _row('Service'.tr, req.serviceName),
                            _divider(),
                            _row("Contact's name".tr, req.name),
                            _divider(),
                            _row('Phone number'.tr, req.phone),
                            _divider(),
                            _row("DECEASED'S GENDER".tr,
                                req.genderLabel.isEmpty
                                    ? '—'
                                    : req.genderLabel.tr),
                            _divider(),
                            _row('Submitted'.tr, req.createdLabel),
                            _divider(),
                            _statusRow(req),
                          ],
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

  Widget _divider() => const Divider(height: 1, color: Color(0xFFF1F2F4));

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 12.5, color: _labelColor)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value.isEmpty ? '—' : value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _navy),
              ),
            ),
          ],
        ),
      );

  Widget _statusRow(FuneralRequest req) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Text('Status'.tr,
                style: const TextStyle(fontSize: 12.5, color: _labelColor)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: _statusBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                        color: _statusText, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    req.status == 'pending'
                        ? 'Awaiting coordinator call'.tr
                        : req.statusLabel.tr,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _statusText),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
