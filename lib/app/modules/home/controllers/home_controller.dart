import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/helpers/snack_helper.dart';
import '../../../core/utils/service_nav.dart';
import '../../../data/models/response/home_response.dart';
import '../../../data/repositories/home.repo.dart';

class HomeController extends GetxController {
  HomeRepository get _repo => Get.find<HomeRepository>();

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

  @override
  void onInit() {
    super.onInit();
    fetchBanners();
    fetchPopular();
    fetchRecent();
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
      popular = await _repo.fetchPopular(limit: 6);
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
      recent = await _repo.fetchRecent(limit: 6);
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
