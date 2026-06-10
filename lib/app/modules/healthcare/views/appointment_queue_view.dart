import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/appointments_controller.dart';

const _green = Color(0xFF16A34A);
const _tile = Color(0xFFD9F7E6);

class AppointmentQueueView extends GetView<AppointmentsController> {
  const AppointmentQueueView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: GetBuilder<AppointmentsController>(
          builder: (con) {
            final a = con.selected;
            if (a == null) return const SizedBox.shrink();
            final upcoming = a.upcoming;
            return Column(
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
                          Text('Appointment status',
                              style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A))),
                          SizedBox(height: 1),
                          Text('Live serial & queue',
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xFF94A3B8))),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      // Doctor + patient
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            border:
                                Border.all(color: const Color(0xFFEDEFF2))),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                  color: _tile,
                                  borderRadius: BorderRadius.circular(14)),
                              alignment: Alignment.center,
                              child: Text(a.doctorInitials,
                                  style: const TextStyle(
                                      color: _green,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(a.doctorName,
                                      style: const TextStyle(
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF0F172A))),
                                  const SizedBox(height: 2),
                                  Text('${a.specialty} · ${a.typeLabel}',
                                      style: const TextStyle(
                                          fontSize: 12.5,
                                          color: Color(0xFF94A3B8))),
                                ],
                              ),
                            ),
                            _StatusPill(upcoming: upcoming),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Serial + queue hero
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Color(0xFF0F7A52), Color(0xFF0B5E3F)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            const Text('YOUR SERIAL',
                                style: TextStyle(
                                    color: Color(0xFFCDEDE0),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.6)),
                            const SizedBox(height: 4),
                            Text(a.serialNo > 0 ? '${a.serialNo}' : '—',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 44,
                                    fontWeight: FontWeight.w800)),
                            const SizedBox(height: 6),
                            if (upcoming)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _heroStat('Now serving', con.nowServingLabel),
                                  Container(
                                    width: 1,
                                    height: 30,
                                    color:
                                        Colors.white.withValues(alpha: 0.2),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 18),
                                  ),
                                  _heroStat('Ahead of you', '${con.aheadCount}'),
                                ],
                              )
                            else
                              Text('Visit completed',
                                  style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.9),
                                      fontSize: 13)),
                          ],
                        ),
                      ),
                      if (upcoming) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(16),
                              border:
                                  Border.all(color: const Color(0xFFEDEFF2))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text('Queue progress',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF0F172A))),
                                  const Spacer(),
                                  Text('~${con.estimatedWaitMin} min wait',
                                      style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                          color: _green)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: _progress(a.serialNo, con.aheadCount),
                                  minHeight: 8,
                                  backgroundColor: const Color(0xFFE9ECF1),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          _green),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                  con.aheadCount == 0
                                      ? 'You are next — please be ready.'
                                      : 'Now serving serial ${con.nowServingLabel} · you are ${con.aheadCount} away.',
                                  style: const TextStyle(
                                      fontSize: 12.5,
                                      color: Color(0xFF64748B))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(16),
                              border:
                                  Border.all(color: const Color(0xFFEDEFF2))),
                          child: Column(
                            children: [
                              _row(Icons.calendar_today_outlined, 'When',
                                  a.whenLabel),
                              const _Div(),
                              _row(
                                  a.isVideo
                                      ? Icons.videocam_outlined
                                      : Icons.location_on_outlined,
                                  'Venue',
                                  a.venueName.isNotEmpty ? a.venueName : '—'),
                              const _Div(),
                              _row(Icons.person_outline_rounded, 'Patient',
                                  a.patientName.isNotEmpty ? a.patientName : '—'),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 22),
                      _PrescriptionsSection(con: con),
                    ],
                  ),
                ),
                if (upcoming)
                  Container(
                    color: AppColors.white,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: OutlinedButton.icon(
                              onPressed: () => _pickAndReschedule(context, con),
                              icon: const Icon(Icons.event_repeat_outlined,
                                  size: 18),
                              label: const Text('Reschedule',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF334155),
                                side:
                                    const BorderSide(color: Color(0xFFE2E8F0)),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: con.openPrescription,
                              icon: const Icon(Icons.description_outlined,
                                  size: 18),
                              label: const Text('Latest Rx',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800)),
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
              ],
            );
          },
        ),
      ),
    );
  }

  double _progress(int mine, int ahead) {
    if (mine <= 0) return 0.04;
    final served = (mine - ahead).clamp(0, mine);
    return (served / mine).clamp(0.04, 1.0);
  }

  Future<void> _pickAndReschedule(
      BuildContext context, AppointmentsController con) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
    );
    if (date == null) return;
    if (!context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (time == null) return;
    final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    final iso = _toIso(dt);
    con.reschedule(iso);
  }

  /// 2026-06-10T10:00:00+06:00
  String _toIso(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}'
        'T${two(d.hour)}:${two(d.minute)}:00+06:00';
  }

  Widget _heroStat(String label, String value) => Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 11.5)),
        ],
      );

  Widget _row(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: _green),
            const SizedBox(width: 12),
            Text(label,
                style:
                    const TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
            const Spacer(),
            Flexible(
              child: Text(value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A))),
            ),
          ],
        ),
      );
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
            color: _tile, borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.circle, size: 7, color: _green),
            SizedBox(width: 4),
            Text('Upcoming',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF15803D))),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: const Color(0xFFEDF1EE),
          borderRadius: BorderRadius.circular(20)),
      child: const Text('Completed',
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF475569))),
    );
  }
}

class _Div extends StatelessWidget {
  const _Div();
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, color: Color(0xFFF1F5F9));
}

// ── Prescriptions by this doctor ────────────────────────────────────
class _PrescriptionsSection extends StatelessWidget {
  const _PrescriptionsSection({required this.con});
  final AppointmentsController con;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Prescriptions from this doctor',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A))),
        const SizedBox(height: 12),
        if (con.loadingPrescriptions && con.doctorPrescriptions.isEmpty)
          const SnListSkeleton(count: 3, padding: EdgeInsets.zero)
        else if (con.doctorPrescriptions.isEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEDEFF2))),
            child: const Text('No prescriptions yet.',
                style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
          )
        else
          ...con.doctorPrescriptions.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEDEFF2))),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                            color: _tile,
                            borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.description_outlined,
                            color: _green, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                      p.diagnosis.isNotEmpty
                                          ? p.diagnosis
                                          : 'Prescription',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF0F172A))),
                                ),
                                Text(p.dateLabel,
                                    style: const TextStyle(
                                        fontSize: 11.5,
                                        color: Color(0xFF94A3B8))),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text('${p.items.length} medicines',
                                style: const TextStyle(
                                    fontSize: 12.5, color: Color(0xFF64748B))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        onPressed: () => con.downloadPrescription(p.id),
                        icon: const Icon(Icons.download_rounded,
                            color: _green, size: 22),
                      ),
                    ],
                  ),
                ),
              )),
      ],
    );
  }
}
