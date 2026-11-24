import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/ambulance_response.dart';
import '../controllers/ambulance_controller.dart';

const _red = Color(0xFFE4484D);
const _redTint = Color(0xFFFFEFEF);
const _green = Color(0xFF12A14F);
const _navy = Color(0xFF0F172A);

/// Support screen reached from the fare-estimate page's header headset
/// icon — shows the admin-configured hotline numbers so a rider can call
/// for help while booking.
class AmbulanceSupportView extends GetView<AmbulanceController> {
  const AmbulanceSupportView({super.key});

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
                  Text('Support Center (ambulance)'.tr,
                      style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          color: _navy)),
                ],
              ),
            ),
            Expanded(
              child: GetBuilder<AmbulanceController>(
                builder: (con) {
                  if (con.loadingHotlines && con.hotlines.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  if (con.hotlines.isEmpty) {
                    return Center(
                      child: Text('No hotlines available.'.tr,
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xFF94A3B8))),
                    );
                  }
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _red,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(LucideIcons.headset,
                                  color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                  'Call our hotline for immediate assistance.'
                                      .tr,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      height: 1.4)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      ...con.hotlines.asMap().entries.map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: FadeInUp(
                                from: 18,
                                duration: const Duration(milliseconds: 300),
                                delay: Duration(milliseconds: 70 * e.key),
                                child: _SupportHotlineRow(
                                  hotline: e.value,
                                  onCall: () => con.callHotline(e.value.number),
                                  onWhatsApp: () =>
                                      con.openWhatsApp(e.value.whatsappUrl),
                                ),
                              ),
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

class _SupportHotlineRow extends StatelessWidget {
  const _SupportHotlineRow({
    required this.hotline,
    required this.onCall,
    required this.onWhatsApp,
  });
  final AmbulanceHotline hotline;
  final VoidCallback onCall;
  final VoidCallback onWhatsApp;

  @override
  Widget build(BuildContext context) {
    final hasWhatsApp = hotline.whatsappUrl.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(12),
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
              color: _redTint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.phone, color: _red, size: 20),
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
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: _red)),
                const SizedBox(height: 2),
                Text(hotline.number,
                    style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: _navy)),
              ],
            ),
          ),
          if (hasWhatsApp) ...[
            GestureDetector(
              onTap: onWhatsApp,
              child: Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFF25D366),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.messageCircle,
                    color: Colors.white, size: 17),
              ),
            ),
            const SizedBox(width: 8),
          ],
          GestureDetector(
            onTap: onCall,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              decoration: BoxDecoration(
                color: _green,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.phone, size: 15, color: Colors.white),
                  const SizedBox(width: 6),
                  Text('Call'.tr,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
