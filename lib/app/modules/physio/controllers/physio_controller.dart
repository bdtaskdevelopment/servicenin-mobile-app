import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/helpers/snack_helper.dart';
import '../../../data/models/response/physio_response.dart';
import '../../../data/repositories/physio.repo.dart';
import '../../../routes/app_pages.dart';

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

class PhysioSession {
  const PhysioSession({
    required this.id,
    required this.doctor,
    required this.center,
    required this.when,
    required this.status,
    required this.bookingGroupId,
    this.scheduledAt,
    this.progress,
  });
  final String id;
  final String doctor;
  final String center;
  final String when;
  // Raw backend status: pending / assigned / in_progress / completed /
  // cancelled — shown as-is so the app always matches whatever the admin
  // web panel set, instead of collapsing everything into "Upcoming".
  final String status;
  final String bookingGroupId;
  final DateTime? scheduledAt;
  final String? progress;

  // Still "open" (not finished) as long as it isn't completed/cancelled —
  // used only for grouping/headline logic, not for the status label itself.
  bool get isOpen {
    final s = status.toLowerCase();
    return s != 'completed' && s != 'cancelled' && s != 'canceled';
  }

  factory PhysioSession.fromApi(PhysioAppointment a) => PhysioSession(
        id: a.id,
        doctor: a.staffName.isNotEmpty ? a.staffName : 'Therapist',
        center: a.centerName,
        when: a.whenLabel,
        status: a.status,
        bookingGroupId: a.bookingGroupId,
        scheduledAt: a.scheduledAt,
        progress: null,
      );
}

class PhysioController extends GetxController {
  PhysioRepository get _repo => Get.find<PhysioRepository>();

  // ── Home: services + centers ─────────────────────────────────────────
  List<PhysioServiceItem> services = [];
  List<PhysioCenter> centers = [];
  bool loadingServices = false;
  bool loadingCenters = false;
  PhysioServiceItem? selectedService;

  @override
  void onInit() {
    super.onInit();
    fetchServices();
  }

  Future<void> fetchServices() async {
    loadingServices = true;
    update();
    try {
      services = await _repo.fetchServices();
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingServices = false;
      update();
    }
  }

  /// Selecting a service is mandatory before any center shows up — the
  /// center list only ever loads for the chosen service, re-filtered to
  /// actually have an available, accepted therapist right now. Services
  /// are a global catalog (no per-center assignment), so this isn't a
  /// service→center mapping — it's just "who can take this booking".
  Future<void> selectService(PhysioServiceItem s) async {
    selectedService = s;
    loadingCenters = true;
    update();
    try {
      final list = await _repo.fetchCentersForService(s.id);
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
    await refreshCenter();
  }

  /// Re-fetches the current center's detail + staff list — used both
  /// right after opening it and by the center page's pull-to-refresh.
  Future<void> refreshCenter() async {
    final c = center;
    if (c == null) return;
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

  // Day-count (multi-day booking): books the same therapist, same time,
  // for N consecutive days starting at the picked date. Full 1-30 range so
  // the dropdown offers every day count, not just a handful of presets.
  int dayCount = 1;
  static final List<int> dayCountOptions =
      List<int>.generate(30, (i) => i + 1);

  void setDayCount(int n) {
    dayCount = n;
    update();
  }

  int get perDayRate => selectedService == null
      ? 0
      : (sessionType == 1
          ? selectedService!.homePricePerDay
          : selectedService!.centerPricePerDay);

  int get totalPrice => perDayRate * dayCount;

  Future<void> bookTherapist(PhysioTherapist t) async {
    therapist = t;
    sessionType = 0;
    dateIndex = 0;
    selectedSlotAt = '';
    slots = [];
    dayCount = 1;
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

  /// Pull-to-refresh on the book-a-session page — re-fetches dates + the
  /// currently selected date's slots (keeping the user's date selection,
  /// unlike the initial load which always starts at day 0). Picks up any
  /// slot that just freed up, e.g. once an appointment there is marked
  /// completed/cancelled.
  Future<void> refreshBookView() async {
    loadingDates = true;
    update();
    try {
      final prevIndex = dateIndex;
      _dates = await _repo.fetchScheduleDates();
      dateIndex = prevIndex < _dates.length ? prevIndex : 0;
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
      final all = await _repo.fetchPaymentMethods();
      // Physio takes cash only — no online payment.
      paymentMethods = all
          .where((m) => m.enabled && m.key.toLowerCase() == 'cash')
          .toList();
      selectedPaymentKey =
          paymentMethods.isNotEmpty ? paymentMethods.first.key : 'cash';
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
    if (selectedService == null) {
      SnackHelper.error('সার্ভিস নির্বাচন করুন');
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
        'service_id': selectedService!.id,
        'day_count': dayCount,
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

  /// Groups [sessions] by bookingGroupId so a multi-day booking renders as
  /// one card ("Day X of N") instead of N disconnected rows. Sessions with
  /// no group id (the single-day majority) are each their own singleton
  /// group — a shared empty key would otherwise wrongly merge them.
  List<List<PhysioSession>> get sessionGroups {
    final byGroup = <String, List<PhysioSession>>{};
    var soloIdx = 0;
    for (final s in sessions) {
      final key =
          s.bookingGroupId.isNotEmpty ? s.bookingGroupId : 'solo-${soloIdx++}';
      byGroup.putIfAbsent(key, () => []).add(s);
    }
    for (final g in byGroup.values) {
      g.sort((a, b) =>
          (a.scheduledAt ?? DateTime(0)).compareTo(b.scheduledAt ?? DateTime(0)));
    }
    return byGroup.values.toList();
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
