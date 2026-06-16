import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/helpers/snack_helper.dart';
import '../../../data/models/response/physio_response.dart';
import '../../../data/repositories/physio.repo.dart';
import '../../../routes/app_pages.dart';

IconData physioConcernIcon(String iconOrKey) {
  final s = iconOrKey.toLowerCase();
  if (s.contains('spine') || s.contains('back')) {
    return Icons.airline_seat_recline_normal_rounded;
  }
  if (s.contains('sport')) return Icons.sports_handball_rounded;
  if (s.contains('surg') || s.contains('heal')) return Icons.healing_rounded;
  if (s.contains('neuro') || s.contains('brain')) {
    return Icons.psychology_rounded;
  }
  if (s.contains('knee') || s.contains('joint') || s.contains('arth')) {
    return Icons.accessibility_new_rounded;
  }
  if (s.contains('neck')) return Icons.self_improvement_rounded;
  if (s.contains('stroke')) return Icons.favorite_rounded;
  return Icons.healing_rounded;
}

class PhysioConcern {
  const PhysioConcern(this.label, this.icon, {this.key = ''});
  final String label;
  final IconData icon;
  final String key;

  factory PhysioConcern.fromApi(PhysioConcernModel c) =>
      PhysioConcern(c.label, physioConcernIcon(c.icon.isNotEmpty ? c.icon : c.key),
          key: c.key);
}

class PhysioTherapist {
  const PhysioTherapist({
    required this.initials,
    required this.name,
    required this.focus,
    required this.years,
    required this.fee,
    this.id = '',
  });
  final String initials;
  final String name;
  final String focus;
  final String years;
  final String fee;
  final String id;

  factory PhysioTherapist.fromApi(PhysioStaff s) => PhysioTherapist(
        id: s.id,
        initials: s.initials,
        name: s.fullName,
        focus: s.specialization,
        years: s.yearsExp > 0 ? '${s.yearsExp} yrs' : (s.schedule),
        fee: '',
      );
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
    this.id = '',
    this.contact = '',
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
  final String id;
  final String contact;

  factory PhysioCenter.fromApi(PhysioCenterModel c) {
    final tags =
        c.matchingTherapists.map((t) => t.specialization).toSet().toList();
    return PhysioCenter(
      id: c.id,
      name: c.name,
      area: c.address,
      distance: c.wardNo.isNotEmpty ? 'Ward ${c.wardNo}' : '',
      rating: '',
      reviews: '',
      tags: tags,
      hours: '',
      about: c.description,
      contact: c.contactPhone,
      therapists: c.matchingTherapists.map(PhysioTherapist.fromApi).toList(),
    );
  }
}

enum SessionStatus { upcoming, completed }

class PhysioSession {
  const PhysioSession({
    required this.id,
    required this.doctor,
    required this.center,
    required this.when,
    required this.status,
    this.progress,
  });
  final String id;
  final String doctor;
  final String center;
  final String when;
  final SessionStatus status;
  final String? progress;

  factory PhysioSession.fromApi(PhysioAppointment a) => PhysioSession(
        id: a.id,
        doctor: a.staffName.isNotEmpty ? a.staffName : 'Therapist',
        center: a.centerName,
        when: a.whenLabel,
        status:
            a.upcoming ? SessionStatus.upcoming : SessionStatus.completed,
        progress: null,
      );
}

class PhysioController extends GetxController {
  PhysioRepository get _repo => Get.find<PhysioRepository>();

  // ── Home: concerns + centers ────────────────────────────────────────
  List<PhysioConcern> concerns = [];
  List<PhysioCenter> centers = [];
  bool loadingConcerns = false;
  bool loadingCenters = false;
  String selectedConcernKey = '';
  String selectedConcernLabel = '';

  @override
  void onInit() {
    super.onInit();
    fetchConcerns();
    fetchCenters();
  }

  Future<void> fetchConcerns() async {
    loadingConcerns = true;
    update();
    try {
      final list = await _repo.fetchConcerns();
      concerns = list.map(PhysioConcern.fromApi).toList();
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingConcerns = false;
      update();
    }
  }

  Future<void> fetchCenters() async {
    loadingCenters = true;
    update();
    try {
      final list = await _repo.fetchCenters();
      centers = list.map(PhysioCenter.fromApi).toList();
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingCenters = false;
      update();
    }
  }

  Future<void> selectConcern(PhysioConcern c) async {
    selectedConcernKey = c.key;
    selectedConcernLabel = c.label;
    loadingCenters = true;
    update();
    try {
      final list = await _repo.fetchCentersForConcern(c.key);
      centers = list.map(PhysioCenter.fromApi).toList();
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingCenters = false;
      update();
    }
  }

  // ── Center detail + staff ───────────────────────────────────────────
  PhysioCenter? center;
  bool loadingCenter = false;

  Future<void> openCenter(PhysioCenter c) async {
    center = c;
    update();
    Get.toNamed(Routes.PHYSIO_CENTER);
    loadingCenter = true;
    update();
    try {
      final detail = await _repo.fetchCenter(c.id);
      final staff = await _repo.fetchStaff(c.id);
      center = PhysioCenter.fromApi(detail);
      center = PhysioCenter(
        id: center!.id,
        name: center!.name,
        area: center!.area,
        distance: center!.distance,
        rating: center!.rating,
        reviews: center!.reviews,
        tags: staff.map((s) => s.specialization).toSet().toList(),
        hours: center!.hours,
        about: center!.about,
        contact: center!.contact,
        therapists: staff.map(PhysioTherapist.fromApi).toList(),
      );
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingCenter = false;
      update();
    }
  }

  // ── Booking ─────────────────────────────────────────────────────────
  PhysioTherapist? therapist;
  int sessionType = 0; // 0 = center, 1 = home

  List<PhysioScheduleDate> _dates = [];
  int dateIndex = 0;
  bool loadingDates = false;
  List<PhysioScheduleDate> get scheduleDates => _dates;

  List<PhysioTimeSlot> slots = [];
  String selectedSlotAt = '';
  bool loadingSlots = false;

  List<PhysioOption> paymentMethods = [];
  String selectedPaymentKey = '';
  bool loadingPayments = false;

  final TextEditingController notesCtrl = TextEditingController();
  final TextEditingController homeAddressCtrl = TextEditingController();

  bool booking = false;
  PhysioAppointment? lastAppointment;

  void setSessionType(int v) {
    sessionType = v;
    update();
  }

  void selectPayment(String key) {
    selectedPaymentKey = key;
    update();
  }

  void selectSlot(String at) {
    selectedSlotAt = at;
    update();
  }

  String get selectedDateLabel =>
      dateIndex < _dates.length ? _dates[dateIndex].label : '';

  String get selectedTime {
    final s = slots.firstWhereOrNull((x) => x.scheduledAt == selectedSlotAt);
    return s?.time ?? '';
  }

  Future<void> bookTherapist(PhysioTherapist t) async {
    therapist = t;
    sessionType = 0;
    dateIndex = 0;
    selectedSlotAt = '';
    slots = [];
    notesCtrl.clear();
    update();
    Get.toNamed(Routes.PHYSIO_BOOK);
    await _loadDates();
    await _loadPayments();
  }

  Future<void> _loadDates() async {
    loadingDates = true;
    update();
    try {
      _dates = await _repo.fetchScheduleDates();
      dateIndex = 0;
      if (_dates.isNotEmpty) await loadSlotsForSelectedDate();
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingDates = false;
      update();
    }
  }

  void selectDate(int i) {
    dateIndex = i;
    update();
    loadSlotsForSelectedDate();
  }

  Future<void> loadSlotsForSelectedDate() async {
    final staffId = therapist?.id ?? '';
    if (staffId.isEmpty || dateIndex >= _dates.length) return;
    loadingSlots = true;
    update();
    try {
      slots = await _repo.fetchTimeSlots(staffId, _dates[dateIndex].date);
      final firstFree = slots.firstWhereOrNull((s) => s.available);
      selectedSlotAt = firstFree?.scheduledAt ?? '';
    } catch (_) {
    } finally {
      loadingSlots = false;
      update();
    }
  }

  Future<void> _loadPayments() async {
    loadingPayments = true;
    update();
    try {
      paymentMethods = await _repo.fetchPaymentMethods();
      final def = await _repo.fetchDefaultPaymentMethod();
      selectedPaymentKey = def.isNotEmpty
          ? def
          : (paymentMethods.firstWhereOrNull((m) => m.enabled)?.key ?? '');
    } catch (_) {
    } finally {
      loadingPayments = false;
      update();
    }
  }

  Future<void> confirmBooking() async {
    if (booking) return;
    final staffId = therapist?.id ?? '';
    final centerId = center?.id ?? '';
    if (staffId.isEmpty || centerId.isEmpty) {
      SnackHelper.error('থেরাপিস্ট নির্বাচন করুন');
      return;
    }
    if (selectedSlotAt.isEmpty) {
      SnackHelper.error('সময় নির্বাচন করুন');
      return;
    }
    if (sessionType == 1 && homeAddressCtrl.text.trim().isEmpty) {
      SnackHelper.error('হোম ভিজিটের ঠিকানা দিন');
      return;
    }
    booking = true;
    update();
    try {
      final payload = {
        'staff_id': staffId,
        'center_id': centerId,
        'appointment_type': sessionType == 1 ? 'home' : 'center',
        'concern': selectedConcernKey,
        'scheduled_at': selectedSlotAt,
        'payment_method':
            selectedPaymentKey.isNotEmpty ? selectedPaymentKey : 'cash',
        'home_address': sessionType == 1 ? homeAddressCtrl.text.trim() : '',
        'notes': notesCtrl.text.trim(),
      };
      lastAppointment = await _repo.book(payload);
      Get.toNamed(Routes.PHYSIO_BOOKED);
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      booking = false;
      update();
    }
  }

  // ── My sessions ─────────────────────────────────────────────────────
  List<PhysioSession> sessions = [];
  bool loadingSessions = false;

  void openSessions() {
    fetchMySessions();
    Get.toNamed(Routes.PHYSIO_SESSIONS);
  }

  void viewMySessions() {
    fetchMySessions();
    Get.until((r) => r.settings.name == Routes.PHYSIO);
    Get.toNamed(Routes.PHYSIO_SESSIONS);
  }

  Future<void> fetchMySessions() async {
    loadingSessions = true;
    update();
    try {
      final list = await _repo.fetchMyAppointments();
      sessions = list.map(PhysioSession.fromApi).toList();
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingSessions = false;
      update();
    }
  }

  void backToPhysioHome() =>
      Get.until((r) => r.settings.name == Routes.PHYSIO);

  @override
  void onClose() {
    notesCtrl.dispose();
    homeAddressCtrl.dispose();
    super.onClose();
  }
}
