import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/ambulance_response.dart';
import '../../../global_widget/custom_app_bar.dart';
import '../controllers/ambulance_controller.dart';

const _red = Color(0xFFE23744);

/// Support screen reached from the fare-estimate page's overflow menu —
/// shows the admin-configured hotline numbers (Hotline 1/2/3) so a rider can
/// call for help while booking.
class AmbulanceSupportView extends GetView<AmbulanceController> {
  const AmbulanceSupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: CustomAppBar(title: 'Support'.tr, backgroundColor: AppColors.white),
      body: GetBuilder<AmbulanceController>(
        builder: (con) {
          if (con.loadingHotlines && con.hotlines.isEmpty) {
            return const SizedBox.shrink();
          }
          if (con.hotlines.isEmpty) {
            return Center(
              child: Text('No hotlines available.'.tr,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              Text('Call our hotline for immediate assistance.'.tr,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
              const SizedBox(height: 16),
              ...con.hotlines.asMap().entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: FadeInUp(
                        from: 18,
                        duration: const Duration(milliseconds: 300),
                        delay: Duration(milliseconds: 70 * e.key),
                        child: _SupportHotlineRow(
                          hotline: e.value,
                          onTap: () => con.callHotline(e.value.number),
                        ),
                      ),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _SupportHotlineRow extends StatelessWidget {
  const _SupportHotlineRow({required this.hotline, required this.onTap});
  final AmbulanceHotline hotline;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.support_agent_rounded, color: _red, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hotline.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A))),
                  const SizedBox(height: 2),
                  Text(hotline.number,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFE07A1F))),
                ],
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFD9F7E6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.call_rounded, color: Color(0xFF16A34A), size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
