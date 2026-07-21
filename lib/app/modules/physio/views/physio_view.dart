import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/physio_response.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/physio_controller.dart';

const _orange = Color(0xFFB45309);
const _brown = Color(0xFF8A3E12);
const _tile = Color(0xFFFCE6CB);

class PhysioView extends GetView<PhysioController> {
  const PhysioView({super.key});

  @override
  Widget build(BuildContext context) {
    final con = controller;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Physiotherapy'.tr,
                          style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                      const SizedBox(height: 1),
                      Text('Centers & therapists near you'.tr,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: con.openSessions,
                    child: const Icon(Icons.calendar_today_outlined,
                        color: Color(0xFF1A1A1A), size: 22),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GetBuilder<PhysioController>(
                builder: (_) => ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  // Banner
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [_brown, Color(0xFFA84E16)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -8,
                          top: -10,
                          child: Icon(Icons.directions_run_rounded,
                              size: 92,
                              color: Colors.white.withValues(alpha: 0.12)),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Start a pain-free life'.tr,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800)),
                            const SizedBox(height: 8),
                            Text(
                                'Certified physiotherapists · home & in-center sessions'.tr,
                                style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 12.5)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text('Choose a service'.tr,
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A))),
                  const SizedBox(height: 14),
                  if (con.loadingServices && con.services.isEmpty)
                    const SnListSkeleton(count: 2, padding: EdgeInsets.zero)
                  else if (con.services.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text('No services available right now.'.tr,
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xFF94A3B8))),
                    )
                  else
                    FadeInUp(
                      from: 18,
                      duration: const Duration(milliseconds: 350),
                      child: Column(
                        children: con.services
                            .map((s) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: GestureDetector(
                                    onTap: () => con.selectService(s),
                                    child: _ServiceCard(
                                      service: s,
                                      selected: con.selectedService?.id == s.id,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  const SizedBox(height: 24),
                  Text('Physio centers'.tr,
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A))),
                  const SizedBox(height: 2),
                  if (con.selectedService != null)
                    Text(
                        '${con.centers.length} ${'centers for'.tr} ${con.selectedService!.name}',
                        style: const TextStyle(fontSize: 12.5, color: _orange)),
                  const SizedBox(height: 14),
                  if (con.selectedService == null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEDEFF2)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.arrow_upward_rounded,
                              color: _orange.withValues(alpha: 0.6), size: 22),
                          const SizedBox(height: 8),
                          Text('Select a service above to see its centers'.tr,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 13, color: Color(0xFF94A3B8))),
                        ],
                      ),
                    )
                  else if (con.loadingCenters && con.centers.isEmpty)
                    const SnListSkeleton(
                      count: 3,
                      padding: EdgeInsets.zero,
                    )
                  else if (con.centers.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text('No centers found.'.tr,
                          style:
                              const TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                    )
                  else
                    ...con.centers.toList().asMap().entries.map((e) => FadeInUp(
                          from: 18,
                          duration: const Duration(milliseconds: 350),
                          delay: Duration(milliseconds: 70 * e.key),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () => con.openCenter(e.value),
                              child: _CenterCard(center: e.value),
                            ),
                          ),
                        )),
                ],
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
  const _ServiceCard({required this.service, required this.selected});
  final PhysioServiceItem service;
  final bool selected;
  @override
  Widget build(BuildContext context) {
    final fromPrice = [service.centerPricePerDay, service.homePricePerDay]
        .where((p) => p > 0)
        .fold<int?>(null, (min, p) => min == null || p < min ? p : min);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: selected ? _tile : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: selected ? _brown : const Color(0xFFEDEFF2),
              width: selected ? 1.6 : 1.2)),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: selected ? Colors.white : _tile,
                borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.healing_rounded, color: _orange, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A))),
                if (service.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(service.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF94A3B8))),
                ],
                if (fromPrice != null) ...[
                  const SizedBox(height: 4),
                  Text('${'From'.tr} ৳$fromPrice/${'day'.tr}',
                      style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: _orange)),
                ],
              ],
            ),
          ),
          Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              size: 22,
              color: selected ? _brown : const Color(0xFFCBD5E1)),
        ],
      ),
    );
  }
}

class _CenterCard extends StatelessWidget {
  const _CenterCard({required this.center});
  final PhysioCenter center;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEDEFF2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                    color: _tile, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.directions_run_rounded,
                    color: _orange, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(center.name,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A))),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(center.area,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 12.5, color: Color(0xFF94A3B8))),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (center.distance.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(center.distance,
                    style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF16A34A))),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: center.tags.map((t) => _Tag(t)).toList(),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8)),
      child: Text(text,
          style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569))),
    );
  }
}
