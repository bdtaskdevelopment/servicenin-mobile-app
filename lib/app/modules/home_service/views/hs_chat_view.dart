import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/service_response.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/hs_chat_controller.dart';

const _darkTeal = Color(0xFF0E7C6B);

class HsChatView extends StatefulWidget {
  const HsChatView({super.key});

  @override
  State<HsChatView> createState() => _HsChatViewState();
}

class _HsChatViewState extends State<HsChatView> {
  final HsChatController con = Get.find<HsChatController>();
  final ScrollController _scroll = ScrollController();
  bool _didInitialScroll = false;

  @override
  void initState() {
    super.initState();
    final id = Get.arguments is String ? Get.arguments as String : '';
    con.configure(id);
    con.startPolling();
  }

  @override
  void dispose() {
    con.stopPolling();
    _scroll.dispose();
    super.dispose();
  }

  void _maybeScrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      final pos = _scroll.position;
      if (!_didInitialScroll || pos.maxScrollExtent - pos.pixels < 220) {
        _scroll.jumpTo(pos.maxScrollExtent);
        _didInitialScroll = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F6),
      body: Column(
        children: [
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
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Service chat',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A))),
                        SizedBox(height: 1),
                        Text('Message your provider',
                            style: TextStyle(
                                fontSize: 12, color: Color(0xFF94A3B8))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GetBuilder<HsChatController>(
              builder: (c) {
                if (c.loading && c.messages.isEmpty) {
                  return const SnListSkeleton(showTrailing: false);
                }
                if (c.messages.isEmpty) {
                  return const Center(
                    child: Text('No messages yet — say hello 👋',
                        style: TextStyle(color: Color(0xFF94A3B8))),
                  );
                }
                _maybeScrollToEnd();
                return ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  itemCount: c.messages.length,
                  itemBuilder: (_, i) {
                    final m = c.messages[i];
                    return _Bubble(msg: m, mine: c.isMine(m));
                  },
                );
              },
            ),
          ),
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
                        constraints: const BoxConstraints(minHeight: 48),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(24)),
                        alignment: Alignment.centerLeft,
                        child: TextField(
                          controller: con.input,
                          minLines: 1,
                          maxLines: 4,
                          onSubmitted: (_) => con.send(),
                          textInputAction: TextInputAction.send,
                          decoration: const InputDecoration(
                            hintText: 'Type a message…',
                            hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                            border: InputBorder.none,
                            isCollapsed: true,
                          ),
                          style: const TextStyle(
                              fontSize: 14.5, color: Color(0xFF0F172A)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GetBuilder<HsChatController>(
                      builder: (c) => InkWell(
                        onTap: c.sending ? null : con.send,
                        customBorder: const CircleBorder(),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                              color: c.sending
                                  ? _darkTeal.withValues(alpha: 0.5)
                                  : _darkTeal,
                              shape: BoxShape.circle),
                          child: c.sending
                              ? const Padding(
                                  padding: EdgeInsets.all(14),
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.send_rounded,
                                  color: Colors.white, size: 20),
                        ),
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
  const _Bubble({required this.msg, required this.mine});
  final ServiceChatMessage msg;
  final bool mine;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment:
            mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: Get.width * 0.74),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: mine ? _darkTeal : AppColors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(mine ? 16 : 4),
                bottomRight: Radius.circular(mine ? 4 : 16),
              ),
            ),
            child: Text(msg.message,
                style: TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    color: mine ? Colors.white : const Color(0xFF1E293B))),
          ),
          const SizedBox(height: 4),
          Text(msg.timeLabel,
              style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }
}
