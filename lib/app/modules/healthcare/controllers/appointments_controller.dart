import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

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
    this.venue = '',
    this.when = '',
    this.nowServing = '',
    this.ahead = 0,
    this.color = const Color(0xFF16A34A),
  });

  final String initials;
  final String name;
  final String specialty;
  final String relation;
  final ApptStatus status;
  final IconData icon; // location / video
  final String line;
  final String? token; // serial number
  final bool rx;

  // Queue / live status (for upcoming appointments).
  final String venue;
  final String when;
  final String nowServing;
  final int ahead; // patients ahead of you
  final Color color;

  Appointment copyWith({String? when, String? line}) => Appointment(
        initials: initials,
        name: name,
        specialty: specialty,
        relation: relation,
        status: status,
        icon: icon,
        line: line ?? this.line,
        token: token,
        rx: rx,
        venue: venue,
        when: when ?? this.when,
        nowServing: nowServing,
        ahead: ahead,
        color: color,
      );
}

class PastRx {
  const PastRx({
    required this.doctor,
    required this.specialty,
    required this.date,
    required this.summary,
  });
  final String doctor;
  final String specialty;
  final String date;
  final String summary;
}

class AppointmentsController extends GetxController {
  final List<Appointment> upcoming = [
    Appointment(
      initials: 'SA',
      name: 'Dr. Salma Akter',
      specialty: 'Cardiology',
      relation: 'Self',
      status: ApptStatus.upcoming,
      icon: Icons.location_on_outlined,
      line: 'Today · 3:40 PM · Popular Diagnostic, Gulshan-2',
      token: '14',
      venue: 'Popular Diagnostic, Gulshan-2',
      when: 'Today · 3:40 PM',
      nowServing: '9',
      ahead: 5,
      color: Color(0xFF16A34A),
    ),
    Appointment(
      initials: 'RK',
      name: 'Dr. Rahim Khan',
      specialty: 'Pediatrics',
      relation: 'Son · Rafi',
      status: ApptStatus.upcoming,
      icon: Icons.location_on_outlined,
      line: 'Today · 5:30 PM · Praava Health, Banani',
      token: '7',
      venue: 'Praava Health, Banani',
      when: 'Today · 5:30 PM',
      nowServing: '3',
      ahead: 4,
      color: Color(0xFF14B8A6),
    ),
    Appointment(
      initials: 'TH',
      name: 'Dr. Tanvir Hasan',
      specialty: 'Dermatology',
      relation: 'Father',
      status: ApptStatus.upcoming,
      icon: Icons.videocam_outlined,
      line: 'Tomorrow · 10:00 AM · Video consult',
      token: '21',
      venue: 'Video consult',
      when: 'Tomorrow · 10:00 AM',
      nowServing: '—',
      ahead: 12,
      color: Color(0xFF6366F1),
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
      venue: 'Video consult',
      when: '6 May · 8:30 PM',
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
      venue: 'Praava, Dhanmondi',
      when: '28 Apr · 5:30 PM',
    ),
  ];

  // Past prescriptions for this patient (across visits).
  final List<PastRx> prescriptions = const [
    PastRx(
      doctor: 'Dr. Salma Akter',
      specialty: 'Cardiology',
      date: '2 Apr 2026',
      summary: 'Bisoprolol 5mg · low-salt diet · review in 4 weeks',
    ),
    PastRx(
      doctor: 'Dr. Tanvir Hasan',
      specialty: 'Dermatology',
      date: '6 May 2026',
      summary: 'Topical retinoid · sunscreen SPF 50 · 6-week course',
    ),
    PastRx(
      doctor: 'Dr. Rahim Khan',
      specialty: 'Pediatrics',
      date: '28 Apr 2026',
      summary: 'Paracetamol syrup · ORS · follow-up if fever persists',
    ),
  ];

  /// The appointment the user tapped to view its queue / status.
  Appointment? selected;
  void openAppointment(Appointment a) {
    selected = a;
    update();
    Get.toNamed(Routes.HC_QUEUE);
  }

  /// Date/time options offered when rescheduling.
  final List<String> rescheduleDates = const [
    'Tomorrow · 16 May',
    'Sat · 17 May',
    'Sun · 18 May',
    'Mon · 19 May',
  ];
  final List<String> rescheduleTimes = const [
    '10:00 AM',
    '11:30 AM',
    '4:00 PM',
    '5:30 PM',
    '6:30 PM',
  ];

  void reschedule(String date, String time) {
    final s = selected;
    if (s == null) return;
    final when = '$date · $time';
    final updated = s.copyWith(when: when, line: '$when · ${s.venue}');
    final i = upcoming.indexOf(s);
    if (i >= 0) upcoming[i] = updated;
    selected = updated;
    update();
    Get.back(); // close reschedule sheet
    Get.snackbar(
      'Appointment rescheduled',
      'New time: $when',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
    );
  }

  void openPrescription() => Get.toNamed(Routes.HEALTHCARE_PRESCRIPTION);
}
