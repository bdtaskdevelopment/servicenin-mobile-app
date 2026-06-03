import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class HcDepartment {
  const HcDepartment(this.name, this.icon, this.color);
  final String name;
  final IconData icon;
  final Color color;
}

class FamilyMember {
  const FamilyMember({
    required this.name,
    required this.relation,
    required this.age,
    required this.gender,
    required this.bloodGroup,
    required this.color,
  });
  final String name;
  final String relation;
  final String age;
  final String gender;
  final String bloodGroup;
  final Color color;

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
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

  // ── Family members ──────────────────────────────────────────────────
  final List<FamilyMember> family = [
    const FamilyMember(
        name: 'Tanzil Ahmed',
        relation: 'Self',
        age: '31',
        gender: 'M',
        bloodGroup: 'B+',
        color: Color(0xFF16A34A)),
    const FamilyMember(
        name: 'Ayesha Ahmed',
        relation: 'Spouse',
        age: '29',
        gender: 'F',
        bloodGroup: 'O+',
        color: Color(0xFFEC4899)),
    const FamilyMember(
        name: 'Rafi Ahmed',
        relation: 'Son',
        age: '6',
        gender: 'M',
        bloodGroup: 'B+',
        color: Color(0xFF14B8A6)),
  ];

  static const List<Color> _familyColors = [
    Color(0xFF0F7A52),
    Color(0xFFF59E0B),
    Color(0xFF6366F1),
    Color(0xFFE11D48),
    Color(0xFF14B8A6),
  ];

  void addFamilyMember({
    required String name,
    required String relation,
    required String age,
    required String gender,
    required String bloodGroup,
  }) {
    family.add(FamilyMember(
      name: name,
      relation: relation,
      age: age,
      gender: gender,
      bloodGroup: bloodGroup,
      color: _familyColors[family.length % _familyColors.length],
    ));
    update();
  }

  void openFamily() => Get.toNamed(Routes.HEALTHCARE_FAMILY);

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
