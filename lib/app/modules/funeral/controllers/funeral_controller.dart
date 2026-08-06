import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/helpers/snack_helper.dart';
import '../../../core/mixins/live_refresh_mixin.dart';
import '../../../data/models/response/funeral_response.dart';
import '../../../data/repositories/funeral.repo.dart';
import '../../../routes/app_pages.dart';

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
  final TextEditingController notes = TextEditingController();
  bool submitting = false;
  FuneralRequest? lastRequest;

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

  void done() => Get.until((r) => r.settings.name == Routes.FUNERAL);

  @override
  void onClose() {
    name.dispose();
    address.dispose();
    phone.dispose();
    notes.dispose();
    super.onClose();
  }
}
