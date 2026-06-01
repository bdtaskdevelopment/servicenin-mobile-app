import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/sn_catalog.dart';
import '../../../data/models/sn_service.dart';

class SnSearchController extends GetxController {
  final TextEditingController textController = TextEditingController();
  String query = '';

  static const List<String> trending = [
    'Ambulance',
    'Blood O+',
    'AC service',
    'Doctor',
    'Holding tax',
    'Physio',
  ];

  List<SnService> get results {
    if (query.trim().isEmpty) return SnCatalog.services;
    final q = query.toLowerCase();
    return SnCatalog.services
        .where((s) => s.name.toLowerCase().contains(q))
        .toList();
  }

  void onQueryChanged(String value) {
    query = value;
    update();
  }

  void applyChip(String value) {
    textController.text = value;
    query = value;
    update();
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}
