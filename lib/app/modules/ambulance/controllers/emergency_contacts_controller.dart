import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NationalLine {
  const NationalLine(this.number, this.label, this.color);
  final String number;
  final String label;
  final Color color;
}

class EmergencyContact {
  const EmergencyContact({
    required this.initials,
    required this.name,
    required this.role,
    required this.phone,
    required this.color,
    this.starred = false,
    this.liveShare = false,
  });

  final String initials;
  final String name;
  final String role;
  final String phone;
  final Color color;
  final bool starred;
  final bool liveShare;
}

class EmergencyContactsController extends GetxController {
  final List<NationalLine> nationalLines = const [
    NationalLine('999', 'National Emergency', Color(0xFFE11D48)),
    NationalLine('16263', 'Health Hotline', Color(0xFF14B8A6)),
    NationalLine('999', 'Fire Service', Color(0xFFF59E0B)),
    NationalLine('109', "Women's Helpline", Color(0xFFEC4899)),
  ];

  final List<EmergencyContact> contacts = const [
    EmergencyContact(
        initials: 'SA',
        name: 'Sadia Ahmed',
        role: 'Wife · Guardian',
        phone: '+880 1711-234567',
        color: Color(0xFFE11D48),
        starred: true,
        liveShare: true),
    EmergencyContact(
        initials: 'SA',
        name: 'Dr. Salma Akter',
        role: 'Family doctor',
        phone: '+880 1819-998877',
        color: Color(0xFF14B8A6),
        liveShare: true),
    EmergencyContact(
        initials: 'KA',
        name: 'Karim Ahmed',
        role: 'Brother',
        phone: '+880 1711-998123',
        color: Color(0xFF334155)),
    EmergencyContact(
        initials: 'HR',
        name: 'Office HR',
        role: 'Work',
        phone: '+880 9612-345678',
        color: Color(0xFF7C3AED)),
  ];

  bool autoShare = true;
  void toggleAutoShare(bool value) {
    autoShare = value;
    update();
  }
}
