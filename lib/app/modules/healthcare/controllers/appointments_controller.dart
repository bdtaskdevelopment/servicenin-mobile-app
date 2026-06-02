import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum ApptStatus { upcoming, completed }

class Appointment {
  const Appointment({
    required this.initials,
    required this.name,
    required this.specialty,
    required this.relation,
    required this.status,
    required this.icon,
    required this.line,
    this.token,
    this.rx = false,
  });

  final String initials;
  final String name;
  final String specialty;
  final String relation;
  final ApptStatus status;
  final IconData icon; // location / video
  final String line;
  final String? token;
  final bool rx;
}

class AppointmentsController extends GetxController {
  final List<Appointment> upcoming = const [
    Appointment(
      initials: 'SA',
      name: 'Dr. Salma Akter',
      specialty: 'Cardiology',
      relation: 'Self',
      status: ApptStatus.upcoming,
      icon: Icons.location_on_outlined,
      line: 'Today · 3:40 PM · Popular Diagnostic, Gulshan-2',
      token: '14',
    ),
  ];

  final List<Appointment> completed = const [
    Appointment(
      initials: 'TH',
      name: 'Dr. Tanvir Hasan',
      specialty: 'Dermatology',
      relation: 'Self',
      status: ApptStatus.completed,
      icon: Icons.videocam_outlined,
      line: '6 May · 8:30 PM · Video consult',
      rx: true,
    ),
    Appointment(
      initials: 'RK',
      name: 'Dr. Rahim Khan',
      specialty: 'Pediatrics',
      relation: 'Father',
      status: ApptStatus.completed,
      icon: Icons.location_on_outlined,
      line: '28 Apr · 5:30 PM · Praava, Dhanmondi',
      rx: true,
    ),
  ];
}
