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
                            onTap: () => con.call(e.value.number),
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
  const _SupportRow({required this.hotline, required this.onTap});
  final SupportHotline hotline;
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
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFD9F7E6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.call_rounded,
                  color: Color(0xFF16A34A), size: 20),
            ),
          ],
        ),
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
