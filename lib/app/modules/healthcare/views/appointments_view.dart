import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/healthcare_response.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/appointments_controller.dart';

const _green = Color(0xFF15803D);
const _tile = Color(0xFFD9F7E6);

class AppointmentsView extends GetView<AppointmentsController> {
  const AppointmentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: AppColors.white,
          surfaceTintColor: AppColors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleSpacing: 0,
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 20, color: Color(0xFF1A1A1A)),
          ),
          title: Text('My appointments'.tr,
              style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A))),
          bottom: TabBar(
            indicatorColor: _green,
            indicatorWeight: 2.5,
            labelColor: _green,
            unselectedLabelColor: const Color(0xFF94A3B8),
            labelStyle: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
            unselectedLabelStyle:
                const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
            tabs: [
              Tab(text: 'Upcoming'.tr),
              Tab(text: 'Completed'.tr),
            ],
          ),
        ),
        body: GetBuilder<AppointmentsController>(
          builder: (con) {
            if (con.loading && con.all.isEmpty) {
              return const SnListSkeleton();
            }
            return TabBarView(
              children: [
                _List(items: con.upcoming),
                _List(items: con.completed),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _List extends StatelessWidget {
  const _List({required this.items});
  final List<HcAppointment> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return RefreshIndicator(
        color: _green,
        onRefresh: Get.find<AppointmentsController>().fetchMine,
        child: ListView(
          children: [
            const SizedBox(height: 140),
            Center(
              child: Text('No appointments'.tr,
                  style: const TextStyle(color: Color(0xFF94A3B8))),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: _green,
      onRefresh: Get.find<AppointmentsController>().fetchMine,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: items
            .toList()
            .asMap()
            .entries
            .map((e) => FadeInUp(
                  from: 18,
                  duration: const Duration(milliseconds: 350),
                  delay: Duration(
                      milliseconds: 70 * (e.key < 6 ? e.key : 6)),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () => Get.find<AppointmentsController>()
                          .openAppointment(e.value),
                      child: _ApptCard(
                        appt: e.value,
                        doctorName: Get.find<AppointmentsController>()
                            .doctorNameFor(e.value),
                        doctorInitials: Get.find<AppointmentsController>()
                            .doctorInitialsFor(e.value),
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _ApptCard extends StatelessWidget {
  const _ApptCard({
    required this.appt,
    required this.doctorName,
    required this.doctorInitials,
  });
  final HcAppointment appt;
  final String doctorName;
  final String doctorInitials;

  @override
  Widget build(BuildContext context) {
    final isUpcoming = appt.upcoming;
    final line = [appt.whenLabel, appt.venueName]
        .where((s) => s.isNotEmpty)
        .join(' · ');
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                    color: _tile, borderRadius: BorderRadius.circular(12)),
                alignment: Alignment.center,
                child: Text(doctorInitials,
                    style: const TextStyle(
                        color: _green,
                        fontSize: 15,
                        fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doctorName,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A))),
                    const SizedBox(height: 2),
                    Text('${appt.specialty} · ${appt.typeLabel}',
                        style: const TextStyle(
                            fontSize: 12.5, color: Color(0xFF94A3B8))),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusPill(upcoming: isUpcoming),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: _DashedDivider(),
          ),
          Row(
            children: [
              Icon(
                  appt.isVideo
                      ? Icons.videocam_outlined
                      : Icons.location_on_outlined,
                  size: 16,
                  color: const Color(0xFF94A3B8)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(line,
                    style: const TextStyle(
                        fontSize: 12.5, color: Color(0xFF64748B))),
              ),
              const SizedBox(width: 8),
              if (appt.serialNo > 0)
                Row(
                  children: [
                    Text('Serial '.tr,
                        style: const TextStyle(
                            fontSize: 12.5, color: Color(0xFF94A3B8))),
                    Text('${appt.serialNo}',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A))),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.upcoming});
  final bool upcoming;

  @override
  Widget build(BuildContext context) {
    if (upcoming) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.circle, size: 7, color: Color(0xFF16A34A)),
            const SizedBox(width: 4),
            Text('Upcoming'.tr,
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700, color: _green)),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: const Color(0xFFEDF1EE),
          borderRadius: BorderRadius.circular(20)),
      child: Text('Completed'.tr,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF475569))),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        const dash = 5.0;
        const gap = 4.0;
        final count = (c.maxWidth / (dash + gap)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            count,
            (_) => Container(
              width: dash,
              height: 1,
              color: const Color(0xFFE2E8F0),
            ),
          ),
        );
      },
    );
  }
}
