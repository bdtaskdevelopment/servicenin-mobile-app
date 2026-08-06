import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/helpers/location_helper.dart';
import '../../../core/helpers/snack_helper.dart';
import '../../../core/values/storage.dart';
import '../../../data/models/sn_place.dart';
import '../../../data/repositories/blood.repo.dart';
import '../../../data/services/geo_search.service.dart';
import '../../../data/services/storage.service.dart';
import '../../../routes/app_pages.dart';
import '../../home_service/views/hs_address_search_view.dart';
import 'blood_controller.dart';

class NeedBloodController extends GetxController {
  static const List<String> groups = [
    'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-',
  ];
  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// Alert-radius options in km; 0 means "all over" (no distance limit).
  static const List<int> radiusOptions = [10, 20, 50, 0];

  String group = 'O+';
  int units = 2;
  BloodSeverity severity = BloodSeverity.critical;
  int radiusKm = 10;

  void setRadius(int km) {
    radiusKm = km;
    update();
  }

  String radiusLabel(int km) => km == 0 ? 'All over'.tr : '$km km';

  bool busy = false;

  // When the blood is needed — date + time.
  DateTime? neededAt;
  TimeOfDay? neededTime;
  String neededDate = 'Today · ASAP';

  /// The picked date + time combined as a local DateTime (falls back to now).
  DateTime get _neededMoment {
    final d = neededAt ?? DateTime.now();
    final t = neededTime;
    return DateTime(d.year, d.month, d.day, t?.hour ?? 0, t?.minute ?? 0);
  }

  /// API timestamp in RFC3339 (UTC). Carries the picked time so the donor
  /// side can show exactly when the blood is needed.
  String get neededAtIso => _neededMoment.toUtc().toIso8601String();

  /// "3:30 PM" style label for the picked time (empty when not picked).
  String get neededTimeLabel {
    final t = neededTime;
    if (t == null) return '';
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m ${t.period == DayPeriod.am ? 'AM' : 'PM'}';
  }

  void _refreshNeededLabel() {
    final d = neededAt;
    if (d == null) {
      neededDate = 'Today · ASAP';
      return;
    }
    final date = '${d.day} ${_months[d.month - 1]} ${d.year}';
    neededDate =
        neededTimeLabel.isEmpty ? date : '$date · $neededTimeLabel';
  }

  void setNeeded(DateTime d) {
    neededAt = d;
    _refreshNeededLabel();
    update();
  }

  void setNeededTime(TimeOfDay t) {
    neededTime = t;
    // Picking a time implies a date — default to today if none chosen yet.
    neededAt ??= DateTime.now();
    _refreshNeededLabel();
    update();
  }

  // Hospital / location. lat/lng default to Dhaka but are replaced by the
  // device's real GPS position on open, and can be updated by tapping the
  // Google map or searching an address (same paid-Maps flow as ambulance /
  // home service).
  final TextEditingController hospitalName = TextEditingController();
  final TextEditingController hospitalAddress = TextEditingController();
  double lat = 23.8103;
  double lng = 90.4125;

  /// Human-readable address for the current pin (reverse-geocoded).
  String locationLabel = '';
  bool loadingLocation = false;

  /// Bumped only when the pin is set from GPS or search, so the map widget
  /// re-centers on it. A plain map tap leaves this unchanged (the tapped
  /// point is already on screen — just move the marker, don't recreate the
  /// native map).
  int mapVersion = 0;

  // Contact details — prefilled from the logged-in user's saved info
  // (name/email/phone). Fields not present in user info stay empty.
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController description = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    final raw = StorageService.read(StorageConstants.userInfo);
    if (raw is String && raw.trim().isNotEmpty) {
      try {
        final m = jsonDecode(raw) as Map<String, dynamic>;
        name.text = m['name']?.toString() ?? '';
        email.text = m['email']?.toString() ?? '';
        phone.text = m['phone']?.toString() ?? '';
      } catch (_) {
        // Leave fields empty if the stored info can't be parsed.
      }
    }
    _initDefaultLocation();
  }

  // ── Location (paid Google Maps: GPS default + tap / search to update) ──

  /// Defaults the pin to the device's current GPS position and reverse-
  /// geocodes it to a readable address. Silently no-ops if location is
  /// unavailable or denied — the user can still tap/search the map.
  Future<void> _initDefaultLocation({bool overwriteAddress = false}) async {
    loadingLocation = true;
    update();
    try {
      final pos = await LocationService.getCurrentPosition();
      if (pos == null) return;
      lat = pos.latitude;
      lng = pos.longitude;
      mapVersion++; // recenter the map on the real location
      final resolved =
          await GeoSearchService.instance.reverse(LatLng(lat, lng));
      if (resolved != null && resolved.isNotEmpty) {
        locationLabel = resolved;
        if (overwriteAddress || hospitalAddress.text.trim().isEmpty) {
          hospitalAddress.text = resolved;
        }
      }
    } finally {
      loadingLocation = false;
      update();
    }
  }

  /// "Use my current location" button — re-reads GPS and overwrites the
  /// address with the resolved one.
  Future<void> useCurrentLocation() =>
      _initDefaultLocation(overwriteAddress: true);

  /// Dropping the pin by tapping the map. The tapped point is already on
  /// screen, so we move the marker without recentering; the address updates
  /// from the reverse geocode.
  Future<void> setLocationFromMapTap(LatLng point) async {
    lat = point.latitude;
    lng = point.longitude;
    loadingLocation = true;
    update();
    try {
      final resolved = await GeoSearchService.instance.reverse(point);
      if (resolved != null && resolved.isNotEmpty) {
        locationLabel = resolved;
        hospitalAddress.text = resolved;
      }
    } finally {
      loadingLocation = false;
      update();
    }
  }

  /// Opens the Google Places search (reused from home service) and adopts
  /// the chosen address + coordinates.
  Future<void> openLocationSearch() async {
    final place = await Get.to<SnPlace>(
        () => HsAddressSearchView(title: 'Search location'.tr));
    if (place == null) return;
    lat = place.point.latitude;
    lng = place.point.longitude;
    mapVersion++; // recenter the map on the picked place
    locationLabel = place.address.isNotEmpty ? place.address : place.label;
    hospitalAddress.text = locationLabel;
    update();
  }

  void setGroup(String value) {
    group = value;
    update();
  }

  void setSeverity(BloodSeverity value) {
    severity = value;
    update();
  }

  /// A request may ask for at most 3 bags at a time.
  static const int maxUnits = 3;

  void incUnits() {
    if (units < maxUnits) {
      units++;
      update();
    }
  }

  void decUnits() {
    if (units > 1) {
      units--;
      update();
    }
  }

  Future<void> broadcast() async {
    // Required fields: blood_group, units_needed, hospital_name.
    if (hospitalName.text.trim().isEmpty) {
      SnackHelper.error('হাসপাতালের নাম দিন');
      return;
    }
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
        'units_needed': units,
        'urgency': severity.name, // critical / urgent / routine
        'needed_at': neededAtIso,
        'hospital_name': hospitalName.text.trim(),
        'hospital_address': hospitalAddress.text.trim(),
        'lat': lat,
        'lng': lng,
        'search_radius_km': radiusKm,
        'contact_name': name.text.trim(),
        'contact_phone': phone.text.trim(),
        'contact_address': address.text.trim(),
        'notes': description.text.trim(),
      };
      final res = await Get.find<BloodRepository>().createRequest(payload);
      if (Get.isDialogOpen ?? false) Get.back();
      busy = false;
      update();
      if (res.success) {
        SnackHelper.success(res.message);
        // Recall the "requests near you" API so the just-created request shows
        // up, then redirect to that list (replacing the form) so the user can
        // track it in realtime.
        Get.find<BloodController>().fetchRequests();
        Get.offNamed(Routes.BLOOD_REQUESTS);
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

  @override
  void onClose() {
    hospitalName.dispose();
    hospitalAddress.dispose();
    name.dispose();
    email.dispose();
    phone.dispose();
    address.dispose();
    description.dispose();
    super.onClose();
  }
}
