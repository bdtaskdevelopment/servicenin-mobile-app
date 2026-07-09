import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/sn_place.dart';
import '../../../global_widget/sn_map.dart' show SnMapMarker;
import '../../../global_widget/sn_google_map.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/ambulance_controller.dart';
import '../controllers/fare_controller.dart';
import 'place_search_view.dart';

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
            // Search — pickup/destination, pinned at the top.
            GetBuilder<AmbulanceController>(
              builder: (amb) => _AddressPicker(con: amb),
            ),
            // Map — below the search, full road route.
            GetBuilder<AmbulanceController>(
              builder: (amb) => _MapCard(amb: amb),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                children: [
                  _Label('AMBULANCE TYPE'.tr),
                  const SizedBox(height: 10),
                  GetBuilder<FareController>(builder: (c) => _TypeSelector(c: c)),
                  const SizedBox(height: 14),
                  GetBuilder<FareController>(
                      builder: (c) => _EmergencyToggle(c: c)),
                  const SizedBox(height: 14),
                  GetBuilder<FareController>(
                      builder: (c) => _WaitingTimeSelector(c: c)),
                  const SizedBox(height: 14),
                  GetBuilder<FareController>(builder: (c) => _FareCard(c: c)),
                  const SizedBox(height: 14),
                  _PatientCard(c: controller),
                  const SizedBox(height: 18),
                  _Label('PAYMENT METHOD'.tr),
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
                        : Text('Confirm & dispatch'.tr,
                            style: const TextStyle(
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
    final hasRoute = amb.hasTrip && amb.routePoints.length >= 2;
    return SizedBox(
      height: 260,
      child: SnGoogleMap(
        center: p,
        zoom: 14,
        interactive: true,
        fitToRoute: hasRoute,
        route: hasRoute ? amb.routePoints : const [],
        markers: [
          SnMapMarker(p, _green, Icons.my_location_rounded),
          if (amb.dropPlace != null)
            SnMapMarker(d, _red, Icons.location_on_rounded),
        ],
      ),
    );
  }
}

// ── Pickup + destination (address search) — pinned at the top ────────
class _AddressPicker extends StatelessWidget {
  const _AddressPicker({required this.con});
  final AmbulanceController con;

  Future<void> _search(String hint, void Function(SnPlace) onPicked) async {
    final place =
        await Get.to<SnPlace>(() => PlaceSearchView(title: hint));
    if (place != null) onPicked(place);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      padding: const EdgeInsets.fromLTRB(4, 10, 14, 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            splashRadius: 20,
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 18, color: Color(0xFF1A1A1A)),
          ),
          Expanded(
            child: Column(
              children: [
                _AddressRow(
                  dotColor: _green,
                  label: 'PICKUP'.tr,
                  value: con.pickupPlace?.label,
                  loading: con.loadingPickup,
                  onTap: () =>
                      _search('Search pickup location'.tr, con.setPickupPlace),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                ),
                _AddressRow(
                  dotColor: _red,
                  label: 'DESTINATION'.tr,
                  value: con.dropPlace?.label,
                  loading: false,
                  onTap: () => _search('Search destination'.tr, con.setDropPlace),
                ),
              ],
            ),
          ),
          IconButton(
            splashRadius: 20,
            onPressed: con.openBookings,
            tooltip: 'Trip history'.tr,
            icon: const Icon(Icons.history_rounded,
                size: 22, color: Color(0xFF1A1A1A)),
          ),
        ],
      ),
    );
  }
}

class _AddressRow extends StatelessWidget {
  const _AddressRow({
    required this.dotColor,
    required this.label,
    required this.value,
    required this.loading,
    required this.onTap,
  });
  final Color dotColor;
  final String label;
  final String? value;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Container(
              width: 10,
              height: 10,
              decoration:
                  BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF94A3B8),
                        letterSpacing: 0.6)),
                const SizedBox(height: 3),
                if (loading)
                  const SnBone(width: 140, height: 14)
                else
                  Text(value ?? 'Search an address'.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: value == null
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF0F172A))),
              ],
            ),
          ),
          const Icon(Icons.search_rounded, size: 20, color: Color(0xFF64748B)),
        ],
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
      return SnShimmer(
        child: SizedBox(
          height: 116,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (_, _) =>
                const SnBone(width: 132, height: 116, radius: 14),
          ),
        ),
      );
    }
    if (c.types.isEmpty) {
      return Text('No ambulance types available'.tr,
          style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)));
    }
    return FadeInUp(
      from: 18,
      duration: const Duration(milliseconds: 350),
      child: SizedBox(
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
          Expanded(
            child: Text('Emergency dispatch'.tr,
                style: const TextStyle(
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

// ── Expected waiting time ─────────────────────────────────────────────
class _WaitingTimeSelector extends StatelessWidget {
  const _WaitingTimeSelector({required this.c});
  final FareController c;

  static const _presets = [
    {'label': 'No wait', 'minutes': 0},
    {'label': '1 hour', 'minutes': 60},
    {'label': '3 hours', 'minutes': 180},
    {'label': '5 hours', 'minutes': 300},
    {'label': '1 day', 'minutes': 1440},
    {'label': '2 days', 'minutes': 2880},
  ];

  @override
  Widget build(BuildContext context) {
    final freeMin = c.selectedType?.freeWaitMinutes ?? 45;
    final rate = c.selectedType?.waitingFarePerMin ?? 0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDEFF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.hourglass_bottom_rounded,
                  color: Color(0xFF64748B), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Expected waiting time'.tr,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A))),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Text(
                '$freeMin ${'min free'.tr}, then ৳$rate/${'min'.tr}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _presets.map((p) {
              final minutes = p['minutes'] as int;
              final sel = c.waitingMinutes == minutes;
              return GestureDetector(
                onTap: () => c.setWaitingMinutes(minutes),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: sel ? _navy.withValues(alpha: 0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: sel ? _navy : const Color(0xFFE2E8F0)),
                  ),
                  child: Text((p['label'] as String).tr,
                      style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: sel ? _navy : const Color(0xFF334155))),
                ),
              );
            }).toList(),
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
          ? const SnShimmer(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SnBone(width: 90, height: 12),
                      SnBone(width: 50, height: 12),
                    ],
                  ),
                  SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SnBone(width: 110, height: 12),
                      SnBone(width: 46, height: 12),
                    ],
                  ),
                  SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SnBone(width: 80, height: 12),
                      SnBone(width: 56, height: 12),
                    ],
                  ),
                  SizedBox(height: 18),
                  SnBone(width: double.infinity, height: 26, radius: 8),
                ],
              ),
            )
          : f == null
              ? Text('Select pickup & destination to estimate the fare.'.tr,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)))
              : FadeInUp(
                  from: 18,
                  duration: const Duration(milliseconds: 350),
                  child: Column(
                  children: [
                    _row('Distance'.tr, '${f.distanceKm} km'),
                    _row('Base fare'.tr, '৳${f.baseFare}'),
                    _row('${'Mileage'.tr} (৳${f.perKmFare}/km)', '৳${f.mileageCharge}'),
                    if (f.waitingCharge > 0)
                      _row(
                          '${'Waiting'.tr} (${f.estimatedWaitMinutes - f.waitingFreeMinutes} ${'min'.tr})',
                          f.waitingLabel),
                    if (f.emergencyCharge > 0)
                      _row('Emergency'.tr, '৳${f.emergencyCharge}'),
                    if (f.nightCharge > 0) _row('Night'.tr, '৳${f.nightCharge}'),
                    if (f.taxAmount > 0) _row('Tax'.tr, '৳${f.taxAmount}'),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text('ESTIMATED TOTAL'.tr,
                              style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: 0.4)),
                        ),
                        Text(c.payableLabel,
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: _navy)),
                      ],
                    ),
                  ],
                ),
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
          _field('Patient name'.tr, c.patientNameCtrl, TextInputType.text),
          const SizedBox(height: 10),
          _field('Contact phone'.tr, c.phoneCtrl, TextInputType.phone),
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
      return const SnListSkeleton(
        count: 3,
        padding: EdgeInsets.zero,
      );
    }
    return FadeInUp(
      from: 18,
      duration: const Duration(milliseconds: 350),
      child: Column(
      children: c.methods.where((m) => m.enabled).map((m) {
        final sel = m.key == c.selectedMethod;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: () => c.selectMethod(m.key),
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
                ],
              ),
            ),
          ),
        );
      }).toList(),
      ),
    );
  }
}
