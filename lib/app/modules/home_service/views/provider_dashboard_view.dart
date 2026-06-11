import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/provider_controller.dart';

const _darkTeal = Color(0xFF0E7C6B);
const _navy = Color(0xFF1E2A4A);

class ProviderDashboardView extends GetView<ProviderController> {
  const ProviderDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final con = controller;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Teal header + balance
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [_darkTeal, Color(0xFF0B5E52)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 16, 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          splashRadius: 22,
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              size: 20, color: Colors.white),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Provider dashboard'.tr,
                                style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white)),
                            const Text('Jamal Uddin',
                                style: TextStyle(
                                    fontSize: 12, color: Color(0xFFCDEDE6))),
                          ],
                        ),
                        const Spacer(),
                        const Icon(Icons.notifications_none_rounded,
                            color: Colors.white),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(18)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AVAILABLE BALANCE'.tr,
                              style: const TextStyle(
                                  color: Color(0xFFCDEDE6),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5)),
                          const SizedBox(height: 4),
                          Text(con.balance,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text('${'Pending'.tr} ${con.pending}',
                                  style: const TextStyle(
                                      color: Color(0xFFCDEDE6),
                                      fontSize: 12.5)),
                              const SizedBox(width: 18),
                              Text('${'Withdrawn'.tr} ${con.withdrawn}',
                                  style: const TextStyle(
                                      color: Color(0xFFCDEDE6),
                                      fontSize: 12.5)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: con.withdrawEarnings,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: _darkTeal,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text('Withdraw earnings'.tr,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _stat(con.jobsDone, 'Jobs done'.tr),
                const SizedBox(width: 12),
                _stat(con.rating, 'Rating'.tr),
                const SizedBox(width: 12),
                _stat(con.acceptance, 'Acceptance'.tr),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Assigned jobs'.tr,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text('Tap to accept or navigate'.tr,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...con.jobs.map((j) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: _JobCard(job: j, con: con),
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _stat(String value, String label) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFEDEFF2))),
          child: Column(
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A))),
              const SizedBox(height: 2),
              Text(label,
                  style:
                      const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8))),
            ],
          ),
        ),
      );
}

class _JobCard extends StatelessWidget {
  const _JobCard({required this.job, required this.con});
  final ProviderJob job;
  final ProviderController con;

  @override
  Widget build(BuildContext context) {
    final inProgress = job.status == JobStatus.inProgress;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: inProgress ? _darkTeal : const Color(0xFFEDEFF2),
            width: inProgress ? 1.4 : 1.2),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job.title,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A))),
                    const SizedBox(height: 2),
                    Text(job.place,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFFE07A1F))),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                    color: inProgress
                        ? const Color(0xFFFEF3C7)
                        : const Color(0xFFE6E7FB),
                    borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle,
                        size: 7,
                        color: inProgress
                            ? const Color(0xFFD97706)
                            : const Color(0xFF6366F1)),
                    const SizedBox(width: 4),
                    Text(inProgress ? 'In progress'.tr : 'Assigned'.tr,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: inProgress
                                ? const Color(0xFFB45309)
                                : const Color(0xFF4F46E5))),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          Row(
            children: [
              Text(job.price,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0E7C6B))),
              const Spacer(),
              if (inProgress)
                SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: con.navigateJob,
                    icon: const Icon(Icons.location_on_outlined, size: 16),
                    label: Text('Navigate'.tr,
                        style: const TextStyle(
                            fontSize: 13.5, fontWeight: FontWeight.w800)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _navy,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                )
              else ...[
                _ghost('Decline'.tr, const Color(0xFF334155)),
                const SizedBox(width: 10),
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _darkTeal,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('Accept'.tr,
                        style: const TextStyle(
                            fontSize: 13.5, fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _ghost(String label, Color color) => SizedBox(
        height: 40,
        child: OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 13.5, fontWeight: FontWeight.w700, color: color)),
        ),
      );
}
