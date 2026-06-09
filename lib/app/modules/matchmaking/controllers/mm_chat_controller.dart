import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/storage.dart';
import '../../../data/models/response/matchmaking_response.dart';
import '../../../data/repositories/matchmaking.repo.dart';
import '../../../data/services/storage.service.dart';

class MmChatController extends GetxController {
  MatchmakingRepository get _repo => Get.find<MatchmakingRepository>();

  final TextEditingController input = TextEditingController();

  String interestId = '';
  String title = 'Chat';
  List<MmChatMessage> messages = [];
  bool loading = false;
  bool sending = false;
  String? _myId;

  Timer? _poll;
  static const _pollEvery = Duration(seconds: 3);

  void configure(String id, String t) {
    interestId = id;
    title = t;
    messages = [];
    _myId = _currentUserId();
    update();
  }

  bool isMine(MmChatMessage m) =>
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
    if (interestId.isEmpty) return;
    if (initial) {
      loading = true;
      update();
    }
    try {
      final list = await _repo.fetchChat(interestId);
      list.sort((a, b) => (a.createdAt ?? DateTime(1970))
          .compareTo(b.createdAt ?? DateTime(1970)));
      if (!initial && _same(messages, list)) return;
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
    if (text.isEmpty || sending || interestId.isEmpty) return;
    sending = true;
    update();
    try {
      await _repo.sendChat(interestId, text);
      input.clear();
      await fetch();
    } catch (_) {
    } finally {
      sending = false;
      update();
    }
  }

  bool _same(List<MmChatMessage> a, List<MmChatMessage> b) {
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
