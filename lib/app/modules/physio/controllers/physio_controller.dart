import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class PhysioConcern {
  const PhysioConcern(this.label, this.icon);
  final String label;
  final IconData icon;
}

class PhysioTherapist {
  const PhysioTherapist({
    required this.initials,
    required this.name,
    required this.focus,
    required this.years,
    required this.fee,
  });
  final String initials;
  final String name;
  final String focus;
  final String years;
  final String fee;
}

class PhysioCenter {
  const PhysioCenter({
    required this.name,
    required this.area,
    required this.distance,
    required this.rating,
    required this.reviews,
    required this.tags,
    required this.hours,
    required this.about,
    required this.therapists,
  });
  final String name;
  final String area;
  final String distance;
  final String rating;
  final String reviews;
  final List<String> tags;
  final String hours;
  final String about;
  final List<PhysioTherapist> therapists;
}

enum SessionStatus { upcoming, completed }

class PhysioSession {
  const PhysioSession({
    required this.doctor,
    required this.center,
    required this.when,
    required this.status,
    this.progress,
  });
  final String doctor;
  final String center;
  final String when;
  final SessionStatus status;
  final String? progress;
}

class PhysioController extends GetxController {
  // ---- Static content ----
  final List<PhysioConcern> concerns = const [
    PhysioConcern('Back pain', Icons.airline_seat_recline_normal_rounded),
    PhysioConcern('Sports', Icons.sports_handball_rounded),
    PhysioConcern('Post-surgery', Icons.healing_rounded),
    PhysioConcern('Neuro', Icons.psychology_rounded),
  ];

  final List<PhysioCenter> centers = const [
    PhysioCenter(
      name: 'Mobility+ Physiotherapy',
      area: 'Dhanmondi 27',
      distance: '1.4 km',
      rating: '4.8',
      reviews: '142',
      tags: ['Sports injury', 'Post-surgery', 'Neuro'],
      hours: 'Open 8 AM – 9 PM',
      about:
          'Sports-focused physio studio with gait lab and hydrotherapy pool. '
          'Specialised post-surgery rehab and athlete recovery programs.',
      therapists: [
        PhysioTherapist(
          initials: 'FH',
          name: 'Dr. Farzana Haque',
          focus: 'Sports & post-surgery',
          years: '9 yrs',
          fee: '৳1200',
        ),
        PhysioTherapist(
          initials: 'MN',
          name: 'Dr. Mahin Noor',
          focus: 'Neuro rehab',
          years: '7 yrs',
          fee: '৳1100',
        ),
      ],
    ),
    PhysioCenter(
      name: 'ReActive Rehab Center',
      area: 'Gulshan 1',
      distance: '2.8 km',
      rating: '4.7',
      reviews: '98',
      tags: ['Back pain', 'Geriatric'],
      hours: 'Open 9 AM – 8 PM',
      about:
          'Modern rehab facility with electrotherapy, manual therapy and '
          'exercise studios. Home visits available within 5 km. Insurance & '
          'corporate packages accepted.',
      therapists: [
        PhysioTherapist(
          initials: 'IK',
          name: 'Dr. Imrul Kayes',
          focus: 'Spine & back pain',
          years: '12 yrs',
          fee: '৳1000',
        ),
      ],
    ),
    PhysioCenter(
      name: 'Stride Physio Clinic',
      area: 'Uttara Sector 7',
      distance: '6.1 km',
      rating: '4.6',
      reviews: '64',
      tags: ['Pediatric', 'Stroke'],
      hours: 'Open 9 AM – 7 PM',
      about:
          'Family physio clinic with paediatric and stroke recovery units. '
          'Friendly therapists and home-exercise coaching.',
      therapists: [
        PhysioTherapist(
          initials: 'SA',
          name: 'Dr. Sumona Ahmed',
          focus: 'Pediatric & stroke',
          years: '8 yrs',
          fee: '৳900',
        ),
      ],
    ),
  ];

  final List<PhysioSession> sessions = const [
    PhysioSession(
      doctor: 'Dr. Farzana Haque',
      center: 'Mobility+ Physiotherapy',
      when: 'Tomorrow · 5:30 PM',
      status: SessionStatus.upcoming,
    ),
    PhysioSession(
      doctor: 'Dr. Imrul Kayes',
      center: 'ReActive Rehab Center',
      when: '2 May · 6:00 PM',
      status: SessionStatus.completed,
      progress: 'Session 4 of 8',
    ),
  ];

  // ---- Selection / booking state ----
  PhysioCenter? center;
  PhysioTherapist? therapist;

  int sessionType = 0; // 0 = At center, 1 = Home visit
  int dateIndex = 1; // default Tue 30
  int timeIndex = 3; // default 5:30 PM

  final List<(String, String)> dates = const [
    ('Today', '29 May'),
    ('Tue', '30'),
    ('Wed', '31'),
    ('Thu', '1'),
  ];

  final List<String> times = const [
    '10:00 AM',
    '11:30 AM',
    '4:00 PM',
    '5:30 PM',
    '6:30 PM',
    '7:30 PM',
  ];

  String get selectedTime => times[timeIndex];
  String get selectedDateLabel {
    final d = dates[dateIndex];
    return d.$1 == 'Today' ? d.$1 : '${d.$1} ${d.$2}';
  }

  void setSessionType(int v) {
    sessionType = v;
    update();
  }

  void setDate(int i) {
    dateIndex = i;
    update();
  }

  void setTime(int i) {
    timeIndex = i;
    update();
  }

  // ---- Navigation ----
  void openSessions() => Get.toNamed(Routes.PHYSIO_SESSIONS);

  void openCenter(PhysioCenter c) {
    center = c;
    update();
    Get.toNamed(Routes.PHYSIO_CENTER);
  }

  void bookTherapist(PhysioTherapist t) {
    therapist = t;
    // reset booking defaults
    sessionType = 0;
    dateIndex = 1;
    timeIndex = 3;
    update();
    Get.toNamed(Routes.PHYSIO_BOOK);
  }

  void confirmBooking() => Get.toNamed(Routes.PHYSIO_BOOKED);

  void viewMySessions() => Get.toNamed(Routes.PHYSIO_SESSIONS);

  void backToPhysioHome() => Get.until((r) => Get.currentRoute == Routes.PHYSIO);
}
