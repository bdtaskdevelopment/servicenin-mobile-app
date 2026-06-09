import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/service_response.dart';
import '../../../global_widget/sn_map.dart';
import '../controllers/home_service_controller.dart';

const _teal = Color(0xFF0E9F8E);
const _darkTeal = Color(0xFF0E7C6B);

class HsTrackingView extends GetView<HomeServiceController> {
  const HsTrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: GetBuilder<HomeServiceController>(
        builder: (con) {
          // Latest provider location from the timeline (if shared).
          LatLng center = const LatLng(23.78, 90.40);
          bool hasLoc = false;
          for (final t in con.timeline) {
            if (t.lat != null && t.lng != null) {
              center = LatLng(t.lat!, t.lng!);
              hasLoc = true;
            }
          }
          return Stack(
            children: [
              Positioned.fill(
                child: SnMap(
                  center: center,
                  zoom: hasLoc ? 14 : 11,
                  interactive: false,
                  markers: [
                    if (hasLoc)
                      SnMapMarker(center, _darkTeal,
                          Icons.engineering_rounded),
                  ],
                ),
              ),
              SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Row(
                    children: [
                      _round(Icons.arrow_back_ios_new_rounded, () => Get.back()),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 8)
                            ]),
                        child: Text(
                            hasLoc
                                ? 'Provider location · live'
                                : 'Waiting for provider location',
                            style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A))),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  constraints: BoxConstraints(maxHeight: Get.height * 0.6),
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 20)
                    ],
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
                                    borderRadius: BorderRadius.circular(4))),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: Text(con.bookingSummary,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A))),
                              ),
                              _StatusChip(
                                  status: con.trackedBooking?.status ??
                                      'pending'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(con.whenSummary,
                              style: const TextStyle(
                                  fontSize: 12.5, color: Color(0xFF94A3B8))),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                  child: _ActionBtn(
                                      icon: Icons.chat_bubble_outline_rounded,
                                      label: 'Chat',
                                      onTap: con.openChat)),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: _ActionBtn(
                                      icon: Icons.bookmark_border_rounded,
                                      label: 'Details',
                                      onTap: con.viewBookingDetails)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text('STATUS TIMELINE',
                              style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF94A3B8),
                                  letterSpacing: 0.6)),
                          const SizedBox(height: 12),
                          if (con.loadingTrack && con.timeline.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.4, color: _darkTeal),
                              ),
                            )
                          else
                            _Timeline(entries: con.timeline),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: OutlinedButton(
                              onPressed: con.viewBookingDetails,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: Color(0xFFE2E8F0)),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                              ),
                              child: const Text('View booking details',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A))),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
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
              ]),
          child: Icon(icon, size: 18, color: const Color(0xFF1A1A1A)),
        ),
      );
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.entries});
  final List<ServiceTimelineEntry> entries;
  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Text('No updates yet.',
          style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)));
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 2),
      decoration: BoxDecoration(
          color: const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: List.generate(entries.length, (i) {
          final e = entries[i];
          final last = i == entries.length - 1;
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    const Icon(Icons.check_circle, size: 20, color: _darkTeal),
                    if (!last)
                      Expanded(
                        child: Container(
                            width: 2, color: const Color(0xFFB6E0D7)),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: last ? 8 : 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.statusLabel,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A))),
                        const SizedBox(height: 1),
                        if (e.note.isNotEmpty)
                          Text(e.note,
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF64748B))),
                        Text(e.timeLabel,
                            style: const TextStyle(
                                fontSize: 11.5, color: Color(0xFFE07A1F))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
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
        status.isEmpty ? 'Pending' : status[0].toUpperCase() + status.substring(1).replaceAll('_', ' ');
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

class _ActionBtn extends StatelessWidget {
  const _ActionBtn(
      {required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEDEFF2))),
        child: Column(
          children: [
            Icon(icon, color: _teal, size: 22),
            const SizedBox(height: 6),
            Text(label,
                style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155))),
          ],
        ),
      ),
    );
  }
}
