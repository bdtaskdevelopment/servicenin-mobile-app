import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/helpers/location_helper.dart';
import '../../../core/helpers/snack_helper.dart';
import '../../../core/mixins/live_refresh_mixin.dart';
import '../../../core/values/storage.dart';
import '../../../data/models/response/blood_bank_response.dart';
import '../../../data/models/response/blood_donation_response.dart';
import '../../../data/models/response/blood_event_response.dart';
import '../../../data/models/response/blood_request_response.dart';
import '../../../data/services/geo_search.service.dart';
import '../../../data/models/response/blood_responder_response.dart';
import '../../../data/models/response/blood_response_response.dart';
import '../../../data/models/response/donor_response.dart';
import '../../../data/repositories/blood.repo.dart';
import '../../../data/services/storage.service.dart';
import '../../../routes/app_pages.dart';
// OTP step removed — responses are auto-verified server-side.
// import '../widgets/respond_otp_sheet.dart';
import 'blood_chat_controller.dart';

enum BloodSeverity { critical, urgent, routine }

extension BloodSeverityX on BloodSeverity {
  String get label => switch (this) {
        BloodSeverity.critical => 'Critical',
        BloodSeverity.urgent => 'Urgent',
        BloodSeverity.routine => 'Routine',
      };

  Color get color => switch (this) {
        BloodSeverity.critical => const Color(0xFFE5383B),
        BloodSeverity.urgent => const Color(0xFF92400E),
        BloodSeverity.routine => const Color(0xFF1D4ED8),
      };

  Color get bg => switch (this) {
        BloodSeverity.critical => const Color(0xFFFDECEC),
        BloodSeverity.urgent => const Color(0xFFFEF3C7),
        BloodSeverity.routine => const Color(0xFFE0EBFF),
      };
}

class BloodRequest {
  const BloodRequest({
    required this.units,
    required this.group,
    required this.severity,
    required this.hospital,
    required this.area,
    required this.distance,
    required this.timeAgo,
    required this.responded,
    this.contact = 'Karim Sheikh · 01711-***123',
    this.note = '',
  });

  final int units;
  final String group;
  final BloodSeverity severity;
  final String hospital;
  final String area;
  final String distance; // km
  final String timeAgo;
  final int responded;
  final String contact;
  final String note;
}

class BloodController extends GetxController with LiveRefreshMixin {
  BloodRepository get _repo => Get.find<BloodRepository>();

  // ── Donors near you (GET /api/v1/blood/donors[/nearest]) ────────────
  List<DonorEntry> nearestDonors = [];
  List<DonorEntry> allDonors = [];
  bool loadingNearest = false;
  bool loadingAllDonors = false;

  // ── Live refresh (LiveRefreshMixin) ─────────────────────────────────
  // There's no single-request GET endpoint, so the open detail re-derives
  // itself from the (re-fetched) my-requests / open-requests lists when a
  // blood notification for it arrives.
  @override
  Set<String> get liveRefreshTypes => {'blood_request'};
  @override
  String get liveRefreshId => viewingRequest?.id ?? '';
  @override
  Future<void> onLiveRefresh() async {
    final id = viewingRequest?.id ?? '';
    if (id.isEmpty) return;
    await Future.wait([fetchMyRequests(), fetchRequests()]);
    final fresh = _findRequestById(id);
    if (fresh != null) {
      viewingRequest = fresh;
      update();
    }
  }

  /// Re-points [viewingRequest] at the freshly-fetched copy of [id], if any.
  /// Used after an edit-save so the detail screen the user lands back on
  /// shows the just-updated fields instead of the stale pre-edit object.
  void syncViewingRequest(String id) {
    final fresh = _findRequestById(id);
    if (fresh != null) {
      viewingRequest = fresh;
      update();
    }
  }

  BloodRequestEntry? _findRequestById(String id) {
    for (final r in [...myRequests, ...requestList]) {
      if (r.id == id) return r;
    }
    return null;
  }

  /// Deep-link entry: open a blood request's detail by id. No by-id endpoint
  /// exists, so we (re)load the user's lists and find it there — a blood
  /// notification always targets the requester or a responding donor, so the
  /// request is in one of these. Falls back to the requests list if not found.
  Future<void> loadRequestById(String id) async {
    if (id.isEmpty) return;
    var found = _findRequestById(id);
    if (found == null) {
      await Future.wait([fetchMyRequests(), fetchRequests()]);
      found = _findRequestById(id);
    }
    if (found != null) {
      viewingRequest = found;
      update();
    } else {
      // Couldn't resolve it — send them to the requests list rather than a
      // blank detail page.
      Get.offNamed(Routes.BLOOD_REQUESTS);
      fetchRequests();
    }
  }

  @override
  void onInit() {
    super.onInit();
    _initUserLocation();
    fetchNearestDonors();
    fetchMyResponses();
    fetchMyRank();
    fetchMyDonorStatus();
    fetchMyRequests();
    fetchRequests();
    fetchCommunityStats();
    fetchEvents();
    startLiveRefresh();
  }

  // ── Community impact stats (home screen maroon card) ─────────────────
  Map<String, int> communityStats = const {};
  Future<void> fetchCommunityStats() async {
    communityStats = await _repo.fetchCommunityStats();
    update();
  }

  // ── Nearby donors with a distance radius (repurposed "all donors" screen,
  // route BLOOD_DONORS — the old unbounded fetchAllDonors() had zero
  // callers; this screen is now the mockup's "কাছাকাছি ডোনার" list) ───────
  int donorRadiusKm = 10; // one of 10/20/50/0 ("all")

  void setDonorRadius(int km) {
    donorRadiusKm = km;
    update();
  }

  void _applyDonorDistances() {
    final la = userLat, lo = userLng;
    if (la == null || lo == null) return;
    for (final d in nearestDonors) {
      if (d.lat != null && d.lng != null) {
        d.distanceKm = _haversineKm(la, lo, d.lat!, d.lng!);
      }
    }
  }

  List<DonorEntry> get visibleNearestDonors {
    final list = nearestDonors.where((d) {
      if (donorRadiusKm <= 0) return true; // "all over"
      final dist = d.distanceKm;
      return dist == null || dist <= donorRadiusKm;
    }).toList();
    list.sort((a, b) =>
        (a.distanceKm ?? double.infinity).compareTo(b.distanceKm ?? double.infinity));
    return list;
  }

  void openNearbyDonors() {
    fetchNearestDonors();
    Get.toNamed(Routes.BLOOD_DONORS);
  }

  // ── Blood bank directory ──────────────────────────────────────────────
  List<BloodBank> banks = [];
  bool loadingBanks = false;
  String bankSearch = '';

  Future<void> fetchBanks({String? q}) async {
    loadingBanks = true;
    update();
    try {
      banks = await _repo.fetchBanks(q: q);
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingBanks = false;
      update();
    }
  }

  void searchBanks(String q) {
    bankSearch = q;
    fetchBanks(q: q);
  }

  void openBanks() {
    fetchBanks();
    Get.toNamed(Routes.BLOOD_BANKS);
  }

  // ── Events / campaigns ─────────────────────────────────────────────────
  List<BloodEvent> upcomingEvents = [];
  List<BloodEvent> pastEvents = [];
  bool loadingEvents = false;

  Future<void> fetchEvents() async {
    loadingEvents = true;
    update();
    try {
      final results = await Future.wait([
        _repo.fetchEvents(scope: 'upcoming'),
        _repo.fetchEvents(scope: 'past'),
      ]);
      upcomingEvents = results[0];
      pastEvents = results[1];
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingEvents = false;
      update();
    }
  }

  void openEvents() {
    fetchEvents();
    Get.toNamed(Routes.BLOOD_EVENTS);
  }

  BloodEvent? viewingEvent;
  Future<void> openEvent(BloodEvent e) async {
    viewingEvent = e;
    update();
    Get.toNamed(Routes.BLOOD_EVENT_DETAIL);
    final fresh = await _repo.fetchEvent(e.id);
    if (fresh != null) {
      viewingEvent = fresh;
      update();
    }
  }

  bool joiningEvent = false;
  Future<void> toggleJoinEvent(BloodEvent e) async {
    if (joiningEvent) return;
    joiningEvent = true;
    update();
    try {
      final res = e.hasJoined
          ? await _repo.leaveEvent(e.id)
          : await _repo.joinEvent(e.id);
      if (res.success) {
        final fresh = await _repo.fetchEvent(e.id);
        if (fresh != null) {
          viewingEvent = fresh;
          final idx = upcomingEvents.indexWhere((x) => x.id == e.id);
          if (idx >= 0) upcomingEvents[idx] = fresh;
        }
      } else {
        SnackHelper.error(res.message);
      }
    } catch (ex) {
      SnackHelper.error(ex.toString().replaceFirst('Exception: ', ''));
    } finally {
      joiningEvent = false;
      update();
    }
  }

  // ── Donation history ("আমার রক্তদান" — the 2nd tab on My Responses) ────
  List<BloodDonation> myDonations = [];
  bool loadingDonations = false;

  Future<void> fetchMyDonations() async {
    loadingDonations = true;
    update();
    try {
      myDonations = await _repo.fetchMyDonations();
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingDonations = false;
      update();
    }
  }

  void openAddDonation() => Get.toNamed(Routes.BLOOD_ADD_DONATION);

  // ── Viewer's current location (drives "requests near you" matching) ───
  double? userLat;
  double? userLng;

  /// Reverse-geocoded short area name for the current GPS position — shown
  /// in place of the old hardcoded "Gulshan area".
  String areaLabel = '';

  /// Reads the device GPS, resolves a readable area name, and re-computes
  /// each request's distance from the user. Silent no-op if location is off.
  Future<void> _initUserLocation() async {
    try {
      final pos = await LocationService.getCurrentPosition();
      if (pos == null) return;
      userLat = pos.latitude;
      userLng = pos.longitude;
      // Now that we know where the user is, re-pull the requests so the
      // backend applies the "near you" radius filter (the first load in
      // onInit ran before GPS resolved).
      fetchRequests();
      _applyDonorDistances();
      update();
      final resolved =
          await GeoSearchService.instance.reverse(LatLng(pos.latitude, pos.longitude));
      if (resolved != null && resolved.isNotEmpty) {
        areaLabel = _shortArea(resolved);
        update();
      }
    } catch (_) {
      // Location unavailable — the list falls back to showing everything.
    }
  }

  /// Keep the first one or two address segments (e.g. "Baishakhi, Lake City
  /// Rd") for a compact header label.
  String _shortArea(String full) {
    final parts = full
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    return parts.isEmpty ? full : parts.take(2).join(', ');
  }

  /// Stamps `distanceKm` onto every request from the viewer's position.
  void _applyDistances() {
    final la = userLat, lo = userLng;
    if (la == null || lo == null) return;
    for (final r in requestList) {
      if (r.lat != null && r.lng != null) {
        r.distanceKm = _haversineKm(la, lo, r.lat!, r.lng!);
      }
    }
  }

  /// Great-circle distance in km.
  double _haversineKm(double lat1, double lng1, double lat2, double lng2) {
    const earthKm = 6371.0;
    double rad(double d) => d * math.pi / 180.0;
    final dLat = rad(lat2 - lat1);
    final dLng = rad(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(rad(lat1)) *
            math.cos(rad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return 2 * earthKm * math.asin(math.min(1.0, math.sqrt(a)));
  }

  /// Pull-to-refresh for the Blood Bank home page — reloads the nearby donors,
  /// my responses, my leaderboard rank and my donor availability together.
  Future<void> refreshHome() async {
    await Future.wait([
      fetchNearestDonors(),
      fetchMyResponses(),
      fetchMyRank(),
      fetchMyDonorStatus(),
      fetchMyRequests(),
      fetchRequests(),
      fetchCommunityStats(),
      fetchEvents(),
    ]);
  }

  /// GET /api/v1/blood/donors/me — seed the availability toggle from the
  /// donor profile's `is_available`. Null means the user isn't a registered
  /// donor yet, so the toggle stays at its default until they register.
  Future<void> fetchMyDonorStatus() async {
    try {
      final me = await _repo.fetchMyDonor();
      myDonor = me;
      if (me != null) {
        isDonor = true;
        isAvailable = me.isAvailable;
      } else {
        isDonor = false;
      }
    } catch (_) {
      // Keep the current toggle state on failure.
    } finally {
      update();
    }
  }

  /// GET /api/v1/blood/donors/nearest — for the "Requests near you" section.
  Future<void> fetchNearestDonors() async {
    loadingNearest = true;
    update();
    try {
      nearestDonors = await _repo.fetchNearestDonors();
      _applyDonorDistances();
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingNearest = false;
      update();
    }
  }

  /// GET /api/v1/blood/donors — the full list shown on the "See all" screen.
  Future<void> fetchAllDonors() async {
    loadingAllDonors = true;
    update();
    try {
      allDonors = await _repo.fetchDonors();
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingAllDonors = false;
      update();
    }
  }

  void openAllDonors() {
    fetchAllDonors();
    Get.toNamed(Routes.BLOOD_DONORS);
  }

  /// The donor tapped to view in detail.
  DonorEntry? viewingDonor;
  void viewDonor(DonorEntry donor) {
    viewingDonor = donor;
    update();
    Get.toNamed(Routes.BLOOD_DONOR_DETAIL);
  }

  // ── Blood requests (GET /api/v1/blood/requests) — the Donate section ──
  List<BloodRequestEntry> requestList = [];
  bool loadingRequests = false;

  /// Open requests still needing a donor — shown as a count badge on the
  /// dashboard's "Donate" card.
  int get openRequestsCount =>
      requestList.where((r) => !r.isFulfilled).length;

  /// The "requests near you" list — matched to the viewer:
  ///  • blood group: only requests this user can donate to (only enforced
  ///    once we know their donor group; non-donors see all groups),
  ///  • distance: only requests whose alert radius (search_radius_km, chosen
  ///    by the requester) covers the user's current location; radius 0 =
  ///    "all over" (no limit). Requests we can't place (missing coords /
  ///    location off) are kept rather than hidden.
  /// Sorted nearest-first.
  List<BloodRequestEntry> get visibleRequestEntries {
    // Exact blood-group match: a registered donor only sees requests for their
    // OWN group (e.g. a B+ donor sees only B+ requests), per requirement — not
    // the broader ABO/Rh compatible set. Non-donors (empty group) see all.
    final myGroup = myDonor?.bloodGroup ?? '';
    final list = requestList.where((r) {
      if (myGroup.isNotEmpty && r.bloodGroup != myGroup) return false;
      if (userLat != null &&
          userLng != null &&
          r.lat != null &&
          r.lng != null &&
          r.searchRadiusKm > 0) {
        final d = r.distanceKm ??
            _haversineKm(userLat!, userLng!, r.lat!, r.lng!);
        if (d > r.searchRadiusKm) return false;
      }
      return true;
    }).toList();
    list.sort((a, b) =>
        (a.distanceKm ?? double.infinity).compareTo(b.distanceKm ?? double.infinity));
    return list;
  }

  // ── Requests-list filter chips (সব/আ্যাকটিভ/ডোনেশন/রিজেক্ট) — these read
  // the viewer's OWN response status on each request (from the already-
  // fetched [myResponses]), not the request's own open/fulfilled status. An
  // open request the viewer hasn't responded to yet still counts as Active.
  String requestFilter = 'all'; // all | active | donation | reject

  void setRequestFilter(String value) {
    requestFilter = value;
    update();
  }

  /// The viewer's own fulfillment status for [requestId], or null when they
  /// haven't responded to it.
  String? myResponseStatusFor(String requestId) {
    for (final r in myResponses) {
      if (r.requestId == requestId) return r.status;
    }
    return null;
  }

  List<BloodRequestEntry> get filteredRequestEntries {
    if (requestFilter == 'all') return visibleRequestEntries;
    return visibleRequestEntries.where((r) {
      final status = myResponseStatusFor(r.id);
      switch (requestFilter) {
        case 'donation':
          return status == 'donated';
        case 'reject':
          return status == 'declined';
        case 'active':
          return status == null || status == 'pending' || status == 'accepted';
        default:
          return true;
      }
    }).toList();
  }

  Future<void> fetchRequests() async {
    loadingRequests = true;
    update();
    try {
      // Send the user's location so the backend returns only requests whose
      // alert radius reaches them (correct even when paginated). The
      // client-side distance/group logic then just labels + sorts them.
      requestList = await _repo.fetchRequests(lat: userLat, lng: userLng);
      _applyDistances();
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingRequests = false;
      update();
    }
  }

  /// Open the Donate screen (list of requests) and load it.
  void openDonate() {
    fetchRequests();
    Get.toNamed(Routes.BLOOD_REQUESTS);
  }

  /// The request tapped to view in detail. For the viewer's own request,
  /// this also loads the responders list inline (the detail screen's
  /// `isMyRequest` branch absorbs what used to be a separate
  /// BLOOD_RESPONDERS screen — see [openResponders]).
  BloodRequestEntry? viewingRequest;
  void viewRequest(BloodRequestEntry request) {
    viewingRequest = request;
    update();
    Get.toNamed(Routes.BLOOD_REQUEST_DETAIL);
    if (isMyRequest(request)) {
      selectedMyRequest = request;
      responders = [];
      update();
      fetchResponders();
    }
  }

  // ── My responses (respond + GET /api/v1/blood/responses/my) ─────────
  List<BloodResponseEntry> myResponses = [];
  bool loadingResponses = false;
  bool responding = false;
  bool verifyingOtp = false;

  /// POST /api/v1/blood/requests/:id/respond — offer to donate. The backend now
  /// auto-verifies the response (otp_verified: true), so we go straight to the
  /// confirmation screen instead of an OTP step.
  Future<void> respondToRequest(String requestId) async {
    if (responding) return;
    responding = true;
    update();
    try {
      final res = await _repo.respondToRequest(requestId);
      responding = false;
      update();
      if (res.success) {
        SnackHelper.success(res.message);
        // OTP step removed — response is auto-verified server-side.
        // RespondOtpSheet.show();
        fetchMyResponses();
        Get.offNamed(Routes.BLOOD_CONFIRMED);
      } else {
        SnackHelper.error(res.message);
      }
    } catch (e) {
      responding = false;
      update();
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// POST /api/v1/blood/donors/verify-otp — verify the OTP from the sheet, then
  /// land on the donation-confirmed screen (replacing the request detail).
  Future<void> verifyRespondOtp(String otp) async {
    if (verifyingOtp) return;
    verifyingOtp = true;
    update();
    try {
      final res = await _repo.verifyDonorOtp(otp);
      verifyingOtp = false;
      update();
      if (res.success) {
        SnackHelper.success(res.message);
        fetchMyResponses();
        if (Get.isBottomSheetOpen ?? false) Get.back(); // close the sheet
        Get.offNamed(Routes.BLOOD_CONFIRMED); // replace the request detail
      } else {
        SnackHelper.error(res.message);
      }
    } catch (e) {
      verifyingOtp = false;
      update();
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// GET /api/v1/blood/responses/my — requests I've responded to.
  Future<void> fetchMyResponses() async {
    loadingResponses = true;
    update();
    try {
      myResponses = await _repo.fetchMyResponses();
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingResponses = false;
      update();
    }
  }

  void openMyResponses() {
    fetchMyResponses();
    fetchMyDonations();
    Get.toNamed(Routes.BLOOD_MY_RESPONSES);
  }

  // ── My requests (GET /api/v1/blood/requests/my) ─────────────────────
  List<BloodRequestEntry> myRequests = [];
  bool loadingMyRequests = false;

  Future<void> fetchMyRequests() async {
    loadingMyRequests = true;
    update();
    try {
      myRequests = await _repo.fetchMyRequests();
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingMyRequests = false;
      update();
    }
  }

  void openMyRequests() {
    fetchMyRequests();
    Get.toNamed(Routes.BLOOD_MY_REQUESTS);
  }

  // ── Responders for a chosen request ─────────────────────────────────
  // (GET /api/v1/blood/requests/:id/responders)
  BloodRequestEntry? selectedMyRequest;
  List<BloodResponder> responders = [];
  bool loadingResponders = false;
  bool completing = false;

  /// Confirmed donations so far — donors the requester has marked as having
  /// donated. A multi-unit request needs one per bag.
  int get confirmedCount =>
      responders.where((r) => r.status == 'donated').length;

  /// Bags needed for the selected request (at least 1).
  int get unitsNeededForSelected {
    final u = selectedMyRequest?.unitsNeeded ?? 1;
    return u < 1 ? 1 : u;
  }

  /// The request is FILLED once it has as many confirmed donations as bags
  /// needed (a 3-bag request needs 3 donors to confirm), or the server has
  /// already flipped it to fulfilled. Used to close the actions.
  bool get requestCompleted =>
      (selectedMyRequest?.isFulfilled ?? false) ||
      confirmedCount >= unitsNeededForSelected;

  /// Requester cancels their own still-open request ("রিজেক্ট" on the
  /// owner's request-detail screen).
  bool closingRequest = false;
  Future<void> closeRequest(BloodRequestEntry r) async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Cancel this request?'.tr),
        content: Text('Donors will no longer be able to respond.'.tr),
        actions: [
          TextButton(
              onPressed: () => Get.back(result: false), child: Text('No'.tr)),
          TextButton(
              onPressed: () => Get.back(result: true), child: Text('Yes, cancel'.tr)),
        ],
      ),
    );
    if (ok != true || closingRequest) return;
    closingRequest = true;
    update();
    try {
      final res = await _repo.closeRequest(r.id);
      if (res.success) {
        SnackHelper.success(res.message);
        await fetchMyRequests();
        // Get.until (not Get.back()) — a plain back() after an awaited
        // refresh's update() has been observed to silently no-op here, same
        // race as the edit-request and add-donation save flows.
        Get.until((route) => route.settings.name == Routes.BLOOD_MY_REQUESTS);
      } else {
        SnackHelper.error(res.message);
      }
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      closingRequest = false;
      update();
    }
  }

  void openResponders(BloodRequestEntry r) {
    selectedMyRequest = r;
    responders = [];
    update();
    Get.toNamed(Routes.BLOOD_RESPONDERS);
    fetchResponders();
  }

  Future<void> fetchResponders() async {
    final id = selectedMyRequest?.id ?? '';
    if (id.isEmpty) return;
    loadingResponders = true;
    update();
    try {
      responders = await _repo.fetchResponders(id);
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingResponders = false;
      update();
    }
  }

  /// Call a responder (donor). Falls back to a message when no phone is set.
  void callResponder(BloodResponder r) {
    if (r.donorPhone.isEmpty) {
      SnackHelper.error('ডোনারের ফোন নম্বর পাওয়া যায়নি');
      return;
    }
    callPhone(r.donorPhone);
  }

  /// Open the fulfillment chat with a responder (keyed by the fulfillment id).
  void chatResponder(BloodResponder r) {
    Get.find<BloodChatController>().configure(
      chatId: r.id,
      partnerName: r.displayName,
      partnerPhone: r.donorPhone,
      partnerPhoto: r.donorPhoto,
    );
    Get.toNamed(Routes.BLOOD_CHAT);
  }

  /// "Mark complete" → confirm, then POST /fulfillments/:id/received. On
  /// success the request is marked fulfilled so the actions are disabled.
  Future<void> confirmReceived(BloodResponder r) async {
    // Already-confirmed donors can't be re-confirmed; and once the request is
    // fully filled no further confirmations are needed.
    if (completing || requestCompleted || r.status == 'donated') return;
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Confirm blood received'.tr),
        content: Text('Are you sure you have received blood?'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('Yes, received'.tr),
          ),
        ],
      ),
    );
    if (ok != true) return;
    completing = true;
    update();
    try {
      final res = await _repo.confirmReceived(r.id);
      if (res.success) {
        // Reflect THIS donor as confirmed (status → donated). The request only
        // becomes filled once confirmedCount reaches unitsNeeded, so for a
        // multi-bag request the other donors' actions stay open.
        await fetchResponders();
        fetchMyRequests(); // refresh the my-requests list in the background
        if (requestCompleted) {
          SnackHelper.success('All bags confirmed — request filled.'.tr);
        } else {
          final left = unitsNeededForSelected - confirmedCount;
          SnackHelper.success(
              '${'Donor confirmed.'.tr} $left ${'more to go.'.tr}');
        }
      } else {
        SnackHelper.error(res.message);
      }
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      completing = false;
      update();
    }
  }

  // ── Chat partner (shared by the donor-chat screen) ──────────────────
  String chatTitle = 'Donor';
  String chatInitials = 'D';
  String chatSubtitle = 'connected donor';
  String chatPhone = '';

  /// Open the live chat for a response. The chat endpoint is keyed by the
  /// request id (`/fulfillments/:requestId/chat`).
  void openResponseChat(BloodResponseEntry r) {
    if (r.requestId.isEmpty) {
      SnackHelper.error('চ্যাট খোলা যাচ্ছে না — অনুরোধ আইডি পাওয়া যায়নি');
      return;
    }
    Get.find<BloodChatController>().configure(
      chatId: r.requestId,
      partnerName: r.requesterName,
      partnerPhone: r.phone,
      partnerPhoto: r.requesterPhoto,
    );
    Get.toNamed(Routes.BLOOD_CHAT);
  }

  /// Dial a donor's phone number.
  Future<void> callPhone(String phone) async {
    final digits = phone.trim();
    if (digits.isEmpty) {
      SnackHelper.error('ফোন নম্বর নেই');
      return;
    }
    try {
      await launchUrl(Uri.parse('tel:$digits'),
          mode: LaunchMode.externalApplication);
    } catch (_) {
      SnackHelper.error('ডায়াল করা যায়নি');
    }
  }

  // Donor profile
  String get donorGroup => myDonor?.bloodGroup ?? '';
  final int donations = 12;
  final int livesSaved = 36;

  /// The user's real reverse-geocoded area (from GPS), replacing the old
  /// hardcoded "Gulshan area". Falls back to a neutral label until located.
  String get area => areaLabel.isNotEmpty ? areaLabel : 'your area'.tr;

  // ── My leaderboard rank (GET /api/v1/blood/donors/leaderboard) ──────
  /// My 1-based position on the leaderboard; 0 means unranked/not a donor yet.
  int rank = 0;
  int totalRanked = 0;
  bool loadingRank = false;

  /// True once we know where the user stands (ranked or confirmed unranked).
  bool get hasRank => rank > 0;

  Future<void> fetchMyRank() async {
    loadingRank = true;
    update();
    try {
      final list = await _repo.fetchLeaderboard();
      list.sort((a, b) => b.totalDonations.compareTo(a.totalDonations));
      totalRanked = list.length;
      final myId = _currentUserId();
      final idx = (myId == null || myId.isEmpty)
          ? -1
          : list.indexWhere((d) => d.userId == myId);
      rank = idx >= 0 ? idx + 1 : 0;
    } catch (_) {
      // Leave rank untouched; the card falls back to a neutral label.
    } finally {
      loadingRank = false;
      update();
    }
  }

  /// True when the logged-in user owns this request — you can't respond to
  /// (donate for) your own request, so the Respond button is hidden for it.
  bool isMyRequest(BloodRequestEntry r) {
    final me = _currentUserId();
    return me != null && me.isNotEmpty && r.requesterId == me;
  }

  /// True when this donor card is the logged-in user — you can't call
  /// yourself, so the "Call donor" button is hidden for your own profile.
  bool isMyDonor(DonorEntry d) {
    final me = _currentUserId();
    return me != null && me.isNotEmpty && d.userId == me;
  }

  /// The logged-in user's id, read from stored auth info.
  String? _currentUserId() {
    final raw = StorageService.read(StorageConstants.userInfo);
    if (raw is String && raw.trim().isNotEmpty) {
      try {
        final map = jsonDecode(raw);
        if (map is Map) return map['id']?.toString();
      } catch (_) {}
    }
    return null;
  }

  // Whether the donor is currently available to donate (front-page switch),
  // seeded from /donors/me. `isDonor` is false until the user registers.
  bool isAvailable = true;
  bool isDonor = false;
  // The logged-in user's own donor profile (drives _compatibleGroups below) —
  // null until fetchMyDonorStatus() resolves, or forever if not a donor.
  DonorEntry? myDonor;

  Future<void> toggleAvailable(bool value) async {
    
    final prev = isAvailable;
    isAvailable = value; // optimistic


   
    update();

    try {
      final res = await Get.find<BloodRepository>().updateAvailability(value);
      
      if (res.success) {
        SnackHelper.success(res.message.isEmpty
            ? (value
                ? 'You are now available to donate'
                : 'You are now marked unavailable')
            : res.message);
      } else {
        isAvailable = prev; // revert
        SnackHelper.error(res.message);
      }
    } catch (e) {
      isAvailable = prev; // revert
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      update();
    }
  }

  // "Show compatible groups only" toggle on the Requests view.
  bool compatibleOnly = true;
  void toggleCompatible(bool value) {
    compatibleOnly = value;
    update();
  }

  /// Standard donor→recipient donation compatibility (ABO/Rh), e.g. an O-
  /// donor can give to anyone, while an AB+ donor can only give to AB+.
  /// Keyed by the DONOR's own blood group.
  static const Map<String, Set<String>> _donationCompatibility = {
    'O-': {'O-', 'O+', 'A-', 'A+', 'B-', 'B+', 'AB-', 'AB+'},
    'O+': {'O+', 'A+', 'B+', 'AB+'},
    'A-': {'A-', 'A+', 'AB-', 'AB+'},
    'A+': {'A+', 'AB+'},
    'B-': {'B-', 'B+', 'AB-', 'AB+'},
    'B+': {'B+', 'AB+'},
    'AB-': {'AB-', 'AB+'},
    'AB+': {'AB+'},
  };

  /// Request blood groups the logged-in donor can actually fulfill, based on
  /// their own registered blood group — empty (matches nothing) until that's
  /// known, rather than falling back to some other donor's compatibility set.
  Set<String> get _compatibleGroups =>
      _donationCompatibility[myDonor?.bloodGroup] ?? const {};

  List<BloodRequest> get visibleRequests => compatibleOnly
      ? requests.where((r) => _compatibleGroups.contains(r.group)).toList()
      : requests;

  final List<BloodRequest> requests = const [
    BloodRequest(
      units: 2,
      group: 'O+',
      severity: BloodSeverity.critical,
      hospital: 'Square Hospital',
      area: 'West Panthapath',
      distance: '1.2',
      timeAgo: '8 min ago',
      responded: 3,
      contact: 'Karim Sheikh · 01711-***123',
      note: 'Road accident, ICU. Need within 2 hours.',
    ),
    BloodRequest(
      units: 1,
      group: 'B+',
      severity: BloodSeverity.urgent,
      hospital: 'Dhaka Medical College',
      area: 'Bakshibazar',
      distance: '3.4',
      timeAgo: '22 min ago',
      responded: 5,
      contact: 'Rahim Uddin · 01712-***456',
      note: 'Surgery scheduled tomorrow morning.',
    ),
    BloodRequest(
      units: 3,
      group: 'A+',
      severity: BloodSeverity.routine,
      hospital: 'Labaid Specialized',
      area: 'Dhanmondi',
      distance: '5.1',
      timeAgo: '1 hr ago',
      responded: 8,
      contact: 'Nasrin Akter · 01713-***789',
      note: 'Thalassemia patient, regular transfusion.',
    ),
  ];

  /// The request the donor tapped to view in detail.
  BloodRequest? selectedRequest;
  void selectRequest(BloodRequest request) {
    selectedRequest = request;
    update();
  }

  // ── Connected donors (re-contact anytime) ───────────────────────────
  final List<ConnectedDonor> connectedDonors = const [
    ConnectedDonor(
      initials: 'TA',
      name: 'Tanvir Ahmed',
      group: 'O+',
      area: 'Gulshan · 0.8 km',
      phone: '01711-202345',
      lastDonation: 'Donated 12 May · Square Hospital',
    ),
    ConnectedDonor(
      initials: 'RU',
      name: 'Rahim Uddin',
      group: 'B+',
      area: 'Banani · 2.1 km',
      phone: '01712-556677',
      lastDonation: 'Donated 28 Apr · DMCH',
    ),
    ConnectedDonor(
      initials: 'NA',
      name: 'Nasrin Akter',
      group: 'A+',
      area: 'Dhanmondi · 4.6 km',
      phone: '01713-889900',
      lastDonation: 'Donated 3 Mar · Labaid',
    ),
  ];

  ConnectedDonor? selectedDonor;

  void openMyDonors() => Get.toNamed(Routes.BLOOD_MY_DONORS);

  void openDonorChat(ConnectedDonor donor) {
    selectedDonor = donor;
    chatTitle = donor.name;
    chatInitials = donor.initials;
    chatSubtitle = '${donor.group} · connected donor';
    chatPhone = donor.phone;
    update();
    Get.toNamed(Routes.BLOOD_DONOR_CHAT);
  }

  void callDonor(ConnectedDonor donor) {
    Get.snackbar(
      donor.name,
      'Calling ${donor.phone}…',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
    );
  }
}

class ConnectedDonor {
  const ConnectedDonor({
    required this.initials,
    required this.name,
    required this.group,
    required this.area,
    required this.phone,
    required this.lastDonation,
  });
  final String initials;
  final String name;
  final String group;
  final String area;
  final String phone;
  final String lastDonation;
}
