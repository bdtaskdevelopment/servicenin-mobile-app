import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/home_service_controller.dart';

const _teal = Color(0xFF0E9F8E);
const _darkTeal = Color(0xFF0E7C6B);
const _tile = Color(0xFFE0F2EF);

class ConfirmBookingView extends GetView<HomeServiceController> {
  const ConfirmBookingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: GetBuilder<HomeServiceController>(
          builder: (con) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 16, 4),
                  child: Row(
                    children: [
                      IconButton(
                        splashRadius: 22,
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 20, color: Color(0xFF1A1A1A)),
                      ),
                      Text('Confirm booking'.tr,
                          style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                    ],
                  ),
                ),
                const _Stepper(current: 1),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                    children: [
                      // Cart summary
                      ...con.cartItems.map((s) => Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding:
                                const EdgeInsets.fromLTRB(14, 6, 6, 6),
                            decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(14)),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text('${s.name} ×${con.qtyOf(s)}',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF0F172A))),
                                ),
                                const SizedBox(width: 8),
                                Text('৳${s.price * con.qtyOf(s)}',
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A))),
                                IconButton(
                                  splashRadius: 20,
                                  visualDensity: VisualDensity.compact,
                                  tooltip: 'Remove'.tr,
                                  onPressed: () => con.removeItem(s),
                                  icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      size: 22,
                                      color: Color(0xFFE23744)),
                                ),
                              ],
                            ),
                          )),
                      // Bill: subtotal + 5% VAT = payable
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(14)),
                        child: Column(
                          children: [
                            _BillRow(
                                label: 'Subtotal'.tr,
                                value: '৳${con.totalPrice}'),
                            if (con.vatApplies) ...[
                              const SizedBox(height: 8),
                              _BillRow(
                                  label:
                                      '${'VAT'.tr} (${con.vatPercentLabel}%)',
                                  value: '৳${con.cartVat}'),
                            ],
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Divider(
                                  height: 1, color: Color(0xFFEDEFF2)),
                            ),
                            _BillRow(
                                label: 'Total'.tr,
                                value: '৳${con.cartPayable}',
                                emphasize: true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      _Label('SERVICE ADDRESS'.tr),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(14)),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                  color: _tile,
                                  borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.location_on_outlined,
                                  color: _teal, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: con.addressCtrl,
                                minLines: 1,
                                maxLines: 2,
                                decoration: InputDecoration(
                                  hintText: 'Enter your service address'.tr,
                                  hintStyle:
                                      const TextStyle(color: Color(0xFF94A3B8)),
                                  border: InputBorder.none,
                                  isCollapsed: true,
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                ),
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      _Label('WHEN?'.tr),
                      const SizedBox(height: 10),
                      if (con.loadingDates && con.scheduleDates.isEmpty)
                        SnShimmer(
                          child: SizedBox(
                            height: 74,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: 5,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 10),
                              itemBuilder: (_, _) => const SnBone(
                                  width: 78, height: 74, radius: 12),
                            ),
                          ),
                        )
                      else
                        FadeInUp(
                          from: 18,
                          duration: const Duration(milliseconds: 350),
                          child: SizedBox(
                          height: 74,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: con.scheduleDates.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemBuilder: (_, i) {
                              final sel = con.selectedBookingDate == i;
                              final d = con.scheduleDates[i];
                              return GestureDetector(
                                onTap: () {
                                  con.selectBookingDate(i);
                                  con.loadSlotsForSelectedDate();
                                },
                                child: Container(
                                  width: 78,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: sel ? _darkTeal : AppColors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: sel
                                            ? _darkTeal
                                            : const Color(0xFFE2E8F0)),
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(d.label,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: sel
                                                  ? Colors.white
                                                  : const Color(0xFF64748B))),
                                      const SizedBox(height: 2),
                                      Text(d.day,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w800,
                                              color: sel
                                                  ? Colors.white
                                                  : const Color(0xFF0F172A))),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        ),
                      const SizedBox(height: 14),
                      _Label('TIME SLOT'.tr),
                      const SizedBox(height: 10),
                      if (con.loadingSlots && con.slots.isEmpty)
                        const SnListSkeleton(
                          count: 4,
                          padding: EdgeInsets.zero,
                          showTrailing: false,
                        )
                      else
                        FadeInUp(
                          from: 18,
                          duration: const Duration(milliseconds: 350),
                          child: Column(
                          children: con.slots.map((s) {
                            final sel = con.selectedSlotKey == s.key;
                            final disabled = !s.available;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: GestureDetector(
                                onTap: disabled
                                    ? null
                                    : () => con.selectSlot(s.key),
                                child: Opacity(
                                  opacity: disabled ? 0.5 : 1,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: sel ? _darkTeal : AppColors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: sel
                                              ? _darkTeal
                                              : const Color(0xFFE2E8F0)),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                            sel
                                                ? Icons.radio_button_checked
                                                : Icons.radio_button_off,
                                            size: 20,
                                            color: sel
                                                ? Colors.white
                                                : const Color(0xFFCBD5E1)),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(s.label,
                                              style: TextStyle(
                                                  fontSize: 13.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: sel
                                                      ? Colors.white
                                                      : const Color(
                                                          0xFF0F172A))),
                                        ),
                                        if (disabled)
                                          Text('Full'.tr,
                                              style: const TextStyle(
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF94A3B8))),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        ),
                      const SizedBox(height: 18),
                      _Label('PAYMENT'.tr),
                      const SizedBox(height: 10),
                      if (con.loadingMethods && con.methods.isEmpty)
                        const SnListSkeleton(
                          count: 3,
                          padding: EdgeInsets.zero,
                          showTrailing: false,
                        )
                      else
                      FadeInUp(
                        from: 18,
                        duration: const Duration(milliseconds: 350),
                        child: Column(
                        children: con.enabledMethods.map((m) {
                          final sel = con.selectedMethodKey == m.key;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: GestureDetector(
                              onTap: () => con.selectMethod(m.key),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: sel
                                          ? _teal
                                          : const Color(0xFFE2E8F0),
                                      width: sel ? 1.6 : 1.2),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                        sel
                                            ? Icons.radio_button_checked
                                            : Icons.radio_button_off,
                                        size: 20,
                                        color: sel
                                            ? _teal
                                            : const Color(0xFFCBD5E1)),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(m.label,
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w800,
                                                  color: Color(0xFF0F172A))),
                                          const SizedBox(height: 2),
                                          Text(m.description,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF94A3B8))),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      ),
                    ],
                  ),
                ),
                // Bottom
                Container(
                  color: AppColors.white,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Total (incl. VAT)'.tr,
                              style: const TextStyle(
                                  fontSize: 11.5, color: Color(0xFF94A3B8))),
                          Text('৳${con.cartPayable}',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A))),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            onPressed: con.placing ? null : con.placeBooking,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _darkTeal,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            child: con.placing
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2.4, color: Colors.white),
                                  )
                                : Text('Place booking'.tr,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BillRow extends StatelessWidget {
  const _BillRow(
      {required this.label, required this.value, this.emphasize = false});
  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Row(
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
                fontSize: emphasize ? 16 : 14,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A))),
      ],
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

class _Stepper extends StatelessWidget {
  const _Stepper({required this.current});
  final int current;
  static const _labels = ['Services', 'Schedule', 'Confirm'];
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF7F8FA),
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
      child: Row(
        children: List.generate(_labels.length, (i) {
          final done = i < current;
          final active = i == current;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                      color: (done || active)
                          ? _darkTeal
                          : const Color(0xFFE2E8F0),
                      shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: done
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : Text('${i + 1}',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: active
                                  ? Colors.white
                                  : const Color(0xFF94A3B8))),
                ),
                const SizedBox(width: 6),
                Text(_labels[i].tr,
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: (done || active)
                            ? _darkTeal
                            : const Color(0xFF94A3B8))),
                if (i != _labels.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      color: done ? _darkTeal : const Color(0xFFE2E8F0),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
