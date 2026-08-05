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

  /// Services not surfaced in the app yet — kept out of the search catalog,
  /// trending and results (matched on HomeService.type / key).
  static const _hiddenServices = {'jobs', 'matchmaking'};
  List<HomeService> _visible(List<HomeService> list) => list
      .where((s) =>
          !_hiddenServices.contains(s.type.toLowerCase()) &&
          !_hiddenServices.contains(s.key.toLowerCase()))
      .toList();

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
      allServices = _visible(await _repo.fetchServices());
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
      trending = _visible(await _repo.fetchTrending(limit: 6));
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
      searchResults = _visible(await _repo.search(q.trim()));
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
