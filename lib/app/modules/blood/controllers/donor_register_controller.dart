import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/helpers/location_helper.dart';
import '../../../core/helpers/snack_helper.dart';
import '../../../data/models/response/donor_response.dart';
import '../../../data/models/sn_place.dart';
import '../../../data/repositories/blood.repo.dart';
import '../../../data/services/geo_search.service.dart';
import '../../../routes/app_pages.dart';
import '../../home_service/views/hs_address_search_view.dart';

/// Drives the "Register as a blood donor" flow:
///   1. [register]  → POST /blood/donors/register, then opens the OTP page.
///   2. [verifyOtp] → POST /blood/donors/verify-otp, then returns to the
///      main blood page on success. Both surface the exact API `message`.
class DonorRegisterController extends GetxController {
  static const List<String> groups = [
    'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-',
  ];

  // ── Registration form ──────────────────────────────────────────────
  String group = 'A+';
  // Location. lat/lng default to Dhaka but are replaced by the device's real
  // GPS on open, and can be updated via map tap or address search — the same
  // paid-Google-Maps flow as the "Request blood" form. A donor's location is
  // what lets the system match them to nearby requests.
  double lat = 23.8103;
  double lng = 90.4125;
  String locationLabel = '';
  bool loadingLocation = false;

  /// Bumped only when the pin is set from GPS or search, so the map re-centers;
  /// a plain map tap leaves it unchanged (just moves the marker).
  int mapVersion = 0;

  final TextEditingController age = TextEditingController();
  final TextEditingController profession = TextEditingController();
  final TextEditingController notes = TextEditingController();

  /// True once we know this user already has a donor profile — the screen
  /// then behaves as "update my details" instead of a fresh registration.
  bool isEditing = false;
  bool loadingProfile = true;

  @override
  void onInit() {
    super.onInit();
    _loadExistingOrGps();
  }

  /// If the user is already a donor, pre-fill the form from their saved
  /// profile (edit mode). Otherwise fall back to a GPS-defaulted new form.
  Future<void> _loadExistingOrGps() async {
    loadingProfile = true;
    update();
    DonorEntry? me;
    try {
      me = await Get.find<BloodRepository>().fetchMyDonor();
    } catch (_) {}
    if (me != null && me.id.isNotEmpty) {
      isEditing = true;
      if (me.bloodGroup.isNotEmpty) group = me.bloodGroup;
      if (me.age != null) age.text = me.age.toString();
      if (me.profession.isNotEmpty) profession.text = me.profession;
      if (me.notes.isNotEmpty) notes.text = me.notes;
      loadingProfile = false;
      if (me.lat != null && me.lng != null) {
        lat = me.lat!;
        lng = me.lng!;
        mapVersion++;
        update();
        final resolved =
            await GeoSearchService.instance.reverse(LatLng(lat, lng));
        if (resolved != null && resolved.isNotEmpty) locationLabel = resolved;
      }
      update();
    } else {
      loadingProfile = false;
      // New donor — default the pin to the device's current GPS position.
      await _initDefaultLocation();
    }
  }

  // ── Location (paid Google Maps: GPS default + tap / search to update) ──

  Future<void> _initDefaultLocation() async {
    loadingLocation = true;
    update();
    try {
      final pos = await LocationService.getCurrentPosition();
      if (pos == null) return;
      lat = pos.latitude;
      lng = pos.longitude;
      mapVersion++;
      final resolved =
          await GeoSearchService.instance.reverse(LatLng(lat, lng));
      if (resolved != null && resolved.isNotEmpty) locationLabel = resolved;
    } finally {
      loadingLocation = false;
      update();
    }
  }

  Future<void> useCurrentLocation() => _initDefaultLocation();

  Future<void> setLocationFromMapTap(LatLng point) async {
    lat = point.latitude;
    lng = point.longitude;
    loadingLocation = true;
    update();
    try {
      final resolved = await GeoSearchService.instance.reverse(point);
      if (resolved != null && resolved.isNotEmpty) locationLabel = resolved;
    } finally {
      loadingLocation = false;
      update();
    }
  }

  Future<void> openLocationSearch() async {
    final place = await Get.to<SnPlace>(
        () => HsAddressSearchView(title: 'Search location'.tr));
    if (place == null) return;
    lat = place.point.latitude;
    lng = place.point.longitude;
    mapVersion++;
    locationLabel = place.address.isNotEmpty ? place.address : place.label;
    update();
  }

  // ── OTP step ────────────────────────────────────────────────────────
  static const int otpLength = 6;
  String otp = '';
  bool get isOtpComplete => otp.length == otpLength;

  bool busy = false;

  void setGroup(String value) {
    group = value;
    update();
  }

  void onOtpChanged(String value) {
    otp = value;
    update();
  }

  /// Submit the donor registration. On success, moves to the OTP screen.
  Future<void> register() async {
    if (busy) return;
    busy = true;
    update();
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
    try {
      final payload = <String, dynamic>{
        'blood_group': group,
        'lat': lat,
        'lng': lng,
        'notes': notes.text.trim(),
        if (int.tryParse(age.text.trim()) != null)
          'age': int.parse(age.text.trim()),
        'profession': profession.text.trim(),
      };
      final res = await Get.find<BloodRepository>().registerDonor(payload);
      if (Get.isDialogOpen ?? false) Get.back();
      busy = false;
      update();
      if (res.success) {
        SnackHelper.success(res.message);
        // OTP step removed — the backend now auto-verifies donors on
        // registration (response carries otp_verified: true), so we skip the
        // OTP screen and return to the blood home page.
        // otp = ''; // fresh start for the OTP screen
        // Get.toNamed(Routes.BLOOD_DONOR_VERIFY_OTP);
        Get.until((route) => route.settings.name == Routes.BLOOD);
      } else {
        SnackHelper.error(res.message);
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      busy = false;
      update();
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Verify the OTP. On success, pops back to the main blood page; on failure
  /// shows the exact API message (e.g. "invalid or expired OTP").
  Future<void> verifyOtp() async {
    if (busy || !isOtpComplete) return;
    busy = true;
    update();
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
    try {
      final res = await Get.find<BloodRepository>().verifyDonorOtp(otp);
      if (Get.isDialogOpen ?? false) Get.back();
      busy = false;
      update();
      if (res.success) {
        SnackHelper.success(res.message);
        // Pop the OTP + register pages, landing back on the main blood page.
        Get.until((route) => route.settings.name == Routes.BLOOD);
      } else {
        SnackHelper.error(res.message); // exact API message
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      busy = false;
      update();
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  void onClose() {
    age.dispose();
    profession.dispose();
    notes.dispose();
    super.onClose();
  }
}
