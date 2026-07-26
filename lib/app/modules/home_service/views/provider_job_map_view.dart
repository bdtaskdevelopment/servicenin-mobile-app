import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/values/app_colors.dart';
import '../../../global_widget/sn_google_map.dart';
import '../../../global_widget/sn_map.dart' show SnMapMarker;
import '../controllers/provider_controller.dart';

const _navy = Color(0xFF1E2A4A);

/// The provider's own live-location map for a job — the "Start" action here
/// (and the same action on the dashboard card) is what kicks off the GPS
/// push that makes the customer's tracking screen move.
class ProviderJobMapView extends GetView<ProviderController> {
  const ProviderJobMapView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) controller.stopJobMapRefresh();
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: GetBuilder<ProviderController>(
          builder: (con) {
            final job = con.trackedJob;
            final myPt = (con.myLat != null && con.myLng != null)
                ? LatLng(con.myLat!, con.myLng!)
                : null;
            final destPt = con.destPoint;
            final center = myPt ?? destPt ?? const LatLng(23.78, 90.40);
            final hasBoth = myPt != null && destPt != null;

            return Stack(
              children: [
                Positioned.fill(
                  child: SnGoogleMap(
                    center: center,
                    zoom: hasBoth ? 13 : 14,
                    showMyLocation: true,
                    route: hasBoth ? [myPt, destPt] : const [],
                    markers: [
                      if (destPt != null)
                        SnMapMarker(destPt, _navy, Icons.location_on_rounded),
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
                        if (job != null)
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
                              con.destDistanceLabel.isNotEmpty
                                  ? '${'Destination'.tr} · ${con.destDistanceLabel}'
                                  : (con.loadingDest
                                      ? 'Locating destination…'.tr
                                      : con.statusLabel(job.status)),
                              style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (job != null)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)],
                      ),
                      child: SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(job.title,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A))),
                              const SizedBox(height: 2),
                              Text(job.address,
                                  style: const TextStyle(
                                      fontSize: 12.5, color: Color(0xFF64748B))),
                              const SizedBox(height: 14),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: con.actionLabel(job) != null
                                    ? ElevatedButton.icon(
                                        onPressed: () => con.advanceJob(job),
                                        icon: const Icon(
                                            Icons.navigation_rounded, size: 18),
                                        label: Text(con.actionLabel(job)!.tr,
                                            style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w800)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _navy,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14)),
                                        ),
                                      )
                                    : Container(
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFDCFCE7),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: Text('Job completed'.tr,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w800,
                                                color: Color(0xFF15803D))),
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
                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)
              ]),
          child: Icon(icon, size: 18, color: const Color(0xFF1A1A1A)),
        ),
      );
}
