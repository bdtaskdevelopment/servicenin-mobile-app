import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/helpers/snack_helper.dart';
import '../../../data/models/response/healthcare_response.dart';
import '../../../data/repositories/healthcare.repo.dart';
import '../../../routes/app_pages.dart';
import 'appointments_controller.dart';
import 'healthcare_controller.dart';

class BookingController extends GetxController {
  HealthcareRepository get _repo => Get.find<HealthcareRepository>();
  HealthcareController get _hc => Get.find<HealthcareController>();

  // ── Selected doctor (basics from the list) ──────────────────────────
  HcDoctor? _doctor;
  String get doctorId => _doctor?.id ?? '';
  String get doctorName => _doctor?.name ?? 'Doctor';
  String get doctorInitials => _doctor?.initials ?? 'D';
  String get doctorSpecialty => _doctor?.specialty ?? '';
  /// Fee shown on the profile / booking. Free doctors (`is_paid == false`)
  /// always show "Free"; paid doctors show their consultation fee.
  String get doctorFee {
    if (!isPaid) return 'Free'.tr;
    return profile?.doctor.feeLabel ?? _doctor?.fee ?? '৳0';
  }

  /// Whether this doctor charges for a visit. Source of truth is the API's
  /// `is_paid` flag (NOT the fee amount): `true` → paid, show the fee and the
  /// payment step; `false` → free, skip payment and book directly.
  ///
  /// The doctors-list value is reliable, while the profile endpoint may omit
  /// the flag (parsing to `false`), so a doctor counts as paid when *either*
  /// source reports paid — this prevents the profile response from wrongly
  /// downgrading a paid doctor to free.
  bool get isPaid =>
      (_doctor?.isPaid ?? false) || (profile?.doctor.isPaid ?? false);

  void setDoctor(HcDoctor d) {
    _doctor = d;
    profile = null;
    venues = [];
    _dates = [];
    _slots = [];
    update();
    fetchProfile();
  }

  // ── Doctor profile ──────────────────────────────────────────────────
  DoctorProfile? profile;
  bool loadingProfile = false;

  String get fullDegree =>
      profile?.degrees.join(', ') ?? _doctor?.degree ?? '';
  String get bmdc => profile?.doctor.licenseNo ?? '';
  String get experience =>
      '${profile?.experienceYears ?? _doctor?.reviews ?? 0} yrs';
  String get reviewsCount => '${profile?.reviewsTotal ?? 0}';
  String get ratingLabel =>
      (profile?.rating ?? 0) > 0 ? profile!.rating.toStringAsFixed(1) : (_doctor?.rating ?? '0.0');
  String get avgWait => '~10 min';
  String get about =>
      (profile?.bio.isNotEmpty ?? false) ? profile!.bio : 'No bio available.';
  String get speaks => 'Speaks বাংলা · English';
  List<DoctorReview> get docReviews => profile?.reviews ?? [];

  bool submittingReview = false;
  Future<void> submitReview(int rating, String comment) async {
    if (doctorId.isEmpty || submittingReview) return;
    submittingReview = true;
    update();
    try {
      final res = await _repo.submitReview(doctorId, rating, comment);
      SnackHelper.success(
          res.message.isNotEmpty ? res.message : 'Review submitted');
      await fetchProfile(); // refresh the reviews list
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      submittingReview = false;
      update();
    }
  }

  Future<void> fetchProfile() async {
    if (doctorId.isEmpty) return;
    loadingProfile = true;
    update();
    try {
      profile = await _repo.fetchDoctorProfile(doctorId);
      venues = profile!.venues;
      selectedVenue = 0;
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingProfile = false;
      update();
    }
  }

  // ── Venues ──────────────────────────────────────────────────────────
  List<Venue> venues = [];
  int selectedVenue = 0;
  String get venueName =>
      (selectedVenue < venues.length) ? venues[selectedVenue].venueName : '';
  String? get _venueId =>
      (selectedVenue < venues.length) ? venues[selectedVenue].id : null;

  Future<void> selectVenue(int i) async {
    selectedVenue = i;
    update();
    await fetchDates();
  }

  // ── Schedule dates ──────────────────────────────────────────────────
  List<ScheduleDate> _dates = [];
  int selectedDate = 0;
  bool loadingDates = false;

  /// Records for the date strip: (dayShort, "dd MMM").
  List<(String, String)> get dates =>
      _dates.map((d) => (d.dayShort, d.dayNum)).toList();

  Future<void> fetchDates() async {
    final vid = _venueId;
    if (doctorId.isEmpty || vid == null) return;
    loadingDates = true;
    update();
    try {
      _dates = await _repo.fetchScheduleDates(doctorId, vid);
      selectedDate = 0;
      _slots = [];
      if (_dates.isNotEmpty) await fetchSlots();
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingDates = false;
      update();
    }
  }

  Future<void> selectDate(int i) async {
    selectedDate = i;
    update();
    await fetchSlots();
  }

  // ── Time slots ──────────────────────────────────────────────────────
  List<TimeSlot> _slots = [];
  String selectedTime = '';
  bool loadingSlots = false;

  /// Records for the time grid: (label, isAvailable).
  List<(String, bool)> get times =>
      _slots.map((s) => (s.label, !s.isBooked)).toList();

  Future<void> fetchSlots() async {
    final vid = _venueId;
    if (doctorId.isEmpty || vid == null || selectedDate >= _dates.length) return;
    loadingSlots = true;
    update();
    try {
      _slots = await _repo.fetchTimeSlots(
          doctorId, vid, _dates[selectedDate].date);
      final firstFree = _slots.firstWhere((s) => !s.isBooked,
          orElse: () => _slots.isNotEmpty ? _slots.first : TimeSlot(time: '', label: '', isBooked: true));
      selectedTime = firstFree.label;
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingSlots = false;
      update();
    }
  }

  void selectTime(String label) {
    selectedTime = label;
    update();
  }

  TimeSlot? get _selectedSlot {
    for (final s in _slots) {
      if (s.label == selectedTime) return s;
    }
    return null;
  }

  String get slotSummary {
    if (selectedDate >= _dates.length) return '';
    return '${_dates[selectedDate].dayShort} · $selectedTime';
  }

  String get whenSummary {
    if (selectedDate >= _dates.length) return selectedTime;
    return '${_dates[selectedDate].dateLabel} · $selectedTime';
  }

  // ── Patients (family) ───────────────────────────────────────────────
  List<HcFamilyMember> get patients => _hc.family;
  int selectedPatient = 0;
  void selectPatient(int i) {
    selectedPatient = i;
    update();
  }

  String get patientName => (selectedPatient < patients.length)
      ? patients[selectedPatient].name
      : 'Patient';
  String? get _familyMemberId => (selectedPatient < patients.length)
      ? patients[selectedPatient].id
      : null;

  Future<void> addFamilyPatient({
    required String name,
    required String relation,
    required String age,
    required String gender,
    required String bloodGroup,
  }) async {
    final ok = await _hc.addFamilyMember(
      name: name,
      relation: relation,
      age: age,
      gender: gender,
      bloodGroup: bloodGroup,
    );
    if (ok) {
      selectedPatient = patients.length - 1;
      update();
    }
  }

  final List<String> reasonChips = const [
    'Chest pain', 'Follow-up', 'Fever', 'High BP', 'Routine check',
  ];
  final TextEditingController reasonCtrl = TextEditingController();
  void setReason(String r) {
    reasonCtrl.text = r;
    update();
  }

  // ── Attachment ──────────────────────────────────────────────────────
  String attachmentUrl = '';
  String attachmentName = '';
  bool uploadingAttachment = false;

  Future<void> pickAttachment() async {
    try {
      final picked =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked == null) return;
      uploadingAttachment = true;
      update();
      attachmentUrl = await _repo.uploadDocument(File(picked.path));
      attachmentName = picked.name;
      SnackHelper.success('Report attached');
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      uploadingAttachment = false;
      update();
    }
  }

  // ── Fees / payment ──────────────────────────────────────────────────
  String get consultationFee => doctorFee;
  String get platformFee => '৳0';
  String get firstVisitDiscount => '৳0';
  String get totalPayable => doctorFee;

  int selectedPay = 0; // 0 = Cash at chamber, 1 = bKash
  void selectPay(int i) {
    selectedPay = i;
    update();
  }

  // ── Booking ─────────────────────────────────────────────────────────
  HcAppointment? bookedAppointment;
  bool booking = false;
  String get token => '${bookedAppointment?.serialNo ?? ''}';

  Future<void> _book() async {
    final vid = _venueId;
    final slot = _selectedSlot;
    if (vid == null || slot == null || selectedDate >= _dates.length) {
      SnackHelper.error('সময় নির্বাচন করুন');
      return;
    }
    if (booking) return;
    booking = true;
    update();
    try {
      final date = _dates[selectedDate].date; // 2026-06-10
      final scheduledAt = '${date}T${slot.time}:00+06:00';
      final payload = <String, dynamic>{
        'doctor_id': doctorId,
        'venue_id': vid,
        'scheduled_at': scheduledAt,
        'type': 'in_person',
        'reason': reasonCtrl.text.trim(),
        'payment_method': selectedPay == 1 ? 'bkash' : 'cash',
        if (_familyMemberId != null && _familyMemberId!.isNotEmpty)
          'family_member_id': _familyMemberId,
        if (attachmentUrl.isNotEmpty) 'attachment_url': attachmentUrl,
      };
      bookedAppointment = await _repo.bookAppointment(payload);
      Get.toNamed(Routes.HC_CONFIRMED);
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      booking = false;
      update();
    }
  }

  // ── Navigation ──────────────────────────────────────────────────────
  void bookAppointment() {
    if (_dates.isEmpty) fetchDates();
    if (patients.isEmpty) _hc.fetchFamily();
    Get.toNamed(Routes.HC_SLOT);
  }

  void slotContinue() => Get.toNamed(Routes.HC_PATIENT);
  void patientContinue() => Get.toNamed(Routes.HC_REVIEW);
  void confirmBooking() => _book();
  void viewAppointment() {
    Get.find<AppointmentsController>().fetchMine();
    Get.until((route) => route.settings.name == Routes.HEALTHCARE);
    Get.toNamed(Routes.HEALTHCARE_APPOINTMENTS);
  }

  void backToHealthcareHome() =>
      Get.until((route) => route.settings.name == Routes.HEALTHCARE);

  @override
  void onClose() {
    reasonCtrl.dispose();
    super.onClose();
  }
}
