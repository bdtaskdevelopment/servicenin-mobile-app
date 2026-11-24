import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/funeral_response.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/funeral_controller.dart';

const _forest = Color(0xFF2E6A5E);
const _mint = Color(0xFFE7F0ED);
const _lightTile = Color(0xFFF2F3F8);
const _callGreen = Color(0xFF13A051);
const _navy = Color(0xFF0F172A);
const _subtitle = Color(0xFF6B7A99);

class FuneralView extends GetView<FuneralController> {
  const FuneralView({super.key});

  @override
  Widget build(BuildContext context) {
    final con = controller;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
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
                    icon: const Icon(
                      LucideIcons.chevronLeft,
                      size: 22,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Funeral Services'.tr,
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          color: _navy,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Compassionate, dignified support'.tr,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  _HeaderIconButton(
                    icon: LucideIcons.receiptText,
                    bg: _lightTile,
                    iconColor: _navy,
                    onTap: con.openMyRequests,
                  ),
                  const SizedBox(width: 10),
                  _HeaderIconButton(
                    icon: LucideIcons.headset,
                    bg: _mint,
                    iconColor: _forest,
                    onTap: con.openSupport,
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
                          color: _forest,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(LucideIcons.moon,
                                  color: Colors.white, size: 19),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Inna lillahi wa inna ilaihi raji\'un'.tr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'We\'re here to help you through this time with care.'
                                  .tr,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 12.5,
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
                      Text(
                        'Support center'.tr,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: _navy,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...con.hotlines.asMap().entries.map(
                            (e) => Padding(
                              padding: EdgeInsets.only(
                                  bottom: e.key == con.hotlines.length - 1
                                      ? 0
                                      : 10),
                              child: _SupportCard(
                                hotline: e.value,
                                onTap: () => con.call(e.value.number),
                              ),
                            ),
                          ),
                    ],
                    const SizedBox(height: 22),
                    Text(
                      'Available services'.tr,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _navy,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (con.loadingServices && con.services.isEmpty)
                      const SnListSkeleton(padding: EdgeInsets.zero, count: 3)
                    else if (con.services.isEmpty)
                      Text(
                        'No services available right now.'.tr,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF94A3B8),
                        ),
                      )
                    else
                      ...con.services.toList().asMap().entries.map(
                        (e) {
                          final sel = con.selectedServiceId == e.value.id;
                          return FadeInUp(
                            from: 18,
                            duration: const Duration(milliseconds: 350),
                            delay: Duration(milliseconds: 70 * e.key),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GestureDetector(
                                onTap: () =>
                                    con.selectServiceAndRequest(e.value.id),
                                child: _ServiceCard(
                                  service: e.value,
                                  icon: e.key == 0
                                      ? LucideIcons.handHeart
                                      : LucideIcons.users,
                                  selected: sel,
                                ),
                              ),
                            ),
                          );
                        },
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
                    backgroundColor: AppColors.brandOrange,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Request funeral service'.tr,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(LucideIcons.arrowRight, size: 18),
                    ],
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

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.bg,
    required this.iconColor,
    required this.onTap,
  });
  final IconData icon;
  final Color bg;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(11),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 19, color: iconColor),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.service,
    required this.icon,
    required this.selected,
  });
  final FuneralService service;
  final IconData icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: selected ? _mint : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? _forest : const Color(0xFFEDEFF2),
          width: selected ? 1.6 : 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: selected ? _forest : _lightTile,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: selected ? Colors.white : const Color(0xFF94A3B8),
              size: 21,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              service.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: _navy,
              ),
            ),
          ),
          _RadioDot(selected: selected),
        ],
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});
  final bool selected;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? _forest : const Color(0xFFCBD5E1),
          width: 1.6,
        ),
      ),
      alignment: Alignment.center,
      child: selected
          ? Container(
              width: 11,
              height: 11,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: _forest,
              ),
            )
          : null,
    );
  }
}

/// One support-center entry: icon tile, title + number, a full circular
/// green call button. Deliberately calm — dark forest, not the ambulance
/// module's emergency red: this screen is for a grieving family.
class _SupportCard extends StatelessWidget {
  const _SupportCard({required this.hotline, required this.onTap});
  final FuneralHotline hotline;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
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
              color: _mint,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Icon(LucideIcons.headset, color: _forest, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hotline.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: _navy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hotline.number,
                  style: const TextStyle(fontSize: 12, color: _subtitle),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: _callGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.phone,
                  color: Colors.white, size: 19),
            ),
          ),
        ],
      ),
    );
  }
}
