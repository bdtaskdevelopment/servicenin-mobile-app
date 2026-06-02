import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import 'healthcare_controller.dart';

class HcVenue {
  const HcVenue(this.name, this.schedule);
  final String name;
  final String schedule;
}

class BookingPatient {
  const BookingPatient(this.initials, this.name, this.relation, this.info);
  final String initials;
  final String name;
  final String relation;
  final String info;
}

class DocReview {
  const DocReview(this.initials, this.name, this.text);
  final String initials;
  final String name;
  final String text;
}

class BookingController extends GetxController {
  HcDoctor? doctor;
  void setDoctor(HcDoctor d) {
    doctor = d;
    update();
  }

  String get doctorName => doctor?.name ?? 'Dr. Salma Akter';
  String get doctorInitials => doctor?.initials ?? 'SA';
  String get doctorSpecialty => doctor?.specialty ?? 'Cardiology';
  String get doctorFee => doctor?.fee ?? '৳700';

  // ── Profile (static demo) ────────────────────────────────────────
  final String fullDegree = 'MBBS, FCPS (Cardiology)';
  final String bmdc = 'BMDC 12345';
  final String experience = '14 yrs';
  final String reviewsCount = '312';
  final String avgWait = '~8 min';
  final String about =
      'Senior consultant cardiologist with 14 years treating hypertension, arrhythmia and post-MI care. Visiting consultant across 3 Gulshan-area chambers.';
  final String speaks = 'Speaks বাংলা · English';

  final List<HcVenue> venues = const [
    HcVenue('Popular Diagnostic, Gulshan', 'Sat · Mon · Wed · 3–5 PM'),
    HcVenue('Praava Health, Banani', 'Sun · Tue · 6–8 PM'),
  ];

  final List<DocReview> docReviews = const [
    DocReview('MR', 'Mahmud R.',
        'Very thorough and patient. Explained the ECG results clearly and adjusted my dosage. Highly recommend.'),
  ];

  // ── Slot ─────────────────────────────────────────────────────────
  int selectedVenue = 0;
  void selectVenue(int i) {
    selectedVenue = i;
    update();
  }

  final List<(String, String)> dates = const [
    ('Today', '15 May'),
    ('Tomorrow', '16 May'),
    ('Sat', '17 May'),
    ('Sun', '18 May'),
    ('Mon', '19 May'),
  ];
  int selectedDate = 0;
  void selectDate(int i) {
    selectedDate = i;
    update();
  }

  // (time, available)
  final List<(String, bool)> times = const [
    ('3:00', true),
    ('3:20', true),
    ('3:40', true),
    ('4:00', true),
    ('4:20', true),
    ('4:40', false),
    ('5:00', true),
    ('5:20', true),
  ];
  String selectedTime = '3:40';
  void selectTime(String t) {
    selectedTime = t;
    update();
  }

  String get venueName => venues[selectedVenue].name;
  String get dateLabel => '${dates[selectedDate].$1} · ${dates[selectedDate].$2}';
  String get whenSummary => '${dates[selectedDate].$1} · $selectedTime PM';

  // ── Patient ──────────────────────────────────────────────────────
  final List<BookingPatient> patients = const [
    BookingPatient('TA', 'Tanzil Ahmed', 'Self', '32 yrs · M · B+'),
    BookingPatient('AU', 'Md. Ahsan Ullah', 'Father', '68 yrs · M · B+ · Diabetic'),
    BookingPatient('RB', 'Rokeya Begum', 'Mother', '61 yrs · F · A+'),
  ];
  int selectedPatient = 0;
  void selectPatient(int i) {
    selectedPatient = i;
    update();
  }

  BookingPatient get patient => patients[selectedPatient];

  final List<String> reasonChips = const [
    'Chest pain', 'Follow-up', 'High BP', 'Palpitation', 'Routine check',
  ];

  // ── Fees / payment ───────────────────────────────────────────────
  final String consultationFee = '৳700';
  final String platformFee = '৳20';
  final String firstVisitDiscount = '-৳50';
  final String totalPayable = '৳670';

  int selectedPay = 1; // 0 = Cash at chamber, 1 = bKash
  void selectPay(int i) {
    selectedPay = i;
    update();
  }

  // ── Appointment detail ───────────────────────────────────────────
  final String apptId = 'APT-7741';
  final String token = '14';
  final String nowServing = 'Token 9 · ~25 min';
  final int aheadOfYou = 5;
  final String venueAddress = 'House 9, Road 7 · Level 4, Chamber 12 · 3.1 km';

  // ── Navigation ───────────────────────────────────────────────────
  void bookAppointment() => Get.toNamed(Routes.HC_SLOT);
  void slotContinue() => Get.toNamed(Routes.HC_PATIENT);
  void patientContinue() => Get.toNamed(Routes.HC_REVIEW);
  void confirmBooking() => Get.toNamed(Routes.HC_CONFIRMED);
  void viewAppointment() => Get.toNamed(Routes.HC_APPOINTMENT);
  void backToHealthcareHome() =>
      Get.until((route) => route.settings.name == Routes.HEALTHCARE);
}
