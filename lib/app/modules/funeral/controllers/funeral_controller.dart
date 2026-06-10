import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/helpers/snack_helper.dart';
import '../../../data/models/response/funeral_response.dart';
import '../../../data/repositories/funeral.repo.dart';
import '../../../routes/app_pages.dart';

IconData funeralServiceIcon(String icon) {
  switch (icon.toLowerCase()) {
    case 'package':
      return Icons.inventory_2_outlined;
    case 'water':
    case 'ghusl':
    case 'bath':
      return Icons.waves_rounded;
    case 'truck':
    case 'van':
    case 'ambulance':
      return Icons.local_shipping_outlined;
    case 'mosque':
    case 'janaza':
    case 'prayer':
      return Icons.account_balance_outlined;
    case 'grave':
    case 'burial':
    case 'location':
      return Icons.location_on_outlined;
    case 'shroud':
    case 'kafan':
      return Icons.layers_outlined;
    default:
      return Icons.volunteer_activism_outlined;
  }
}

class FuneralController extends GetxController {
  FuneralRepository get _repo => Get.find<FuneralRepository>();

  // ── Coordinator ─────────────────────────────────────────────────────
  FuneralCoordinator? coordinator;
  bool loadingCoordinator = false;

  // ── Services ────────────────────────────────────────────────────────
  List<FuneralServiceOption> services = [];
  bool loadingServices = false;

  // ── Units ───────────────────────────────────────────────────────────
  List<FuneralUnitModel> units = [];
  bool loadingUnits = false;

  // ── My requests ─────────────────────────────────────────────────────
  List<FuneralRequest> myRequests = [];
  bool loadingRequests = false;

  // ── Request form ────────────────────────────────────────────────────
  String selectedServiceKey = '';
  String gender = 'male';
  final TextEditingController deceasedName = TextEditingController();
  final TextEditingController deceasedAge = TextEditingController();
  final TextEditingController deathTime = TextEditingController();
  final TextEditingController placeOfDeath = TextEditingController();
  final TextEditingController causeOfDeath = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController wardNo = TextEditingController();
  final TextEditingController contactName = TextEditingController();
  final TextEditingController contactPhone = TextEditingController();
  final TextEditingController scheduledAt = TextEditingController();
  bool submitting = false;
  FuneralRequest? lastRequest;

  void selectService(String key) {
    selectedServiceKey = key;
    update();
  }

  void setGender(String g) {
    gender = g;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    fetchCoordinator();
    fetchServices();
    fetchUnits();
  }

  Future<void> fetchCoordinator() async {
    loadingCoordinator = true;
    update();
    try {
      coordinator = await _repo.fetchCoordinator();
    } catch (_) {
    } finally {
      loadingCoordinator = false;
      update();
    }
  }

  Future<void> fetchServices() async {
    loadingServices = true;
    update();
    try {
      services = await _repo.fetchServices();
      if (selectedServiceKey.isEmpty && services.isNotEmpty) {
        selectedServiceKey = services.first.key;
      }
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingServices = false;
      update();
    }
  }

  Future<void> fetchUnits() async {
    loadingUnits = true;
    update();
    try {
      units = await _repo.fetchAvailableUnits();
    } catch (_) {
    } finally {
      loadingUnits = false;
      update();
    }
  }

  // ── Call the coordinator ────────────────────────────────────────────
  Future<void> callCoordinator() async {
    final number = coordinator?.phone.isNotEmpty == true
        ? coordinator!.phone
        : (coordinator?.hotline ?? '');
    if (number.isEmpty) return;
    try {
      await launchUrl(Uri.parse('tel:$number'),
          mode: LaunchMode.externalApplication);
    } catch (_) {
      SnackHelper.error('ডায়াল করা যায়নি');
    }
  }

  // ── Submit request ──────────────────────────────────────────────────
  void requestService() => Get.toNamed(Routes.FUNERAL_REQUEST);

  Future<void> submitRequest() async {
    if (submitting) return;
    if (deceasedName.text.trim().isEmpty) {
      SnackHelper.error('মৃত ব্যক্তির নাম দিন');
      return;
    }
    if (selectedServiceKey.isEmpty) {
      SnackHelper.error('সেবা নির্বাচন করুন');
      return;
    }
    if (contactPhone.text.trim().isEmpty) {
      SnackHelper.error('যোগাযোগের ফোন নম্বর দিন');
      return;
    }
    submitting = true;
    update();
    try {
      final payload = <String, dynamic>{
        'deceased_name': deceasedName.text.trim(),
        if (deceasedAge.text.trim().isNotEmpty)
          'deceased_age': int.tryParse(deceasedAge.text.trim()) ?? 0,
        'gender': gender,
        if (deathTime.text.trim().isNotEmpty)
          'death_time': deathTime.text.trim(),
        if (placeOfDeath.text.trim().isNotEmpty)
          'place_of_death': placeOfDeath.text.trim(),
        if (causeOfDeath.text.trim().isNotEmpty)
          'cause_of_death': causeOfDeath.text.trim(),
        'address': address.text.trim(),
        if (wardNo.text.trim().isNotEmpty) 'ward_no': wardNo.text.trim(),
        'service_type': selectedServiceKey,
        'contact_name': contactName.text.trim(),
        'contact_phone': contactPhone.text.trim(),
        if (scheduledAt.text.trim().isNotEmpty)
          'scheduled_at': scheduledAt.text.trim(),
        'booking_type': 'direct',
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
    for (final c in [
      deceasedName, deceasedAge, deathTime, placeOfDeath, causeOfDeath,
      address, wardNo, contactName, contactPhone, scheduledAt,
    ]) {
      c.dispose();
    }
    super.onClose();
  }
}
