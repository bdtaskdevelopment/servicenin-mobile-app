import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/helpers/location_helper.dart';
import '../../../core/helpers/snack_helper.dart';
import '../../../core/values/bd_geo.dart';
import '../../../data/models/response/ambulance_booking_response.dart';
import '../../../data/models/response/ambulance_response.dart';
import '../../../data/models/sn_place.dart';
import '../../../data/repositories/ambulance.repo.dart';
import '../../../data/services/geo_search.service.dart';
import '../../../data/services/route_planner.service.dart';
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

  /// The ambulance tapped from a list — carried into the fare screen.
  Ambulance? selectedAmbulance;

  /// The most recently confirmed booking — shown on the confirmed screen.
  AmbulanceBookingEntry? lastBooking;

  // ── Pickup / destination (address search) ────────────────────────────
  SnPlace? pickupPlace;
  SnPlace? dropPlace;
  bool loadingPickup = false;

  /// The road route between pickup and destination, drawn on the map.
  List<LatLng> routePoints = [];
  double routeDistanceKm = 0;
  double routeDurationMin = 0;
  bool loadingRoute = false;

  bool get hasTrip => pickupPlace != null && dropPlace != null;

  /// Called when pickup/destination change, so the fare screen can re-estimate.
  VoidCallback? onTripChanged;

  @override
  void onInit() {
    super.onInit();
    fetchAvailable();
    fetchBookings();
    _initDefaultPickup();
  }

  // ── Map points (fall back to the Bangladesh centroid until chosen) ───
  LatLng get pickupPoint => pickupPlace?.point ?? BdGeo.country;
  LatLng get destPoint => dropPlace?.point ?? BdGeo.country;

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

  /// Defaults pickup to the device's current GPS position, reverse-geocoded
  /// to a readable address. Silently does nothing if location is unavailable
  /// or denied — the user can still search pickup manually.
  Future<void> _initDefaultPickup() async {
    loadingPickup = true;
    update();
    try {
      final pos = await LocationService.getCurrentPosition();
      if (pos == null) return;
      final point = LatLng(pos.latitude, pos.longitude);
      final address = await GeoSearchService.instance.reverse(point);
      pickupPlace = SnPlace(
        label: address ?? 'My current location'.tr,
        address: address ?? 'My current location'.tr,
        point: point,
      );
      update();
      await _updateRoute();
    } finally {
      loadingPickup = false;
      update();
    }
  }

  Future<void> setPickupPlace(SnPlace place) async {
    pickupPlace = place;
    update();
    await _updateRoute();
  }

  Future<void> setDropPlace(SnPlace place) async {
    dropPlace = place;
    update();
    await _updateRoute();
  }

  Future<void> _updateRoute() async {
    final p = pickupPlace;
    final d = dropPlace;
    if (p == null || d == null) return;
    loadingRoute = true;
    update();
    final r = await RoutePlannerService.instance.route(p.point, d.point);
    routePoints = r.points;
    routeDistanceKm = r.distanceKm;
    routeDurationMin = r.durationMin;
    loadingRoute = false;
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
    pickupPlace = SnPlace(
      label: b.pickupAddress.isNotEmpty
          ? b.pickupAddress
          : '${b.pickupZilla}, ${b.pickupDivision}',
      address: b.pickupAddress,
      point: (b.pickupLat != null && b.pickupLng != null)
          ? LatLng(b.pickupLat!, b.pickupLng!)
          : BdGeo.point(b.pickupZilla, b.pickupDivision),
    );
    dropPlace = SnPlace(
      label:
          b.destination.isNotEmpty ? b.destination : '${b.dropZilla}, ${b.dropDivision}',
      address: b.destination,
      point: (b.destLat != null && b.destLng != null)
          ? LatLng(b.destLat!, b.destLng!)
          : BdGeo.point(b.dropZilla, b.dropDivision),
    );
    routePoints = [pickupPlace!.point, dropPlace!.point];
    _livePos = null;
    update();
    Get.toNamed(Routes.AMBULANCE_CONFIRMED);
  }
}
