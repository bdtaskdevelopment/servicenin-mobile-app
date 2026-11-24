import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/helpers/snack_helper.dart';
import '../../../core/mixins/live_refresh_mixin.dart';
import '../../../data/models/response/funeral_response.dart';
import '../../../data/models/sn_place.dart';
import '../../../data/repositories/funeral.repo.dart';
import '../../../routes/app_pages.dart';
import '../views/funeral_address_search_view.dart';

class FuneralController extends GetxController with LiveRefreshMixin {
  FuneralRepository get _repo => Get.find<FuneralRepository>();

  // ── Live refresh (LiveRefreshMixin) — list refresher ────────────────
  @override
  Set<String> get liveRefreshTypes => {'funeral_request'};
  @override
  String get liveRefreshId => '';
  @override
  Future<void> onLiveRefresh() => fetchMyRequests();

  // ── Services (admin-managed) ──────────────────────────────────────
  List<FuneralService> services = [];
  bool loadingServices = false;
  String selectedServiceId = '';

  // ── My requests ─────────────────────────────────────────────────────
  List<FuneralRequest> myRequests = [];
  bool loadingRequests = false;

  // ── Support center (GET /api/v1/funeral/hotlines) ───────────────────
  List<FuneralHotline> hotlines = [];
  bool loadingHotlines = false;

  // ── Request form ────────────────────────────────────────────────────
  final TextEditingController name = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController relationship = TextEditingController();
  final TextEditingController notes = TextEditingController();
  bool submitting = false;
  FuneralRequest? lastRequest;

  // Same convention as AccountController.genders (edit profile screen) —
  // raw English labels shown as-is (translated via `.tr` in the UI), only
  // lower-cased when sent to the API.
  final List<String> genders = const ['Male', 'Female', 'Other'];
  String gender = 'Male';
  void setGender(String g) {
    gender = g;
    update();
  }

  void selectService(String id) {
    selectedServiceId = id;
    update();
  }

  void selectServiceAndRequest(String id) {
    selectedServiceId = id;
    update();
    Get.toNamed(Routes.FUNERAL_REQUEST);
  }

  @override
  void onInit() {
    super.onInit();
    fetchServices();
    fetchHotlines();
    startLiveRefresh();
  }

  Future<void> fetchServices() async {
    loadingServices = true;
    update();
    try {
      services = await _repo.fetchServices();
      if (selectedServiceId.isEmpty && services.isNotEmpty) {
        selectedServiceId = services.first.id;
      }
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingServices = false;
      update();
    }
  }

  Future<void> fetchHotlines() async {
    loadingHotlines = true;
    update();
    try {
      hotlines = await _repo.fetchHotlines();
    } catch (_) {
      // Silent — the support strip simply doesn't render if this fails.
      // Nothing about requesting a service depends on it.
    } finally {
      loadingHotlines = false;
      update();
    }
  }

  /// Open the dialer — used by both the support center numbers and the
  /// assigned staff member's contact button.
  Future<void> call(String number) async {
    final digits = number.trim();
    if (digits.isEmpty) return;
    try {
      await launchUrl(Uri.parse('tel:$digits'),
          mode: LaunchMode.externalApplication);
    } catch (_) {
      SnackHelper.error('ডায়াল করা যায়নি');
    }
  }

  /// Opens the pre-built `https://wa.me/...` link for a hotline's WhatsApp
  /// number (see FuneralHotline.whatsappUrl).
  Future<void> openWhatsApp(String url) async {
    if (url.trim().isEmpty) return;
    try {
      await launchUrl(Uri.parse(url.trim()), mode: LaunchMode.externalApplication);
    } catch (_) {
      SnackHelper.error('হোয়াটসঅ্যাপ খোলা যায়নি');
    }
  }

  /// Opens the address search page and, if the user picks a result, fills
  /// the address field — same shape as the other modules' pickAddress, just
  /// without lat/lng capture since the backend only stores a free-text
  /// address for a funeral request.
  Future<void> pickAddress() async {
    final place = await Get.to<SnPlace>(
        () => const FuneralAddressSearchView(title: 'Search address'));
    if (place == null) return;
    address.text = place.address.isNotEmpty ? place.address : place.label;
    update();
  }

  // ── Submit request ──────────────────────────────────────────────────
  void requestService() => Get.toNamed(Routes.FUNERAL_REQUEST);

  Future<void> submitRequest() async {
    if (submitting) return;
    if (selectedServiceId.isEmpty) {
      SnackHelper.error('সেবা নির্বাচন করুন');
      return;
    }
    if (name.text.trim().isEmpty) {
      SnackHelper.error('নাম দিন');
      return;
    }
    if (relationship.text.trim().isEmpty) {
      SnackHelper.error('Please tell us your relationship to the deceased'.tr);
      return;
    }
    if (address.text.trim().isEmpty) {
      SnackHelper.error('ঠিকানা দিন');
      return;
    }
    if (phone.text.trim().isEmpty) {
      SnackHelper.error('ফোন নম্বর দিন');
      return;
    }
    submitting = true;
    update();
    try {
      final payload = <String, dynamic>{
        'service_id': selectedServiceId,
        'name': name.text.trim(),
        'address': address.text.trim(),
        'phone': phone.text.trim(),
        'gender': gender.toLowerCase(),
        'relationship': relationship.text.trim(),
        if (notes.text.trim().isNotEmpty) 'notes': notes.text.trim(),
      };
      lastRequest = await _repo.createRequest(payload);
      Get.toNamed(Routes.FUNERAL_DONE);
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      submitting = false;
      update();
    }
  }

  // ── My requests ─────────────────────────────────────────────────────
  void openMyRequests() {
    fetchMyRequests();
    Get.toNamed(Routes.FUNERAL_REQUESTS);
  }

  /// Direct single-tap open of Funeral's own support screen from the
  /// header's headset icon — a dedicated screen (not the generic
  /// cross-module `SupportView`) since this module's mockup has its own
  /// banner + per-hotline card layout.
  void openSupport() => Get.toNamed(Routes.FUNERAL_SUPPORT);

  Future<void> fetchMyRequests() async {
    loadingRequests = true;
    update();
    try {
      myRequests = await _repo.fetchMyRequests();
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingRequests = false;
      update();
    }
  }

  // ── Single booking detail (mockup "আমার বুকিং") ─────────────────────
  FuneralRequest? viewingRequest;
  bool loadingRequestDetail = false;

  Future<void> openRequestDetail(String id) async {
    if (lastRequest != null && lastRequest!.id == id) {
      viewingRequest = lastRequest;
      update();
      Get.toNamed(Routes.FUNERAL_REQUEST_DETAIL);
      return;
    }
    loadingRequestDetail = true;
    viewingRequest = null;
    update();
    try {
      viewingRequest = await _repo.fetchRequestById(id);
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingRequestDetail = false;
      update();
    }
    if (viewingRequest != null) Get.toNamed(Routes.FUNERAL_REQUEST_DETAIL);
  }

  /// "View my booking" on the confirmation screen — opens the detail
  /// screen for the request that was just submitted.
  void viewLastBooking() {
    final r = lastRequest;
    if (r == null) return;
    openRequestDetail(r.id);
  }

  void done() => Get.until((r) => r.settings.name == Routes.FUNERAL);

  @override
  void onClose() {
    name.dispose();
    address.dispose();
    phone.dispose();
    relationship.dispose();
    notes.dispose();
    super.onClose();
  }
}
