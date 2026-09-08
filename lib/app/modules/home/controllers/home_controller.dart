import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/helpers/snack_helper.dart';
import '../../../core/services/notification_router.dart';
import '../../../core/utils/service_nav.dart';
import '../../../data/models/response/home_response.dart';
import '../../../data/models/response/service_response.dart';
import '../../../data/repositories/home.repo.dart';
import '../../../data/repositories/service.repo.dart';

class HomeController extends GetxController {
  HomeRepository get _repo => Get.find<HomeRepository>();
  ServiceRepository get _serviceRepo => Get.find<ServiceRepository>();

  /// Banner tap: navigate to an in-app module (route), open an external URL,
  /// or launch the dialer — based on the banner's `action`.
  Future<void> openBanner(HomeBanner b) async {
    switch (b.action) {
      case 'url':
        await _launch(b.url);
        break;
      case 'call':
        if (b.phone.trim().isNotEmpty) await _launch('tel:${b.phone.trim()}');
        break;
      case 'module':
      default:
        // route like "/healthcare" → reuse the central module router.
        final key = b.route.replaceAll('/', '').trim();
        if (key.isNotEmpty) ServiceNav.openByKey(key);
    }
  }

  Future<void> _launch(String raw) async {
    final url = raw.trim();
    if (url.isEmpty) return;
    try {
      final ok = await launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication);
      if (!ok) SnackHelper.error('খুলতে সমস্যা হয়েছে');
    } catch (_) {
      SnackHelper.error('খুলতে সমস্যা হয়েছে');
    }
  }

  // ── Banner carousel ─────────────────────────────────────────────────
  List<HomeBanner> banners = [];
  bool loadingBanners = false;
  int promoIndex = 0;
  final PageController bannerController =
      PageController(viewportFraction: 0.92);
  Timer? _autoScroll;

  void setPromo(int i) {
    promoIndex = i;
    update();
  }

  // ── Popular / recent service shortcuts ──────────────────────────────
  List<HomeService> popular = [];
  bool loadingPopular = false;
  List<HomeService> recent = [];
  bool loadingRecent = false;

  /// Services not surfaced in the app yet — kept out of the Popular / Recent
  /// shortcuts (matched on HomeService.type / key).
  static const _hiddenServices = {'jobs', 'matchmaking'};
  List<HomeService> _visible(List<HomeService> list) => list
      .where((s) =>
          !_hiddenServices.contains(s.type.toLowerCase()) &&
          !_hiddenServices.contains(s.key.toLowerCase()))
      .toList();

  // ── Top home-service shortcuts (AC / Refrigerator / Plumbing) ────────
  // Pulled from the same categories the Home Service module lists — these
  // three get first-row visibility on the Home tab for more exposure. Shows
  // whichever of the three currently exist; never blocks or crashes if the
  // admin renames or removes one.
  List<ServiceCategory> topServiceCategories = [];
  bool loadingTopServiceCategories = false;

  Future<void> fetchTopServiceCategories() async {
    loadingTopServiceCategories = true;
    update();
    try {
      final all = await _serviceRepo.fetchCategories();
      topServiceCategories = _pickTopCategories(all);
    } catch (_) {
      topServiceCategories = [];
    } finally {
      loadingTopServiceCategories = false;
      update();
    }
  }

  static List<ServiceCategory> _pickTopCategories(List<ServiceCategory> all) {
    ServiceCategory? find(bool Function(String nameLower) matches) {
      for (final c in all) {
        if (matches(c.name.toLowerCase())) return c;
      }
      return null;
    }

    final ac = find((n) => RegExp(r'\bac\b').hasMatch(n));
    final fridge =
        find((n) => n.contains('refrigerator') || n.contains('fridge'));
    final plumbing = find((n) => n.contains('plumb'));
    return [ac, fridge, plumbing].whereType<ServiceCategory>().toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchBanners();
    fetchPopular();
    fetchRecent();
    fetchTopServiceCategories();
  }

  @override
  void onReady() {
    super.onReady();
    // The authenticated landing is ready — deliver any deep-link that a
    // tapped push queued while the app was cold-starting (or before login).
    NotificationRouter.instance.flushPending();
  }

  Future<void> fetchBanners() async {
    loadingBanners = true;
    update();
    try {
      banners = await _repo.fetchBanners();
      _startAutoScroll();
    } catch (_) {
    } finally {
      loadingBanners = false;
      update();
    }
  }

  Future<void> fetchPopular() async {
    loadingPopular = true;
    update();
    try {
      popular = _visible(await _repo.fetchPopular(limit: 6));
    } catch (_) {
    } finally {
      loadingPopular = false;
      update();
    }
  }

  Future<void> fetchRecent() async {
    loadingRecent = true;
    update();
    try {
      recent = _visible(await _repo.fetchRecent(limit: 6));
    } catch (_) {
    } finally {
      loadingRecent = false;
      update();
    }
  }

  Future<void> refreshAll() async {
    await fetchBanners();
    await fetchPopular();
    await fetchRecent();
  }

  void _startAutoScroll() {
    _autoScroll?.cancel();
    if (banners.length < 2) return;
    _autoScroll = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!bannerController.hasClients || banners.isEmpty) return;
      final next = (promoIndex + 1) % banners.length;
      bannerController.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void onClose() {
    _autoScroll?.cancel();
    bannerController.dispose();
    super.onClose();
  }
}
