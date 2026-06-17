import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/helpers/snack_helper.dart';
import '../../../core/helpers/sslcommerz_helper.dart';
import '../../../core/values/storage.dart';
import '../../../data/models/response/ambulance_response.dart';
import '../../../data/models/response/fare_estimate_response.dart';
import '../../../data/repositories/ambulance.repo.dart';
import '../../../data/services/settings.service.dart';
import '../../../data/services/storage.service.dart';
import '../../../routes/app_pages.dart';
import 'ambulance_controller.dart';

T? _firstOrNull<T>(Iterable<T> items, bool Function(T) test) {
  for (final it in items) {
    if (test(it)) return it;
  }
  return null;
}

class FareController extends GetxController {
  AmbulanceRepository get _repo => Get.find<AmbulanceRepository>();
  AmbulanceController get _amb => Get.find<AmbulanceController>();

  // ── Ambulance types (GET /api/v1/ambulance/types) ───────────────────
  List<AmbulanceType> types = [];
  String? selectedTypeId;
  bool loadingTypes = false;

  AmbulanceType? get selectedType {
    if (types.isEmpty) return null;
    return _firstOrNull(types, (t) => t.id == selectedTypeId) ?? types.first;
  }

  // ── Fare estimate (POST /api/v1/ambulance/fare/estimate) ────────────
  FareEstimate? fare;
  bool loadingFare = false;

  // ── VAT ──────────────────────────────────────────────────────────────
  // The backend can already tax a trip via the ambulance type's own tax_rate
  // (included in total_fare). When that's 0, we apply the global VAT from
  // /api/v1/settings (`services_vat_enabled` / `services_vat_rate`) on top of
  // the fare so ambulance bookings are taxed like the other modules. The
  // guard below means we never double-tax if the type's rate is turned on.
  int get _fareTotal => fare?.totalFare ?? 0;
  bool get _serverTaxed => (fare?.taxAmount ?? 0) > 0;
  double get _vatFraction => Get.isRegistered<SettingsService>()
      ? SettingsService.to.vatFraction
      : 0.05;
  String get vatPercentLabel => Get.isRegistered<SettingsService>()
      ? SettingsService.to.vatPercentLabel
      : '5';
  bool get vatApplies => !_serverTaxed && _vatFraction > 0 && _fareTotal > 0;
  int get vatAmount => vatApplies ? (_fareTotal * _vatFraction).round() : 0;
  String get vatLabel => '৳${FareEstimate.fmt(vatAmount)}';

  /// Fare + VAT — the amount charged to the gateway and shown as the total.
  int get payableAmount => _fareTotal + vatAmount;
  String get payableLabel => '৳${FareEstimate.fmt(payableAmount)}';

  // ── Payment methods (GET /api/v1/ambulance/payment-methods) ─────────
  List<PaymentMethodOption> methods = [];
  String? selectedMethod;
  bool loadingMethods = false;

  bool isEmergency = false;

  // Booking inputs
  final TextEditingController patientNameCtrl =
      TextEditingController(text: 'Patient');
  final TextEditingController phoneCtrl = TextEditingController();

  bool booking = false;

  /// A successful SSLCommerz payment captured for the current fare. Reused on
  /// retry so a failed booking POST never charges the same trip twice; cleared
  /// when the fare (type/route/emergency) changes or a booking succeeds.
  SslcResult? _paidPayment;

  @override
  void onInit() {
    super.onInit();
    if (phoneCtrl.text.trim().isEmpty) phoneCtrl.text = _myPhone();
    // Re-estimate whenever the user changes pickup/destination.
    _amb.onTripChanged = estimate;
    fetchTypes();
    fetchMethods();
    // Refresh settings so VAT honours the current server-side
    // `services_vat_enabled` flag (no VAT when it's off).
    _refreshSettings();
  }

  Future<void> _refreshSettings() async {
    if (!Get.isRegistered<SettingsService>()) return;
    await SettingsService.to.load();
    update();
  }

  /// Prepare the fare screen for a tapped ambulance: pre-select its type and
  /// (re)estimate using the current pickup/destination.
  void initFor(Ambulance? amb) {
    if (amb != null && amb.typeId.isNotEmpty) selectedTypeId = amb.typeId;
    fare = null;
    _amb.onTripChanged = estimate;
    if (types.isEmpty) {
      fetchTypes();
    } else {
      update();
    }
    if (methods.isEmpty) fetchMethods();
    estimate();
  }

  Future<void> fetchTypes() async {
    loadingTypes = true;
    update();
    try {
      types = await _repo.fetchTypes();
      selectedTypeId ??= types.isNotEmpty ? types.first.id : null;
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingTypes = false;
      update();
    }
  }

  Future<void> fetchMethods() async {
    loadingMethods = true;
    update();
    try {
      methods = await _repo.fetchPaymentMethods();
      final def = await _repo.fetchDefaultPaymentMethod();
      // Default to the server default, else the first enabled method.
      selectedMethod = def.isNotEmpty
          ? def
          : _firstOrNull(methods, (m) => m.enabled)?.key;
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingMethods = false;
      update();
    }
  }

  Future<void> estimate() async {
    final typeId = selectedTypeId;
    if (typeId == null ||
        _amb.pickupZilla.isEmpty ||
        _amb.dropZilla.isEmpty) {
      return;
    }
    loadingFare = true;
    _paidPayment = null; // fare is changing → any prior payment is stale
    update();
    try {
      fare = await _repo.estimateFare({
        'type_id': typeId,
        'pickup_division': _amb.pickupDivision,
        'pickup_zilla': _amb.pickupZilla,
        'drop_division': _amb.dropDivision,
        'drop_zilla': _amb.dropZilla,
        'is_emergency': isEmergency,
      });
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingFare = false;
      update();
    }
  }

  void selectType(String id) {
    selectedTypeId = id;
    update();
    estimate();
  }

  void selectMethod(String key) {
    selectedMethod = key;
    update();
  }

  void toggleEmergency(bool v) {
    isEmergency = v;
    update();
    estimate();
  }

  Future<void> confirm() async {
    final typeId = selectedTypeId;
    if (typeId == null) {
      SnackHelper.error('অ্যাম্বুলেন্স টাইপ নির্বাচন করুন');
      return;
    }
    if (_amb.pickupZilla.isEmpty || _amb.dropZilla.isEmpty) {
      SnackHelper.error('পিকআপ ও গন্তব্য নির্বাচন করুন');
      return;
    }
    if (booking) return;
    booking = true;
    update();
    try {
      final payload = <String, dynamic>{
        'type_id': typeId,
        'customer_phone': phoneCtrl.text.trim(),
        'patient_name': patientNameCtrl.text.trim().isEmpty
            ? 'Patient'
            : patientNameCtrl.text.trim(),
        'pickup_division': _amb.pickupDivision,
        'pickup_zilla': _amb.pickupZilla,
        'drop_division': _amb.dropDivision,
        'drop_zilla': _amb.dropZilla,
        'payment_method': selectedMethod ?? 'cash',
        'booking_type': isEmergency ? 'emergency' : 'scheduled',
      };
      // Online payment (SSLCommerz sandbox): initiate → checkout → attach the
      // gateway's val_id + tran_id to the booking payload. Reuse an already
      // successful payment so a retry never charges the same trip twice.
      if (SslcommerzPay.isOnline(selectedMethod ?? '')) {
        var pay = _paidPayment;
        if (pay == null || !pay.success) {
          // Charge fare + VAT (matches the breakdown shown on the fare card).
          pay = await SslcommerzPay.checkout(
            amount: payableAmount.toDouble(),
            productName: selectedType?.name ?? 'Ambulance',
            category: 'ambulance',
          );
          if (!pay.success) {
            SnackHelper.error('পেমেন্ট সম্পন্ন হয়নি');
            booking = false;
            update();
            return;
          }
          _paidPayment = pay;
        }
        payload['payment_method'] = 'sslcommerz';
        payload['val_id'] = pay.valId;
        payload['tran_id'] = pay.tranId;
      }
      final created = await _repo.createBooking(payload);
      _paidPayment = null; // booking succeeded — payment consumed
      _amb.lastBooking = created;
      _amb.fetchBookings(); // refresh the recent-bookings list
      Get.toNamed(Routes.AMBULANCE_CONFIRMED);
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      booking = false;
      update();
    }
  }

  String _myPhone() {
    final raw = StorageService.read(StorageConstants.userInfo);
    if (raw is String && raw.trim().isNotEmpty) {
      try {
        final map = jsonDecode(raw);
        if (map is Map) return map['phone']?.toString() ?? '';
      } catch (_) {}
    }
    return '';
  }

  @override
  void onClose() {
    patientNameCtrl.dispose();
    phoneCtrl.dispose();
    super.onClose();
  }
}
