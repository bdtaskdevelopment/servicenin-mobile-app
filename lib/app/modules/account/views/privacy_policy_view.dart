import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
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
                  Text('Privacy policy'.tr,
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
                        const Icon(Icons.verified_user_outlined,
                            size: 18, color: Color(0xFF4F46E5)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                              'One ServiceNin ID, one privacy promise. Last updated 1 June 2026.'.tr,
                              style: const TextStyle(
                                  fontSize: 12.5,
                                  height: 1.45,
                                  color: Color(0xFF475569))),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _Section(
                    title: 'What we collect'.tr,
                    body:
                        'Your name, phone number, email and NID verification status, plus the service requests you make across all 12 ServiceNin modules.'.tr,
                  ),
                  _Section(
                    title: 'How we use it'.tr,
                    body:
                        'To verify your identity once, route bookings to providers, and show a single activity history. We never sell your data to third parties.'.tr,
                  ),
                  _Section(
                    title: 'Sharing with providers'.tr,
                    body:
                        'When you book, only the details a provider needs to serve you — name, location and contact — are shared, for that request only.'.tr,
                  ),
                  _Section(
                    title: 'Your data rights'.tr,
                    body:
                        'You can edit your profile anytime, export your activity, or permanently delete your account from Settings → Account.'.tr,
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
                            text: 'privacy@servicenin.com',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF4F46E5))),
                        TextSpan(
                            text:
                                ' ${'or call our Dhaka support line.'.tr}'),
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

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});
  final String title;
  final String body;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A))),
          const SizedBox(height: 6),
          Text(body,
              style: const TextStyle(
                  fontSize: 13.5, height: 1.5, color: Color(0xFF475569))),
        ],
      ),
    );
  }
}
