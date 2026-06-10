import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/response/home_response.dart';
import '../../../data/repositories/home.repo.dart';

class SnSearchController extends GetxController {
  HomeRepository get _repo => Get.find<HomeRepository>();

  final TextEditingController textController = TextEditingController();
  String query = '';
  Timer? _debounce;

  List<HomeService> allServices = [];
  bool loadingServices = false;

  List<HomeService> trending = [];
  bool loadingTrending = false;

  List<HomeService> searchResults = [];
  bool searching = false;

  /// What the list renders: full catalog when idle, search hits otherwise.
  List<HomeService> get results =>
      query.trim().isEmpty ? allServices : searchResults;

  @override
  void onInit() {
    super.onInit();
    fetchServices();
    fetchTrending();
  }

  Future<void> fetchServices() async {
    loadingServices = true;
    update();
    try {
      allServices = await _repo.fetchServices();
    } catch (_) {
    } finally {
      loadingServices = false;
      update();
    }
  }

  Future<void> fetchTrending() async {
    loadingTrending = true;
    update();
    try {
      trending = await _repo.fetchTrending(limit: 6);
    } catch (_) {
    } finally {
      loadingTrending = false;
      update();
    }
  }

  void onQueryChanged(String value) {
    query = value;
    update();
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      searchResults = [];
      update();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () => _search(value));
  }

  void applyChip(String value) {
    textController.text = value;
    query = value;
    update();
    _debounce?.cancel();
    _search(value);
  }

  Future<void> _search(String q) async {
    searching = true;
    update();
    try {
      searchResults = await _repo.search(q.trim());
    } catch (_) {
      searchResults = [];
    } finally {
      searching = false;
      update();
    }
  }

  @override
  void onClose() {
    _debounce?.cancel();
    textController.dispose();
    super.onClose();
  }
}
