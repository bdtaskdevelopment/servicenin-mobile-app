import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class SelectableAmbulance {
  const SelectableAmbulance({
    required this.name,
    required this.desc,
    required this.tags,
    required this.base,
    required this.perKm,
    required this.eta,
    required this.avail,
    required this.est,
    required this.color,
    this.badge,
  });

  final String name;
  final String desc;
  final List<String> tags;
  final int base;
  final int perKm;
  final String eta;
  final int avail;
  final String est;
  final Color color;
  final String? badge;
}

class SelectAmbulanceController extends GetxController {
  final String condition = 'Cardiac · Severe';

  final List<SelectableAmbulance> types = const [
    SelectableAmbulance(
      name: 'Basic Life Support',
      desc: 'BLS · Oxygen + first aid',
      tags: ['Minor injury', 'Patient transfer', 'Non-critical'],
      base: 800,
      perKm: 35,
      eta: '6 min',
      avail: 12,
      est: '৳1,059',
      color: Color(0xFF3B82F6),
      badge: 'Most common',
    ),
    SelectableAmbulance(
      name: 'Advanced Life Support',
      desc: 'ALS · Paramedic + monitor',
      tags: ['Cardiac', 'Stroke', 'Trauma'],
      base: 1500,
      perKm: 55,
      eta: '8 min',
      avail: 6,
      est: '৳1,907',
      color: Color(0xFF3B82F6),
    ),
    SelectableAmbulance(
      name: 'ICU Ambulance',
      desc: 'Ventilator + ICU specialist',
      tags: ['Critical care', 'Inter-hospital ICU'],
      base: 2500,
      perKm: 80,
      eta: '10 min',
      avail: 4,
      est: '৳2,968',
      color: Color(0xFFE11D48),
      badge: 'Critical care',
    ),
    SelectableAmbulance(
      name: 'Neonatal Ambulance',
      desc: 'Incubator + neonatal nurse',
      tags: ['Newborn transfer'],
      base: 3000,
      perKm: 90,
      eta: '15 min',
      avail: 3,
      est: '৳3,260',
      color: Color(0xFFEC4899),
    ),
    SelectableAmbulance(
      name: 'Patient Transport',
      desc: 'PTS · Wheelchair access',
      tags: ['Non-emergency'],
      base: 600,
      perKm: 30,
      eta: '12 min',
      avail: 2,
      est: '৳822',
      color: Color(0xFF14B8A6),
    ),
  ];

  int selected = 0;
  void selectType(int i) {
    selected = i;
    update();
  }

  SelectableAmbulance get selectedAmbulance => types[selected];
  String get estFare => types[selected].est;
  int get totalTypes => types.length;
  int get totalAvailable => types.fold(0, (sum, t) => sum + t.avail);

  void proceed() => Get.toNamed(Routes.AMBULANCE_FARE);
}
