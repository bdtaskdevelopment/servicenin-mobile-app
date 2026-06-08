import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/helpers/snack_helper.dart';
import '../../../core/values/bd_geo.dart';
import '../../../data/models/response/ambulance_booking_response.dart';
import '../../../data/models/response/ambulance_response.dart';
import '../../../data/repositories/ambulance.repo.dart';
import '../../../routes/app_pages.dart';
import 'fare_controller.dart';

class AmbulanceController extends GetxController {
  AmbulanceRepository get _repo => Get.find<AmbulanceRepository>();

  // ── Available ambulances (GET /api/v1/ambulance/available) ──────────
  List<Ambulance> available = [];
  bool loadingAvailable = false;

  // ── Bookings (GET /api/v1/ambulance/bookings) ───────────────────────
  List<AmbulanceBookingEntry> bookings = [];
  bool loadingBookings = false;

  // ── Locations (GET /api/v1/locations/…) ─────────────────────────────
  List<String> divisions = [];
  List<String> pickupDistricts = [];
  List<String> dropDistricts = [];
  String pickupDivision = '';
  String pickupZilla = '';
  String dropDivision = '';
  String dropZilla = '';
  bool loadingLocations = false;

  /// The ambulance tapped from a list — carried into the fare screen.
  Ambulance? selectedAmbulance;

  /// The most recently confirmed booking — shown on the confirmed screen.
  AmbulanceBookingEntry? lastBooking;

  /// Called when pickup/destination change, so the fare screen can re-estimate.
  VoidCallback? onTripChanged;

  @override
  void onInit() {
    super.onInit();
    fetchAvailable();
    fetchBookings();
    loadLocations();
  }

  // ── Map points (derived from the selected division/zilla names) ──────
  LatLng get pickupPoint => BdGeo.point(pickupZilla, pickupDivision);
  LatLng get destPoint => BdGeo.point(dropZilla, dropDivision);

  Future<void> fetchAvailable() async {
    loadingAvailable = true;
    update();
    try {
      available = await _repo.fetchAvailable();
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingAvailable = false;
      update();
    }
  }

  Future<void> fetchBookings() async {
    loadingBookings = true;
    update();
    try {
      bookings = await _repo.fetchBookings();
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingBookings = false;
      update();
    }
  }

  Future<void> loadLocations() async {
    if (divisions.isNotEmpty) return; // already loaded
    loadingLocations = true;
    update();
    try {
      divisions = await _repo.fetchDivisions();
      if (divisions.isNotEmpty) {
        pickupDivision = divisions.first;
        dropDivision = divisions.first;
        pickupDistricts = await _repo.fetchDistricts(pickupDivision);
        dropDistricts = List<String>.from(pickupDistricts);
        if (pickupDistricts.isNotEmpty) pickupZilla = pickupDistricts.first;
        // default the destination to a different district when possible
        if (dropDistricts.length > 1) {
          dropZilla = dropDistricts[1];
        } else if (dropDistricts.isNotEmpty) {
          dropZilla = dropDistricts.first;
        }
      }
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingLocations = false;
      update();
      onTripChanged?.call(); // estimate once a default trip is known
    }
  }

  Future<void> setPickupDivision(String div) async {
    if (div == pickupDivision) return;
    pickupDivision = div;
    pickupZilla = '';
    update();
    try {
      pickupDistricts = await _repo.fetchDistricts(div);
      if (pickupDistricts.isNotEmpty) pickupZilla = pickupDistricts.first;
    } catch (_) {}
    update();
    onTripChanged?.call();
  }

  void setPickupZilla(String z) {
    pickupZilla = z;
    update();
    onTripChanged?.call();
  }

  Future<void> setDropDivision(String div) async {
    if (div == dropDivision) return;
    dropDivision = div;
    dropZilla = '';
    update();
    try {
      dropDistricts = await _repo.fetchDistricts(div);
      if (dropDistricts.isNotEmpty) dropZilla = dropDistricts.first;
    } catch (_) {}
    update();
    onTripChanged?.call();
  }

  void setDropZilla(String z) {
    dropZilla = z;
    update();
    onTripChanged?.call();
  }

  // ── Live position (used by the emergency tracking screen) ───────────
  LatLng? _livePos;
  LatLng get liveAmbulancePoint => _livePos ?? pickupPoint;

  void refreshAmbulance() {
    final from = liveAmbulancePoint;
    final to = destPoint;
    _livePos = LatLng(
      from.latitude + (to.latitude - from.latitude) * 0.3,
      from.longitude + (to.longitude - from.longitude) * 0.3,
    );
    update();
  }

  // ── Navigation ──────────────────────────────────────────────────────
  void openSeeAll() => Get.toNamed(Routes.AMBULANCE_ALL);
  void openBookings() => Get.toNamed(Routes.AMBULANCE_BOOKINGS);

  /// Tap an available ambulance → fare estimate (pre-selecting its type).
  void openFareFor(Ambulance amb) {
    selectedAmbulance = amb;
    update();
    Get.find<FareController>().initFor(amb);
    Get.toNamed(Routes.AMBULANCE_FARE);
  }

  /// Open a past booking's summary/map.
  void trackBooking(AmbulanceBookingEntry b) {
    lastBooking = b;
    pickupDivision = b.pickupDivision;
    pickupZilla = b.pickupZilla;
    dropDivision = b.dropDivision;
    dropZilla = b.dropZilla;
    _livePos = null;
    update();
    Get.toNamed(Routes.AMBULANCE_CONFIRMED);
  }
}
