import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/values/app_colors.dart';
import '../../../global_widget/sn_map.dart';
import '../controllers/blood_controller.dart';
import '../controllers/need_blood_controller.dart';

const _red = Color(0xFFE11D48);

class NeedBloodView extends GetView<NeedBloodController> {
  const NeedBloodView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            _Header(),
            Expanded(
              child: GetBuilder<NeedBloodController>(
                builder: (con) {
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                    children: [
                      _SectionLabel('BLOOD GROUP NEEDED'.tr),
                      const SizedBox(height: 12),
                      _GroupGrid(con: con),
                      const SizedBox(height: 22),
                      _SectionLabel('UNITS NEEDED'.tr),
                      const SizedBox(height: 12),
                      _UnitsCard(con: con),
                      const SizedBox(height: 22),
                      _SectionLabel('URGENCY'.tr),
                      const SizedBox(height: 12),
                      _UrgencyRow(con: con),
                      const SizedBox(height: 22),
                      _SectionLabel('WHEN NEEDED'.tr),
                      const SizedBox(height: 12),
                      _TapCard(
                        icon: Icons.calendar_today_outlined,
                        label: 'DATE & TIME'.tr,
                        value: con.neededDate,
                        onTap: () => _pickDate(context, con),
                      ),
                      const SizedBox(height: 22),
                      _SectionLabel('HOSPITAL'.tr),
                      const SizedBox(height: 12),
                      _LabeledInput(
                        label: 'HOSPITAL NAME'.tr,
                        controller: con.hospitalName,
                        hint: 'e.g. Dhaka Medical College Hospital'.tr,
                      ),
                      const SizedBox(height: 12),
                      _LabeledInput(
                        label: 'HOSPITAL ADDRESS'.tr,
                        controller: con.hospitalAddress,
                        hint: 'Area, city, postcode'.tr,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      _LocationCard(con: con),
                      const SizedBox(height: 22),
                      _SectionLabel('ALERT DONORS WITHIN'.tr),
                      const SizedBox(height: 12),
                      _RadiusRow(con: con),
                      const SizedBox(height: 22),
                      _SectionLabel('CONTACT DETAILS'.tr),
                      const SizedBox(height: 12),
                      _LabeledInput(
                        label: 'NAME'.tr,
                        controller: con.name,
                        hint: 'Full name'.tr,
                      ),
                      const SizedBox(height: 12),
                      _LabeledInput(
                        label: 'EMAIL'.tr,
                        controller: con.email,
                        hint: 'you@example.com',
                        keyboard: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      _LabeledInput(
                        label: 'PHONE NUMBER'.tr,
                        controller: con.phone,
                        hint: '01XXXXXXXXX',
                        keyboard: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      _LabeledInput(
                        label: 'ADDRESS'.tr,
                        controller: con.address,
                        hint: 'House, road, area, city'.tr,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 22),
                      _SectionLabel('DESCRIPTION'.tr),
                      const SizedBox(height: 12),
                      _InputCard(
                        controller: con.description,
                        hint:
                            'Patient condition, donor instructions, anything else…'.tr,
                        maxLines: 4,
                      ),
                    ],
                  );
                },
              ),
            ),
            // ── Broadcast button ────────────────────────────────
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: controller.broadcast,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _red,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Broadcast request →'.tr,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ──────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF7F8FA),
      padding: const EdgeInsets.fromLTRB(8, 6, 12, 10),
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
              Text('Request blood'.tr,
                  style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A))),
              const SizedBox(height: 1),
              Text('Broadcast to nearby donors'.tr,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Color(0xFF94A3B8),
        letterSpacing: 0.8,
      ),
    );
  }
}

// ── Blood group grid ────────────────────────────────────────────────
class _GroupGrid extends StatelessWidget {
  const _GroupGrid({required this.con});
  final NeedBloodController con;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.7,
      children: NeedBloodController.groups.map((g) {
        final sel = con.group == g;
        return GestureDetector(
          onTap: () => con.setGroup(g),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: sel ? _red : AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: sel ? _red : const Color(0xFFE2E8F0),
              ),
            ),
            child: Text(g,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: sel ? Colors.white : const Color(0xFF1E293B))),
          ),
        );
      }).toList(),
    );
  }
}

// ── Units card ──────────────────────────────────────────────────────
class _UnitsCard extends StatelessWidget {
  const _UnitsCard({required this.con});
  final NeedBloodController con;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDEFF2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text('Bags of blood'.tr,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A))),
          ),
          _stepBtn(Icons.remove_rounded, con.decUnits, filled: false),
          SizedBox(
            width: 44,
            child: Text('${con.units}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A))),
          ),
          _stepBtn(Icons.add_rounded, con.incUnits, filled: true),
        ],
      ),
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback onTap, {required bool filled}) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: filled ? _red : AppColors.white,
          shape: BoxShape.circle,
          border: filled ? null : Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Icon(icon,
            size: 20, color: filled ? Colors.white : const Color(0xFF334155)),
      ),
    );
  }
}

// ── Urgency row ─────────────────────────────────────────────────────
class _UrgencyRow extends StatelessWidget {
  const _UrgencyRow({required this.con});
  final NeedBloodController con;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: BloodSeverity.values.map((s) {
        final sel = con.severity == s;
        return Expanded(
          child: Padding(
            padding:
                EdgeInsets.only(right: s == BloodSeverity.routine ? 0 : 12),
            child: GestureDetector(
              onTap: () => con.setSeverity(s),
              child: Container(
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: sel ? s.bg : AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: sel ? s.color : const Color(0xFFE2E8F0),
                    width: sel ? 1.6 : 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration:
                          BoxDecoration(color: s.color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(s.label,
                        style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: sel ? s.color : const Color(0xFF334155))),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Alert radius row ────────────────────────────────────────────────
class _RadiusRow extends StatelessWidget {
  const _RadiusRow({required this.con});
  final NeedBloodController con;

  @override
  Widget build(BuildContext context) {
    final options = NeedBloodController.radiusOptions;
    return Row(
      children: options.map((km) {
        final sel = con.radiusKm == km;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: km == options.last ? 0 : 10),
            child: GestureDetector(
              onTap: () => con.setRadius(km),
              child: Container(
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: sel ? _red : AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: sel ? _red : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Text(con.radiusLabel(km),
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: sel ? Colors.white : const Color(0xFF334155))),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Date picker ─────────────────────────────────────────────────────
Future<void> _pickDate(BuildContext context, NeedBloodController con) async {
  final now = DateTime.now();
  final picked = await showDatePicker(
    context: context,
    initialDate: now,
    firstDate: now,
    lastDate: now.add(const Duration(days: 60)),
    builder: (ctx, child) => Theme(
      data: Theme.of(ctx).copyWith(
        colorScheme: const ColorScheme.light(primary: _red),
      ),
      child: child!,
    ),
  );
  if (picked != null) {
    con.setNeeded(picked);
  }
}

// ── Hospital location (map + GPS coordinates) ───────────────────────
class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.con});
  final NeedBloodController con;

  @override
  Widget build(BuildContext context) {
    final point = LatLng(con.lat, con.lng);
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDEFF2)),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 130,
              child: SnMap(
                center: point,
                zoom: 14,
                interactive: false,
                markers: [
                  SnMapMarker(point, _red, Icons.local_hospital_rounded),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
            child: Row(
              children: [
                const Icon(Icons.my_location_rounded,
                    size: 16, color: Color(0xFF16A34A)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'GPS · ${con.lat.toStringAsFixed(4)}, ${con.lng.toStringAsFixed(4)}',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B)),
                  ),
                ),
                Text('Auto-detected'.tr,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF16A34A))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tappable card (date) ────────────────────────────────────────────
class _TapCard extends StatelessWidget {
  const _TapCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEDEFF2)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFFDE4E4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: _red),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF94A3B8),
                          letterSpacing: 0.5)),
                  const SizedBox(height: 3),
                  Text(value,
                      style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A))),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}

// ── Input card (meeting address / description) ──────────────────────
class _InputCard extends StatelessWidget {
  const _InputCard({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDEFF2)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A)),
        decoration: InputDecoration(
          isDense: true,
          hintText: hint,
          hintStyle: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFFB6C0CC)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

// ── Labeled input (name / email / phone / address) ──────────────────
class _LabeledInput extends StatelessWidget {
  const _LabeledInput({
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboard,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboard;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDEFF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.5)),
          TextField(
            controller: controller,
            keyboardType: keyboard,
            maxLines: maxLines,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFB6C0CC)),
            ),
          ),
        ],
      ),
    );
  }
}
