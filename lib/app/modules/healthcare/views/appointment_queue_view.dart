import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/healthcare_response.dart';
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Appointment status'.tr,
                              style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A))),
                          const SizedBox(height: 1),
                          Text('Live serial & queue'.tr,
                              style: const TextStyle(
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
                              child: Text(con.doctorInitialsFor(a),
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
                                  Text(con.doctorNameFor(a),
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
                      if (upcoming) ...[
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
                              _row(Icons.calendar_today_outlined, 'When'.tr,
                                  a.whenLabel),
                              const _Div(),
                              _row(
                                  a.isVideo
                                      ? Icons.videocam_outlined
                                      : Icons.location_on_outlined,
                                  'Venue'.tr,
                                  a.venueName.isNotEmpty ? a.venueName : '—'),
                              const _Div(),
                              _row(Icons.person_outline_rounded, 'Patient'.tr,
                                  a.patientName.isNotEmpty ? a.patientName : '—'),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 22),
                      _PrescriptionsSection(con: con),
                      if (!upcoming) ...[
                        const SizedBox(height: 22),
                        _ReviewSection(
                            con: con, doctorName: con.doctorNameFor(a)),
                      ],
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
                              onPressed: con.hasPrescriptionForSelected
                                  ? null
                                  : () => _pickAndReschedule(context, con),
                              icon: const Icon(Icons.event_repeat_outlined,
                                  size: 18),
                              label: Text('Reschedule'.tr,
                                  style: const TextStyle(
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
                              label: Text('Latest Rx'.tr,
                                  style: const TextStyle(
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
          children: [
            const Icon(Icons.circle, size: 7, color: _green),
            const SizedBox(width: 4),
            Text('Upcoming'.tr,
                style: const TextStyle(
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
      child: Text('Completed'.tr,
          style: const TextStyle(
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
        Text('Prescriptions from this doctor'.tr,
            style: const TextStyle(
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
            child: Text('No prescriptions yet.'.tr,
                style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
          )
        else
          ...con.doctorPrescriptions.toList().asMap().entries.map((entry) {
            final p = entry.value;
            return FadeInUp(
              from: 18,
              duration: const Duration(milliseconds: 350),
              delay: Duration(
                  milliseconds: 70 * (entry.key < 6 ? entry.key : 6)),
              child: Padding(
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
                                  child: Text('Prescription'.tr,
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
                            Text('${p.items.length} ${'medicines'.tr}',
                                style: const TextStyle(
                                    fontSize: 12.5, color: Color(0xFF64748B))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        tooltip: 'View'.tr,
                        onPressed: () => Get.bottomSheet(
                          _PrescriptionSheet(rx: p, con: con),
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                        ),
                        icon: const Icon(Icons.visibility_outlined,
                            color: Color(0xFF334155), size: 22),
                      ),
                      IconButton(
                        tooltip: 'Download'.tr,
                        onPressed: () => con.downloadPrescription(p.id),
                        icon: const Icon(Icons.download_rounded,
                            color: _green, size: 22),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}

// ── Review section (shown on a completed appointment) ────────────────
class _ReviewSection extends StatefulWidget {
  const _ReviewSection({required this.con, required this.doctorName});
  final AppointmentsController con;
  final String doctorName;

  @override
  State<_ReviewSection> createState() => _ReviewSectionState();
}

class _ReviewSectionState extends State<_ReviewSection> {
  int _rating = 5;
  final _commentCtrl = TextEditingController();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    await widget.con.submitReview(_rating, _commentCtrl.text.trim());
    _commentCtrl.clear();
    setState(() => _rating = 5);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppointmentsController>(
      builder: (con) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEDEFF2))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rate your visit'.tr,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A))),
            const SizedBox(height: 2),
            Text(
                widget.doctorName.isNotEmpty
                    ? '${'How was your appointment with'.tr} ${widget.doctorName}?'
                    : 'How was your appointment?'.tr,
                style: const TextStyle(
                    fontSize: 12.5, color: Color(0xFF94A3B8))),
            const SizedBox(height: 14),
            Row(
              children: List.generate(5, (i) {
                final filled = i < _rating;
                return GestureDetector(
                  onTap: () => setState(() => _rating = i + 1),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Icon(
                        filled
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        size: 34,
                        color: const Color(0xFFF59E0B)),
                  ),
                );
              }),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEDEFF2))),
              child: TextField(
                controller: _commentCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Share your experience…'.tr,
                  hintStyle: const TextStyle(color: Color(0xFFB8C0CC)),
                ),
                style: const TextStyle(
                    fontSize: 14.5, color: Color(0xFF0F172A)),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: con.submittingReview ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: con.submittingReview
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.2, color: Colors.white))
                    : Text('Submit review'.tr,
                        style: const TextStyle(
                            fontSize: 15.5, fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Prescription detail bottom sheet (view + download) ───────────────
class _PrescriptionSheet extends StatelessWidget {
  const _PrescriptionSheet({required this.rx, required this.con});
  final Prescription rx;
  final AppointmentsController con;

  @override
  Widget build(BuildContext context) {
    final vitals = <String>[
      if (rx.bloodPressure.isNotEmpty) 'BP ${rx.bloodPressure}',
      if (rx.pulse.isNotEmpty) 'Pulse ${rx.pulse}',
      if (rx.temperature.isNotEmpty) 'Temp ${rx.temperature}',
      if (rx.weight.isNotEmpty) 'Wt ${rx.weight}',
    ].join('  ·  ');

    return Container(
      constraints: BoxConstraints(maxHeight: Get.height * 0.88),
      decoration: const BoxDecoration(
        color: Color(0xFFF7F8FA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(4)),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                          rx.doctorName.isNotEmpty
                              ? rx.doctorName
                              : 'Prescription'.tr,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                    ),
                    if (rx.dateLabel.isNotEmpty)
                      Text(rx.dateLabel,
                          style: const TextStyle(
                              fontSize: 12.5, color: Color(0xFF94A3B8))),
                  ],
                ),
                if (rx.doctorSpecialty.isNotEmpty ||
                    rx.patientName.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                      [rx.doctorSpecialty, if (rx.patientName.isNotEmpty) 'Patient: ${rx.patientName}']
                          .where((s) => s.isNotEmpty)
                          .join('  ·  '),
                      style: const TextStyle(
                          fontSize: 12.5, color: Color(0xFF64748B))),
                ],
                if (vitals.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(vitals,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF334155))),
                ],
                _block('Chief complaint'.tr, rx.chiefComplaint),
                _block('Diagnosis'.tr, rx.diagnosis),
                _block('Investigations'.tr, rx.investigations),
                if (rx.items.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('Rx'.tr,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: _green)),
                  const SizedBox(height: 8),
                  ...rx.items.asMap().entries.map((e) => _MedRow(
                        index: e.key + 1,
                        item: e.value,
                      )),
                ],
                _block('Advice'.tr, rx.advice),
                if (rx.followUpDate != null) ...[
                  const SizedBox(height: 12),
                  Text(
                      '${'Follow-up'.tr}: ${DateFormat('d MMM yyyy').format(rx.followUpDate!.toLocal())}',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A))),
                ],
              ],
            ),
          ),
          // Download action
          Container(
            color: AppColors.white,
            padding: EdgeInsets.fromLTRB(
                16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: GetBuilder<AppointmentsController>(
                builder: (c) => ElevatedButton.icon(
                  onPressed: c.downloading
                      ? null
                      : () => c.downloadPrescription(rx.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: c.downloading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.2, color: Colors.white))
                      : const Icon(Icons.download_rounded, size: 20),
                  label: Text('Download PDF'.tr,
                      style: const TextStyle(
                          fontSize: 15.5, fontWeight: FontWeight.w800)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _block(String label, String value) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.4)),
          const SizedBox(height: 3),
          Text(value,
              style: const TextStyle(
                  fontSize: 14, height: 1.45, color: Color(0xFF334155))),
        ],
      ),
    );
  }
}

class _MedRow extends StatelessWidget {
  const _MedRow({required this.index, required this.item});
  final int index;
  final PrescriptionItem item;

  @override
  Widget build(BuildContext context) {
    final name = item.tradeName.isNotEmpty ? item.tradeName : item.genericName;
    final subtitle = [item.strength, item.form]
        .where((s) => s.isNotEmpty)
        .join(' ');
    final schedule = [item.dosage, item.frequency, item.duration]
        .where((s) => s.isNotEmpty)
        .join('  ·  ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$index. ${name.isNotEmpty ? name : 'Medicine'}'
              '${subtitle.isNotEmpty ? '  ($subtitle)' : ''}',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A))),
          if (schedule.isNotEmpty) ...[
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(schedule,
                  style: const TextStyle(
                      fontSize: 12.5, color: Color(0xFF64748B))),
            ),
          ],
        ],
      ),
    );
  }
}
