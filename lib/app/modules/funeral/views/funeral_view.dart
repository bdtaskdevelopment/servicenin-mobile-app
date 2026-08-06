import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../core/values/app_url.dart';
import '../../../data/models/response/funeral_response.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../../support/views/support_view.dart';
import '../controllers/funeral_controller.dart';

const _charcoal = Color(0xFF332F2C);
const _grayTile = Color(0xFFE8EAED);
const _subtitle = Color(0xFF6B7A99);

class FuneralView extends GetView<FuneralController> {
  const FuneralView({super.key});

  @override
  Widget build(BuildContext context) {
    final con = controller;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
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
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Funeral Services'.tr,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Compassionate, dignified support'.tr,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: con.openMyRequests,
                    child: const Icon(
                      Icons.receipt_long_outlined,
                      color: Color(0xFF1A1A1A),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Support center — same icon and placement as every other
                  // module. The strip below repeats the numbers inline, which
                  // is what the ambulance module does too.
                  SupportIconButton(
                    title: 'Funeral Support'.tr,
                    endpoint: ApiURL.funeralHotlines,
                  ),
                ],
              ),
            ),
            Expanded(
              child: GetBuilder<FuneralController>(
                builder: (con) => ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  children: [
                    FadeInDown(
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: _charcoal,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Inna lillahi wa inna ilaihi raji\'un'.tr,
                              style: const TextStyle(
                                color: Color(0xFFF4D9A8),
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'We\'re here to help you through this time with care.'
                                  .tr,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 13,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Support center — a family in this situation should be able
                    // to reach a person before doing anything else, so the
                    // numbers sit directly under the banner. Hidden entirely
                    // when the admin has configured none.
                    if (con.hotlines.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          const Icon(Icons.support_agent_rounded,
                              size: 18, color: Color(0xFF0F172A)),
                          const SizedBox(width: 6),
                          Text(
                            'Support center'.tr,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: con.hotlines
                            .asMap()
                            .entries
                            .map(
                              (e) => Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      right: e.key == con.hotlines.length - 1
                                          ? 0
                                          : 10),
                                  child: _SupportCard(
                                    hotline: e.value,
                                    onTap: () => con.call(e.value.number),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 22),
                    Text(
                      'Available services'.tr,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (con.loadingServices && con.services.isEmpty)
                      const SnListSkeleton(padding: EdgeInsets.zero, count: 3)
                    else if (con.services.isEmpty)
                      Text(
                        'No services available right now.'.tr,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF94A3B8),
                        ),
                      )
                    else
                      ...con.services.toList().asMap().entries.map(
                        (e) => FadeInUp(
                          from: 18,
                          duration: const Duration(milliseconds: 350),
                          delay: Duration(milliseconds: 70 * e.key),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () =>
                                  con.selectServiceAndRequest(e.value.id),
                              child: _ServiceCard(service: e.value),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: con.requestService,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _charcoal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Request funeral service'.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service});
  final FuneralService service;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEFF2)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _grayTile,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.volunteer_activism_outlined,
              color: Color(0xFF334155),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                if (service.description.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    service.description,
                    style: const TextStyle(fontSize: 12.5, color: _subtitle),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One tappable support-center number. Deliberately calm — dark neutral, not
/// the ambulance module's emergency red: this screen is for a grieving family.
class _SupportCard extends StatelessWidget {
  const _SupportCard({required this.hotline, required this.onTap});
  final FuneralHotline hotline;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: _charcoal.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _charcoal.withValues(alpha: 0.16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.call_rounded, color: _charcoal, size: 15),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    hotline.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: _charcoal,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              hotline.number,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
