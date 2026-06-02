import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/schedule_controller.dart';

const _navy = Color(0xFF1E2A4A);
const _orange = AppColors.brandOrange;

class ScheduleAmbulanceView extends GetView<ScheduleController> {
  const ScheduleAmbulanceView({super.key});

  @override
  Widget build(BuildContext context) {
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
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Schedule ambulance',
                          style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                      SizedBox(height: 1),
                      Text('Step 2 of 3 · Patient & schedule',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ],
              ),
            ),
            // v2 banner
            Container(
              width: double.infinity,
              color: const Color(0xFFFFF7E6),
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('● v2',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFB45309))),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pre-scheduling (date/time) is a v2 feature — current bookings API dispatches immediately.',
                      style: TextStyle(
                          fontSize: 12, color: Color(0xFFB45309), height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const _Stepper(),
            Expanded(
              child: GetBuilder<ScheduleController>(
                builder: (con) {
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    children: [
                      const _Label('ROUTE'),
                      const SizedBox(height: 10),
                      _RouteCard(con: con),
                      const SizedBox(height: 18),
                      const _Label('DATE & TIME'),
                      const SizedBox(height: 10),
                      Row(
                        children: List.generate(con.dates.length, (i) {
                          final sel = con.selectedDate == i;
                          final d = con.dates[i];
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  right: i == con.dates.length - 1 ? 0 : 10),
                              child: GestureDetector(
                                onTap: () => con.selectDate(i),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: sel ? _navy : AppColors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: sel
                                            ? _navy
                                            : const Color(0xFFE2E8F0)),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(d.label,
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: sel
                                                  ? Colors.white
                                                  : const Color(0xFF64748B))),
                                      const SizedBox(height: 2),
                                      Text(d.date,
                                          style: TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w800,
                                              color: sel
                                                  ? Colors.white
                                                  : const Color(0xFF0F172A))),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 12),
                      _CardRow(
                        leading: const Icon(Icons.access_time_rounded,
                            color: Color(0xFF334155), size: 22),
                        child: Text(con.time,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A))),
                        trailing: const _ChangeLink(),
                      ),
                      const SizedBox(height: 18),
                      const _Label('AMBULANCE TYPE'),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _navy, width: 1.4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.airport_shuttle_rounded,
                                color: _navy, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(con.ambulanceType,
                                      style: const TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF0F172A))),
                                  const SizedBox(height: 2),
                                  Text(con.ambulanceSub,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF94A3B8))),
                                ],
                              ),
                            ),
                            const _ChangeLink(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      const _Label('PATIENT'),
                      const SizedBox(height: 10),
                      _PatientCard(con: con),
                      const SizedBox(height: 18),
                      const _Label('CONTACT PERSON'),
                      const SizedBox(height: 10),
                      _CardRow(
                        leading: const Icon(Icons.person_outline_rounded,
                            color: Color(0xFF334155), size: 22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('WILL TRAVEL WITH PATIENT',
                                style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF94A3B8),
                                    letterSpacing: 0.5)),
                            const SizedBox(height: 2),
                            Text(con.contactPerson,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _FareCard(con: con),
                    ],
                  );
                },
              ),
            ),
            // Bottom
            _BottomBar(label: 'Confirm schedule', onTap: controller.confirmSchedule),
          ],
        ),
      ),
    );
  }
}

// ── Stepper ─────────────────────────────────────────────────────────
class _Stepper extends StatelessWidget {
  const _Stepper();

  @override
  Widget build(BuildContext context) {
    const steps = ['LOCATIONS', 'SCHEDULE', 'PATIENT', 'CONFIRM'];
    const current = 1; // SCHEDULE active, LOCATIONS done
    return Container(
      color: const Color(0xFFF7F8FA),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: List.generate(steps.length, (i) {
          final done = i < current;
          final active = i == current;
          return Expanded(
            child: Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: done
                            ? const Color(0xFF22C55E)
                            : active
                                ? _navy
                                : const Color(0xFFE2E8F0),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: done
                          ? const Icon(Icons.check,
                              size: 15, color: Colors.white)
                          : Text('${i + 1}',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: active
                                      ? Colors.white
                                      : const Color(0xFF94A3B8))),
                    ),
                  ],
                ),
                if (i != steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      color: done
                          ? const Color(0xFF22C55E)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF94A3B8),
          letterSpacing: 0.6));
}

class _ChangeLink extends StatelessWidget {
  const _ChangeLink();
  @override
  Widget build(BuildContext context) => const Text('Change',
      style: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w700, color: _orange));
}

class _CardRow extends StatelessWidget {
  const _CardRow({required this.leading, required this.child, this.trailing});
  final Widget leading;
  final Widget child;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDEFF2)),
      ),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 12),
          Expanded(child: child),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  const _RouteCard({required this.con});
  final ScheduleController con;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDEFF2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              const SizedBox(height: 4),
              Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                      color: _navy, shape: BoxShape.circle)),
              Container(width: 2, height: 26, color: const Color(0xFFE2E8F0)),
              Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(color: Color(0xFFE11D48))),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('PICKUP',
                    style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF94A3B8))),
                const SizedBox(height: 1),
                Text(con.pickup,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 14),
                const Text('DESTINATION',
                    style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF94A3B8))),
                const SizedBox(height: 1),
                Text(con.destination,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A))),
              ],
            ),
          ),
          const Icon(Icons.share_outlined, color: Color(0xFF94A3B8), size: 20),
        ],
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  const _PatientCard({required this.con});
  final ScheduleController con;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDEFF2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                    color: Color(0xFFE6E7FB), shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(con.patientInitials,
                    style: const TextStyle(
                        color: Color(0xFF4F46E5),
                        fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(con.patientName,
                        style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A))),
                    const SizedBox(height: 2),
                    Text(con.patientInfo,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF94A3B8))),
                  ],
                ),
              ),
              const Text('Switch',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _orange)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Medical note',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B))),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10)),
            child: Text(con.medicalNote,
                style: const TextStyle(
                    fontSize: 12.5, color: Color(0xFF475569), height: 1.4)),
          ),
        ],
      ),
    );
  }
}

class _FareCard extends StatelessWidget {
  const _FareCard({required this.con});
  final ScheduleController con;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _navy,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Estimated fare · ${con.fareDistance} · ${con.ambulanceType}',
                    style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.white.withValues(alpha: 0.8))),
                const SizedBox(height: 2),
                Text(con.estimatedFare,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
              ],
            ),
          ),
          const Text('Breakdown →',
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: _orange)),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          SizedBox(
            width: 54,
            height: 54,
            child: OutlinedButton(
              onPressed: () => Get.back(),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                side: const BorderSide(color: Color(0xFFE2E8F0)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: Color(0xFF334155)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _navy,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
