import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../global_widget/sn_shimmer.dart';
import '../controllers/ambulance_controller.dart';
import '../widgets/ambulance_widgets.dart';

const _red = Color(0xFFE23744);

class AmbulanceBookingsView extends GetView<AmbulanceController> {
  const AmbulanceBookingsView({super.key});

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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('My bookings'.tr,
                          style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                      const SizedBox(height: 1),
                      Text('Tap a trip to see its details'.tr,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: _red,
                onRefresh: controller.fetchBookings,
                child: GetBuilder<AmbulanceController>(
                  builder: (con) {
                    if (con.loadingBookings && con.bookings.isEmpty) {
                      return const SnListSkeleton();
                    }
                    if (con.bookings.isEmpty) {
                      return ListView(
                        children: [
                          const SizedBox(height: 120),
                          Center(
                            child: Text('No bookings yet.'.tr,
                                style: const TextStyle(color: Color(0xFF94A3B8))),
                          ),
                        ],
                      );
                    }
                    return FadeInUp(
                      from: 18,
                      duration: const Duration(milliseconds: 350),
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        children: con.bookings
                            .map((b) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: BookingCard(
                                      booking: b,
                                      onTap: () => con.trackBooking(b)),
                                ))
                            .toList(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
