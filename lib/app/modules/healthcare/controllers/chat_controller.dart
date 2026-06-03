import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatMessage {
  const ChatMessage(this.text, this.me, this.time);
  final String text;
  final bool me;
  final String time;
}

class ChatController extends GetxController {
  final String doctorName = 'Dr. Salma Akter';
  final String subtitle = 'Usually replies in ~10 min';

  final TextEditingController input = TextEditingController();

  final List<ChatMessage> messages = [
    const ChatMessage(
        'Hello Tanzil, I have reviewed your ECG. How are you feeling today?',
        false,
        '2:10 PM'),
    const ChatMessage(
        'Much better doctor. The chest tightness is mostly gone.',
        true,
        '2:12 PM'),
    const ChatMessage(
        'Good. Continue the Bisoprolol and reduce salt. See me at 3:40 today, serial 14.',
        false,
        '2:13 PM'),
    const ChatMessage('Thank you, I will be there.', true, '2:14 PM'),
  ];

  void send() {
    final text = input.text.trim();
    if (text.isEmpty) return;
    messages.add(ChatMessage(text, true, 'now'));
    input.clear();
    update();
  }

  @override
  void onClose() {
    input.dispose();
    super.onClose();
  }
}
