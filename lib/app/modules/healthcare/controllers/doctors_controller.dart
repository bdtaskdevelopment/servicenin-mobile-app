import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import 'booking_controller.dart';
import 'healthcare_controller.dart';

class DoctorsController extends GetxController {
  final List<String> filters = const [
    'All', 'Cardiology', 'Gynecology', 'Pediatrics', 'Orthopedics',
  ];
  int selectedFilter = 0;
  void selectFilter(int i) {
    selectedFilter = i;
    update();
  }

  final List<HcDoctor> doctors = const [
    HcDoctor(
      initials: 'SA',
      name: 'Dr. Salma Akter',
      specialty: 'Cardiology',
      degree: 'MBBS',
      rating: '4.9',
      reviews: 312,
      fee: '৳700',
      slot: 'Today 3–5 PM',
      color: Color(0xFF16A34A),
      video: true,
    ),
    HcDoctor(
      initials: 'RK',
      name: 'Dr. Rahim Khan',
      specialty: 'Pediatrics',
      degree: 'MBBS',
      rating: '4.7',
      reviews: 198,
      fee: '৳500',
      slot: 'Today 5–7 PM',
      color: Color(0xFF16A34A),
    ),
    HcDoctor(
      initials: 'TH',
      name: 'Dr. Tanvir Hasan',
      specialty: 'Dermatology',
      degree: 'MBBS',
      rating: '4.8',
      reviews: 254,
      fee: '৳600',
      slot: 'Tomorrow 10 AM',
      color: Color(0xFF16A34A),
      video: true,
    ),
    HcDoctor(
      initials: 'NJ',
      name: 'Dr. Nusrat Jahan',
      specialty: 'Gynecology',
      degree: 'MBBS',
      rating: '4.9',
      reviews: 401,
      fee: '৳800',
      slot: 'Today 7–9 PM',
      color: Color(0xFF16A34A),
    ),
  ];

  List<HcDoctor> get filtered => selectedFilter == 0
      ? doctors
      : doctors
          .where((d) => d.specialty == filters[selectedFilter])
          .toList();

  void openDoctor(HcDoctor d) {
    Get.find<BookingController>().setDoctor(d);
    Get.toNamed(Routes.HC_DOCTOR_PROFILE);
  }
}
