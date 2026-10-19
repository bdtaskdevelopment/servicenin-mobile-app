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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
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
                  color: _red.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.support_agent_rounded,
                    color: _red, size: 22),
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
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: OutlinedButton.icon(
                    onPressed: onCall,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF16A34A),
                      side: const BorderSide(color: Color(0xFF16A34A)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.call_rounded, size: 17),
                    label: Text('Call'.tr,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
              if (hasWhatsApp) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: ElevatedButton.icon(
                      onPressed: onWhatsApp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.chat_rounded, size: 17),
                      label: Text('WhatsApp'.tr,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
