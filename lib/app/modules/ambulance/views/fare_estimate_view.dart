import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/values/app_colors.dart';
import '../../../global_widget/sn_map.dart';
import '../controllers/ambulance_controller.dart';
import '../controllers/fare_controller.dart';

const _navy = Color(0xFF1E2A4A);
const _red = Color(0xFFE23744);
const _green = Color(0xFF16A34A);

class FareEstimateView extends GetView<FareController> {
  const FareEstimateView({super.key});

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
                      Text('Fare estimate',
                          style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                      SizedBox(height: 1),
                      Text('Cash on completion · No advance',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                children: [
                  // Map + pickup/destination
                  GetBuilder<AmbulanceController>(
                    builder: (amb) => Column(
                      children: [
                        _MapCard(amb: amb),
                        const SizedBox(height: 12),
                        _LocationPicker(con: amb),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const _Label('AMBULANCE TYPE'),
                  const SizedBox(height: 10),
                  GetBuilder<FareController>(builder: (c) => _TypeSelector(c: c)),
                  const SizedBox(height: 14),
                  GetBuilder<FareController>(
                      builder: (c) => _EmergencyToggle(c: c)),
                  const SizedBox(height: 14),
                  GetBuilder<FareController>(builder: (c) => _FareCard(c: c)),
                  const SizedBox(height: 14),
                  _PatientCard(c: controller),
                  const SizedBox(height: 18),
                  const _Label('PAYMENT METHOD'),
                  const SizedBox(height: 12),
                  GetBuilder<FareController>(builder: (c) => _PayList(c: c)),
                ],
              ),
            ),
            // Bottom confirm
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: GetBuilder<FareController>(
                  builder: (c) => ElevatedButton(
                    onPressed: c.booking ? null : c.confirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _navy,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: c.booking
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.4, color: Colors.white),
                          )
                        : const Text('Confirm & dispatch',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
            ),
          ],
        ),
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

// ── Map ─────────────────────────────────────────────────────────────
class _MapCard extends StatelessWidget {
  const _MapCard({required this.amb});
  final AmbulanceController amb;
  @override
  Widget build(BuildContext context) {
    final p = amb.pickupPoint;
    final d = amb.destPoint;
    final mid = LatLng(
        (p.latitude + d.latitude) / 2, (p.longitude + d.longitude) / 2);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 150,
        child: SnMap(
          center: mid,
          zoom: 7.2,
          interactive: false,
          route: [p, d],
          markers: [
            SnMapMarker(p, _green, Icons.my_location_rounded),
            SnMapMarker(d, _red, Icons.location_on_rounded),
          ],
        ),
      ),
    );
  }
}

// ── Pickup + destination ────────────────────────────────────────────
class _LocationPicker extends StatelessWidget {
  const _LocationPicker({required this.con});
  final AmbulanceController con;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEFF2)),
      ),
      child: Column(
        children: [
          _LocBlock(
            dotColor: _green,
            label: 'PICKUP',
            division: con.pickupDivision,
            zilla: con.pickupZilla,
            onDivision: () => _sheet(
              title: 'Pickup division',
              options: con.divisions,
              selected: con.pickupDivision,
              onSelect: con.setPickupDivision,
            ),
            onZilla: () => _sheet(
              title: 'Pickup district',
              options: con.pickupDistricts,
              selected: con.pickupZilla,
              onSelect: con.setPickupZilla,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          _LocBlock(
            dotColor: _red,
            label: 'DESTINATION',
            division: con.dropDivision,
            zilla: con.dropZilla,
            onDivision: () => _sheet(
              title: 'Destination division',
              options: con.divisions,
              selected: con.dropDivision,
              onSelect: con.setDropDivision,
            ),
            onZilla: () => _sheet(
              title: 'Destination district',
              options: con.dropDistricts,
              selected: con.dropZilla,
              onSelect: con.setDropZilla,
            ),
          ),
        ],
      ),
    );
  }

  void _sheet({
    required String title,
    required List<String> options,
    required String selected,
    required void Function(String) onSelect,
  }) {
    if (options.isEmpty) return;
    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        constraints: BoxConstraints(maxHeight: Get.height * 0.7),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 14),
            Text(title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A))),
            const SizedBox(height: 8),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(Get.context!).padding.bottom + 8),
                children: options.map((o) {
                  final sel = o == selected;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    onTap: () {
                      onSelect(o);
                      Get.back();
                    },
                    title: Text(o,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: sel ? FontWeight.w800 : FontWeight.w500,
                            color: sel ? _red : const Color(0xFF334155))),
                    trailing: sel
                        ? const Icon(Icons.check_rounded, color: _red)
                        : null,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocBlock extends StatelessWidget {
  const _LocBlock({
    required this.dotColor,
    required this.label,
    required this.division,
    required this.zilla,
    required this.onDivision,
    required this.onZilla,
  });
  final Color dotColor;
  final String label;
  final String division;
  final String zilla;
  final VoidCallback onDivision;
  final VoidCallback onZilla;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration:
                  BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF94A3B8),
                    letterSpacing: 0.6)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
                child: _DropChip(
                    label: 'Division', value: division, onTap: onDivision)),
            const SizedBox(width: 10),
            Expanded(
                child:
                    _DropChip(label: 'District', value: zilla, onTap: onZilla)),
          ],
        ),
      ],
    );
  }
}

class _DropChip extends StatelessWidget {
  const _DropChip(
      {required this.label, required this.value, required this.onTap});
  final String label;
  final String value;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF94A3B8))),
                  const SizedBox(height: 2),
                  Text(value.isEmpty ? '—' : value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A))),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded,
                size: 20, color: Color(0xFF64748B)),
          ],
        ),
      ),
    );
  }
}

// ── Ambulance type selector ─────────────────────────────────────────
class _TypeSelector extends StatelessWidget {
  const _TypeSelector({required this.c});
  final FareController c;
  @override
  Widget build(BuildContext context) {
    if (c.loadingTypes && c.types.isEmpty) {
      return const SizedBox(
        height: 84,
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2.4, color: _red),
        ),
      );
    }
    if (c.types.isEmpty) {
      return const Text('No ambulance types available',
          style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)));
    }
    return SizedBox(
      height: 116,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: c.types.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final t = c.types[i];
          final sel = t.id == c.selectedType?.id;
          return GestureDetector(
            onTap: () => c.selectType(t.id),
            child: Container(
              width: 188,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: sel ? _navy : const Color(0xFFEDEFF2),
                    width: sel ? 1.8 : 1.2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                            color: _red.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(9)),
                        child: const Icon(Icons.airport_shuttle_rounded,
                            color: _red, size: 18),
                      ),
                      const Spacer(),
                      if (sel)
                        const Icon(Icons.check_circle, size: 18, color: _navy),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(t.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A))),
                  const SizedBox(height: 2),
                  Text('৳${t.baseFare} base · ৳${t.perKmFare}/km',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 11.5, color: Color(0xFF94A3B8))),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Emergency toggle ────────────────────────────────────────────────
class _EmergencyToggle extends StatelessWidget {
  const _EmergencyToggle({required this.c});
  final FareController c;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 4, 8, 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDEFF2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.emergency_share_rounded, color: _red, size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Text('Emergency dispatch',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A))),
          ),
          Switch.adaptive(
            value: c.isEmergency,
            onChanged: c.toggleEmergency,
            activeTrackColor: _red,
            activeThumbColor: Colors.white,
          ),
        ],
      ),
    );
  }
}

// ── Fare breakdown ──────────────────────────────────────────────────
class _FareCard extends StatelessWidget {
  const _FareCard({required this.c});
  final FareController c;
  @override
  Widget build(BuildContext context) {
    final f = c.fare;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDEFF2)),
      ),
      child: c.loadingFare && f == null
          ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: CircularProgressIndicator(strokeWidth: 2.4, color: _red),
              ),
            )
          : f == null
              ? const Text('Select pickup & destination to estimate the fare.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)))
              : Column(
                  children: [
                    _row('Distance', '${f.distanceKm} km'),
                    _row('Base fare', '৳${f.baseFare}'),
                    _row('Mileage (৳${f.perKmFare}/km)', '৳${f.mileageCharge}'),
                    if (f.emergencyCharge > 0)
                      _row('Emergency', '৳${f.emergencyCharge}'),
                    if (f.nightCharge > 0) _row('Night', '৳${f.nightCharge}'),
                    if (f.taxAmount > 0) _row('Tax', '৳${f.taxAmount}'),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                    ),
                    Row(
                      children: [
                        const Expanded(
                          child: Text('ESTIMATED TOTAL',
                              style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: 0.4)),
                        ),
                        Text(f.totalLabel,
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: _navy)),
                      ],
                    ),
                  ],
                ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 13.5, color: Color(0xFF64748B))),
            ),
            Text(value,
                style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A))),
          ],
        ),
      );
}

// ── Patient / contact info ──────────────────────────────────────────
class _PatientCard extends StatelessWidget {
  const _PatientCard({required this.c});
  final FareController c;
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
          _field('Patient name', c.patientNameCtrl, TextInputType.text),
          const SizedBox(height: 10),
          _field('Contact phone', c.phoneCtrl, TextInputType.phone),
        ],
      ),
    );
  }

  Widget _field(String hint, TextEditingController ctrl, TextInputType kb) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: kb,
        decoration: InputDecoration(
          labelText: hint,
          border: InputBorder.none,
          labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
        ),
        style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A)),
      ),
    );
  }
}

// ── Payment methods ─────────────────────────────────────────────────
class _PayList extends StatelessWidget {
  const _PayList({required this.c});
  final FareController c;
  @override
  Widget build(BuildContext context) {
    if (c.loadingMethods && c.methods.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: CircularProgressIndicator(strokeWidth: 2.4, color: _red),
        ),
      );
    }
    return Column(
      children: c.methods.map((m) {
        final sel = m.key == c.selectedMethod;
        final disabled = !m.enabled;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: disabled ? null : () => c.selectMethod(m.key),
            child: Opacity(
              opacity: disabled ? 0.55 : 1,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: sel ? _navy : const Color(0xFFE2E8F0),
                      width: sel ? 1.6 : 1.2),
                ),
                child: Row(
                  children: [
                    Icon(
                        sel
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        size: 20,
                        color: sel ? _navy : const Color(0xFFCBD5E1)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.label,
                              style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A))),
                          const SizedBox(height: 2),
                          Text(m.description,
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF94A3B8))),
                        ],
                      ),
                    ),
                    if (disabled)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(20)),
                        child: const Text('Soon',
                            style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF94A3B8))),
                      ),
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
