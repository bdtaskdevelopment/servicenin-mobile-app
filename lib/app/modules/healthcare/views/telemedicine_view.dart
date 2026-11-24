import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/healthcare_response.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/telemedicine_controller.dart';

const _teal = Color(0xFF0D9383);
const _tealTile = Color(0xFFE6F5F4);
const _amberTint = Color(0xFFFFF4DE);
const _amberText = Color(0xFFB86E00);
const _green = Color(0xFF12A14F);

class TelemedicineView extends GetView<TelemedicineController> {
  const TelemedicineView({super.key});

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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Telemedicine Call Center'.tr,
                          style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                      const SizedBox(height: 1),
                      Text('Call or WhatsApp a support desk directly'.tr,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: GetBuilder<TelemedicineController>(
                builder: (con) {
                  if (con.loading && con.desks.isEmpty) {
                    return const SnListSkeleton(count: 4);
                  }
                  if (con.desks.isEmpty) {
                    return Center(
                      child: Text('No support desk available.'.tr,
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xFF94A3B8))),
                    );
                  }
                  return RefreshIndicator(
                    color: _teal,
                    onRefresh: con.fetchDesks,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: con.desks.length,
                      itemBuilder: (_, i) => FadeInUp(
                        from: 18,
                        duration: const Duration(milliseconds: 300),
                        delay: Duration(milliseconds: 60 * i),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _DeskCard(desk: con.desks[i], con: con),
                        ),
                      ),
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

class _DeskCard extends StatelessWidget {
  const _DeskCard({required this.desk, required this.con});
  final TelemedicineSupport desk;
  final TelemedicineController con;

  @override
  Widget build(BuildContext context) {
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
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: _tealTile, borderRadius: BorderRadius.circular(12)),
                child: const Icon(LucideIcons.headset, color: _teal, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(desk.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A))),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color:
                        desk.isOpenNow ? const Color(0xFFE7F6ED) : _amberTint,
                    borderRadius: BorderRadius.circular(20)),
                child: Text(desk.isOpenNow ? 'Open now'.tr : 'Closed'.tr,
                    style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: desk.isOpenNow ? _green : _amberText)),
              ),
            ],
          ),
          if (desk.note.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(desk.note,
                style: const TextStyle(
                    fontSize: 12.5, color: Color(0xFF64748B), height: 1.4)),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              if (desk.phone.isNotEmpty)
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: OutlinedButton.icon(
                      onPressed: () => con.call(desk.phone),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _teal,
                        side: const BorderSide(color: _teal),
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
              if (desk.phone.isNotEmpty && desk.whatsappUrl.isNotEmpty)
                const SizedBox(width: 10),
              if (desk.whatsappUrl.isNotEmpty)
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: ElevatedButton.icon(
                      onPressed: () => con.openWhatsApp(desk.whatsappUrl),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _green,
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
          ),
        ],
      ),
    );
  }
}
