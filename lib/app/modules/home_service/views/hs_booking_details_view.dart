import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../core/values/app_url.dart';
import '../../../global_widget/invoice_actions.dart';
import '../controllers/home_service_controller.dart';

const _teal = Color(0xFF0E9F8E);
const _darkTeal = Color(0xFF0E7C6B);
const _tile = Color(0xFFE0F2EF);

class HsBookingDetailsView extends GetView<HomeServiceController> {
  const HsBookingDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final con = controller;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
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
                      Text('Booking details'.tr,
                          style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                      Text(con.bookingId,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                children: [
                  // Service card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                              color: _tile,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.ac_unit_rounded,
                              color: _teal, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(con.bookingSummary,
                                  style: const TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A))),
                              const SizedBox(height: 2),
                              Text(
                                  '${con.techName} · ${con.whenSummary}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF94A3B8))),
                            ],
                          ),
                        ),
                        _StatusChip(status: con.trackedBooking?.status ?? ''),
                      ],
                    ),
                  ),
                  // Status timeline & work proof hidden for now.
                  /*
                  const SizedBox(height: 18),
                  const _Label('STATUS TIMELINE'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                    decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: List.generate(con.timeline.length, (i) {
                        final t = con.timeline[i];
                        final last = i == con.timeline.length - 1;
                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  const Icon(Icons.check_circle,
                                      size: 20, color: _darkTeal),
                                  if (!last)
                                    Expanded(
                                      child: Container(
                                          width: 2,
                                          color: const Color(0xFFB6E0D7)),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Padding(
                                  padding:
                                      EdgeInsets.only(bottom: last ? 8 : 18),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(t.statusLabel,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF0F172A))),
                                      const SizedBox(height: 1),
                                      if (t.note.isNotEmpty)
                                        Text(t.note,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF64748B))),
                                      Text(t.timeLabel,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFFE07A1F))),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: const [
                      _Label('WORK PROOF'),
                      SizedBox(width: 8),
                      Text('before · after',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: const [
                      Expanded(child: _ProofBox(label: 'Before', tinted: false)),
                      SizedBox(width: 12),
                      Expanded(child: _ProofBox(label: 'After', tinted: true)),
                    ],
                  ),
                  */
                  const SizedBox(height: 18),
                  _Label('INVOICE'.tr),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        _fee('Service charge'.tr, '৳${con.subtotalAmount}'),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        _fee('VAT (5%)'.tr, '৳${con.vat}'),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        _fee('Total paid'.tr, '৳${con.totalPaid}', bold: true),
                      ],
                    ),
                  ),
                  if ((con.trackedBooking?.id ?? '').isNotEmpty) ...[
                    const SizedBox(height: 14),
                    InvoiceActions(
                      viewPath: ApiURL.hsInvoicePdf(con.trackedBooking!.id),
                      downloadPath:
                          ApiURL.hsInvoicePdfDownload(con.trackedBooking!.id),
                      fileName: 'invoice-${con.trackedBooking!.id}',
                      accent: _darkTeal,
                    ),
                  ],
                ],
              ),
            ),
            // Bottom actions
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: con.rateService,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _darkTeal,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            child: Text('Rate service'.tr,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          // Rebook hidden for now — replaced with dispute.
                          // child: OutlinedButton(
                          //   onPressed: () {},
                          //   child: const Text('Rebook'),
                          // ),
                          child: OutlinedButton(
                            onPressed: () => _showDisputeDialog(context, con),
                            style: OutlinedButton.styleFrom(
                              side:
                                  const BorderSide(color: Color(0xFFFECACA)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            child: Text('Report issue'.tr,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFDC2626))),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Duplicate dispute link hidden — dispute now in the row above.
                  // const SizedBox(height: 8),
                  // TextButton(
                  //   onPressed: () => _showDisputeDialog(context, con),
                  //   child: const Text('Report an issue (dispute)',
                  //       style: TextStyle(
                  //           fontSize: 13.5,
                  //           fontWeight: FontWeight.w700,
                  //           color: Color(0xFFDC2626))),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fee(String label, String amount, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: bold ? 15 : 13.5,
                    fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
                    color: bold
                        ? const Color(0xFF0F172A)
                        : const Color(0xFF475569))),
            Text(amount,
                style: TextStyle(
                    fontSize: bold ? 16 : 14,
                    fontWeight: FontWeight.w800,
                    color: bold ? _darkTeal : const Color(0xFF0F172A))),
          ],
        ),
      );
}

void _showDisputeDialog(BuildContext context, HomeServiceController con) {
  final reasonCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text('Report an issue'.tr,
          style: const TextStyle(fontWeight: FontWeight.w800)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: reasonCtrl,
            decoration: InputDecoration(
              hintText: 'Reason'.tr,
              filled: true,
              fillColor: const Color(0xFFF7F8FA),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: descCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Describe what went wrong…'.tr,
              filled: true,
              fillColor: const Color(0xFFF7F8FA),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('Cancel'.tr,
              style: const TextStyle(color: Color(0xFF64748B))),
        ),
        ElevatedButton(
          onPressed: () {
            if (reasonCtrl.text.trim().isEmpty) return;
            Get.back();
            con.submitDispute(reasonCtrl.text.trim(), descCtrl.text.trim());
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white),
          child: Text('Submit'.tr),
        ),
      ],
    ),
  );
}

/// Status chip — same mapping as the bookings list and tracking sheet so the
/// status shown here always matches.
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;
  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();
    final done = s == 'completed';
    final bad = s == 'cancelled' || s == 'canceled';
    final bg = bad
        ? const Color(0xFFFEE2E2)
        : done
            ? const Color(0xFFDCFCE7)
            : const Color(0xFFFEF3C7);
    final fg = bad
        ? const Color(0xFFDC2626)
        : done
            ? const Color(0xFF15803D)
            : const Color(0xFFB45309);
    final label = status.isEmpty
        ? 'Pending'
        : status[0].toUpperCase() + status.substring(1).replaceAll('_', ' ');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w800, color: fg)),
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

// ignore: unused_element
class _ProofBox extends StatelessWidget {
  const _ProofBox({required this.label, required this.tinted});
  final String label;
  final bool tinted;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 110,
          decoration: BoxDecoration(
              color: tinted ? _tile : const Color(0xFFE9EDF1),
              borderRadius: BorderRadius.circular(14)),
          child: Icon(Icons.photo_camera_outlined,
              color: tinted ? _teal : const Color(0xFF94A3B8), size: 30),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF334155))),
      ],
    );
  }
}
