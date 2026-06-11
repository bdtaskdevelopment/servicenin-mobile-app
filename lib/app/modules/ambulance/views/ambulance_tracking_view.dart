import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../global_widget/sn_map.dart';
import '../controllers/ambulance_controller.dart';
import '../controllers/emergency_controller.dart';

const _red = Color(0xFFE23744);
const _navy = Color(0xFF1E2A4A);

class AmbulanceTrackingView extends GetView<EmergencyController> {
  const AmbulanceTrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    final con = controller;
    final amb = Get.find<AmbulanceController>();
    final destPoint = amb.destPoint;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: GetBuilder<AmbulanceController>(
              builder: (a) {
                final ambPoint = a.liveAmbulancePoint;
                return SnMap(
                  center: ambPoint,
                  zoom: 13,
                  route: [ambPoint, destPoint],
                  markers: [
                    SnMapMarker(ambPoint, _red, Icons.airport_shuttle_rounded),
                    SnMapMarker(destPoint, _navy, Icons.location_on_rounded),
                  ],
                );
              },
            ),
          ),
          // Refresh ambulance location
          Positioned(
            right: 14,
            bottom: Get.height * 0.64 + 12,
            child: _round(Icons.refresh_rounded, () {
              amb.refreshAmbulance();
              Get.snackbar(
                'Location updated'.tr,
                'Ambulance position refreshed'.tr,
                snackPosition: SnackPosition.TOP,
                margin: const EdgeInsets.all(12),
                duration: const Duration(seconds: 1),
              );
            }),
          ),
          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  _round(Icons.arrow_back_ios_new_rounded, () => Get.back()),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(21),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8)
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.circle,
                              size: 9, color: Color(0xFF22C55E)),
                          const SizedBox(width: 6),
                          Text('${'On the way'.tr} · ${con.estArrival}',
                              style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A))),
                          const Spacer(),
                          Text(con.distance,
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF94A3B8))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Relevant icon → Emergency contacts (was a share icon)
                  _round(Icons.contacts_outlined, con.openEmergencyContacts),
                ],
              ),
            ),
          ),
          // Bottom panel
          Align(
            alignment: Alignment.bottomCenter,
            child: _Panel(con: con),
          ),
        ],
      ),
    );
  }

  Widget _round(IconData icon, VoidCallback onTap) => InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)
            ],
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF1A1A1A)),
        ),
      );
}

class _Panel extends StatelessWidget {
  const _Panel({required this.con});
  final EmergencyController con;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: Get.height * 0.62),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Column(
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
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('LIVE · ON THE WAY'.tr,
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: _red,
                                letterSpacing: 0.5)),
                        const SizedBox(height: 4),
                        Text('${'Arriving in'.tr} ${con.estArrival}',
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A))),
                        const SizedBox(height: 2),
                        Text(con.routeVia,
                            style: const TextStyle(
                                fontSize: 12.5, color: Color(0xFF94A3B8))),
                      ],
                    ),
                  ),
                  Stack(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                            color: _red.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14)),
                        child: const Icon(Icons.airport_shuttle_rounded,
                            color: _red, size: 26),
                      ),
                      const Positioned(
                        right: 0,
                        top: 0,
                        child: Icon(Icons.circle,
                            size: 12, color: Color(0xFF22C55E)),
                      ),
                    ],
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: Color(0xFFF1F5F9)),
              ),
              // Driver row
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                        color: const Color(0xFFE6E7FB),
                        borderRadius: BorderRadius.circular(12)),
                    alignment: Alignment.center,
                    child: Text(con.driverInitials,
                        style: const TextStyle(
                            color: Color(0xFF4F46E5),
                            fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(con.driverName,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A))),
                        const SizedBox(height: 2),
                        Text(
                            '★ ${con.driverRating} · ${con.driverTrips} · ${con.driverYears}',
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF94A3B8))),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: const Color(0xFFE6E7FB),
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(con.vehicle,
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF4F46E5))),
                      ),
                      const SizedBox(height: 4),
                      Text(con.driverPhone,
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                      child: _ActionBtn(
                          icon: Icons.call_rounded,
                          label: 'Call driver'.tr,
                          bg: const Color(0xFFD9F7E6),
                          fg: const Color(0xFF16A34A))),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _ActionBtn(
                          icon: Icons.notifications_active_outlined,
                          label: 'Call support'.tr,
                          bg: const Color(0xFFFDE4E4),
                          fg: _red)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _ActionBtn(
                          icon: Icons.share_outlined,
                          label: 'Share trip'.tr,
                          bg: const Color(0xFFE6E7FB),
                          fg: const Color(0xFF4F46E5))),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      style: BorderStyle.solid),
                ),
                alignment: Alignment.center,
                child: Text('▶ Simulate: trip completed → payment'.tr,
                    style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B))),
              ),
              const SizedBox(height: 16),
              Text('TRIP STATUS'.tr,
                  style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF94A3B8),
                      letterSpacing: 0.5)),
              const SizedBox(height: 12),
              ...List.generate(con.tripStatus.length, (i) {
                final s = con.tripStatus[i];
                final done = i < con.activeTripStep;
                final active = i == con.activeTripStep;
                final color = done
                    ? const Color(0xFF22C55E)
                    : active
                        ? _red
                        : const Color(0xFFCBD5E1);
                return Padding(
                  padding: EdgeInsets.only(
                      bottom: i == con.tripStatus.length - 1 ? 0 : 14),
                  child: Row(
                    children: [
                      Icon(
                          done
                              ? Icons.check_circle
                              : active
                                  ? Icons.radio_button_checked
                                  : Icons.circle_outlined,
                          size: 20,
                          color: color),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(s.label,
                            style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: (done || active)
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: (done || active)
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFF94A3B8))),
                      ),
                      Text(s.time,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn(
      {required this.icon,
      required this.label,
      required this.bg,
      required this.fg});
  final IconData icon;
  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          Icon(icon, color: fg, size: 22),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 11.5, fontWeight: FontWeight.w700, color: fg)),
        ],
      ),
    );
  }
}

