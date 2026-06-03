import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/values/app_colors.dart';
import '../../../global_widget/custom_app_bar.dart';
import '../../../global_widget/sn_map.dart';
import '../../../routes/app_pages.dart';
import '../controllers/ambulance_controller.dart';
import '../controllers/select_ambulance_controller.dart';

const _red = Color(0xFFE23744);
const _green = Color(0xFF16A34A);

class AmbulanceView extends GetView<AmbulanceController> {
  const AmbulanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: CustomAppBar(
        title: 'Ambulance',
        backgroundColor: AppColors.white,
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(Routes.AMBULANCE_NOTIFICATIONS),
            icon: const Icon(Icons.notifications_none_rounded,
                color: Color(0xFF1A1A1A)),
          ),
        ],
      ),
      body: GetBuilder<AmbulanceController>(
        builder: (con) {
          final ambulances = Get.find<SelectAmbulanceController>().types;
          final top5 = ambulances.take(5).toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _LocationSection(con: con),
              const SizedBox(height: 22),
              Row(
                children: [
                  const Text('Available ambulances',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A))),
                  const Spacer(),
                  GestureDetector(
                    onTap: con.openSeeAll,
                    child: const Text('See all →',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.brandOrange)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...List.generate(top5.length, (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _AmbulanceCard(
                      amb: top5[i],
                      onTap: () {
                        final sel = Get.find<SelectAmbulanceController>();
                        sel.selectType(i);
                        sel.proceed();
                      },
                    ),
                  )),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Recent bookings',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A))),
                  const Spacer(),
                  GestureDetector(
                    onTap: con.openBookings,
                    child: const Text('See all →',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.brandOrange)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...con.bookings.take(2).map((b) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () => con.trackBooking(b),
                      child: _BookingCard(booking: b),
                    ),
                  )),
            ],
          );
        },
      ),
    );
  }
}

// ── Location (pickup + destination) with map preview ────────────────
class _LocationSection extends StatelessWidget {
  const _LocationSection({required this.con});
  final AmbulanceController con;

  @override
  Widget build(BuildContext context) {
    final mid = LatLng(
      (con.pickupPoint.latitude + con.destPoint.latitude) / 2,
      (con.pickupPoint.longitude + con.destPoint.longitude) / 2,
    );
    return Column(
      children: [
        // Map preview
        SizedBox(
          height: 150,
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SnMap(
                    center: mid,
                    zoom: 7.2,
                    interactive: false,
                    route: [con.pickupPoint, con.destPoint],
                    markers: [
                      SnMapMarker(
                          con.pickupPoint, _green, Icons.my_location_rounded),
                      SnMapMarker(
                          con.destPoint, _red, Icons.location_on_rounded),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 10,
                top: 10,
                child: InkWell(
                  onTap: con.refreshMap,
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 6),
                      ],
                    ),
                    child: const Icon(Icons.refresh_rounded,
                        size: 20, color: Color(0xFF1A1A1A)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Pickup + destination selectors
        Container(
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
                zilla: con.pickupZillaName,
                onDivision: () => _pickDivision(con, pickup: true),
                onZilla: () => _pickZilla(con, pickup: true),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: Color(0xFFF1F5F9)),
              ),
              _LocBlock(
                dotColor: _red,
                label: 'DESTINATION',
                division: con.destDivision,
                zilla: con.destZillaName,
                onDivision: () => _pickDivision(con, pickup: false),
                onZilla: () => _pickZilla(con, pickup: false),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _pickDivision(AmbulanceController con, {required bool pickup}) {
    final cur = pickup ? con.pickupDiv : con.destDiv;
    _sheet(
      title: 'Select division',
      options: con.divisions,
      selected: cur,
      onSelect: (i) => pickup ? con.setPickupDiv(i) : con.setDestDiv(i),
    );
  }

  void _pickZilla(AmbulanceController con, {required bool pickup}) {
    final div = pickup ? con.pickupDiv : con.destDiv;
    final cur = pickup ? con.pickupZilla : con.destZilla;
    _sheet(
      title: 'Select zilla',
      options: con.zillasOf(div).map((z) => z.name).toList(),
      selected: cur,
      onSelect: (i) => pickup ? con.setPickupZilla(i) : con.setDestZilla(i),
    );
  }

  void _sheet({
    required String title,
    required List<String> options,
    required int selected,
    required void Function(int) onSelect,
  }) {
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
                children: List.generate(options.length, (i) {
                  final sel = i == selected;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    onTap: () {
                      onSelect(i);
                      Get.back();
                    },
                    title: Text(options[i],
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                                sel ? FontWeight.w800 : FontWeight.w500,
                            color: sel ? _red : const Color(0xFF334155))),
                    trailing: sel
                        ? const Icon(Icons.check_rounded, color: _red)
                        : null,
                  );
                }),
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
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
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
            Expanded(child: _DropChip(label: 'Division', value: division, onTap: onDivision)),
            const SizedBox(width: 10),
            Expanded(child: _DropChip(label: 'Zilla', value: zilla, onTap: onZilla)),
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
                  Text(value,
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

// ── Ambulance card (top-5 list) ─────────────────────────────────────
class _AmbulanceCard extends StatelessWidget {
  const _AmbulanceCard({required this.amb, required this.onTap});
  final SelectableAmbulance amb;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEDEFF2)),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                  color: amb.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.airport_shuttle_rounded,
                  color: amb.color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(amb.name,
                      style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A))),
                  const SizedBox(height: 2),
                  Text('৳${amb.base} base · ৳${amb.perKm}/km · ${amb.eta}',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF94A3B8))),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.circle, size: 6, color: Color(0xFF16A34A)),
                  const SizedBox(width: 4),
                  Text('${amb.avail}',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF15803D))),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}

// ── Booking card ────────────────────────────────────────────────────
class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});
  final AmbulanceBooking booking;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDEFF2)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.airport_shuttle_rounded,
                color: Color(0xFF334155), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(booking.id,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF94A3B8))),
                const SizedBox(height: 2),
                Text(booking.title,
                    style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text(booking.dateAmount,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: booking.ongoing
                  ? const Color(0xFFFEF3C7)
                  : const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(booking.ongoing ? 'On the way' : 'Completed',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: booking.ongoing
                        ? const Color(0xFFB45309)
                        : const Color(0xFF15803D))),
          ),
        ],
      ),
    );
  }
}
