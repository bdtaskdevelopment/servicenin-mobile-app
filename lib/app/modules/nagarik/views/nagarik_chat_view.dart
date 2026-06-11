import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/nagarik_response.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/nagarik_controller.dart';

const _orange = Color(0xFFF15A24);

class NagarikChatView extends StatefulWidget {
  const NagarikChatView({super.key});

  @override
  State<NagarikChatView> createState() => _NagarikChatViewState();
}

class _NagarikChatViewState extends State<NagarikChatView> {
  final con = Get.find<NagarikController>();

  @override
  void dispose() {
    con.stopChat();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F6),
      body: GetBuilder<NagarikController>(
        builder: (con) {
          final t = con.selectedTicket;
          final code = t == null
              ? 'Ticket'.tr
              : (t.categoryLabel.isNotEmpty ? t.categoryLabel : 'Ticket'.tr);
          final subject = t?.subject ?? '';
          final visible = con.messages
              .where((m) => m.message.trim().isNotEmpty)
              .toList();
          return Column(
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(code,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A))),
                              Text('DNCC support'.tr,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF94A3B8))),
                            ],
                          ),
                        ),
                        if (t != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                                color: t.isResolved
                                    ? const Color(0xFFDCFCE7)
                                    : const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(20)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.circle,
                                    size: 7,
                                    color: t.isResolved
                                        ? const Color(0xFF16A34A)
                                        : const Color(0xFFD97706)),
                                const SizedBox(width: 5),
                                Text(t.statusLabel,
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: t.isResolved
                                            ? const Color(0xFF15803D)
                                            : const Color(0xFFB45309))),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: con.loadingMessages && visible.isEmpty
                    ? const SnListSkeleton(showTrailing: false)
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                        children: [
                          if (subject.isNotEmpty)
                            Center(child: _SubjectChip(subject)),
                          const SizedBox(height: 14),
                          if (visible.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: Center(
                                child: Text(
                                    'No messages yet. Start the conversation.'
                                        .tr,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF94A3B8))),
                              ),
                            )
                          else
                            ...visible.map((m) =>
                                _Bubble(msg: m, mine: con.isMine(m))),
                        ],
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
                            constraints:
                                const BoxConstraints(minHeight: 48),
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(24)),
                            alignment: Alignment.centerLeft,
                            child: TextField(
                              controller: con.chatInput,
                              minLines: 1,
                              maxLines: 4,
                              onSubmitted: (_) => con.sendMessage(),
                              decoration: InputDecoration(
                                hintText: 'Reply to support…'.tr,
                                hintStyle: const TextStyle(
                                    color: Color(0xFF94A3B8)),
                                border: InputBorder.none,
                                isCollapsed: true,
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                              style: const TextStyle(
                                  fontSize: 14.5, color: Color(0xFF0F172A)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        InkWell(
                          onTap: con.sendingMessage ? null : con.sendMessage,
                          customBorder: const CircleBorder(),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                                color: _orange, shape: BoxShape.circle),
                            child: con.sendingMessage
                                ? const Padding(
                                    padding: EdgeInsets.all(14),
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: Colors.white),
                                  )
                                : const Icon(Icons.send_rounded,
                                    color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SubjectChip extends StatelessWidget {
  const _SubjectChip(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
  const _Bubble({required this.msg, required this.mine});
  final NagarikMessage msg;
  final bool mine;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment:
            mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!mine)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Text(
                  msg.senderName.isNotEmpty
                      ? msg.senderName
                      : 'DNCC Support'.tr,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _orange)),
            ),
          Container(
            constraints: BoxConstraints(maxWidth: Get.width * 0.76),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: mine ? _orange : AppColors.white,
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
          if (msg.timeLabel.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(msg.timeLabel,
                style: const TextStyle(
                    fontSize: 11, color: Color(0xFF94A3B8))),
          ],
        ],
      ),
    );
  }
}
