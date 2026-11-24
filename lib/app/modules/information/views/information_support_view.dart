import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/support_response.dart';
import '../../support/controllers/support_controller.dart';

const _blue = Color(0xFF0183C7);
const _blueTint = Color(0xFFE6F4FA);

/// Information module's own skin on the shared [SupportController] — the
/// generic [SupportView] is reused by four other modules with their own
/// themes, so this is a dedicated view (same data/actions) matching this
/// module's blue mockup instead of restyling the shared screen for everyone.
class InformationSupportView extends GetView<SupportController> {
  const InformationSupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FA),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(8, 6, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    splashRadius: 22,
                    onPressed: () => Get.back(),
                    icon: const Icon(LucideIcons.chevronLeft,
                        size: 22, color: Color(0xFF0F172A)),
                  ),
                  Text('Support Center (info)'.tr,
                      style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A))),
                ],
              ),
            ),
            Expanded(
              child: GetBuilder<SupportController>(
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
                  return RefreshIndicator(
                    color: _blue,
                    onRefresh: con.fetch,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _blue,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color:
                                      Colors.white.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(LucideIcons.headset,
                                    color: Colors.white, size: 19),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Call our hotline for immediate assistance (info).'
                                      .tr,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      height: 1.3),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (con.hotlines.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 32, horizontal: 8),
                            child: Text(
                              'No support numbers available right now.'.tr,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 13, color: Color(0xFF94A3B8)),
                            ),
                          )
                        else
                          ...con.hotlines.asMap().entries.map(
                                (e) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: FadeInUp(
                                    from: 18,
                                    duration:
                                        const Duration(milliseconds: 300),
                                    delay: Duration(milliseconds: 70 * e.key),
                                    child: _SupportCard(
                                      hotline: e.value,
                                      onCall: () => con.call(e.value.number),
                                      onWhatsApp: () => con.openWhatsApp(
                                          e.value.whatsappUrl),
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
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

IconData _hotlineIcon(String label) {
  final l = label.toLowerCase();
  if (l.contains('correct')) return LucideIcons.filePen;
  if (l.contains('info') || l.contains('desk')) return LucideIcons.info;
  if (l.contains('support')) return LucideIcons.headset;
  return LucideIcons.phone;
}

/// Bangla label for the handful of standard admin-configured hotline names
/// this endpoint always returns (Support Center / Information Desk /
/// Corrections) — there's no Bangla field on [SupportHotline], so this is a
/// substring-matched client-side translation, falling back to the raw label
/// for anything an admin names differently.
String _hotlineLabel(String label) {
  final l = label.toLowerCase();
  if (l.contains('correct')) return 'তথ্য সংশোধন';
  if (l.contains('info') || l.contains('desk')) return 'তথ্যকেন্দ্র';
  if (l.contains('support')) return 'সাপোর্ট সেন্টার';
  return label;
}

class _SupportCard extends StatelessWidget {
  const _SupportCard({
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _blueTint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_hotlineIcon(hotline.label),
                    color: _blue, size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_hotlineLabel(hotline.label),
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
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B))),
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
                      foregroundColor: _blue,
                      side: const BorderSide(color: _blue),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(LucideIcons.phone, size: 16),
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
                      icon: const Icon(LucideIcons.messageCircle, size: 16),
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
