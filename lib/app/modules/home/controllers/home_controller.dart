import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/response/home_response.dart';
import '../../../data/repositories/home.repo.dart';

class HomeController extends GetxController {
  HomeRepository get _repo => Get.find<HomeRepository>();

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
