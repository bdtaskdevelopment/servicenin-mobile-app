import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../global_widget/sn_shimmer.dart';
import '../../../routes/app_pages.dart';
import '../controllers/booking_controller.dart';
import '../controllers/healthcare_controller.dart';
import '../widgets/hc_doctor_card.dart';

const _green = Color(0xFF15803D);

class AllAvailableDoctorsView extends GetView<HealthcareController> {
  const AllAvailableDoctorsView({super.key});

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
                      Text('Available today',
                          style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                      SizedBox(height: 1),
                      Text('Doctors taking patients today',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: _green,
                onRefresh: controller.fetchAvailableToday,
                child: GetBuilder<HealthcareController>(
                  builder: (con) {
                    if (con.loadingDoctors && con.doctors.isEmpty) {
                      return const SnListSkeleton(
                          padding: EdgeInsets.fromLTRB(16, 8, 16, 24));
                    }
                    if (con.doctors.isEmpty) {
                      return ListView(
                        children: const [
                          SizedBox(height: 140),
                          Center(
                            child: Text('No doctors available today.',
                                style: TextStyle(color: Color(0xFF94A3B8))),
                          ),
                        ],
                      );
                    }
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      children: con.doctors
                          .map((d) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: GestureDetector(
                                  onTap: () {
                                    Get.find<BookingController>().setDoctor(d);
                                    Get.toNamed(Routes.HC_DOCTOR_PROFILE);
                                  },
                                  child: HcDoctorCard(doctor: d),
                                ),
                              ))
                          .toList(),
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
