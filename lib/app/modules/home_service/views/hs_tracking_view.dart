import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/values/app_colors.dart';
import '../../../global_widget/home_service_status_widgets.dart';
import '../../../global_widget/sn_google_map.dart';
import '../../../global_widget/sn_map.dart' show SnMapMarker;
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/home_service_controller.dart';

const _teal = Color(0xFF0E9F8E);
const _darkTeal = Color(0xFF0E7C6B);

class HsTrackingView extends GetView<HomeServiceController> {
  const HsTrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) controller.stopLiveTrackingOnLeave();
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: GetBuilder<HomeServiceController>(
          builder: (con) {
          final b = con.trackedBooking;
          // Provider location — prefer the booking's provider_lat/lng, else the
          // latest point shared on the timeline.
          LatLng? providerPt;
          if (b != null && b.hasProviderLocation) {
            providerPt = LatLng(b.providerLat!, b.providerLng!);
          } else {
            for (final t in con.timeline) {
              if (t.lat != null && t.lng != null) {
                providerPt = LatLng(t.lat!, t.lng!);
              }
            }
          }
          final userPt =
              con.hasUserLocation ? LatLng(con.userLat!, con.userLng!) : null;
          final hasLoc = providerPt != null;
          // Center on the midpoint when we have both points, else the provider.
          final LatLng center = (providerPt != null && userPt != null)
              ? LatLng((providerPt.latitude + userPt.latitude) / 2,
                  (providerPt.longitude + userPt.longitude) / 2)
              : (providerPt ?? const LatLng(23.78, 90.40));
          final double zoom = (providerPt != null && userPt != null)
              ? 12.5
              : (hasLoc ? 14 : 11);
          return Stack(
            children: [
              Positioned.fill(
                child: SnGoogleMap(
                  center: center,
                  zoom: zoom,
                  route: (providerPt != null && userPt != null)
                      ? [userPt, providerPt]
                      : const [],
                  markers: [
                    if (providerPt != null)
                      SnMapMarker(providerPt, _darkTeal,
                          Icons.engineering_rounded),
                    if (userPt != null)
                      SnMapMarker(userPt, const Color(0xFF2563EB),
                          Icons.my_location_rounded),
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
                                ? (con.providerDistanceLabel.isNotEmpty
                                    ? '${'Technician'.tr} · ${con.providerDistanceLabel}'
                                    : 'Technician location · live'.tr)
                                : 'Waiting for technician location'.tr,
                            style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A))),
                      ),
                      const SizedBox(width: 10),
                      con.loadingTrack
                          ? Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                  color: AppColors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                        color:
                                            Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 8)
                                  ]),
                              padding: const EdgeInsets.all(11),
                              child: const CircularProgressIndicator(
                                  strokeWidth: 2.4, color: _darkTeal),
                            )
                          : _round(Icons.refresh_rounded,
                              con.refreshTracking),
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
                              HomeServiceStatusChip(
                                  status: con.trackedBooking?.status ??
                                      'pending'),
                            ],
                          ),
                          // Subtitle under the status hidden for now.
                          // const SizedBox(height: 4),
                          // Text(con.whenSummary,
                          //     style: const TextStyle(
                          //         fontSize: 12.5, color: Color(0xFF94A3B8))),
                          if (con.providerDistanceLabel.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF7F4),
                                borderRadius: BorderRadius.circular(10),
                                border:
                                    Border.all(color: const Color(0xFFCDEBE4)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.near_me_rounded,
                                      size: 16, color: _darkTeal),
                                  const SizedBox(width: 8),
                                  Text(
                                      '${'Technician is'.tr} ${con.providerDistanceLabel} ${'away from you'.tr}',
                                      style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF0F4D40))),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                  child: _ActionBtn(
                                      icon: Icons.chat_bubble_outline_rounded,
                                      label: 'Chat'.tr,
                                      enabled: con.chatAvailable,
                                      onTap: con.openChat)),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: _ActionBtn(
                                      icon: Icons.bookmark_border_rounded,
                                      label: 'Details'.tr,
                                      onTap: con.viewBookingDetails)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text('STATUS TIMELINE'.tr,
                              style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF94A3B8),
                                  letterSpacing: 0.6)),
                          const SizedBox(height: 12),
                          if (con.loadingTrack && con.timeline.isEmpty)
                            const SnListSkeleton(
                              count: 3,
                              padding: EdgeInsets.zero,
                              showTrailing: false,
                            )
                          else
                            HomeServiceStatusStepper(
                              status: con.trackedBooking?.status ?? 'pending',
                              timestamps: {
                                for (final t in con.timeline)
                                  t.status.toLowerCase(): t.timeLabel,
                              },
                            ),
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
                              child: Text('View booking details'.tr,
                                  style: const TextStyle(
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

class _ActionBtn extends StatelessWidget {
  const _ActionBtn(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.enabled = true});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;
  @override
  Widget build(BuildContext context) {
    final iconColor = enabled ? _teal : const Color(0xFFB6BDC7);
    final labelColor =
        enabled ? const Color(0xFF334155) : const Color(0xFFB6BDC7);
    return GestureDetector(
      // Keep it tappable even when disabled so the guard can explain why.
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
            color: enabled ? AppColors.white : const Color(0xFFF4F5F7),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEDEFF2))),
        child: Column(
          children: [
            Icon(enabled ? icon : Icons.lock_outline_rounded,
                color: iconColor, size: 22),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: labelColor)),
          ],
        ),
      ),
    );
  }
}
