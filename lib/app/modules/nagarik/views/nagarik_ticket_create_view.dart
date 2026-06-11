import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/nagarik_controller.dart';

const _orange = Color(0xFFF15A24);
const _tile = Color(0xFFFCE6CB);

class NagarikTicketCreateView extends GetView<NagarikController> {
  const NagarikTicketCreateView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: GetBuilder<NagarikController>(
          builder: (con) => Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 16, 8),
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
                        Text('New support ticket'.tr,
                            style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A))),
                        const SizedBox(height: 1),
                        Text('DNCC support will reply in chat'.tr,
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF94A3B8))),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                  children: [
                    _Label('CATEGORY'.tr),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: con.ticketCategories.map((c) {
                        final sel = con.ticketCategoryKey == c['value'];
                        return GestureDetector(
                          onTap: () => con.setTicketCategory(c['value']!),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: sel ? _tile : AppColors.white,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                  color: sel
                                      ? _orange
                                      : const Color(0xFFE2E8F0),
                                  width: sel ? 1.6 : 1.2),
                            ),
                            child: Text(c['label']!,
                                style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: sel
                                        ? _orange
                                        : const Color(0xFF334155))),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    _Label('SUBJECT'.tr),
                    const SizedBox(height: 10),
                    _Input(
                        controller: con.ticketSubject,
                        hint: 'e.g. Holding tax payment failed'.tr),
                    const SizedBox(height: 18),
                    _Label('DESCRIPTION'.tr),
                    const SizedBox(height: 10),
                    _Input(
                        controller: con.ticketDescription,
                        hint: 'Explain your issue, include any reference IDs…'
                            .tr,
                        maxLines: 5),
                    const SizedBox(height: 18),
                    _Label('PRIORITY'.tr),
                    const SizedBox(height: 10),
                    Row(
                      children: List.generate(con.priorities.length, (i) {
                        final sel = con.ticketPriorityIndex == i;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                                right: i == con.priorities.length - 1
                                    ? 0
                                    : 10),
                            child: GestureDetector(
                              onTap: () => con.setTicketPriority(i),
                              child: Container(
                                height: 48,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: sel ? _tile : AppColors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: sel
                                          ? _orange
                                          : const Color(0xFFE2E8F0),
                                      width: sel ? 1.6 : 1.2),
                                ),
                                child: Text(con.priorities[i]['label']!,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: sel
                                            ? _orange
                                            : const Color(0xFF334155))),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              // Submit
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed:
                        con.creatingTicket ? null : con.submitTicket,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _orange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: con.creatingTicket
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.4, color: Colors.white),
                          )
                        : Text('Create ticket'.tr,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF94A3B8),
          letterSpacing: 0.6));
}

class _Input extends StatelessWidget {
  const _Input({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEDEFF2))),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 14.5, color: Color(0xFF0F172A)),
        decoration: InputDecoration(
          isCollapsed: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: InputBorder.none,
          hintText: hint,
          hintStyle:
              const TextStyle(fontSize: 14.5, color: Color(0xFFB8C0CC)),
        ),
      ),
    );
  }
}
