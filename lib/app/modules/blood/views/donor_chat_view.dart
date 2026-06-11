import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/blood_controller.dart';

const _red = Color(0xFFE11D48);

class _Msg {
  const _Msg(this.text, this.me, this.time);
  final String text;
  final bool me;
  final String time;
}

class DonorChatView extends StatefulWidget {
  const DonorChatView({super.key});

  @override
  State<DonorChatView> createState() => _DonorChatViewState();
}

class _DonorChatViewState extends State<DonorChatView> {
  final TextEditingController _input = TextEditingController();
  final List<_Msg> _messages = [
    _Msg('Assalamu alaikum, thank you for donating last time!'.tr, true,
        '10:02'),
    _Msg('Walaikum salam. Happy to help anytime.'.tr, false, '10:05'),
    _Msg('We may need O+ again next month for my father.'.tr, true, '10:06'),
    _Msg('Sure, just message me a few days before. I\'m usually free on weekends.'.tr,
        false, '10:08'),
  ];

  void _send() {
    final t = _input.text.trim();
    if (t.isEmpty) return;
    setState(() {
      _messages.add(_Msg(t, true, 'now'));
      _input.clear();
    });
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final con = Get.find<BloodController>();
    final name = con.chatTitle;
    final initials = con.chatInitials;
    final subtitle = con.chatSubtitle;
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
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: _red.withValues(alpha: 0.12),
                          shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Text(initials,
                          style: const TextStyle(
                              color: _red, fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A))),
                          Text(subtitle,
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF94A3B8))),
                        ],
                      ),
                    ),
                    IconButton(
                      splashRadius: 22,
                      onPressed: () => con.callPhone(con.chatPhone),
                      icon: const Icon(Icons.call_rounded,
                          color: _red, size: 22),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              children: _messages.map((m) => _Bubble(msg: m)).toList(),
            ),
          ),
          // Input
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
                            borderRadius: BorderRadius.circular(24)),
                        alignment: Alignment.centerLeft,
                        child: TextField(
                          controller: _input,
                          onSubmitted: (_) => _send(),
                          decoration: InputDecoration(
                            hintText: 'Message donor…'.tr,
                            hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                            border: InputBorder.none,
                            isCollapsed: true,
                          ),
                          style: const TextStyle(
                              fontSize: 14.5, color: Color(0xFF0F172A)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: _send,
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                            color: _red, shape: BoxShape.circle),
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

class _Bubble extends StatelessWidget {
  const _Bubble({required this.msg});
  final _Msg msg;
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
            constraints: BoxConstraints(maxWidth: Get.width * 0.76),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: me ? _red : AppColors.white,
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
