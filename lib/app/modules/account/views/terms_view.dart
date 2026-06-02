import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TermsView extends StatelessWidget {
  const TermsView({super.key});

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
                  const Text('Terms of service',
                      style: TextStyle(
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
                      children: const [
                        Icon(Icons.description_outlined,
                            size: 18, color: Color(0xFF4F46E5)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                              'By using ServiceNin you agree to these terms. Last updated 1 June 2026.',
                              style: TextStyle(
                                  fontSize: 12.5,
                                  height: 1.45,
                                  color: Color(0xFF475569))),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _Section(
                    title: 'Using ServiceNin',
                    body:
                        'One verified ServiceNin ID lets you access all 12 modules. You agree to provide accurate information and to use the services lawfully.',
                  ),
                  _Section(
                    title: 'Bookings & providers',
                    body:
                        'ServiceNin connects you with independent providers (hospitals, technicians, coaching centers and more). Service quality, pricing and timing are the provider\'s responsibility.',
                  ),
                  _Section(
                    title: 'Payments',
                    body:
                        'Most services are pay-after-service or paid directly to the provider. Any online payment fees and refund timelines are shown before you confirm.',
                  ),
                  _Section(
                    title: 'Emergencies',
                    body:
                        'For Blood, Ambulance and other emergency services we route your request as fast as possible, but cannot guarantee availability. In a life-threatening emergency, also call national hotlines.',
                  ),
                  _Section(
                    title: 'Account & termination',
                    body:
                        'You can delete your account anytime from Settings → Account. We may suspend accounts that misuse the platform or violate these terms.',
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                          fontSize: 12.5,
                          height: 1.5,
                          color: Color(0xFF94A3B8)),
                      children: [
                        TextSpan(text: 'Questions? Email '),
                        TextSpan(
                            text: 'legal@servicenin.com',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF4F46E5))),
                        TextSpan(text: ' or call our Dhaka support line.'),
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
