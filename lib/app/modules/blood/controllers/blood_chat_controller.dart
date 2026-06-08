import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/helpers/snack_helper.dart';
import '../../../core/values/storage.dart';
import '../../../data/models/response/chat_message_response.dart';
import '../../../data/repositories/blood.repo.dart';
import '../../../data/services/storage.service.dart';

/// Drives the live blood-fulfillment chat: loads the thread, polls for new
/// messages every few seconds, and sends new ones.
class BloodChatController extends GetxController {
  BloodRepository get _repo => Get.find<BloodRepository>();

  final TextEditingController input = TextEditingController();

  /// The id used in the chat endpoint (the request/fulfillment id).
  String chatId = '';
  String partnerName = 'Requester';
  String partnerInitials = 'R';
  String? partnerPhone;

  List<ChatMessage> messages = [];
  bool loading = false;
  bool sending = false;
  String? _myUserId;

  Timer? _poll;
  static const _pollEvery = Duration(seconds: 3);

  /// Set the chat context before navigating to the chat screen.
  void configure({
    required String chatId,
    required String partnerName,
    String? partnerPhone,
  }) {
    this.chatId = chatId;
    this.partnerName = partnerName.isNotEmpty ? partnerName : 'Requester';
    partnerInitials = _initialsOf(this.partnerName);
    this.partnerPhone = partnerPhone;
    messages = [];
    _myUserId = _currentUserId();
    update();
  }

  /// True when the message was sent by the logged-in user (align right).
  bool isMine(ChatMessage m) =>
      _myUserId != null && _myUserId!.isNotEmpty && m.senderId == _myUserId;

  void startPolling() {
    fetchMessages(initial: true);
    _poll?.cancel();
    _poll = Timer.periodic(_pollEvery, (_) => fetchMessages());
  }

  void stopPolling() {
    _poll?.cancel();
    _poll = null;
  }

  Future<void> fetchMessages({bool initial = false}) async {
    if (chatId.isEmpty) return;
    if (initial) {
      loading = true;
      update();
    }
    try {
      final list = await _repo.fetchChat(chatId);
      list.sort((a, b) => (a.createdAt ?? DateTime(1970))
          .compareTo(b.createdAt ?? DateTime(1970)));
      // Skip the rebuild on background polls when nothing changed, so the
      // chat doesn't flicker or yank the scroll while you read history.
      if (!initial && _sameThread(messages, list)) return;
      messages = list;
      update();
    } catch (_) {
      // Silent on background polls; surface only the first load failure.
      if (initial) SnackHelper.error('চ্যাট লোড করা যায়নি');
    } finally {
      if (initial) {
        loading = false;
        update();
      }
    }
  }

  Future<void> send() async {
    final text = input.text.trim();
    if (text.isEmpty || sending || chatId.isEmpty) return;
    sending = true;
    update();
    try {
      final msg = await _repo.sendChat(chatId, text);
      input.clear();
      messages.add(msg); // optimistic: show immediately
      update();
      fetchMessages(); // reconcile with the server
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      sending = false;
      update();
    }
  }

  /// Two snapshots are the "same" when they have the same number of messages
  /// and the same last message id — enough to tell a poll brought nothing new.
  bool _sameThread(List<ChatMessage> a, List<ChatMessage> b) {
    if (a.length != b.length) return false;
    if (a.isEmpty) return true;
    return a.last.id == b.last.id;
  }

  String _initialsOf(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return 'R';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
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
