import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HcDepartment {
  const HcDepartment(this.name, this.icon, this.color);
  final String name;
  final IconData icon;
  final Color color;
}

class HcDoctor {
  const HcDoctor({
    required this.initials,
    required this.name,
    required this.specialty,
    required this.degree,
    required this.rating,
    required this.reviews,
    required this.fee,
    required this.slot,
    required this.color,
    this.video = false,
  });

  final String initials;
  final String name;
  final String specialty;
  final String degree;
  final String rating;
  final int reviews;
  final String fee;
  final String slot;
  final Color color;
  final bool video;
}

class HealthcareController extends GetxController {
  // In-person (0) / Video consult (1)
  int mode = 0;
  void setMode(int m) {
    mode = m;
    update();
  }

  final List<HcDepartment> departments = const [
    HcDepartment('কার্ডিও', Icons.favorite, Color(0xFF0F172A)),
    HcDepartment('গাইনি', Icons.female_rounded, Color(0xFF16A34A)),
    HcDepartment('শিশু', Icons.person_outline_rounded, Color(0xFF14B8A6)),
    HcDepartment('অর্থো', Icons.directions_run_rounded, Color(0xFF16A34A)),
    HcDepartment('চর্ম', Icons.shield_outlined, Color(0xFF16A34A)),
    HcDepartment('নাক-কান', Icons.hearing_rounded, Color(0xFF14B8A6)),
    HcDepartment('ডায়াবেটিস', Icons.water_drop_rounded, Color(0xFF0F172A)),
    HcDepartment('মানসিক', Icons.favorite_border_rounded, Color(0xFF0F172A)),
  ];

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
  ];
}
