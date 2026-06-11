import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/chat_controller.dart';

const _green = Color(0xFF0F7A52);

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F6),
      body: Column(
        children: [
          // Header
          Container(
            color: AppColors.white,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 16, 10),
                child: Row(
                  children: [
                    IconButton(
                      splashRadius: 22,
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 20, color: Color(0xFF1A1A1A)),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(controller.doctorName,
                            style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A))),
                        const SizedBox(height: 1),
                        Text(controller.subtitle,
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF94A3B8))),
                      ],
                    ),
                    const Spacer(),
                    const Icon(Icons.call_rounded,
                        color: Color(0xFF1A1A1A), size: 22),
                  ],
                ),
              ),
            ),
          ),
          // v2 banner
          Container(
            width: double.infinity,
            color: const Color(0xFFFFF7E6),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('● v2',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFB45309))),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'In-app doctor chat is planned for v2 — not in the current API.'.tr,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFFB45309), height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          // Messages
          Expanded(
            child: GetBuilder<ChatController>(
              builder: (con) {
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  children: [
                    Center(child: _DayChip('Today'.tr)),
                    const SizedBox(height: 12),
                    ...con.messages.map((m) => _Bubble(msg: m)),
                  ],
                );
              },
            ),
          ),
          // Input bar
          Container(
            color: AppColors.white,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        alignment: Alignment.centerLeft,
                        child: TextField(
                          controller: controller.input,
                          decoration: InputDecoration(
                            hintText: 'Type a message…'.tr,
                            hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                            border: InputBorder.none,
                            isCollapsed: true,
                          ),
                          style: const TextStyle(
                              fontSize: 14.5, color: Color(0xFF0F172A)),
                          onSubmitted: (_) => controller.send(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: controller.send,
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                            color: _green, shape: BoxShape.circle),
                        child: const Icon(Icons.send_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(20)),
      child: Text(text,
          style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B))),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.msg});
  final ChatMessage msg;

  @override
  Widget build(BuildContext context) {
    final me = msg.me;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment:
            me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: Get.width * 0.74),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: me ? _green : AppColors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(me ? 16 : 4),
                bottomRight: Radius.circular(me ? 4 : 16),
              ),
            ),
            child: Text(msg.text,
                style: TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    color: me ? Colors.white : const Color(0xFF1E293B))),
          ),
          const SizedBox(height: 4),
          Text(msg.time,
              style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }
}
