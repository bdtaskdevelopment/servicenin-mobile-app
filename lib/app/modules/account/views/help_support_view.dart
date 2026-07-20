import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/helpers/snack_helper.dart';
import '../../../data/services/settings.service.dart';

const _indigo = Color(0xFF4F46E5);
const _green = Color(0xFF16A34A);

Future<void> _openExternal(String url) async {
  final trimmed = url.trim();
  if (trimmed.isEmpty) return;
  try {
    final ok =
        await launchUrl(Uri.parse(trimmed), mode: LaunchMode.externalApplication);
    if (!ok) SnackHelper.error('খুলতে সমস্যা হয়েছে');
  } catch (_) {
    SnackHelper.error('খুলতে সমস্যা হয়েছে');
  }
}

/// "Help & support" — contact info sourced from the admin's Settings →
/// Contact group (GET /api/v1/settings, already loaded by [SettingsService]
/// at app startup).
class HelpSupportView extends StatelessWidget {
  const HelpSupportView({super.key});

  @override
  Widget build(BuildContext context) {
    final s = SettingsService.to.settings;
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F6),
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
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20, color: Color(0xFF1A1A1A)),
                  ),
                  Text('Help & support'.tr,
                      style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A))),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: const Color(0xFFE3E7F5),
                        borderRadius: BorderRadius.circular(14)),
                    child: Row(
                      children: [
                        const Icon(Icons.support_agent_rounded,
                            size: 18, color: _indigo),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                              'Need a hand? Reach us any of these ways.'.tr,
                              style: const TextStyle(
                                  fontSize: 12.5,
                                  height: 1.45,
                                  color: Color(0xFF475569))),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (s.contactPhone.isNotEmpty)
                    _ContactRow(
                      icon: Icons.call_outlined,
                      label: 'Phone'.tr,
                      value: s.contactPhone,
                      actionIcon: Icons.call_rounded,
                      actionColor: _green,
                      onTap: () => _openExternal('tel:${s.contactPhone}'),
                    ),
                  if (s.contactEmail.isNotEmpty)
                    _ContactRow(
                      icon: Icons.email_outlined,
                      label: 'Email'.tr,
                      value: s.contactEmail,
                      actionIcon: Icons.arrow_outward_rounded,
                      actionColor: _indigo,
                      onTap: () => _openExternal('mailto:${s.contactEmail}'),
                    ),
                  if (s.contactWebsite.isNotEmpty)
                    _ContactRow(
                      icon: Icons.language_rounded,
                      label: 'Website'.tr,
                      value: s.contactWebsite,
                      actionIcon: Icons.arrow_outward_rounded,
                      actionColor: _indigo,
                      onTap: () => _openExternal(s.contactWebsite),
                    ),
                  if (s.contactAddress.isNotEmpty)
                    _ContactRow(
                      icon: Icons.location_on_outlined,
                      label: 'Address'.tr,
                      value: s.contactAddress,
                    ),
                  if (s.contactHours.isNotEmpty)
                    _ContactRow(
                      icon: Icons.schedule_rounded,
                      label: 'Support hours'.tr,
                      value: s.contactHours,
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

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    this.actionIcon,
    this.actionColor,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final IconData? actionIcon;
  final Color? actionColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF0FB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 19, color: _indigo),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF94A3B8))),
                    const SizedBox(height: 2),
                    Text(value,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                            color: Color(0xFF0F172A))),
                  ],
                ),
              ),
              if (actionIcon != null) ...[
                const SizedBox(width: 8),
                Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: (actionColor ?? _indigo).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(actionIcon, size: 16, color: actionColor ?? _indigo),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
