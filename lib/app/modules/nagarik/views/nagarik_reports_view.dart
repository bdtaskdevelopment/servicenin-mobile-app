import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../global_widget/sn_shimmer.dart';
import '../controllers/nagarik_controller.dart';
import 'nagarik_view.dart' show ReportCard, SupportIconButton;

const _green = Color(0xFF15803C);

class NagarikReportsView extends GetView<NagarikController> {
  const NagarikReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FA),
      body: SafeArea(
        child: GetBuilder<NagarikController>(
          builder: (con) => Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(8, 6, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      splashRadius: 22,
                      onPressed: () => Get.back(),
                      icon: const Icon(LucideIcons.chevronLeft,
                          size: 22, color: Color(0xFF0F172A)),
                    ),
                    Text(
                      'My reports'.tr,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const Spacer(),
                    SupportIconButton(con: con),
                  ],
                ),
              ),
              Expanded(
                child: Builder(builder: (_) {
                  if (con.loadingGrievances && con.grievances.isEmpty) {
                    return const SnListSkeleton(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 24));
                  }
                  if (con.grievances.isEmpty) {
                    return _Empty(con: con);
                  }
                  return RefreshIndicator(
                    color: _green,
                    onRefresh: con.fetchGrievances,
                    child: FadeInUp(
                      from: 18,
                      duration: const Duration(milliseconds: 350),
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        children: con.grievances
                            .map(
                              (g) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: GestureDetector(
                                  onTap: () => con.openGrievance(g),
                                  child: ReportCard(report: g),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.con});
  final NagarikController con;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 90),
        Center(
          child: Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _green,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: _green.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6)),
                  ],
                ),
                child: const Icon(LucideIcons.fileText,
                    color: Colors.white, size: 26),
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),
        Center(
          child: Text('No issues reported yet.'.tr,
              style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF334155))),
        ),
        const SizedBox(height: 18),
        Center(
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: con.reportIssue,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF16621),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 22),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.megaphone, size: 18),
                  const SizedBox(width: 8),
                  Text('Report an issue'.tr,
                      style: const TextStyle(
                          fontSize: 14.5, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
