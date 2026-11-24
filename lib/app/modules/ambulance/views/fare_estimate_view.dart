import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/helpers/app_helper.dart';
import '../../../core/values/app_colors.dart';
import '../../../data/models/response/ambulance_response.dart';
import '../../../data/models/sn_place.dart';
import '../../../global_widget/sn_map.dart' show SnMapMarker;
import '../../../global_widget/sn_google_map.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../../../routes/app_pages.dart';
import '../controllers/ambulance_controller.dart';
import '../controllers/fare_controller.dart';
import 'place_search_view.dart';

const _red = Color(0xFFE4484D);
const _redTint = Color(0xFFFFEFEF);
const _orange = Color(0xFFF16621);
const _blue = Color(0xFF1D6FD9);
const _blueTint = Color(0xFFE9F1FD);
const _green = Color(0xFF12A14F);
const _amber = Color(0xFFFFF4DE);
const _amberText = Color(0xFFB45309);
const _navy = Color(0xFF0F172A);
const _grayField = Color(0xFFF4F5FA);

class FareEstimateView extends GetView<FareController> {
  const FareEstimateView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(8, 6, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    splashRadius: 22,
                    onPressed: () => Get.back(),
                    icon: const Icon(LucideIcons.chevronLeft,
                        size: 22, color: Color(0xFF1A1A1A)),
                  ),
                  Expanded(
                    child: Text('Book ambulance'.tr,
                        style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: _navy)),
                  ),
                  GestureDetector(
                    onTap: () => Get.toNamed(Routes.AMBULANCE_SUPPORT),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: _redTint,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(LucideIcons.headset,
                          size: 19, color: _red),
                    ),
                  ),
                ],
              ),
            ),
            // Map fills the top of the screen; the pickup/destination
            // search card floats on top of it. Collapsed while the keyboard
            // is open (e.g. typing the patient name/phone below) so those
            // fields have room to scroll into view instead of being pushed
            // off-screen under the keyboard.
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(),
              height: MediaQuery.of(context).viewInsets.bottom > 0
                  ? 0
                  : MediaQuery.of(context).size.height * 0.4,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: GetBuilder<AmbulanceController>(
                      builder: (amb) => _MapCard(amb: amb),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: GetBuilder<AmbulanceController>(
                      builder: (amb) => _AddressPicker(con: amb),
                    ),
                  ),
                ],
              ),
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
                  GetBuilder<FareController>(
                      builder: (c) => c.fare == null
                          ? const SizedBox.shrink()
                          : _FareCard(c: c)),
                  const SizedBox(height: 14),
                  _PatientCard(c: controller),
                  const SizedBox(height: 18),
                  _Label('PAYMENT METHOD'.tr),
                  const SizedBox(height: 12),
                  GetBuilder<FareController>(builder: (c) => _PayList(c: c)),
                ],
              ),
            ),
            // Bottom bar: a circular "booking history" icon button beside
            // the large orange "Confirm & dispatch" button.
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: GetBuilder<AmbulanceController>(
                builder: (amb) => GetBuilder<FareController>(
                  builder: (c) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (c.fare == null) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.info,
                                  size: 16, color: Color(0xFF94A3B8)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                    'Select pickup & destination to estimate the fare.'
                                        .tr,
                                    style: const TextStyle(
                                        fontSize: 12.5,
                                        color: Color(0xFF64748B))),
                              ),
                            ],
                          ),
                        ),
                      ],
                      Row(
                        children: [
                          GestureDetector(
                            onTap: amb.openBookings,
                            child: Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: const Color(0xFFCBD5E1)),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(LucideIcons.history,
                                  size: 21, color: _navy),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 54,
                              child: ElevatedButton(
                                onPressed: (c.booking || amb.loadingPickup)
                                    ? null
                                    : c.confirm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _orange,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  disabledBackgroundColor:
                                      _orange.withValues(alpha: 0.5),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(14)),
                                ),
                                child: c.booking
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2.4,
                                            color: Colors.white),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Flexible(
                                            child: Text(
                                                amb.loadingPickup
                                                    ? 'Finding your location…'
                                                        .tr
                                                    : 'Confirm & dispatch'.tr,
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w800)),
                                          ),
                                          if (!amb.loadingPickup) ...[
                                            const SizedBox(width: 8),
                                            const Icon(LucideIcons.arrowRight,
                                                size: 18),
                                          ],
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
    return SnGoogleMap(
      center: p,
      zoom: 14,
      interactive: true,
      fitToRoute: hasRoute,
      route: hasRoute ? amb.routePoints : const [],
      routeColor: _blue,
      markers: [
        SnMapMarker(p, _blue, Icons.my_location_rounded),
        if (amb.dropPlace != null)
          SnMapMarker(d, _red, Icons.location_on_rounded),
      ],
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 14,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            _AddressField(
              label: 'PICKUP'.tr,
              icon: Container(
                width: 10,
                height: 10,
                decoration:
                    const BoxDecoration(color: _blue, shape: BoxShape.circle),
              ),
              value: con.pickupPlace?.label,
              placeholder: 'Your location'.tr,
              loading: con.loadingPickup,
              valueColor: _navy,
              trailing: _SearchTile(
                onTap: () => _search(
                    'Search pickup location'.tr, con.setPickupPlace),
              ),
              onTap: () =>
                  _search('Search pickup location'.tr, con.setPickupPlace),
            ),
            const _AddressConnector(),
            _AddressField(
              icon: const Icon(LucideIcons.mapPin, size: 18, color: _red),
              value: con.dropPlace?.label,
              placeholder: 'Choose destination'.tr,
              loading: false,
              trailing: _SearchTile(
                onTap: () =>
                    _search('Search destination'.tr, con.setDropPlace),
              ),
              onTap: () => _search('Search destination'.tr, con.setDropPlace),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchTile extends StatelessWidget {
  const _SearchTile({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFFF2F3F8),
          borderRadius: BorderRadius.circular(9),
        ),
        alignment: Alignment.center,
        child: const Icon(LucideIcons.search, size: 16, color: Color(0xFF64748B)),
      ),
    );
  }
}

/// The short dotted line + hairline divider linking the pickup and
/// destination fields — the familiar "route" accent from map apps.
class _AddressConnector extends StatelessWidget {
  const _AddressConnector();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 18,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    3,
                    (_) => Container(
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(
                          color: Color(0xFF94A3B8), shape: BoxShape.circle),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child:
                  Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressField extends StatelessWidget {
  const _AddressField({
    required this.icon,
    required this.value,
    required this.placeholder,
    required this.loading,
    required this.onTap,
    this.label,
    this.valueColor,
    this.trailing,
  });
  final String? label;
  final Widget icon;
  final String? value;
  final String placeholder;
  final bool loading;
  final VoidCallback onTap;
  final Color? valueColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  SizedBox(width: 20, child: Center(child: icon)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: loading
                        ? const SnBone(width: 140, height: 14)
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (label != null) ...[
                                Text(label!,
                                    style: const TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF94A3B8),
                                        letterSpacing: 0.4)),
                                const SizedBox(height: 2),
                              ],
                              Text(value ?? placeholder,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: valueColor ??
                                          (value == null
                                              ? const Color(0xFF94A3B8)
                                              : const Color(0xFF0F172A)))),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (trailing != null)
          Padding(padding: const EdgeInsets.only(right: 10), child: trailing),
      ],
    );
  }
}

// ── Ambulance type selector ─────────────────────────────────────────
class _TypeSelector extends StatelessWidget {
  const _TypeSelector({required this.c});
  final FareController c;

  static const _palette = [
    (LucideIcons.ambulance, _red, _redTint),
    (LucideIcons.snowflake, _blue, _blueTint),
  ];

  @override
  Widget build(BuildContext context) {
    if (c.loadingTypes && c.types.isEmpty) {
      return SnShimmer(
        child: SizedBox(
          height: 122,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, __) =>
                const SnBone(width: 150, height: 122, radius: 14),
          ),
        ),
      );
    }
    if (c.types.isEmpty) {
      return Text('No ambulance types available'.tr,
          style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)));
    }
    // The mockup shows exactly 2 full-width cards — matched exactly when
    // the admin has configured 1-2 types. With more than that, this falls
    // back to a smaller horizontally-scrolling row instead of cramming
    // everything into half the screen width.
    final large = c.types.length <= 2;
    final cards = c.types.asMap().entries.map((e) {
      final i = e.key;
      final t = e.value;
      final sel = t.id == c.selectedType?.id;
      final (icon, accent, tint) = _palette[i % _palette.length];
      return _TypeCard(
        t: t,
        sel: sel,
        icon: icon,
        accent: accent,
        tint: tint,
        large: large,
        onTap: () => c.selectType(t.id),
      );
    }).toList();

    return FadeInUp(
      from: 18,
      duration: const Duration(milliseconds: 350),
      child: large
          ? Row(
              children: cards
                  .asMap()
                  .entries
                  .map((e) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                              right: e.key == cards.length - 1 ? 0 : 10),
                          child: e.value,
                        ),
                      ))
                  .toList(),
            )
          : SizedBox(
              height: 122,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: cards.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) => SizedBox(width: 168, child: cards[i]),
              ),
            ),
    );
  }
}

class _TypeCard extends StatelessWidget {
  const _TypeCard({
    required this.t,
    required this.sel,
    required this.icon,
    required this.accent,
    required this.tint,
    required this.large,
    required this.onTap,
  });
  final AmbulanceType t;
  final bool sel;
  final IconData icon;
  final Color accent;
  final Color tint;
  final bool large;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tileSize = large ? 56.0 : 36.0;
    final tileRadius = large ? 16.0 : 10.0;
    final iconSize = large ? 26.0 : 17.0;
    final checkSize = large ? 26.0 : 18.0;
    final checkIconSize = large ? 15.0 : 11.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(large ? 14 : 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: sel ? accent : const Color(0xFFEDEFF2),
              width: sel ? 1.6 : 1.2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: tileSize,
                  height: tileSize,
                  decoration: BoxDecoration(
                      color: sel ? accent : tint,
                      borderRadius: BorderRadius.circular(tileRadius)),
                  child: Icon(icon,
                      color: sel ? Colors.white : accent, size: iconSize),
                ),
                if (sel)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      width: checkSize,
                      height: checkSize,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Icon(LucideIcons.circleCheckBig,
                          color: Colors.white, size: checkIconSize),
                    ),
                  ),
              ],
            ),
            SizedBox(height: large ? 10 : 7),
            Text(t.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: large ? 15.5 : 12.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A))),
            const SizedBox(height: 2),
            Text(
                '${'Starting'.tr} ৳${Helpers.format(t.baseFare)} · ${'PER KM'.tr} ৳${Helpers.format(t.perKmFare)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: large ? 12.5 : 10.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF94A3B8))),
          ],
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
      padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
      decoration: BoxDecoration(
        color: _redTint,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(LucideIcons.siren, color: _red, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text('Emergency dispatch'.tr,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _navy)),
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
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                    color: _amber, borderRadius: BorderRadius.circular(10)),
                alignment: Alignment.center,
                child: const Icon(LucideIcons.hourglass,
                    color: _amberText, size: 17),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Expected waiting time'.tr,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _navy)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 44),
            child: Text(
                '${'First'.tr} $freeMin ${'min free, then per minute'.tr} ৳${Helpers.format(rate)}',
                style: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8))),
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
                    color: sel ? _red : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: sel ? _red : const Color(0xFFE2E8F0)),
                  ),
                  child: Text((p['label'] as String).tr,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: sel ? Colors.white : const Color(0xFF334155))),
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
              ? const SizedBox.shrink()
              : FadeInUp(
                  from: 18,
                  duration: const Duration(milliseconds: 350),
                  child: Column(
                  children: [
                    _row('Distance'.tr, '${f.distanceKm} km'),
                    _row('Base fare'.tr, f.baseLabel),
                    _row('${'Mileage'.tr} (${f.perKmFareLabel}/km)',
                        f.mileageLabel),
                    if (f.waitingCharge > 0)
                      _row(
                          '${'Waiting'.tr} (${f.estimatedWaitMinutes - f.waitingFreeMinutes} ${'min'.tr})',
                          f.waitingLabel),
                    if (f.emergencyCharge > 0)
                      _row('Emergency'.tr, f.emergencyLabel),
                    if (f.nightCharge > 0) _row('Night'.tr, f.nightLabel),
                    if (f.taxAmount > 0) _row('Tax'.tr, f.taxLabel),
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
                                  color: _navy,
                                  letterSpacing: 0.4)),
                        ),
                        Text(c.payableLabel,
                            style: const TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                                color: _orange)),
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
                      fontSize: 13, color: Color(0xFF64748B))),
            ),
            Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _navy)),
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
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          _field('${'Patient name'.tr} *', null, c.patientNameCtrl,
              TextInputType.text, LucideIcons.user),
          const SizedBox(height: 8),
          _field(null, 'Contact phone'.tr, c.phoneCtrl, TextInputType.phone,
              LucideIcons.phone, hint: '01XXXXXXXXX'),
        ],
      ),
    );
  }

  Widget _field(String? placeholderOnly, String? smallLabel,
      TextEditingController ctrl, TextInputType kb, IconData icon,
      {String? hint}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: _grayField,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF64748B)),
          const SizedBox(width: 10),
          Expanded(
            child: smallLabel == null
                ? TextField(
                    controller: ctrl,
                    keyboardType: kb,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 13),
                      border: InputBorder.none,
                      hintText: placeholderOnly,
                      hintStyle: const TextStyle(
                          fontSize: 14, color: Color(0xFF94A3B8)),
                    ),
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700, color: _navy),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 9),
                        child: Text(smallLabel,
                            style: const TextStyle(
                                fontSize: 11.5, color: Color(0xFF64748B))),
                      ),
                      TextField(
                        controller: ctrl,
                        keyboardType: kb,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.only(bottom: 9),
                          border: InputBorder.none,
                          hintText: hint,
                          hintStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFB0AEB8)),
                        ),
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _navy),
                      ),
                    ],
                  ),
          ),
        ],
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
                color: sel ? const Color(0xFFEFFBF3) : AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: sel ? _green : const Color(0xFFE2E8F0),
                    width: sel ? 1.6 : 1.2),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: sel ? _green : const Color(0xFFF2F3F8),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    alignment: Alignment.center,
                    child: Icon(LucideIcons.wallet,
                        size: 18,
                        color: sel ? Colors.white : const Color(0xFF94A3B8)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.label.tr,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: _navy)),
                        const SizedBox(height: 2),
                        Text(m.description.tr,
                            style: const TextStyle(
                                fontSize: 11.5, color: Color(0xFF94A3B8))),
                      ],
                    ),
                  ),
                  Icon(
                      sel ? LucideIcons.circleCheckBig : LucideIcons.circle,
                      size: 20,
                      color: sel ? _green : const Color(0xFFCBD5E1)),
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
