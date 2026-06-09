import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/matchmaking_response.dart';
import '../controllers/mm_chat_controller.dart';

const _maroon = Color(0xFFB11D5C);

class MmChatView extends StatefulWidget {
  const MmChatView({super.key});

  @override
  State<MmChatView> createState() => _MmChatViewState();
}

class _MmChatViewState extends State<MmChatView> {
  final MmChatController con = Get.find<MmChatController>();
  final ScrollController _scroll = ScrollController();
  bool _didInitialScroll = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    final id = (args is Map ? args['id'] : '')?.toString() ?? '';
    final title = (args is Map ? args['title'] : 'Chat')?.toString() ?? 'Chat';
    con.configure(id, title);
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(con.title,
                            style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A))),
                        const SizedBox(height: 1),
                        const Text('Matched · be respectful',
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
            child: GetBuilder<MmChatController>(
              builder: (c) {
                if (c.loading && c.messages.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                        strokeWidth: 2.6, color: _maroon),
                  );
                }
                if (c.messages.isEmpty) {
                  return const Center(
                    child: Text('No messages yet — say salam 👋',
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
                    GetBuilder<MmChatController>(
                      builder: (c) => InkWell(
                        onTap: c.sending ? null : con.send,
                        customBorder: const CircleBorder(),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                              color: c.sending
                                  ? _maroon.withValues(alpha: 0.5)
                                  : _maroon,
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
  final MmChatMessage msg;
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
              color: mine ? _maroon : AppColors.white,
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
