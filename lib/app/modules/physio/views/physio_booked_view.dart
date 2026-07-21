import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../core/values/app_url.dart';
import '../../../global_widget/invoice_actions.dart';
import '../controllers/physio_controller.dart';

const _brown = Color(0xFF8A3E12);

class PhysioBookedView extends GetView<PhysioController> {
  const PhysioBookedView({super.key});

  @override
  Widget build(BuildContext context) {
    final con = controller;
    final t = con.therapist;
    final center = con.center;
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
                      decoration: const BoxDecoration(
                          color: _brown, shape: BoxShape.circle),
                      child: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 42),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text('Session booked'.tr,
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A))),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text('Your physio session is confirmed'.tr,
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
                        _row(Icons.person_outline_rounded,
                            con.lastAppointment?.staffName.isNotEmpty == true
                                ? con.lastAppointment!.staffName
                                : (t?.name ?? '')),
                        const SizedBox(height: 14),
                        _row(Icons.meeting_room_outlined,
                            center?.name ?? ''),
                        const SizedBox(height: 14),
                        _row(
                            Icons.calendar_today_outlined,
                            con.lastAppointment?.whenLabel.isNotEmpty == true
                                ? con.lastAppointment!.whenLabel
                                : '${con.selectedDateLabel} · ${con.selectedTime}'),
                        const SizedBox(height: 14),
                        _row(
                            Icons.bolt_rounded,
                            con.sessionType == 1
                                ? '${'Home visit'.tr} · ${con.selectedPaymentKey}'
                                : '${'At center'.tr} · ${con.selectedPaymentKey}'),
                        if ((con.lastAppointment?.dayCount ?? con.dayCount) >
                            1) ...[
                          const SizedBox(height: 14),
                          _row(Icons.event_repeat_rounded,
                              '${con.lastAppointment?.dayCount ?? con.dayCount} ${'Days'.tr}'),
                        ],
                      ],
                    ),
                  ),
                  if (con.perDayRate > 0) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(18)),
                      child: Column(
                        children: [
                          _billRow('Per day'.tr, '৳${con.perDayRate}'),
                          const SizedBox(height: 8),
                          _billRow('Days'.tr,
                              '${con.lastAppointment?.dayCount ?? con.dayCount}'),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Divider(height: 1, color: Color(0xFFE2E8F0)),
                          ),
                          _billRow(
                            'Total'.tr,
                            '৳${con.lastAppointment?.groupTotalAmount ?? con.totalPrice}',
                            emphasize: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (con.lastAppointment?.id.isNotEmpty ?? false) ...[
                    const SizedBox(height: 16),
                    InvoiceActions(
                      // The backend resolves the whole booking group from
                      // any single day's appointment id, so day 1's id
                      // (returned by book()) is all we need here.
                      viewPath: ApiURL.physioInvoicePdf(con.lastAppointment!.id),
                      downloadPath:
                          ApiURL.physioInvoicePdfDownload(con.lastAppointment!.id),
                      fileName: 'invoice-${con.lastAppointment!.id}',
                      accent: _brown,
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
                        backgroundColor: _brown,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text('View my sessions'.tr,
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

  Widget _row(IconData icon, String value) => Row(
        children: [
          Icon(icon, size: 19, color: _brown),
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

  Widget _billRow(String label, String value, {bool emphasize = false}) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: emphasize ? 15 : 13.5,
                  fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
                  color: emphasize
                      ? const Color(0xFF0F172A)
                      : const Color(0xFF64748B))),
          Text(value,
              style: TextStyle(
                  fontSize: emphasize ? 17 : 13.5,
                  fontWeight: FontWeight.w800,
                  color: emphasize ? _brown : const Color(0xFF0F172A))),
        ],
      );
}
