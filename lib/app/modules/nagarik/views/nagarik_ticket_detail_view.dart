import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/nagarik_controller.dart';
import 'nagarik_view.dart' show StatusPill;

const _orange = Color(0xFFF15A24);
const _tile = Color(0xFFFCE6CB);

class NagarikTicketDetailView extends GetView<NagarikController> {
  const NagarikTicketDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: Color(0xFF1A1A1A)),
        ),
        title: Text('Ticket details'.tr,
            style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A))),
      ),
      body: GetBuilder<NagarikController>(
        builder: (con) {
          final t = con.selectedTicket;
          if (t == null) {
            return Center(
              child: Text('Ticket not found.'.tr,
                  style: const TextStyle(color: Color(0xFF94A3B8))),
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  children: [
                    // Header card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 3)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                    color: _tile,
                                    borderRadius: BorderRadius.circular(12)),
                                child: const Icon(
                                    Icons.confirmation_number_outlined,
                                    color: _orange,
                                    size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                    t.subject.isNotEmpty
                                        ? t.subject
                                        : t.categoryLabel,
                                    style: const TextStyle(
                                        fontSize: 16.5,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A))),
                              ),
                              const SizedBox(width: 8),
                              StatusPill(
                                  label: t.statusLabel, resolved: t.isResolved),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (t.categoryLabel.isNotEmpty)
                                _chip(Icons.category_outlined, t.categoryLabel),
                              if (t.priority.isNotEmpty)
                                _chip(Icons.flag_outlined,
                                    _priorityLabel(t.priority)),
                              if (t.createdLabel.isNotEmpty)
                                _chip(Icons.schedule_rounded, t.createdLabel),
                              if (t.userName.isNotEmpty)
                                _chip(Icons.person_outline_rounded, t.userName),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (con.loadingTicketDetail && t.description.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(
                              strokeWidth: 2.4, color: _orange),
                        ),
                      )
                    else ...[
                      _Head('Description'.tr),
                      const SizedBox(height: 8),
                      Text(
                          t.description.isEmpty
                              ? 'No description provided.'.tr
                              : t.description,
                          style: const TextStyle(
                              fontSize: 13.5,
                              height: 1.5,
                              color: Color(0xFF334155))),
                    ],
                  ],
                ),
              ),
              // Open chat
              Container(
                color: AppColors.white,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => con.openTicket(t),
                    icon: const Icon(Icons.chat_bubble_outline_rounded,
                        size: 20),
                    label: Text('Open chat'.tr,
                        style: const TextStyle(
                            fontSize: 15.5, fontWeight: FontWeight.w800)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _orange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
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

  Widget _chip(IconData icon, String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: const Color(0xFF64748B)),
            const SizedBox(width: 5),
            Text(text,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569))),
          ],
        ),
      );

  String _priorityLabel(String p) {
    final s = p.replaceAll('_', ' ');
    return s.isEmpty ? '' : s[0].toUpperCase() + s.substring(1);
  }
}

class _Head extends StatelessWidget {
  const _Head(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 15.5,
          fontWeight: FontWeight.w800,
          color: Color(0xFF0F172A)));
}
