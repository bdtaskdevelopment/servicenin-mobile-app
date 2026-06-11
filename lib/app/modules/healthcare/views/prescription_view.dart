import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/prescription_controller.dart';

const _green = Color(0xFF0F7A52);
const _tile = Color(0xFFD9F7E6);

class PrescriptionView extends GetView<PrescriptionController> {
  const PrescriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: GetBuilder<PrescriptionController>(
          builder: (con) => Column(
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
                      Text('Prescription'.tr,
                          style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                      const SizedBox(height: 1),
                      Text('${con.apptId} · ${con.date}',
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.share_outlined,
                      color: Color(0xFF1A1A1A), size: 22),
                ],
              ),
            ),
            Expanded(
              child: con.loading && con.rx == null
                  ? const _RxSkeleton()
                  : FadeInUp(
                      from: 18,
                      duration: const Duration(milliseconds: 350),
                      child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                children: [
                  // Rx card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                  color: _green,
                                  borderRadius: BorderRadius.circular(12)),
                              alignment: Alignment.center,
                              child: const Text('R',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(con.doctor,
                                      style: const TextStyle(
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF0F172A))),
                                  const SizedBox(height: 2),
                                  Text(con.degree,
                                      style: const TextStyle(
                                          fontSize: 11.5,
                                          color: Color(0xFF94A3B8))),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 5),
                              decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.circle,
                                      size: 7, color: Color(0xFF16A34A)),
                                  const SizedBox(width: 4),
                                  Text('Digital · signed'.tr,
                                      style: const TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF15803D))),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Patient'.tr,
                                      style: const TextStyle(
                                          fontSize: 11.5,
                                          color: Color(0xFF94A3B8))),
                                  const SizedBox(height: 2),
                                  Text(con.patient,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF0F172A))),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Diagnosis'.tr,
                                    style: const TextStyle(
                                        fontSize: 11.5,
                                        color: Color(0xFF94A3B8))),
                                const SizedBox(height: 2),
                                Text(con.diagnosis,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A))),
                              ],
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                        ),
                        ...List.generate(con.meds.length, (i) {
                          final m = con.meds[i];
                          return Padding(
                            padding: EdgeInsets.only(
                                bottom: i == con.meds.length - 1 ? 0 : 14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                      color: _tile,
                                      borderRadius: BorderRadius.circular(8)),
                                  alignment: Alignment.center,
                                  child: Text('${i + 1}',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: _green)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(m.name,
                                          style: const TextStyle(
                                              fontSize: 14.5,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF0F172A))),
                                      const SizedBox(height: 3),
                                      Row(
                                        children: [
                                          Text(m.dose,
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  color: _green)),
                                          Text('  ·  ${m.duration}  ·  ',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF94A3B8))),
                                          Text(m.timing,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFFE07A1F))),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: Text('ADVICE'.tr,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF94A3B8),
                            letterSpacing: 0.6)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, right: 4),
                    child: Text(con.advice,
                        style: const TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFF334155),
                            height: 1.5)),
                  ),
                ],
              ),
              ),
            ),
            // Bottom
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: con.downloading ? null : con.download,
                  icon: const Icon(Icons.download_rounded, size: 20),
                  label: Text(con.downloading ? 'Downloading…'.tr : 'Download PDF'.tr,
                      style:
                          const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}

// ── Loading skeleton for the prescription detail ────────────────────
class _RxSkeleton extends StatelessWidget {
  const _RxSkeleton();
  @override
  Widget build(BuildContext context) {
    return SnShimmer(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE8ECF1)),
            ),
            child: Column(
              children: [
                Row(
                  children: const [
                    SnBone(width: 46, height: 46, radius: 12),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SnBone(width: 150, height: 14),
                          SizedBox(height: 8),
                          SnBone(width: 100, height: 11),
                        ],
                      ),
                    ),
                    SnBone(width: 80, height: 22, radius: 20),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: const [
                    Expanded(child: SnBone(width: 90, height: 12)),
                    Expanded(child: SnBone(width: 90, height: 12)),
                  ],
                ),
                const SizedBox(height: 18),
                ...List.generate(
                  3,
                  (_) => const Padding(
                    padding: EdgeInsets.only(bottom: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SnBone(width: 26, height: 26, radius: 8),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SnBone(width: 160, height: 13),
                              SizedBox(height: 6),
                              SnBone(width: 200, height: 11),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SnBone(width: 80, height: 12),
          const SizedBox(height: 10),
          const SnBone(height: 12),
          const SizedBox(height: 8),
          const SnBone(width: 240, height: 12),
        ],
      ),
    );
  }
}

