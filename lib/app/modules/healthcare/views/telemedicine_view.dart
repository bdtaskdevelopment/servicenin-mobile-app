import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/healthcare_response.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/telemedicine_controller.dart';

const _teal = Color(0xFF0F766E);
const _tealTile = Color(0xFFD6F1EE);

class TelemedicineView extends GetView<TelemedicineController> {
  const TelemedicineView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
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
                    color: _tealTile, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.support_agent_rounded,
                    color: _teal, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(desk.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A))),
                    if (desk.timeLabel.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(desk.timeLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: desk.isOpenNow
                        ? const Color(0xFFDCFCE7)
                        : const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(
                    desk.isOpenNow ? 'Open now'.tr : 'Closed'.tr,
                    style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: desk.isOpenNow
                            ? const Color(0xFF15803D)
                            : const Color(0xFFDC2626))),
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
                      icon: const Icon(Icons.call_rounded, size: 17),
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
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.chat_rounded, size: 17),
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
