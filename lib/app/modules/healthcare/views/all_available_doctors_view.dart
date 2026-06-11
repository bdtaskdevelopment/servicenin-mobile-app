import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../global_widget/sn_shimmer.dart';
import '../../../routes/app_pages.dart';
import '../controllers/booking_controller.dart';
import '../controllers/healthcare_controller.dart';
import '../widgets/hc_doctor_card.dart';

const _green = Color(0xFF15803D);

class AllAvailableDoctorsView extends StatefulWidget {
  const AllAvailableDoctorsView({super.key});

  @override
  State<AllAvailableDoctorsView> createState() =>
      _AllAvailableDoctorsViewState();
}

class _AllAvailableDoctorsViewState extends State<AllAvailableDoctorsView> {
  final HealthcareController controller = Get.find<HealthcareController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initAvailableList();
    });
  }

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
                      Text('Available today'.tr,
                          style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                      const SizedBox(height: 1),
                      Text('Doctors taking patients today'.tr,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: _green,
                onRefresh: () => controller.initAvailableList(force: true),
                child: GetBuilder<HealthcareController>(
                  builder: (con) {
                    if (con.loadingAvailable && con.availableDoctors.isEmpty) {
                      return const SnListSkeleton(
                          padding: EdgeInsets.fromLTRB(16, 8, 16, 24));
                    }
                    if (con.availableDoctors.isEmpty) {
                      return ListView(
                        children: [
                          const SizedBox(height: 140),
                          Center(
                            child: Text('No doctors available today.'.tr,
                                style: const TextStyle(color: Color(0xFF94A3B8))),
                          ),
                        ],
                      );
                    }
                    return ListView(
                      controller: con.availableScrollCtrl,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      children: [
                        ...con.availableDoctors
                            .toList()
                            .asMap()
                            .entries
                            .map((e) => FadeInUp(
                                  from: 18,
                                  duration: const Duration(milliseconds: 350),
                                  delay: Duration(
                                      milliseconds:
                                          70 * (e.key < 6 ? e.key : 6)),
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: GestureDetector(
                                      onTap: () {
                                        Get.find<BookingController>()
                                            .setDoctor(e.value);
                                        Get.toNamed(Routes.HC_DOCTOR_PROFILE);
                                      },
                                      child: HcDoctorCard(doctor: e.value),
                                    ),
                                  ),
                                )),
                        if (con.loadingMoreAvailable)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.4, color: _green),
                              ),
                            ),
                          ),
                      ],
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
