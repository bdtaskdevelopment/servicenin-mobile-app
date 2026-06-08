import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/values/app_colors.dart';
import '../../../core/values/bd_geo.dart';
import '../../../global_widget/sn_map.dart';
import '../../../routes/app_pages.dart';
import '../controllers/ambulance_controller.dart';

const _navy = Color(0xFF1E2A4A);
const _red = Color(0xFFE23744);
const _green = Color(0xFF16A34A);

class BookingConfirmedView extends GetView<AmbulanceController> {
  const BookingConfirmedView({super.key});

  @override
  Widget build(BuildContext context) {
    final b = controller.lastBooking;
    final pickup =
        BdGeo.point(b?.pickupZilla ?? '', b?.pickupDivision ?? '');
    final drop = BdGeo.point(b?.dropZilla ?? '', b?.dropDivision ?? '');
    final mid = LatLng((pickup.latitude + drop.latitude) / 2,
        (pickup.longitude + drop.longitude) / 2);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Column(
        children: [
          // Map
          SizedBox(
            width: double.infinity,
            height: Get.height * 0.34,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: SnMap(
                    center: mid,
                    zoom: 7,
                    interactive: false,
                    route: [pickup, drop],
                    markers: [
                      SnMapMarker(pickup, _green, Icons.my_location_rounded),
                      SnMapMarker(drop, _red, Icons.location_on_rounded),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: InkWell(
                        onTap: () => Get.until(
                            (r) => r.settings.name == Routes.AMBULANCE),
                        customBorder: const CircleBorder(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 6),
                            ],
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              size: 18, color: Color(0xFF1A1A1A)),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Details
          Expanded(
            child: b == null
                ? const Center(
                    child: Text('No booking found',
                        style: TextStyle(color: Color(0xFF94A3B8))),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    children: [
                      // Success banner
                      Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                                color: _green.withValues(alpha: 0.12),
                                shape: BoxShape.circle),
                            child: const Icon(Icons.check_circle_rounded,
                                color: _green, size: 28),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Ambulance booked',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A))),
                                const SizedBox(height: 2),
                                Text('Booking ${b.bookingNo}',
                                    style: const TextStyle(
                                        fontSize: 12.5,
                                        color: Color(0xFF94A3B8))),
                              ],
                            ),
                          ),
                          _StatusBadge(status: b.status),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Route card
                      _Card(
                        child: Column(
                          children: [
                            _RouteRow(
                                dot: _green,
                                label: 'PICKUP',
                                value: b.pickupAddress.isNotEmpty
                                    ? b.pickupAddress
                                    : '${b.pickupZilla}, ${b.pickupDivision}'),
                            const Padding(
                              padding: EdgeInsets.only(left: 4, top: 6, bottom: 6),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: SizedBox(
                                  height: 16,
                                  child: VerticalDivider(
                                      width: 12,
                                      thickness: 1.4,
                                      color: Color(0xFFCBD5E1)),
                                ),
                              ),
                            ),
                            _RouteRow(
                                dot: _red,
                                label: 'DESTINATION',
                                value: b.destination.isNotEmpty
                                    ? b.destination
                                    : '${b.dropZilla}, ${b.dropDivision}'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Ambulance + patient
                      _Card(
                        child: Column(
                          children: [
                            _InfoRow(
                                icon: Icons.airport_shuttle_rounded,
                                label: 'Ambulance',
                                value: b.typeName),
                            _InfoRow(
                                icon: Icons.straighten_rounded,
                                label: 'Distance',
                                value: '${b.distanceKm} km'),
                            _InfoRow(
                                icon: Icons.person_outline_rounded,
                                label: 'Patient',
                                value: b.patientName.isEmpty
                                    ? '—'
                                    : b.patientName),
                            _InfoRow(
                                icon: Icons.call_outlined,
                                label: 'Contact',
                                value: b.customerPhone.isEmpty
                                    ? '—'
                                    : b.customerPhone),
                            _InfoRow(
                                icon: Icons.bolt_rounded,
                                label: 'Type',
                                value: b.bookingType.isEmpty
                                    ? '—'
                                    : b.bookingType),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Payment
                      _Card(
                        child: Column(
                          children: [
                            _InfoRow(
                                icon: Icons.payments_outlined,
                                label: 'Payment',
                                value: _cap(b.paymentMethod)),
                            _InfoRow(
                                icon: Icons.schedule_rounded,
                                label: 'Payment status',
                                value: _cap(b.paymentStatus)),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child:
                                  Divider(height: 1, color: Color(0xFFF1F5F9)),
                            ),
                            Row(
                              children: [
                                const Expanded(
                                  child: Text('TOTAL FARE',
                                      style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF0F172A),
                                          letterSpacing: 0.4)),
                                ),
                                Text(b.fareLabel,
                                    style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: _navy)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () => Get.until(
                              (r) => Get.currentRoute == Routes.AMBULANCE),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _navy,
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('Back to ambulance home',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  String _cap(String s) =>
      s.isEmpty ? '—' : s[0].toUpperCase() + s.substring(1).replaceAll('_', ' ');
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEDEFF2)),
        ),
        child: child,
      );
}

class _RouteRow extends StatelessWidget {
  const _RouteRow(
      {required this.dot, required this.label, required this.value});
  final Color dot;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF94A3B8),
                      letterSpacing: 0.5)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A))),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
          const Spacer(),
          Flexible(
            child: Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A))),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;
  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();
    final done = s == 'completed';
    final bad = s == 'cancelled' || s == 'canceled';
    final bg = bad
        ? const Color(0xFFFEE2E2)
        : done
            ? const Color(0xFFDCFCE7)
            : const Color(0xFFFEF3C7);
    final fg = bad
        ? const Color(0xFFDC2626)
        : done
            ? const Color(0xFF15803D)
            : const Color(0xFFB45309);
    final label =
        status.isEmpty ? 'Pending' : status[0].toUpperCase() + status.substring(1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w800, color: fg)),
    );
  }
}
