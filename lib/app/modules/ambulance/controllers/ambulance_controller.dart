import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

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

  // ── Hotlines (GET /api/v1/ambulance/hotlines) ───────────────────────
  List<AmbulanceHotline> hotlines = [];
  bool loadingHotlines = false;

  /// The ambulance tapped from a list — carried into the fare screen.
  Ambulance? selectedAmbulance;

  /// The most recently confirmed booking — shown on the confirmed screen.
  AmbulanceBookingEntry? lastBooking;

  /// Bookings rated this session (the API doesn't echo a rated flag back on
  /// the booking list, so this is a best-effort local record).
  final Set<String> ratedBookingIds = {};
  bool submittingRating = false;

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
    fetchHotlines();
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

  Future<void> fetchHotlines() async {
    loadingHotlines = true;
    update();
    try {
      hotlines = await _repo.fetchHotlines();
    } catch (e) {
      // Silent — the hotline strip just doesn't render if this fails.
    } finally {
      loadingHotlines = false;
      update();
    }
  }

  /// Open the phone dialer for a hotline number.
  Future<void> callHotline(String number) async {
    final digits = number.trim();
    if (digits.isEmpty) return;
    final uri = Uri.parse('tel:$digits');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      SnackHelper.error('ডায়াল করা যায়নি');
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

  /// Rates a completed trip, or files it as a complaint. Returns whether the
  /// submission succeeded (a snackbar reports the outcome either way).
  Future<bool> submitRating(
    String bookingId, {
    required int driverRating,
    required int ambulanceConditionRating,
    required int serviceRating,
    String comment = '',
    bool isComplaint = false,
    String complaintNote = '',
  }) async {
    if (submittingRating) return false;
    submittingRating = true;
    update();
    try {
      final res = await _repo.rateBooking(
        bookingId,
        driverRating: driverRating,
        ambulanceConditionRating: ambulanceConditionRating,
        serviceRating: serviceRating,
        comment: comment,
        isComplaint: isComplaint,
        complaintNote: complaintNote,
      );
      if (res.success) {
        ratedBookingIds.add(bookingId);
        SnackHelper.success(
            res.message.isNotEmpty ? res.message : 'Thank you for your feedback'.tr);
        return true;
      }
      SnackHelper.error(res.message);
      return false;
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      // The backend rejects a second rating for the same booking — treat
      // that as an already-successful outcome instead of a hard error, so
      // the user isn't stuck on the rating form for something already done.
      if (msg.toLowerCase().contains('already submitted')) {
        ratedBookingIds.add(bookingId);
        SnackHelper.success('You have already rated this trip'.tr);
        return true;
      }
      SnackHelper.error(msg);
      return false;
    } finally {
      submittingRating = false;
      update();
    }
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

  bool refreshingBooking = false;

  /// Re-fetches [lastBooking]'s latest state from the server — backs the
  /// pull-to-refresh on the booking details page.
  Future<void> refreshBookingDetails() async {
    final current = lastBooking;
    if (current == null || current.id.isEmpty || refreshingBooking) return;
    refreshingBooking = true;
    update();
    try {
      lastBooking = await _repo.fetchBookingById(current.id);
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      refreshingBooking = false;
      update();
    }
  }

  /// The road-following route for the booking details/confirmed page — kept
  /// separate from the live [routePoints] used while picking a trip, since
  /// that gets cleared right after a booking is confirmed.
  List<LatLng> lastBookingRoutePoints = [];
  String? _lastBookingRouteFor;

  LatLng _pickupPointOf(AmbulanceBookingEntry b) =>
      (b.pickupLat != null && b.pickupLng != null)
          ? LatLng(b.pickupLat!, b.pickupLng!)
          : BdGeo.point(b.pickupZilla, b.pickupDivision);

  LatLng _dropPointOf(AmbulanceBookingEntry b) =>
      (b.destLat != null && b.destLng != null)
          ? LatLng(b.destLat!, b.destLng!)
          : BdGeo.point(b.dropZilla, b.dropDivision);

  /// Adopts an already-known road route for [lastBooking] (e.g. the one just
  /// computed while picking the trip) instead of fetching it again.
  void useRouteForLastBooking(List<LatLng> points) {
    final b = lastBooking;
    if (b == null || points.length < 2) return;
    lastBookingRoutePoints = points;
    _lastBookingRouteFor = b.id;
  }

  /// Fetches the real road-following polyline for [lastBooking] (same routing
  /// service the booking screen uses), so the details page map matches it
  /// instead of drawing a straight line between the two pins. Safe to call
  /// repeatedly — skips the network call once already loaded for this booking.
  Future<void> loadLastBookingRoute() async {
    final b = lastBooking;
    if (b == null) return;
    if (_lastBookingRouteFor == b.id && lastBookingRoutePoints.isNotEmpty) {
      return;
    }
    _lastBookingRouteFor = b.id;
    try {
      final r = await RoutePlannerService.instance
          .route(_pickupPointOf(b), _dropPointOf(b));
      lastBookingRoutePoints = r.points;
      update();
    } catch (_) {
      // Keep whatever was there before (the view falls back to a straight
      // line when this list is empty) — a failed route fetch shouldn't
      // block viewing the booking details.
    }
  }

  /// Open a past booking's summary/map.
  void trackBooking(AmbulanceBookingEntry b) {
    lastBooking = b;
    lastBookingRoutePoints = [];
    _lastBookingRouteFor = null;
    _livePos = null;
    unawaited(loadLastBookingRoute());
    update();
    Get.toNamed(Routes.AMBULANCE_CONFIRMED);
  }
}
