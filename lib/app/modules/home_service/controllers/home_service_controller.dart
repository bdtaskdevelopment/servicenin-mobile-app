import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../../core/helpers/location_helper.dart';
import '../../../core/helpers/snack_helper.dart';
import '../../../core/helpers/sslcommerz_helper.dart';
import '../../../data/models/response/service_response.dart';
import '../../../data/repositories/service.repo.dart';
import '../../../data/services/settings.service.dart';
import '../../../routes/app_pages.dart';

/// Icon for a service category, chosen from its (English) name.
IconData hsCatIcon(String name) {
  final n = name.toLowerCase();
  if (n.contains('ac')) return Icons.ac_unit_rounded;
  if (n.contains('clean')) return Icons.cleaning_services_rounded;
  if (n.contains('plumb')) return Icons.water_drop_rounded;
  if (n.contains('electric')) return Icons.lightbulb_outline_rounded;
  if (n.contains('appliance') || n.contains('repair')) return Icons.bolt_rounded;
  if (n.contains('pest')) return Icons.shield_outlined;
  if (n.contains('paint')) return Icons.format_paint_rounded;
  if (n.contains('shift') || n.contains('move')) {
    return Icons.local_shipping_outlined;
  }
  return Icons.home_repair_service_outlined;
}

class HsCategory {
  const HsCategory(this.name, this.en, this.icon, {this.id = ''});
  final String name; // display label (Bangla if available)
  final String en; // English name (list title)
  final IconData icon;
  final String id;

  factory HsCategory.fromApi(ServiceCategory c) => HsCategory(
        c.displayName, // Bangla in bn, English in en
        c.name,
        hsCatIcon(c.name),
        id: c.id,
      );
}

class HsService {
  const HsService(this.name, this.desc, this.price, this.icon,
      {this.id = ''});
  final String name;
  final String desc;
  final String price;
  final IconData icon;
  final String id; // category id (popular items are categories)

  factory HsService.fromApi(ServiceCategory c) => HsService(
        c.displayName, // Bangla in bn, English in en
        c.description.isNotEmpty
            ? c.description
            : '${c.bookingCount} booked this week',
        c.priceLabel,
        hsCatIcon(c.name),
        id: c.id,
      );
}

class HsServiceItem {
  const HsServiceItem({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.bnName,
    required this.duration,
    required this.desc,
    required this.price,
    required this.category,
    this.icon = Icons.home_repair_service_outlined,
  });

  final String id;
  final String categoryId;
  final String name;
  final String bnName;
  final String duration;
  final String desc;
  final int price;
  final String category;
  final IconData icon;

  /// Bangla name in bn, English name in en.
  String get displayName {
    final isBn = Get.locale?.languageCode == 'bn';
    return isBn && bnName.isNotEmpty ? bnName : name;
  }

  factory HsServiceItem.fromApi(SubService s, {String categoryName = ''}) =>
      HsServiceItem(
        id: s.id,
        categoryId: s.categoryId,
        name: s.name,
        bnName: s.nameBn,
        duration: s.durationLabel,
        desc: s.description,
        price: s.price,
        category: categoryName,
      );
}

enum HsListMode { category, all, search }

class HomeServiceController extends GetxController {
  ServiceRepository get _repo => Get.find<ServiceRepository>();

  // ── Catalog ─────────────────────────────────────────────────────────
  List<HsCategory> categories = [];
  List<HsService> popular = [];
  bool loadingCategories = false;
  bool loadingPopular = false;

  @override
  void onInit() {
    super.onInit();
    addressCtrl.text = address;
    fetchCategories();
    fetchPopular();
  }

  Future<void> fetchCategories() async {
    loadingCategories = true;
    update();
    try {
      final list = await _repo.fetchCategories();
      categories = list.map(HsCategory.fromApi).toList();
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingCategories = false;
      update();
    }
  }

  Future<void> fetchPopular() async {
    loadingPopular = true;
    update();
    try {
      final list = await _repo.fetchPopular();
      popular = list.map(HsService.fromApi).toList();
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingPopular = false;
      update();
    }
  }

  // ── Service list (category / search) ────────────────────────────────
  HsListMode mode = HsListMode.category;
  HsCategory? selectedCat;
  String selectedCategory = '';
  List<HsServiceItem> subServices = [];
  bool loadingSub = false;

  String query = '';
  List<HsServiceItem> searchItems = [];
  bool searching = false;

  String get listTitle => switch (mode) {
        HsListMode.search => 'Search services',
        HsListMode.all => 'All services',
        HsListMode.category => selectedCategory.isEmpty
            ? 'Services'
            : selectedCategory,
      };

  List<HsServiceItem> get visibleServices =>
      mode == HsListMode.search ? searchItems : subServices;

  Future<void> _loadSubServices(HsCategory c) async {
    loadingSub = true;
    subServices = [];
    update();
    try {
      final list = await _repo.fetchSubServices(c.id);
      subServices =
          list.map((s) => HsServiceItem.fromApi(s, categoryName: c.en)).toList();
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingSub = false;
      update();
    }
  }

  void onQueryChanged(String v) {
    query = v;
    update();
    _search();
  }

  Future<void> _search() async {
    final q = query.trim();
    if (q.isEmpty) {
      searchItems = [];
      update();
      return;
    }
    searching = true;
    update();
    try {
      final res = await _repo.search(q);
      // Map category names so the sub-service rows show a category label.
      final catName = {for (final c in res.categories) c.id: c.name};
      searchItems = res.subServices
          .map((s) =>
              HsServiceItem.fromApi(s, categoryName: catName[s.categoryId] ?? ''))
          .toList();
    } catch (_) {
    } finally {
      searching = false;
      update();
    }
  }

  // ── Cart (keyed by sub_service id) ──────────────────────────────────
  final Map<String, int> _cart = {};
  final Map<String, HsServiceItem> _byId = {};

  int qtyOf(HsServiceItem s) => _cart[s.id] ?? 0;

  void add(HsServiceItem s) {
    _byId[s.id] = s;
    _cart[s.id] = (_cart[s.id] ?? 0) + 1;
    _paidPayment = null; // cart (amount) changed → any prior payment is stale
    update();
  }

  void dec(HsServiceItem s) {
    final q = (_cart[s.id] ?? 0) - 1;
    if (q <= 0) {
      _cart.remove(s.id);
    } else {
      _cart[s.id] = q;
    }
    _paidPayment = null; // cart (amount) changed → any prior payment is stale
    update();
  }

  /// Remove a service from the cart entirely (the delete button on the confirm
  /// page). If nothing is left, returns to the previous screen.
  void removeItem(HsServiceItem s) {
    _cart.remove(s.id);
    _paidPayment = null; // cart (amount) changed → any prior payment is stale
    update();
    if (_cart.isEmpty) {
      SnackHelper.error('কার্টে কোনো সার্ভিস নেই', title: _moduleTitle);
      Get.back();
    }
  }

  int get totalItems => _cart.values.fold(0, (a, b) => a + b);

  int get totalPrice {
    var total = 0;
    _cart.forEach((id, qty) {
      total += (_byId[id]?.price ?? 0) * qty;
    });
    return total;
  }

  List<HsServiceItem> get cartItems =>
      _cart.keys.map((id) => _byId[id]).whereType<HsServiceItem>().toList();

  // ── Address / schedule / slots / payment ────────────────────────────
  final TextEditingController addressCtrl = TextEditingController();
  String address = 'House 32, Road 11, Gulshan-2';

  List<ServiceScheduleDate> _dates = [];
  int selectedBookingDate = 0;
  bool loadingDates = false;
  List<ServiceScheduleDate> get scheduleDates => _dates;
  ServiceScheduleDate? get _selectedDate =>
      selectedBookingDate < _dates.length ? _dates[selectedBookingDate] : null;

  void selectBookingDate(int i) {
    selectedBookingDate = i;
    update();
  }

  List<ServiceTimeSlot> slots = [];
  String selectedSlotKey = '';
  bool loadingSlots = false;

  void selectSlot(String key) {
    selectedSlotKey = key;
    update();
  }

  List<ServicePaymentMethod> methods = [];
  String selectedMethodKey = '';
  bool loadingMethods = false;

  /// Only enabled gateways — disabled ones are never shown.
  List<ServicePaymentMethod> get enabledMethods =>
      methods.where((m) => m.enabled).toList();

  void selectMethod(String key) {
    selectedMethodKey = key;
    update();
  }

  // ── Booking summary getters (used by placed / details) ──────────────
  /// Cart summary captured at booking time (the API response may omit items),
  /// so the success page can still show `service ×count`.
  String lastCartSummary = '';

  String get bookingSummary {
    final b = lastBooking;
    if (b != null && b.items.isNotEmpty) {
      return '${b.title} ×${b.items.fold(0, (a, i) => a + i.quantity)}';
    }
    if (lastCartSummary.isNotEmpty) return lastCartSummary;
    if (cartItems.isEmpty) return 'Service';
    return '${cartItems.first.displayName} ×$totalItems';
  }

  String get whenSummary {
    final b = lastBooking;
    if (b != null && b.whenLabel.isNotEmpty) return b.whenLabel;
    final d = _selectedDate;
    final slot = slots.firstWhereOrNull((s) => s.key == selectedSlotKey);
    return [d?.label ?? '', slot?.label ?? '']
        .where((s) => s.isNotEmpty)
        .join(' · ');
  }

  int get subtotalAmount => lastBooking?.subtotal ?? totalPrice;
  int get vat => lastBooking?.vatAmount ?? cartVat;
  int get totalPaid => lastBooking?.amount ?? cartPayable;
  String get bookingId => lastBooking?.invoiceNo ?? '—';

  // VAT applied to the live cart. The rate comes from /api/v1/settings
  // (`services_vat_enabled` / `services_vat_rate`) and matches what the backend
  // adds on /services/book, so the charged amount is never short. Falls back to
  // 5% until settings load.
  double get _vatFraction => Get.isRegistered<SettingsService>()
      ? SettingsService.to.vatFraction
      : 0.05;
  String get vatPercentLabel => Get.isRegistered<SettingsService>()
      ? SettingsService.to.vatPercentLabel
      : '5';
  bool get vatApplies => _vatFraction > 0;
  int get cartVat => (totalPrice * _vatFraction).round();
  int get cartPayable => totalPrice + cartVat;

  // Provider details are not in these endpoints yet (coming later).
  String get techName => 'Service provider';
  String get techInitials => 'SP';
  String get techRating => '—';
  String get techJobs => '';

  // ── Booking ─────────────────────────────────────────────────────────
  ServiceBooking? lastBooking;
  bool placing = false;

  /// A successful SSLCommerz payment captured for the current cart. If the
  /// booking POST fails after payment, a retry reuses this instead of opening
  /// the gateway again — so the same transaction is never charged twice.
  /// Cleared when the cart changes or a booking succeeds.
  SslcResult? _paidPayment;

  // ── Track (booking detail + timeline) ───────────────────────────────
  ServiceBooking? trackedBooking;
  List<ServiceTimelineEntry> timeline = [];
  bool loadingTrack = false;

  // The user's location + how far the assigned provider is (computed from the
  // booking's provider_lat/lng on the tracking screen).
  double? userLat;
  double? userLng;
  double? providerDistanceKm;

  bool get hasUserLocation => userLat != null && userLng != null;

  /// "1.8 km away" label for the provider, or '' when not computable.
  String get providerDistanceLabel => providerDistanceKm == null
      ? ''
      : '${providerDistanceKm!.toStringAsFixed(1)} km away';

  // ── My bookings ─────────────────────────────────────────────────────
  List<ServiceBooking> myBookings = [];
  bool loadingMyBookings = false;

  // ── Navigation ──────────────────────────────────────────────────────
  void openCategory(HsCategory c) {
    mode = HsListMode.category;
    selectedCat = c;
    selectedCategory = c.en;
    update();
    _loadSubServices(c);
    Get.toNamed(Routes.HOME_SERVICE_LIST);
  }

  /// Open a category by id (used from "popular" cards / search categories).
  void openCategoryById(String id, String enName) {
    openCategory(HsCategory(enName, enName, hsCatIcon(enName), id: id));
  }

  void openAll() => openSearch();

  void openSearch() {
    mode = HsListMode.search;
    query = '';
    searchItems = [];
    update();
    Get.toNamed(Routes.HOME_SERVICE_LIST);
  }

  Future<void> reviewBooking() async {
    if (totalItems == 0) return;
    // Starting a fresh booking — drop any previous booking so summary/amount
    // getters reflect the current cart, not a completed one.
    lastBooking = null;
    Get.toNamed(Routes.HS_CONFIRM);
    // Refresh VAT/payment settings so the bill honours the current server-side
    // `services_vat_enabled` flag (no VAT when it's off), then load schedule +
    // payment options for the confirm screen.
    _refreshSettings();
    if (_dates.isEmpty) await _loadDates();
    if (methods.isEmpty) await _loadMethods();
  }

  /// Re-pull `/api/v1/settings` so a server-side VAT toggle takes effect
  /// without an app restart, then rebuild the bill.
  Future<void> _refreshSettings() async {
    if (!Get.isRegistered<SettingsService>()) return;
    await SettingsService.to.load();
    update();
  }

  /// Cart icon tap → open the cart (confirm) page, or notify when empty.
  void openCart() {
    if (totalItems == 0) {
      SnackHelper.error('কার্টে কোনো সার্ভিস নেই');
      return;
    }
    reviewBooking();
  }

  Future<void> _loadDates() async {
    loadingDates = true;
    update();
    try {
      _dates = await _repo.fetchScheduleDates();
      selectedBookingDate = 0;
      if (_dates.isNotEmpty) await _loadSlots(_dates.first.date);
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingDates = false;
      update();
    }
  }

  Future<void> loadSlotsForSelectedDate() async {
    final d = _selectedDate;
    if (d != null) await _loadSlots(d.date);
  }

  Future<void> _loadSlots(String date) async {
    loadingSlots = true;
    update();
    try {
      slots = await _repo.fetchTimeSlots(date);
      final firstFree = slots.firstWhereOrNull((s) => s.available);
      selectedSlotKey = firstFree?.key ?? '';
    } catch (_) {
    } finally {
      loadingSlots = false;
      update();
    }
  }

  Future<void> _loadMethods() async {
    loadingMethods = true;
    update();
    try {
      methods = await _repo.fetchPaymentMethods();
      final def = await _repo.fetchDefaultPaymentMethod();
      selectedMethodKey = def.isNotEmpty
          ? def
          : (methods.firstWhereOrNull((m) => m.enabled)?.key ?? '');
    } catch (_) {
    } finally {
      loadingMethods = false;
      update();
    }
  }

  // Error-snackbar title for this module.
  static String get _moduleTitle => 'Home Service'.tr;

  Future<void> placeBooking() async {
    if (placing) return;
    if (cartItems.isEmpty) {
      SnackHelper.error('No services selected'.tr, title: _moduleTitle);
      return;
    }
    final d = _selectedDate;
    if (d == null || selectedSlotKey.isEmpty) {
      SnackHelper.error('Select a date & time slot'.tr, title: _moduleTitle);
      return;
    }
    if (addressCtrl.text.trim().isEmpty) {
      SnackHelper.error('Enter a service address'.tr, title: _moduleTitle);
      return;
    }
    placing = true;
    update();
    try {
      address = addressCtrl.text.trim();
      final categoryId = cartItems.first.categoryId;
      final payload = <String, dynamic>{
        'category_id': categoryId,
        'address': address,
        'scheduled_at': '${d.date}T00:00:00+06:00',
        'time_slot': selectedSlotKey,
        'payment_method':
            selectedMethodKey.isNotEmpty ? selectedMethodKey : 'cash',
        'items': cartItems
            .map((s) => {'sub_service_id': s.id, 'quantity': qtyOf(s)})
            .toList(),
      };
      // Online payment (SSLCommerz sandbox): initiate → checkout → attach the
      // gateway's val_id + tran_id to the booking payload. Reuse an already
      // successful payment so a retry never charges the same booking twice.
      if (SslcommerzPay.isOnline(selectedMethodKey)) {
        var pay = _paidPayment;
        if (pay == null || !pay.success) {
          // Charge the current cart total incl. 5% VAT (matches what the
          // backend requires), never a stale amount from a previous booking.
          pay = await SslcommerzPay.checkout(
            amount: cartPayable.toDouble(),
            productName: bookingSummary,
            category: 'homeservice',
          );
          if (!pay.success) {
            SnackHelper.error('পেমেন্ট সম্পন্ন হয়নি', title: _moduleTitle);
            placing = false;
            update();
            return;
          }
          _paidPayment = pay;
        }
        payload['payment_method'] = 'sslcommerz';
        payload['val_id'] = pay.valId;
        payload['tran_id'] = pay.tranId;
      }
      // Capture the cart summary before clearing (the booking response may
      // not echo the items back).
      lastCartSummary = cartItems.isEmpty
          ? ''
          : '${cartItems.first.displayName} ×$totalItems';
      lastBooking = await _repo.book(payload);
      _cart.clear();
      _paidPayment = null; // booking succeeded — payment consumed
      Get.toNamed(Routes.HS_PLACED);
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''),
          title: _moduleTitle);
    } finally {
      placing = false;
      update();
    }
  }

  Future<void> trackBooking() async {
    // Always open the tracking page using the booking we already have, then
    // refresh from the API when we have a real id. (The create response may
    // omit a top-level id, which previously made this button do nothing.)
    trackedBooking = lastBooking ?? trackedBooking;
    update();
    Get.toNamed(Routes.HS_TRACKING);
    final id = (lastBooking?.id.isNotEmpty ?? false)
        ? lastBooking!.id
        : (trackedBooking?.id ?? '');
    if (id.isNotEmpty) await _loadTrack(id);
  }

  Future<void> openBooking(ServiceBooking b) async {
    trackedBooking = b;
    lastBooking = b;
    update();
    Get.toNamed(Routes.HS_TRACKING);
    await _loadTrack(b.id);
  }

  /// Manual refresh from the tracking screen — re-pulls the booking (and the
  /// provider's latest location) and recomputes the distance.
  Future<void> refreshTracking() async {
    final id = trackedBooking?.id ?? lastBooking?.id ?? '';
    if (id.isNotEmpty) await _loadTrack(id);
  }

  Future<void> _loadTrack(String id) async {
    loadingTrack = true;
    update();
    try {
      trackedBooking = await _repo.fetchBooking(id);
      lastBooking = trackedBooking;
      timeline = await _repo.fetchTimeline(id);
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingTrack = false;
      update();
    }
    // Compute the distance from the user to the provider (best-effort, after
    // the main load so a slow GPS fix doesn't block the screen).
    _updateProviderDistance();
  }

  /// Get the user's location and compute the straight-line distance to the
  /// assigned provider's shared location. No-op when either is unavailable.
  Future<void> _updateProviderDistance() async {
    final b = trackedBooking;
    if (b == null || !b.hasProviderLocation) {
      providerDistanceKm = null;
      update();
      return;
    }
    final pos = await LocationService.getCurrentPosition();
    final lat = pos?.latitude ?? LocationService.cachedLat;
    final lng = pos?.longitude ?? LocationService.cachedLng;
    if (lat == null || lng == null) {
      providerDistanceKm = null;
      update();
      return;
    }
    userLat = lat;
    userLng = lng;
    final meters =
        Geolocator.distanceBetween(lat, lng, b.providerLat!, b.providerLng!);
    providerDistanceKm = meters / 1000.0;
    update();
  }

  Future<void> fetchMyBookings() async {
    loadingMyBookings = true;
    update();
    try {
      myBookings = await _repo.fetchMyBookings();
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingMyBookings = false;
      update();
    }
  }

  void openMyBookings() {
    fetchMyBookings();
    Get.toNamed(Routes.HS_MY_BOOKINGS);
  }

  // ── Rating / dispute ────────────────────────────────────────────────
  Future<bool> submitRating(int stars, String comment) async {
    final id = trackedBooking?.id ?? lastBooking?.id;
    if (id == null) return false;
    try {
      final res = await _repo.rate(id, stars, comment);
      if (res.success) {
        SnackHelper.success(res.message.isNotEmpty ? res.message : 'Thank you');
        return true;
      }
      SnackHelper.error(res.message);
      return false;
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<bool> submitDispute(String reason, String description) async {
    final id = trackedBooking?.id ?? lastBooking?.id;
    if (id == null) return false;
    try {
      final res = await _repo.dispute(id, reason, description);
      if (res.success) {
        SnackHelper.success(res.message.isNotEmpty ? res.message : 'Dispute opened');
        return true;
      }
      SnackHelper.error(res.message);
      return false;
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  // ── Navigation (misc) ───────────────────────────────────────────────
  void viewBookingDetails() => Get.toNamed(Routes.HS_DETAILS);
  void rateService() => Get.toNamed(Routes.HS_RATE);
  void openChat() {
    final id = trackedBooking?.id ?? lastBooking?.id;
    if (id == null || id.isEmpty) return;
    Get.toNamed(Routes.HS_CHAT, arguments: id);
  }

  void openSubscriptions() => Get.toNamed(Routes.HS_SUBSCRIPTIONS);

  void backToHomeService() =>
      Get.until((route) => route.settings.name == Routes.HOME_SERVICE);

  @override
  void onClose() {
    addressCtrl.dispose();
    super.onClose();
  }
}
