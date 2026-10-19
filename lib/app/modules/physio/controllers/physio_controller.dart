import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/helpers/snack_helper.dart';
import '../../../core/mixins/live_refresh_mixin.dart';
import '../../../data/models/response/physio_response.dart';
import '../../../data/models/sn_place.dart';
import '../../../data/repositories/physio.repo.dart';
import '../../../routes/app_pages.dart';
import '../views/physio_address_search_view.dart';

/// A center in the picker list — the first step of the new center-first
/// flow (was previously only reachable after picking a service).
class PhysioCenter {
  const PhysioCenter({
    required this.id,
    required this.name,
    required this.area,
    required this.contact,
    required this.about,
    required this.wardNo,
  });
  final String id;
  final String name;
  final String area;
  final String contact;
  final String about;
  final String wardNo;

  factory PhysioCenter.fromApi(PhysioCenterModel c) => PhysioCenter(
        id: c.id,
        name: c.name,
        area: c.address,
        contact: c.contactPhone,
        about: c.description,
        wardNo: c.wardNo,
      );
}

class PhysioSession {
  const PhysioSession({
    required this.id,
    required this.staffName,
    required this.center,
    required this.centerId,
    required this.when,
    required this.status,
    required this.bookingGroupId,
    required this.items,
    this.scheduledAt,
    this.progress,
    this.paymentStatus = '',
    this.kind = '',
    this.reportUrl = '',
  });
  final String id;
  final String staffName;
  final String center;
  final String centerId;
  final String when;
  // Raw backend status: pending / assigned / in_progress / processing /
  // report_ready / completed / cancelled — shown as-is so the app always
  // matches whatever the admin web panel set, instead of collapsing
  // everything into "Upcoming".
  final String status;
  final String bookingGroupId;
  final DateTime? scheduledAt;
  final String? progress;
  // paid / partial / free / unpaid — mirrors home-service's payment pill.
  final String paymentStatus;
  final List<PhysioAppointmentItem> items;
  // "lab" | "patient_care" — see PhysioAppointment.kind.
  final String kind;
  final String reportUrl;

  bool get awaitingAssignment => staffName.isEmpty;

  /// True for a lab/X-ray session — see PhysioAppointment.isLabOnly for
  /// why this prefers `kind` over the items-derivation.
  bool get isLabOnly => kind.isNotEmpty
      ? kind == 'lab'
      : (items.isNotEmpty && items.every((i) => i.categoryKind == 'lab'));

  // Still "open" (not finished) as long as it isn't completed/cancelled —
  // used only for grouping/headline logic, not for the status label itself.
  bool get isOpen {
    final s = status.toLowerCase();
    return s != 'completed' && s != 'cancelled' && s != 'canceled';
  }

  factory PhysioSession.fromApi(PhysioAppointment a) => PhysioSession(
        id: a.id,
        staffName: a.staffName,
        center: a.centerName,
        centerId: a.centerId,
        when: a.whenLabel,
        status: a.status,
        bookingGroupId: a.bookingGroupId,
        scheduledAt: a.scheduledAt,
        progress: null,
        paymentStatus: a.paymentStatus,
        items: a.items,
        kind: a.kind,
        reportUrl: a.reportUrl,
      );
}

class PhysioController extends GetxController with LiveRefreshMixin {
  PhysioRepository get _repo => Get.find<PhysioRepository>();

  // ── Home: center picker ──────────────────────────────────────────────
  List<PhysioCenter> centers = [];
  bool loadingCenters = false;

  // ── Live refresh (LiveRefreshMixin) ─────────────────────────────────
  // No per-session detail page, so this is a LIST refresher (empty id):
  // any physio status change re-pulls the "my sessions" list.
  @override
  Set<String> get liveRefreshTypes => {'physio_appointment'};
  @override
  String get liveRefreshId => '';
  @override
  Future<void> onLiveRefresh() => fetchMySessions();

  @override
  void onInit() {
    super.onInit();
    fetchCenters();
    startLiveRefresh();
    // A lat/lng captured from the map search is only valid for the exact
    // text it was resolved from — if the user types over it afterward,
    // drop the now-stale coordinates rather than submit a mismatch.
    homeAddressCtrl.addListener(() {
      if (homeAddressLat != null) {
        homeAddressLat = null;
        homeAddressLng = null;
      }
    });
    addressCtrl.addListener(() {
      if (addressLat != null) {
        addressLat = null;
        addressLng = null;
      }
    });
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

  // ── Center: kind picker + catalog + cart ────────────────────────────
  PhysioCenter? center;
  // 'lab' | 'patient_care' | null (null = still choosing a kind)
  String? selectedKind;
  bool loadingCatalog = false;
  List<PhysioCatalogItem> catalog = [];
  final Map<String, List<PhysioCatalogItem>> _catalogByKind = {};
  final Map<String, PhysioCatalogItem> _itemsById = {};

  // Free-text + category filter over the currently-open kind's catalog —
  // purely client-side (the whole kind's catalog is already fetched), so
  // filtering never re-hits the network.
  final TextEditingController catalogSearchCtrl = TextEditingController();
  String catalogSearch = '';
  // null = "All categories".
  String? selectedCategoryId;

  void setCatalogSearch(String q) {
    catalogSearch = q;
    update();
  }

  void selectCategory(String? categoryId) {
    selectedCategoryId = categoryId;
    update();
  }

  void _resetCatalogFilters() {
    catalogSearch = '';
    catalogSearchCtrl.clear();
    selectedCategoryId = null;
  }

  /// Distinct categories present in the current kind's catalog, in the
  /// order they first appear — drives the filter chip row. Independent of
  /// the active search/category filter so switching categories never
  /// hides the chip you'd need to switch back.
  List<MapEntry<String, String>> get catalogCategories {
    final seen = <String>{};
    final out = <MapEntry<String, String>>[];
    for (final item in catalog) {
      if (item.categoryId.isEmpty || seen.contains(item.categoryId)) continue;
      seen.add(item.categoryId);
      out.add(MapEntry(item.categoryId, item.categoryName));
    }
    return out;
  }

  /// The catalog actually rendered — [catalog] narrowed by the selected
  /// category and/or the free-text search (matches name or description).
  List<PhysioCatalogItem> get filteredCatalog {
    var list = catalog;
    final categoryId = selectedCategoryId;
    if (categoryId != null) {
      list = list.where((i) => i.categoryId == categoryId).toList();
    }
    final q = catalogSearch.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where((i) =>
              i.name.toLowerCase().contains(q) ||
              i.description.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  // Cart — keyed by service id, same Map<String,int> shape as Home
  // Service's cart (home_service_controller.dart). Locked to ONE kind per
  // checkout once it has an item — a booking can't mix lab/X-ray and
  // therapy services (they go through different status pipelines
  // server-side, see PhysioAppointment.kind) — _cartKind tracks whichever
  // kind the cart's current items came from, and resets once it's empty.
  final Map<String, int> _cart = {};
  String? _cartKind;

  void openCenter(PhysioCenter c) {
    center = c;
    selectedKind = null;
    catalog = [];
    _catalogByKind.clear();
    _itemsById.clear();
    _cart.clear();
    _cartKind = null;
    _resetCatalogFilters();
    update();
    Get.toNamed(Routes.PHYSIO_CENTER);
  }

  Future<void> selectKind(String kind) async {
    selectedKind = kind;
    _resetCatalogFilters();
    update();
    await _loadCatalog(kind);
  }

  void backToKindPicker() {
    selectedKind = null;
    update();
  }

  Future<void> _loadCatalog(String kind) async {
    final c = center;
    if (c == null) return;
    final cached = _catalogByKind[kind];
    if (cached != null) {
      catalog = cached;
      update();
      return;
    }
    loadingCatalog = true;
    update();
    try {
      final list = await _repo.fetchCenterCatalog(c.id, kind);
      _catalogByKind[kind] = list;
      for (final item in list) {
        _itemsById[item.id] = item;
      }
      catalog = list;
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingCatalog = false;
      update();
    }
  }

  /// Re-fetches the currently-open kind's catalog — pull-to-refresh.
  Future<void> refreshCenter() async {
    final kind = selectedKind;
    if (kind == null) return;
    _catalogByKind.remove(kind);
    await _loadCatalog(kind);
  }

  int qtyOf(String serviceId) => _cart[serviceId] ?? 0;

  void addToCart(PhysioCatalogItem item) {
    final kind = selectedKind;
    if (_cartKind != null && kind != null && _cartKind != kind) {
      SnackHelper.error('Your cart already has ${_cartKind == 'lab' ? 'lab/X-ray' : 'therapy'} services — clear it before adding a ${kind == 'lab' ? 'lab/X-ray' : 'therapy'} service.'
          .tr);
      return;
    }
    _itemsById[item.id] = item;
    // Patient-care items are a single pick per session — how many visits
    // that becomes is set up on the backend afterwards, not chosen here —
    // so adding it again just keeps it selected rather than stacking a
    // quantity. Lab/X-ray items can still be ordered more than one at a
    // time (e.g. two X-rays).
    _cart[item.id] =
        kind == 'patient_care' ? 1 : (_cart[item.id] ?? 0) + 1;
    _cartKind = kind;
    update();
  }

  void removeFromCart(PhysioCatalogItem item) {
    final current = _cart[item.id] ?? 0;
    if (current <= 1) {
      _cart.remove(item.id);
    } else {
      _cart[item.id] = current - 1;
    }
    if (_cart.isEmpty) _cartKind = null;
    update();
  }

  int get totalItems => _cart.values.fold(0, (a, b) => a + b);

  /// Cart rows as (item, quantity) pairs, resolved against every kind
  /// fetched so far — so a lab item added before switching to Patient
  /// care still shows correctly in the cart/checkout.
  List<MapEntry<PhysioCatalogItem, int>> get cartItems => _cart.entries
      .where((e) => _itemsById.containsKey(e.key))
      .map((e) => MapEntry(_itemsById[e.key]!, e.value))
      .toList();

  String get _visitType => sessionType == 1 ? 'home' : 'center';

  int get cartTotal =>
      cartItems.fold(0, (sum, e) => sum + e.key.priceFor(_visitType) * e.value);

  /// Sum of struck-through original prices where a discount applies,
  /// otherwise the payable price — for an "original total" comparison
  /// line on the checkout summary.
  int get cartOriginalTotal => cartItems.fold(
      0,
      (sum, e) =>
          sum +
          (e.key.originalPriceFor(_visitType) ?? e.key.priceFor(_visitType)) *
              e.value);

  bool get cartHasDiscount => cartOriginalTotal > cartTotal;

  /// Cart total for a specific visit type ('center'|'home'), independent
  /// of whichever one is currently selected — lets the checkout screen
  /// compare both without actually switching [sessionType].
  int cartTotalFor(String visitType) =>
      cartItems.fold(0, (sum, e) => sum + e.key.priceFor(visitType) * e.value);

  /// True when the cart would actually cost something different between
  /// center and home visits — gates the "why did the price change"
  /// explanation on the visit-type toggle, so it only shows up when
  /// there's a real difference to explain.
  bool get visitPriceDiffers => cartTotalFor('center') != cartTotalFor('home');

  // ── Checkout ──────────────────────────────────────────────────────────
  int sessionType = 0; // 0 = center, 1 = home

  List<PhysioScheduleDate> _dates = [];
  int dateIndex = 0;
  bool loadingDates = false;
  List<PhysioScheduleDate> get scheduleDates => _dates;

  TimeOfDay selectedTimeOfDay = const TimeOfDay(hour: 10, minute: 0);

  List<PhysioOption> paymentMethods = [];
  String selectedPaymentKey = '';
  bool loadingPayments = false;

  final TextEditingController notesCtrl = TextEditingController();
  final TextEditingController homeAddressCtrl = TextEditingController();
  // Residential address for CENTER visits — saved to the patient's
  // per-center profile so it's reusable on their next booking.
  final TextEditingController addressCtrl = TextEditingController();

  // Coordinates captured when the address was picked via Google Places
  // search (PhysioAddressSearchView) — same "clear on hand-edit" pattern
  // Home Service's address field uses, so a stale lat/lng never rides
  // along with a since-edited free-typed address.
  double? homeAddressLat;
  double? homeAddressLng;
  double? addressLat;
  double? addressLng;

  /// Opens the Google Places search page for [ctrl] and, if the user
  /// picks a result, fills the text field and captures its coordinates.
  Future<void> pickAddress({
    required TextEditingController ctrl,
    required bool isHome,
  }) async {
    final place = await Get.to<SnPlace>(
        () => const PhysioAddressSearchView(title: 'Search your address'));
    if (place == null) return;
    final text = place.address.isNotEmpty ? place.address : place.label;
    ctrl.text = text;
    if (isHome) {
      homeAddressLat = place.point.latitude;
      homeAddressLng = place.point.longitude;
    } else {
      addressLat = place.point.latitude;
      addressLng = place.point.longitude;
    }
    update();
  }

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

  void selectDate(int i) {
    dateIndex = i;
    // Switching back to today can leave a previously-picked time stranded
    // in the past (e.g. picked 9 AM for tomorrow, now viewing today at
    // 11 AM) — bump it forward so it's never silently invalid.
    if (isTodaySelected() && isPastTimeOfDay(selectedTimeOfDay)) {
      selectedTimeOfDay = earliestSelectableTimeToday();
    }
    update();
  }

  void selectTime(TimeOfDay t) {
    selectedTimeOfDay = t;
    update();
  }

  /// True when the currently selected schedule date is today — the only
  /// day a time-of-day can actually be "in the past".
  bool isTodaySelected() {
    if (dateIndex >= _dates.length) return false;
    final now = DateTime.now();
    final todayStr = '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    return _dates[dateIndex].date == todayStr;
  }

  bool isPastTimeOfDay(TimeOfDay t) {
    final now = DateTime.now();
    return t.hour < now.hour || (t.hour == now.hour && t.minute < now.minute);
  }

  /// A few minutes ahead of right now, so "earliest selectable" never
  /// reads as already-stale by the time the user taps Confirm.
  TimeOfDay earliestSelectableTimeToday() {
    final now = DateTime.now();
    var minute = now.minute + 5;
    var hour = now.hour;
    if (minute >= 60) {
      minute -= 60;
      hour += 1;
    }
    if (hour >= 24) return const TimeOfDay(hour: 23, minute: 59);
    return TimeOfDay(hour: hour, minute: minute);
  }

  String get selectedDateLabel =>
      dateIndex < _dates.length ? _dates[dateIndex].label : '';

  String get selectedTimeLabel {
    final h = selectedTimeOfDay.hour;
    final m = selectedTimeOfDay.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final h12 = h % 12 == 0 ? 12 : h % 12;
    return '$h12:$m $period';
  }

  /// Proceeds from the catalog/cart screen to checkout — validates the
  /// cart isn't empty first.
  void proceedToCheckout() {
    if (totalItems == 0) {
      SnackHelper.error('কমপক্ষে একটি সার্ভিস যুক্ত করুন');
      return;
    }
    sessionType = 0;
    dateIndex = 0;
    selectedTimeOfDay = const TimeOfDay(hour: 10, minute: 0);
    notesCtrl.clear();
    update();
    Get.toNamed(Routes.PHYSIO_BOOK);
    _loadDates();
    _loadPayments();
  }

  Future<void> _loadDates() async {
    loadingDates = true;
    update();
    try {
      _dates = await _repo.fetchScheduleDates();
      dateIndex = 0;
      // The default 10 AM may already be gone by the time someone opens
      // checkout later in the day.
      if (isTodaySelected() && isPastTimeOfDay(selectedTimeOfDay)) {
        selectedTimeOfDay = earliestSelectableTimeToday();
      }
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingDates = false;
      update();
    }
  }

  /// Pull-to-refresh on the checkout page — re-fetches dates, keeping the
  /// user's date selection where still possible.
  Future<void> refreshBookView() async {
    loadingDates = true;
    update();
    try {
      final prevIndex = dateIndex;
      _dates = await _repo.fetchScheduleDates();
      dateIndex = prevIndex < _dates.length ? prevIndex : 0;
      if (isTodaySelected() && isPastTimeOfDay(selectedTimeOfDay)) {
        selectedTimeOfDay = earliestSelectableTimeToday();
      }
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingDates = false;
      update();
    }
  }

  Future<void> _loadPayments() async {
    loadingPayments = true;
    update();
    try {
      final all = await _repo.fetchPaymentMethods();
      // Physio takes cash only — no online payment.
      paymentMethods =
          all.where((m) => m.enabled && m.key.toLowerCase() == 'cash').toList();
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
    final c = center;
    if (c == null || totalItems == 0) {
      SnackHelper.error('কার্ট খালি');
      return;
    }
    if (dateIndex >= _dates.length) {
      SnackHelper.error('তারিখ নির্বাচন করুন');
      return;
    }
    if (sessionType == 1 && homeAddressCtrl.text.trim().isEmpty) {
      SnackHelper.error('হোম ভিজিটের ঠিকানা দিন');
      return;
    }
    if (isTodaySelected() && isPastTimeOfDay(selectedTimeOfDay)) {
      SnackHelper.error('অতীতের সময় বুক করা যাবে না, বর্তমান বা পরবর্তী সময় বেছে নিন');
      return;
    }
    booking = true;
    update();
    try {
      final date = _dates[dateIndex].date;
      final hhmm =
          '${selectedTimeOfDay.hour.toString().padLeft(2, '0')}:${selectedTimeOfDay.minute.toString().padLeft(2, '0')}';
      final payload = {
        'center_id': c.id,
        'appointment_type': sessionType == 1 ? 'home' : 'center',
        'scheduled_at': '$date $hhmm',
        'payment_method':
            selectedPaymentKey.isNotEmpty ? selectedPaymentKey : 'cash',
        'home_address': sessionType == 1 ? homeAddressCtrl.text.trim() : '',
        'address': sessionType == 1 ? '' : addressCtrl.text.trim(),
        'notes': notesCtrl.text.trim(),
        'items': cartItems
            .map((e) => {'service_id': e.key.id, 'quantity': e.value})
            .toList(),
      };
      lastAppointment = await _repo.book(payload);
      _cart.clear();
      // Otherwise the next add-to-cart (even of a different kind, on a
      // totally empty cart) trips the "cart has the other kind" guard in
      // addToCart(), since that guard only checks _cartKind, not _cart.
      _cartKind = null;
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

  /// Groups [sessions] by bookingGroupId so a legacy multi-day booking
  /// still renders as one card ("Day X of N") — new cart bookings never
  /// set a group id, so each is its own singleton group.
  List<List<PhysioSession>> get sessionGroups {
    final byGroup = <String, List<PhysioSession>>{};
    var soloIdx = 0;
    for (final s in sessions) {
      final key =
          s.bookingGroupId.isNotEmpty ? s.bookingGroupId : 'solo-${soloIdx++}';
      byGroup.putIfAbsent(key, () => []).add(s);
    }
    for (final g in byGroup.values) {
      g.sort((a, b) => (a.scheduledAt ?? DateTime(0))
          .compareTo(b.scheduledAt ?? DateTime(0)));
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

  void backToPhysioHome() => Get.until((r) => r.settings.name == Routes.PHYSIO);

  @override
  void onClose() {
    notesCtrl.dispose();
    homeAddressCtrl.dispose();
    addressCtrl.dispose();
    catalogSearchCtrl.dispose();
    super.onClose();
  }
}
