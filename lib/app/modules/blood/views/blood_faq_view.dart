import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/blood_faq_controller.dart';

const _red = Color(0xFFE11D48);

/// Blood-bank FAQ list — GET /api/v1/blood/faqs. Tapping a question opens
/// [BloodFaqDetailView] with the full answer.
class BloodFaqView extends GetView<BloodFaqController> {
  const BloodFaqView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            _Header(),
            Expanded(
              child: GetBuilder<BloodFaqController>(
                builder: (con) {
                  if (con.loading && con.faqs.isEmpty) {
                    return const SnListSkeleton();
                  }
                  return RefreshIndicator(
                    color: _red,
                    onRefresh: con.fetchFaqs,
                    child: con.faqs.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 80),
                                child: Center(
                                  child: Text(
                                    'No FAQs yet — check back soon.'.tr,
                                    style: const TextStyle(
                                        color: Color(0xFF94A3B8)),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                            itemCount: con.faqs.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (_, i) {
                              final f = con.faqs[i];
                              return FadeInUp(
                                from: 14,
                                duration: const Duration(milliseconds: 300),
                                delay: Duration(milliseconds: 50 * i),
                                child: GestureDetector(
                                  onTap: () => con.openFaq(f),
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                          color: const Color(0xFFEDEFF2)),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFDE4E4),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Icon(
                                              Icons.help_outline_rounded,
                                              color: _red,
                                              size: 19),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(f.question,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF0F172A))),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                            Icons.chevron_right_rounded,
                                            color: Color(0xFF94A3B8)),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
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

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(8, 6, 12, 10),
      child: Row(
        children: [
          IconButton(
            splashRadius: 22,
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 20, color: Color(0xFF1A1A1A)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('FAQ'.tr,
                  style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A))),
              const SizedBox(height: 1),
              Text('Common questions answered'.tr,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
            ],
          ),
        ],
      ),
    );
  }
}
