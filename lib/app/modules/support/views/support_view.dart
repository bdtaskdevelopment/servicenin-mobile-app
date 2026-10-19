import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/support_response.dart';
import '../../../global_widget/custom_app_bar.dart';
import '../controllers/support_controller.dart';

/// Shared support screen, opened from the support icon in a module's header.
/// Lists the numbers that module's admin configured; tapping one dials it.
class SupportView extends GetView<SupportController> {
  const SupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: CustomAppBar(
        title: controller.title,
        backgroundColor: AppColors.white,
      ),
      body: GetBuilder<SupportController>(
        builder: (con) {
          if (con.loading && con.hotlines.isEmpty) {
            return const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.2),
              ),
            );
          }
          if (con.hotlines.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No support numbers available right now.'.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF94A3B8)),
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: con.fetch,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                Text(
                  'Call us for immediate assistance.'.tr,
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 16),
                ...con.hotlines.asMap().entries.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: FadeInUp(
                          from: 18,
                          duration: const Duration(milliseconds: 300),
                          delay: Duration(milliseconds: 70 * e.key),
                          child: _SupportRow(
                            hotline: e.value,
                            onCall: () => con.call(e.value.number),
                            onWhatsApp: () => con.openWhatsApp(e.value.whatsappUrl),
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SupportRow extends StatelessWidget {
  const _SupportRow({
    required this.hotline,
    required this.onCall,
    required this.onWhatsApp,
  });
  final SupportHotline hotline;
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
                  color: const Color(0xFF334155).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.support_agent_rounded,
                    color: Color(0xFF334155), size: 22),
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
                      foregroundColor: const Color(0xFF0F766E),
                      side: const BorderSide(color: Color(0xFF0F766E)),
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

/// The header icon that opens the screen above. Dropped into the top-right of
/// a module's own header — one call site per module, so they stay consistent.
/// Compact overflow (⋮) menu that opens the module's support center — same
/// space-saving pattern as the ambulance module's top-bar menu.
class SupportIconButton extends StatelessWidget {
  const SupportIconButton({
    super.key,
    required this.title,
    required this.endpoint,
    this.color = const Color(0xFF1A1A1A),
    this.size = 22,
  });

  /// Screen title, e.g. "Blood Support".
  final String title;

  /// Module endpoint, e.g. 'api/v1/blood/hotlines'.
  final String endpoint;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      splashRadius: 20,
      tooltip: 'Support'.tr,
      padding: EdgeInsets.zero,
      icon: Icon(Icons.more_vert_rounded, size: size, color: color),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (_) => Get.toNamed(
        '/support-center',
        arguments: {'title': title, 'endpoint': endpoint},
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'support',
          child: Row(
            children: [
              const Icon(Icons.support_agent_rounded,
                  size: 18, color: Color(0xFF1A1A1A)),
              const SizedBox(width: 10),
              Text('Support'.tr),
            ],
          ),
        ),
      ],
    );
  }
}
