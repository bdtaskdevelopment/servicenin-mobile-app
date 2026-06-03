import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
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
            final upcoming = a.status == ApptStatus.upcoming;
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
                        border: Border.all(color: const Color(0xFFEDEFF2))),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                              color: a.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14)),
                          alignment: Alignment.center,
                          child: Text(a.initials,
                              style: TextStyle(
                                  color: a.color,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(a.name,
                                  style: const TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A))),
                              const SizedBox(height: 2),
                              Text('${a.specialty} · for ${a.relation}',
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
                        Text(a.token ?? '—',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 44,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        if (upcoming)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _heroStat('Now serving', a.nowServing),
                              Container(
                                width: 1,
                                height: 30,
                                color: Colors.white.withValues(alpha: 0.2),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 18),
                              ),
                              _heroStat('Ahead of you', '${a.ahead}'),
                            ],
                          )
                        else
                          Text('Visit completed',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 13)),
                      ],
                    ),
                  ),
                  if (upcoming) ...[
                    const SizedBox(height: 14),
                    // Queue progress
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
                              Text('~${a.ahead * 5} min wait',
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
                              value: _progress(a),
                              minHeight: 8,
                              backgroundColor: const Color(0xFFE9ECF1),
                              valueColor:
                                  const AlwaysStoppedAnimation<Color>(_green),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                              a.nowServing == '—'
                                  ? 'Queue starts soon — you\'ll be notified as it moves.'
                                  : 'Now serving serial ${a.nowServing} · you are ${a.ahead} away.',
                              style: const TextStyle(
                                  fontSize: 12.5,
                                  color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Details
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
                          _row(Icons.calendar_today_outlined, 'When', a.when),
                          const _Div(),
                          _row(a.icon, 'Venue', a.venue),
                          const _Div(),
                          _row(Icons.person_outline_rounded, 'Patient',
                              a.relation),
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
                          onPressed: () => _showReschedule(con),
                          icon: const Icon(Icons.event_repeat_outlined,
                              size: 18),
                          label: const Text('Reschedule',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF334155),
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
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
                          onPressed: () {},
                          icon: const Icon(Icons.call_outlined, size: 18),
                          label: const Text('Call chamber',
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

  double _progress(Appointment a) {
    final now = int.tryParse(a.nowServing) ?? 0;
    final mine = int.tryParse(a.token ?? '') ?? 1;
    if (mine <= 0) return 0;
    final v = now / mine;
    return v.clamp(0.04, 1.0);
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
                  color: Colors.white.withValues(alpha: 0.85), fontSize: 11.5)),
        ],
      );

  Widget _row(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: _green),
            const SizedBox(width: 12),
            Text(label,
                style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
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

// ── Past prescriptions ──────────────────────────────────────────────
class _PrescriptionsSection extends StatelessWidget {
  const _PrescriptionsSection({required this.con});
  final AppointmentsController con;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Past prescriptions',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A))),
            const Spacer(),
            GestureDetector(
              onTap: con.openPrescription,
              child: const Text('See all →',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _green)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...con.prescriptions.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: con.openPrescription,
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
                                  child: Text('${p.doctor} · ${p.specialty}',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF0F172A))),
                                ),
                                Text(p.date,
                                    style: const TextStyle(
                                        fontSize: 11.5,
                                        color: Color(0xFF94A3B8))),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(p.summary,
                                style: const TextStyle(
                                    fontSize: 12.5,
                                    height: 1.35,
                                    color: Color(0xFF64748B))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.chevron_right_rounded,
                          color: Color(0xFF94A3B8)),
                    ],
                  ),
                ),
              ),
            )),
      ],
    );
  }
}

// ── Reschedule bottom sheet ─────────────────────────────────────────
void _showReschedule(AppointmentsController con) {
  Get.bottomSheet(
    _RescheduleSheet(con: con),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

class _RescheduleSheet extends StatefulWidget {
  const _RescheduleSheet({required this.con});
  final AppointmentsController con;
  @override
  State<_RescheduleSheet> createState() => _RescheduleSheetState();
}

class _RescheduleSheetState extends State<_RescheduleSheet> {
  int _date = 0;
  int _time = 0;

  @override
  Widget build(BuildContext context) {
    final con = widget.con;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(height: 18),
          const Text('Reschedule appointment',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          Text(con.selected?.name ?? '',
              style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
          const SizedBox(height: 18),
          const _SheetLabel('NEW DATE'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(con.rescheduleDates.length, (i) {
              final sel = _date == i;
              return GestureDetector(
                onTap: () => setState(() => _date = i),
                child: _chip(con.rescheduleDates[i], sel),
              );
            }),
          ),
          const SizedBox(height: 16),
          const _SheetLabel('NEW TIME'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(con.rescheduleTimes.length, (i) {
              final sel = _time == i;
              return GestureDetector(
                onTap: () => setState(() => _time = i),
                child: _chip(con.rescheduleTimes[i], sel),
              );
            }),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () => con.reschedule(
                  con.rescheduleDates[_date], con.rescheduleTimes[_time]),
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Confirm new time',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, bool sel) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: sel ? _green : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: sel ? _green : const Color(0xFFE2E8F0)),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: sel ? Colors.white : const Color(0xFF334155))),
      );
}

class _SheetLabel extends StatelessWidget {
  const _SheetLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF94A3B8),
          letterSpacing: 0.6));
}
