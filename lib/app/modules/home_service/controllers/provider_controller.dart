import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/helpers/location_helper.dart';
import '../../../core/helpers/snack_helper.dart';
import '../../../data/models/response/service_response.dart';
import '../../../data/repositories/service.repo.dart';
import '../../../data/services/geo_search.service.dart';
import '../../../routes/app_pages.dart';

class WithdrawalEntry {
  const WithdrawalEntry(this.amount, this.method, this.id, this.date);
  final String amount;
  final String method;
  final String id;
  final String date;
}

/// Statuses that still belong on the "Assigned jobs" list — anything past
/// `completed` (or a dead job) drops off automatically once the list is
/// re-fetched after a status change.
const _activeJobStatuses = {
  'assigned',
  'accepted',
  'on_the_way',
  'arrived',
  'in_progress',
};

String _statusLabel(String status) {
  switch (status) {
    case 'on_the_way':
      return 'On the way';
    case 'in_progress':
      return 'In progress';
    default:
      return status.isEmpty
          ? ''
          : status[0].toUpperCase() + status.substring(1).replaceAll('_', ' ');
  }
}

/// Label for the single dynamic action button shown once a job is past
/// "assigned" (which instead shows separate Accept/Decline buttons).
String? _advanceLabel(String? nextStatus) {
  switch (nextStatus) {
    case 'on_the_way':
      return 'Start job';
    case 'arrived':
      return 'Mark arrived';
    case 'in_progress':
      return 'Start work';
    case 'completed':
      return 'Complete';
    default:
      return null;
  }
}

class ProviderController extends GetxController {
  ServiceRepository get _repo => Get.find<ServiceRepository>();

  ProviderDashboardSummary? dashboard;
  List<ProviderJob> jobs = [];
  bool loading = false;

  // Dashboard card fallbacks so the layout never shows a blank/null while
  // the first load is in flight.
  String get name => dashboard?.fullName.isNotEmpty == true ? dashboard!.fullName : '';
  String get balance => dashboard?.balanceLabel ?? '৳0';
  String get pending => dashboard?.pendingLabel ?? '৳0';
  String get withdrawn => dashboard?.withdrawnLabel ?? '৳0';
  String get jobsDone => '${dashboard?.totalJobs ?? 0}';
  String get rating => dashboard?.ratingLabel ?? '—';
  // Not returned by the dashboard endpoint (no acceptance-rate field on the
  // backend) — shown as a dash rather than a fabricated number.
  final String acceptance = '—';

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    loading = true;
    update();
    try {
      final results = await Future.wait([
        _repo.fetchProviderDashboard(),
        _repo.fetchProviderJobs(),
      ]);
      dashboard = results[0] as ProviderDashboardSummary;
      jobs = (results[1] as List<ProviderJob>)
          .where((j) => _activeJobStatuses.contains(j.status))
          .toList();
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loading = false;
      update();
    }
  }

  Future<void> acceptJob(ProviderJob job) async {
    try {
      await _repo.acceptJob(job.id,
          taskId: job.isWholeBooking ? null : job.taskIds.first);
      await loadDashboard();
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> declineJob(ProviderJob job) async {
    try {
      await _repo.declineJob(job.id,
          taskId: job.isWholeBooking ? null : job.taskIds.first);
      await loadDashboard();
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// The single dynamic action for a job past "assigned" — advances it to
  /// [ProviderJob.nextStatus]. Starts/stops the GPS push timer around the
  /// on_the_way ⇄ arrived leg, since that's the stretch a citizen actually
  /// needs to see moving on their tracking map. This is what the map
  /// screen's "Start" button (and the dashboard card's action button) both
  /// call — same trip, same button, two entry points.
  Future<void> advanceJob(ProviderJob job) async {
    final next = job.nextStatus;
    if (next == null) return;
    try {
      await _repo.updateBookingStatus(job.id, next,
          taskId: job.isWholeBooking ? null : job.taskIds.first);
      if (next == 'on_the_way') {
        _startLocationPush(job.id);
      } else {
        _stopLocationPush();
      }
      await loadDashboard();
      if (trackedJob?.id == job.id) {
        trackedJob = _findJob(job.id);
        if (trackedJob == null) Get.back(); // e.g. completed — nothing left to track
        update();
      }
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  String? actionLabel(ProviderJob job) => _advanceLabel(job.nextStatus);
  String statusLabel(String status) => _statusLabel(status);

  ProviderJob? _findJob(String id) {
    for (final j in jobs) {
      if (j.id == id) return j;
    }
    return null;
  }

  // ── Job map screen — provider's own live position + destination pin ──
  //
  // Separate from the network location-push timer above: this is a purely
  // local, on-screen refresh (position + geocoded destination) so the map
  // and distance label update while the screen is open. Stops when the
  // screen closes; the actual GPS-push-to-backend timer above is untouched
  // by this and keeps running (the citizen still needs updates even if the
  // provider backs out of this screen mid-trip).
  ProviderJob? trackedJob;
  LatLng? destPoint;
  bool loadingDest = false;
  double? myLat;
  double? myLng;
  Timer? _myLocTimer;

  double? get destDistanceKm {
    if (myLat == null || myLng == null || destPoint == null) return null;
    return Geolocator.distanceBetween(
            myLat!, myLng!, destPoint!.latitude, destPoint!.longitude) /
        1000;
  }

  String get destDistanceLabel {
    final km = destDistanceKm;
    if (km == null) return '';
    return km < 1 ? '${(km * 1000).round()} m away' : '${km.toStringAsFixed(1)} km away';
  }

  Future<void> openJobMap(ProviderJob job) async {
    trackedJob = job;
    destPoint = null;
    myLat = null;
    myLng = null;
    update();
    Get.toNamed(Routes.HS_PROVIDER_JOB_MAP);
    _startMyLocationRefresh();
    await _geocodeDestination(job.address);
  }

  Future<void> _geocodeDestination(String address) async {
    if (address.isEmpty) return;
    loadingDest = true;
    update();
    destPoint = await GeoSearchService.instance.forward(address);
    loadingDest = false;
    update();
  }

  void _startMyLocationRefresh() {
    _myLocTimer?.cancel();
    _refreshMyLocation();
    _myLocTimer =
        Timer.periodic(const Duration(seconds: 5), (_) => _refreshMyLocation());
  }

  Future<void> _refreshMyLocation() async {
    final pos = await LocationService.getCurrentPosition();
    if (pos == null) return;
    myLat = pos.latitude;
    myLng = pos.longitude;
    update();
  }

  /// Called via the map screen's PopScope on any exit path — stops the
  /// local position refresh only (the GPS-push-to-backend timer keeps
  /// running independently, see [advanceJob]'s doc comment above).
  void stopJobMapRefresh() {
    _myLocTimer?.cancel();
    _myLocTimer = null;
  }

  // ── GPS push while a job is on_the_way ───────────────────────────────
  Timer? _locationTimer;
  String? _activeLocationBookingId;

  void _startLocationPush(String bookingId) {
    _stopLocationPush();
    _activeLocationBookingId = bookingId;
    _pushOnce(bookingId); // don't wait a full tick for the first ping
    _locationTimer = Timer.periodic(
        const Duration(seconds: 20), (_) => _pushOnce(bookingId));
  }

  void _stopLocationPush() {
    _locationTimer?.cancel();
    _locationTimer = null;
    _activeLocationBookingId = null;
  }

  Future<void> _pushOnce(String bookingId) async {
    if (_activeLocationBookingId != bookingId) return; // superseded/stopped
    final pos = await LocationService.getCurrentPosition();
    if (pos == null || _activeLocationBookingId != bookingId) return;
    try {
      await _repo.pushProviderLocation(bookingId, pos.latitude, pos.longitude);
    } catch (_) {
      // Best-effort — next tick will retry; no need to surface a snackbar
      // for a background ping.
    }
  }

  // ── Earnings tab (unchanged — real balance/withdrawal integration is a
  // separate, later task) ──────────────────────────────────────────────
  final String monthEarnings = '৳24,680';
  final String monthJobs = '32 jobs';
  final String avgPerJob = 'avg ৳771/job';

  final List<String> withdrawMethods = const ['bKash', 'Nagad', 'Rocket', 'Bank'];
  int selectedWithdraw = 0;
  void selectWithdraw(int i) {
    selectedWithdraw = i;
    update();
  }

  final List<WithdrawalEntry> history = const [
    WithdrawalEntry('৳5,000', 'bKash', 'WD-221', '28 May'),
    WithdrawalEntry('৳8,000', 'Bank', 'WD-198', '6 May'),
    WithdrawalEntry('৳3,500', 'Nagad', 'WD-176', '24 Apr'),
  ];

  // ── Navigation ───────────────────────────────────────────────────────
  void withdrawEarnings() => Get.toNamed(Routes.HS_EARNINGS);
  void withdrawAll() =>
      Get.until((route) => route.settings.name == Routes.HS_PROVIDER);

  @override
  void onClose() {
    _stopLocationPush();
    stopJobMapRefresh();
    super.onClose();
  }
}
