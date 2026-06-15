import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/nagarik_controller.dart';
import 'nagarik_view.dart' show ReportCard;

const _orange = Color(0xFFF15A24);

class NagarikReportsView extends GetView<NagarikController> {
  const NagarikReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Color(0xFF1A1A1A),
          ),
        ),
        title: Text(
          'My reports'.tr,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
      ),
      body: GetBuilder<NagarikController>(
        builder: (con) {
          if (con.loadingGrievances && con.grievances.isEmpty) {
            return const SnListSkeleton(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 24));
          }
          if (con.grievances.isEmpty) {
            return _Empty('No grievances filed yet.'.tr);
          }
          return RefreshIndicator(
            color: _orange,
            onRefresh: con.fetchGrievances,
            child: FadeInUp(
              from: 18,
              duration: const Duration(milliseconds: 350),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
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
        },
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 140),
        Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF94A3B8),
            ),
          ),
        ),
      ],
    );
  }
}
