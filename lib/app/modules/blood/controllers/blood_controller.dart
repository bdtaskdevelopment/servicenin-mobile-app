import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/helpers/snack_helper.dart';
import '../../../core/values/storage.dart';
import '../../../data/models/response/blood_request_response.dart';
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
        BloodSeverity.critical => const Color(0xFFE11D48),
        BloodSeverity.urgent => const Color(0xFFB45309),
        BloodSeverity.routine => const Color(0xFF2563EB),
      };

  Color get bg => switch (this) {
        BloodSeverity.critical => const Color(0xFFFEE2E2),
        BloodSeverity.urgent => const Color(0xFFFEF3C7),
        BloodSeverity.routine => const Color(0xFFDBEAFE),
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

class BloodController extends GetxController {
  BloodRepository get _repo => Get.find<BloodRepository>();

  // ── Donors near you (GET /api/v1/blood/donors[/nearest]) ────────────
  List<DonorEntry> nearestDonors = [];
  List<DonorEntry> allDonors = [];
  bool loadingNearest = false;
  bool loadingAllDonors = false;

  @override
  void onInit() {
    super.onInit();
    fetchNearestDonors();
    fetchMyResponses();
    fetchMyRank();
    fetchMyDonorStatus();
    fetchMyRequests();
    fetchRequests();
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
    ]);
  }

  /// GET /api/v1/blood/donors/me — seed the availability toggle from the
  /// donor profile's `is_available`. Null means the user isn't a registered
  /// donor yet, so the toggle stays at its default until they register.
  Future<void> fetchMyDonorStatus() async {
    try {
      final me = await _repo.fetchMyDonor();
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

  /// Requests filtered by the "compatible groups only" toggle.
  List<BloodRequestEntry> get visibleRequestEntries => compatibleOnly
      ? requestList
          .where((r) => _compatibleGroups.contains(r.bloodGroup))
          .toList()
      : requestList;

  Future<void> fetchRequests() async {
    loadingRequests = true;
    update();
    try {
      requestList = await _repo.fetchRequests();
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

  /// The request tapped to view in detail.
  BloodRequestEntry? viewingRequest;
  void viewRequest(BloodRequestEntry request) {
    viewingRequest = request;
    update();
    Get.toNamed(Routes.BLOOD_REQUEST_DETAIL);
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

  /// True once blood has been confirmed received for the open request — used
  /// to disable the call / chat / complete actions.
  bool get requestCompleted => selectedMyRequest?.isFulfilled ?? false;

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
    );
    Get.toNamed(Routes.BLOOD_CHAT);
  }

  /// "Mark complete" → confirm, then POST /fulfillments/:id/received. On
  /// success the request is marked fulfilled so the actions are disabled.
  Future<void> confirmReceived(BloodResponder r) async {
    if (completing || requestCompleted) return;
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
        SnackHelper.success(res.message.isNotEmpty
            ? res.message
            : 'Blood received confirmed. Thank you!');
        // Mark the open request fulfilled so call/chat/complete disable.
        final cur = selectedMyRequest;
        if (cur != null) {
          selectedMyRequest = BloodRequestEntry(
            id: cur.id,
            requesterId: cur.requesterId,
            bloodGroup: cur.bloodGroup,
            unitsNeeded: cur.unitsNeeded,
            hospitalName: cur.hospitalName,
            hospitalAddress: cur.hospitalAddress,
            contactName: cur.contactName,
            contactPhone: cur.contactPhone,
            contactEmail: cur.contactEmail,
            urgency: cur.urgency,
            status: 'fulfilled',
            notes: cur.notes,
            requesterName: cur.requesterName,
            requesterPhone: cur.requesterPhone,
            responseCount: cur.responseCount,
            createdAt: cur.createdAt,
            expiresAt: cur.expiresAt,
          );
        }
        fetchMyRequests(); // refresh the my-requests list in the background
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
  final String donorGroup = 'B+';
  final int donations = 12;
  final int livesSaved = 36;
  final String area = 'Gulshan area';

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

  /// Groups this B+ donor is willing to match against (demo set).
  static const Set<String> _compatibleGroups = {'O+', 'B+', 'A+', 'AB+'};

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
