import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/storage.dart';
import '../../../data/models/response/service_response.dart';
import '../../../data/repositories/service.repo.dart';
import '../../../data/services/storage.service.dart';

/// Live chat for a service booking — loads the thread and polls for new
/// messages every few seconds.
class HsChatController extends GetxController {
  ServiceRepository get _repo => Get.find<ServiceRepository>();

  final TextEditingController input = TextEditingController();

  String bookingId = '';
  List<ServiceChatMessage> messages = [];
  bool loading = false;
  bool sending = false;
  String? _myId;

  Timer? _poll;
  static const _pollEvery = Duration(seconds: 3);

  void configure(String id) {
    bookingId = id;
    messages = [];
    _myId = _currentUserId();
    update();
  }

  bool isMine(ServiceChatMessage m) =>
      _myId != null && _myId!.isNotEmpty && m.senderId == _myId;

  void startPolling() {
    fetch(initial: true);
    _poll?.cancel();
    _poll = Timer.periodic(_pollEvery, (_) => fetch());
  }

  void stopPolling() {
    _poll?.cancel();
    _poll = null;
  }

  Future<void> fetch({bool initial = false}) async {
    if (bookingId.isEmpty) return;
    if (initial) {
      loading = true;
      update();
    }
    try {
      final list = await _repo.fetchChat(bookingId);
      list.sort((a, b) => (a.createdAt ?? DateTime(1970))
          .compareTo(b.createdAt ?? DateTime(1970)));
      if (!initial && _sameThread(messages, list)) return;
      messages = list;
      update();
    } catch (_) {
    } finally {
      if (initial) {
        loading = false;
        update();
      }
    }
  }

  Future<void> send() async {
    final text = input.text.trim();
    if (text.isEmpty || sending || bookingId.isEmpty) return;
    sending = true;
    update();
    try {
      await _repo.sendChat(bookingId, text);
      input.clear();
      await fetch();
    } catch (_) {
    } finally {
      sending = false;
      update();
    }
  }

  bool _sameThread(List<ServiceChatMessage> a, List<ServiceChatMessage> b) {
    if (a.length != b.length) return false;
    if (a.isEmpty) return true;
    return a.last.id == b.last.id;
  }

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

  @override
  void onClose() {
    stopPolling();
    input.dispose();
    super.onClose();
  }
}
