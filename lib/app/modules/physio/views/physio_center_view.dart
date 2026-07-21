import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/physio_controller.dart';

const _orange = Color(0xFFB45309);
const _brown = Color(0xFF8A3E12);
const _tile = Color(0xFFFCE6CB);

class PhysioCenterView extends GetView<PhysioController> {
  const PhysioCenterView({super.key});

  @override
  Widget build(BuildContext context) {
    final con = controller;
    final center = con.center;
    if (center == null) {
      return const Scaffold(body: SizedBox.shrink());
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 16, 4),
              child: Row(
                children: [
                  IconButton(
                    splashRadius: 22,
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20, color: Color(0xFF1A1A1A)),
                  ),
                  Text('Center'.tr,
                      style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A))),
                ],
              ),
            ),
            Expanded(
              child: GetBuilder<PhysioController>(
                builder: (con) {
                  final center = con.center;
                  if (center == null) return const SizedBox.shrink();
                  return RefreshIndicator(
                    color: _brown,
                    onRefresh: con.refreshCenter,
                    child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      // Center identity
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                                color: _tile,
                                borderRadius: BorderRadius.circular(16)),
                            child: const Icon(Icons.directions_run_rounded,
                                color: _orange, size: 32),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(center.name,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A))),
                                const SizedBox(height: 4),
                                Text(center.area,
                                    style: const TextStyle(
                                        fontSize: 12.5,
                                        color: Color(0xFF94A3B8))),
                                if (center.contact.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.call_outlined,
                                          size: 14, color: _orange),
                                      const SizedBox(width: 4),
                                      Text(center.contact,
                                          style: const TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w700,
                                              color: _orange)),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (center.tags.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: center.tags.map((t) => _Tag(t)).toList(),
                        ),
                      ],
                      const SizedBox(height: 22),
                      Text('Therapists'.tr,
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                      const SizedBox(height: 2),
                      Text('Pick one to book a session'.tr,
                          style: const TextStyle(fontSize: 12.5, color: _orange)),
                      const SizedBox(height: 14),
                      if (con.loadingCenter && center.therapists.isEmpty)
                        const SnListSkeleton(
                          count: 3,
                          padding: EdgeInsets.zero,
                        )
                      else if (center.therapists.isEmpty)
                        Text('No therapists available.'.tr,
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFF94A3B8)))
                      else
                        ...center.therapists
                            .toList()
                            .asMap()
                            .entries
                            .map((e) => FadeInUp(
                                  from: 18,
                                  duration: const Duration(milliseconds: 350),
                                  delay: Duration(milliseconds: 70 * e.key),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 12),
                                    child: _TherapistCard(
                                        therapist: e.value, con: con),
                                  ),
                                )),
                      if (center.about.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Text('About'.tr,
                            style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A))),
                        const SizedBox(height: 10),
                        Text(center.about,
                            style: const TextStyle(
                                fontSize: 13.5,
                                height: 1.5,
                                color: Color(0xFF475569))),
                      ],
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

class _TherapistCard extends StatelessWidget {
  const _TherapistCard({required this.therapist, required this.con});
  final PhysioTherapist therapist;
  final PhysioController con;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEDEFF2))),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
                color: _tile, borderRadius: BorderRadius.circular(12)),
            alignment: Alignment.center,
            child: Text(therapist.initials,
                style: const TextStyle(
                    color: _orange,
                    fontSize: 15,
                    fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(therapist.name,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text('${therapist.focus} · ${therapist.years}',
                    style: const TextStyle(
                        fontSize: 12.5, color: Color(0xFF94A3B8))),
                const SizedBox(height: 3),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(therapist.fee,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A))),
                    Text(' /${'session'.tr}',
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF94A3B8))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: () => con.bookTherapist(therapist),
              style: ElevatedButton.styleFrom(
                backgroundColor: _brown,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 22),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Book'.tr,
                  style: const
                      TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800)),
            ),
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
          color: _tile, borderRadius: BorderRadius.circular(8)),
      child: Text(text,
          style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: _orange)),
    );
  }
}
