import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/support_response.dart';
import '../../support/controllers/support_controller.dart';

const _violet = Color(0xFF7C3AED);
const _tile = Color(0xFFF3EEFC);
const _navy = Color(0xFF0F172A);
const _subtitle = Color(0xFF94A3B8);

/// Training's own skin on the shared [SupportController] — the generic
/// [SupportView] is reused by several other modules with their own themes
/// (see information_support_view.dart / funeral_support_view.dart for the
/// same pattern), so this is a dedicated screen matching this module's
/// mockup (a violet banner + one full-width "Call" card per hotline)
/// instead of restyling the shared screen for everyone.
class TrainingSupportView extends GetView<SupportController> {
  const TrainingSupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
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
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20, color: Color(0xFF1A1A1A)),
                  ),
                  Text('Training Support'.tr,
                      style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: _navy)),
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
                        child: CircularProgressIndicator(
                            strokeWidth: 2.2, color: _violet),
                      ),
                    );
                  }
                  return RefreshIndicator(
                    color: _violet,
                    onRefresh: con.fetch,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _violet,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(Icons.headset_mic_rounded,
                                    color: Colors.white, size: 19),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Call us now for immediate assistance.'.tr,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      height: 1.4),
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
                                  fontSize: 13, color: _subtitle),
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
                                    child: _HotlineCard(
                                      hotline: e.value,
                                      onCall: () => con.call(e.value.number),
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

/// This endpoint always returns the same 3 admin-configured hotline names
/// (Support Center / Admissions / Course Help). There's no Bangla field on
/// [SupportHotline], so this is a substring-matched client-side translation,
/// falling back to the raw label for anything an admin renames.
IconData _hotlineIcon(String label) {
  final l = label.toLowerCase();
  if (l.contains('admission')) return Icons.school_rounded;
  if (l.contains('course')) return Icons.menu_book_rounded;
  return Icons.headset_mic_rounded;
}

String _hotlineLabel(String label) {
  final l = label.toLowerCase();
  if (l.contains('admission')) return 'Admissions'.tr;
  if (l.contains('course')) return 'Course support'.tr;
  if (l.contains('support')) return 'Support Center'.tr;
  return label;
}

class _HotlineCard extends StatelessWidget {
  const _HotlineCard({required this.hotline, required this.onCall});
  final SupportHotline hotline;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
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
                  color: _tile,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(_hotlineIcon(hotline.label),
                    color: _violet, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _hotlineLabel(hotline.label),
                      style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: _navy),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hotline.number,
                      style: const TextStyle(fontSize: 13, color: _subtitle),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton.icon(
              onPressed: onCall,
              style: OutlinedButton.styleFrom(
                foregroundColor: _violet,
                side: const BorderSide(color: _violet, width: 1.2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.call_rounded, size: 16),
              label: Text('Call'.tr,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}
