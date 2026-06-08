import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/chat_message_response.dart';
import '../controllers/blood_chat_controller.dart';

const _red = Color(0xFFE11D48);

class BloodChatView extends StatefulWidget {
  const BloodChatView({super.key});

  @override
  State<BloodChatView> createState() => _BloodChatViewState();
}

class _BloodChatViewState extends State<BloodChatView> {
  final BloodChatController con = Get.find<BloodChatController>();
  final ScrollController _scroll = ScrollController();
  bool _didInitialScroll = false;

  @override
  void initState() {
    super.initState();
    con.startPolling();
  }

  @override
  void dispose() {
    con.stopPolling();
    _scroll.dispose();
    super.dispose();
  }

  /// Pin to the newest message on first paint and whenever the reader is
  /// already near the bottom — but leave them be if they've scrolled up.
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
          // Header
          Container(
            color: AppColors.white,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
                child: GetBuilder<BloodChatController>(
                  builder: (c) => Row(
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
                        child: Text(c.partnerInitials,
                            style: const TextStyle(
                                color: _red, fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.partnerName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A))),
                            const Text('blood request chat',
                                style: TextStyle(
                                    fontSize: 12, color: Color(0xFF94A3B8))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Messages
          Expanded(
            child: GetBuilder<BloodChatController>(
              builder: (c) {
                if (c.loading && c.messages.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                        strokeWidth: 2.6, color: _red),
                  );
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
                    GetBuilder<BloodChatController>(
                      builder: (c) => InkWell(
                        onTap: c.sending ? null : con.send,
                        customBorder: const CircleBorder(),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                              color: c.sending
                                  ? _red.withValues(alpha: 0.5)
                                  : _red,
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
  final ChatMessage msg;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment:
            mine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!mine) ...[
            _Avatar(name: msg.senderName, photo: msg.senderPhoto),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: Get.width * 0.72),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(
                    color: mine ? _red : AppColors.white,
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
                          color:
                              mine ? Colors.white : const Color(0xFF1E293B))),
                ),
                const SizedBox(height: 4),
                Text(msg.timeLabel,
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, this.photo});
  final String name;
  final String? photo;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'U';
    final hasPhoto = photo != null && photo!.trim().isNotEmpty;
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
          color: _red.withValues(alpha: 0.12), shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: hasPhoto
          ? CachedNetworkImage(
              imageUrl: photo!,
              width: 30,
              height: 30,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => _letter(initial),
            )
          : _letter(initial),
    );
  }

  Widget _letter(String initial) => Text(initial,
      style: const TextStyle(
          color: _red, fontSize: 12, fontWeight: FontWeight.w800));
}
