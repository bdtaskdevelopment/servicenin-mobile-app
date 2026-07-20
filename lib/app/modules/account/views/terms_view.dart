import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/services/settings.service.dart';

/// Terms of service — content sourced from the admin's Settings → App
/// Configuration → "Terms of Service (full text)" (GET /api/v1/settings,
/// already loaded by [SettingsService] at app startup). Falls back to a
/// short default while the admin hasn't set custom content yet.
class TermsView extends StatelessWidget {
  const TermsView({super.key});

  @override
  Widget build(BuildContext context) {
    final content = SettingsService.to.settings.termsContent.trim();
    final paragraphs = content.isEmpty
        ? const [
            'Using ServiceNin: One verified ServiceNin ID lets you access all 12 modules. You agree to provide accurate information and to use the services lawfully.',
            'Bookings & providers: ServiceNin connects you with independent providers (hospitals, technicians, coaching centers and more). Service quality, pricing and timing are the provider\'s responsibility.',
            'Payments: Most services are pay-after-service or paid directly to the provider. Any online payment fees and refund timelines are shown before you confirm.',
            'Emergencies: For Blood, Ambulance and other emergency services we route your request as fast as possible, but cannot guarantee availability. In a life-threatening emergency, also call national hotlines.',
            'Account & termination: You can delete your account anytime from Settings → Account. We may suspend accounts that misuse the platform or violate these terms.',
          ]
        : content
            .split(RegExp(r'\n\s*\n'))
            .map((p) => p.trim())
            .where((p) => p.isNotEmpty)
            .toList();
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F6),
      body: SafeArea(
        child: Column(
          children: [
            // Header
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
                  Text('Terms of service'.tr,
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
                        const Icon(Icons.description_outlined,
                            size: 18, color: Color(0xFF4F46E5)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                              'By using ServiceNin you agree to these terms.'.tr,
                              style: const TextStyle(
                                  fontSize: 12.5,
                                  height: 1.45,
                                  color: Color(0xFF475569))),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  for (final p in paragraphs)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(p,
                          style: const TextStyle(
                              fontSize: 13.5,
                              height: 1.5,
                              color: Color(0xFF475569))),
                    ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                          fontSize: 12.5,
                          height: 1.5,
                          color: Color(0xFF94A3B8)),
                      children: [
                        TextSpan(text: '${'Questions? Email'.tr} '),
                        const TextSpan(
                            text: 'legal@servicenin.com',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF4F46E5))),
                        TextSpan(text: ' ${'or call our Dhaka support line.'.tr}'),
                      ],
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
