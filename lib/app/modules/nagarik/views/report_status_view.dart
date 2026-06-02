import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/nagarik_controller.dart';

const _orange = Color(0xFFF15A24);
const _tile = Color(0xFFFCE6CB);

class _Step {
  const _Step(this.title, this.time, this.state);
  final String title;
  final String time;
  final int state; // 0 done, 1 current, 2 pending
}

class ReportStatusView extends GetView<NagarikController> {
  const ReportStatusView({super.key});

  @override
  Widget build(BuildContext context) {
    final con = controller;
    final g = con.selectedGrievance ?? con.grievances.first;
    const steps = [
      _Step('Submitted by you', '3 days ago', 0),
      _Step('Acknowledged by Ward 19 office', '3 days ago', 0),
      _Step('Assigned to maintenance crew', '1 day ago', 0),
      _Step('Work in progress', 'Today', 1),
      _Step('Resolved & verified', '', 2),
    ];
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Report status',
                          style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                      Text(g.ref,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.share_outlined,
                      color: Color(0xFF1A1A1A), size: 21),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                children: [
                  // Title row
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                            color: _tile,
                            borderRadius: BorderRadius.circular(12)),
                        child: Icon(g.icon, color: _orange, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(g.title,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A))),
                            const SizedBox(height: 2),
                            Text(g.ward,
                                style: const TextStyle(
                                    fontSize: 12.5,
                                    color: Color(0xFF94A3B8))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StatusPill(status: g.status),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Photo placeholder
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EAED),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.photo_camera_outlined,
                        color: Color(0xFFB0B6C0), size: 34),
                  ),
                  const SizedBox(height: 22),
                  const Text('Progress',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A))),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                    decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: const Color(0xFFEDEFF2))),
                    child: Column(
                      children: List.generate(steps.length, (i) {
                        return _TimelineRow(
                          step: steps[i],
                          isLast: i == steps.length - 1,
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Officer card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: const Color(0xFFEAF1FB),
                        borderRadius: BorderRadius.circular(14)),
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline_rounded,
                            size: 20, color: Color(0xFF2563EB)),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Md. Aslam · Ward 19 Officer',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1D4ED8))),
                              SizedBox(height: 2),
                              Text('Handling your report',
                                  style: TextStyle(
                                      fontSize: 12, color: Color(0xFF60A5FA))),
                            ],
                          ),
                        ),
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.call_rounded,
                              color: Color(0xFF2563EB), size: 20),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.step, required this.isLast});
  final _Step step;
  final bool isLast;
  @override
  Widget build(BuildContext context) {
    final done = step.state == 0;
    final current = step.state == 1;
    final active = done || current;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? _orange : Colors.transparent,
                  border: Border.all(
                      color: active ? _orange : const Color(0xFFCBD5E1),
                      width: 2.4),
                ),
                child: done
                    ? const Icon(Icons.check_rounded,
                        size: 13, color: Colors.white)
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: done ? _orange : const Color(0xFFE2E8F0),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 1, bottom: isLast ? 10 : 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.title,
                      style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: active
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFB0B6C0))),
                  if (step.time.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(step.time,
                        style: TextStyle(
                            fontSize: 12,
                            color: current
                                ? _orange
                                : const Color(0xFF94A3B8))),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final ReportStatus status;
  @override
  Widget build(BuildContext context) {
    final resolved = status == ReportStatus.resolved;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: resolved
              ? const Color(0xFFDCFCE7)
              : const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle,
              size: 7,
              color: resolved
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFD97706)),
          const SizedBox(width: 5),
          Text(resolved ? 'Resolved' : 'In progress',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: resolved
                      ? const Color(0xFF15803D)
                      : const Color(0xFFB45309))),
        ],
      ),
    );
  }
}
