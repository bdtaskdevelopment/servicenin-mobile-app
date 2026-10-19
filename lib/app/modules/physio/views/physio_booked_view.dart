import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../core/values/app_url.dart';
import '../../../global_widget/invoice_actions.dart';
import '../controllers/physio_controller.dart';
import '../physio_palette.dart';

class PhysioBookedView extends GetView<PhysioController> {
  const PhysioBookedView({super.key});

  @override
  Widget build(BuildContext context) {
    final con = controller;
    final appt = con.lastAppointment;
    final center = con.center;
    final brown = physioStyleFor(center?.id ?? '').accent;
    return Scaffold(
      backgroundColor: const Color(0xFFFDF5EC),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 16),
                children: [
                  Center(
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration:
                          BoxDecoration(color: brown, shape: BoxShape.circle),
                      child: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 42),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text('Booking confirmed'.tr,
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A))),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                        'A therapist/lab technician will be assigned shortly'
                            .tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 13.5, color: Color(0xFF64748B))),
                  ),
                  const SizedBox(height: 26),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(18)),
                    child: Column(
                      children: [
                        _row(Icons.meeting_room_outlined, center?.name ?? '',
                            brown),
                        const SizedBox(height: 14),
                        _row(
                            Icons.calendar_today_outlined,
                            appt?.whenLabel.isNotEmpty == true
                                ? appt!.whenLabel
                                : '${con.selectedDateLabel} · ${con.selectedTimeLabel}',
                            brown),
                        const SizedBox(height: 14),
                        _row(
                            Icons.bolt_rounded,
                            con.sessionType == 1
                                ? 'Home visit'.tr
                                : 'At center'.tr,
                            brown),
                      ],
                    ),
                  ),
                  if (appt != null && appt.items.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(18)),
                      child: Column(
                        children: [
                          ...appt.items.map((it) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _billRow(
                                    it.quantity > 1
                                        ? '${it.serviceName} × ${it.quantity}'
                                        : it.serviceName,
                                    '৳${it.lineTotal}',
                                    brown),
                              )),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 6),
                            child: Divider(height: 1, color: Color(0xFFE2E8F0)),
                          ),
                          _billRow('Total'.tr, '৳${appt.amount}', brown,
                              emphasize: true),
                        ],
                      ),
                    ),
                  ],
                  if (appt?.id.isNotEmpty ?? false) ...[
                    const SizedBox(height: 16),
                    InvoiceActions(
                      viewPath: ApiURL.physioInvoicePdf(appt!.id),
                      downloadPath: ApiURL.physioInvoicePdfDownload(appt.id),
                      fileName: 'invoice-${appt.id}',
                      accent: brown,
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: con.viewMySessions,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brown,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                          (appt?.isLabOnly ?? false)
                              ? 'View my bookings'.tr
                              : 'View my sessions'.tr,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: con.backToPhysioHome,
                    child: Text('Back to Physio home'.tr,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B))),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String value, Color accent) => Row(
        children: [
          Icon(icon, size: 19, color: accent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A))),
          ),
        ],
      );

  Widget _billRow(String label, String value, Color accent,
          {bool emphasize = false}) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: emphasize ? 15 : 13.5,
                    fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
                    color: emphasize
                        ? const Color(0xFF0F172A)
                        : const Color(0xFF64748B))),
          ),
          const SizedBox(width: 8),
          Text(value,
              style: TextStyle(
                  fontSize: emphasize ? 17 : 13.5,
                  fontWeight: FontWeight.w800,
                  color: emphasize ? accent : const Color(0xFF0F172A))),
        ],
      );
}
