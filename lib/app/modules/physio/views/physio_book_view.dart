import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/physio_controller.dart';

const _brown = Color(0xFF8A3E12);
const _tile = Color(0xFFFCE6CB);

class PhysioBookView extends GetView<PhysioController> {
  const PhysioBookView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: GetBuilder<PhysioController>(
          builder: (con) {
            final t = con.therapist;
            return Column(
              children: [
                // Header
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Book a session'.tr,
                              style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A))),
                          Text(t?.name ?? '',
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF94A3B8))),
                        ],
                      ),
                    ],
                  ),
                ),
                const _Stepper(current: 1),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                    children: [
                      _Label('SESSION TYPE'.tr),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _TypeCard(
                              icon: Icons.meeting_room_outlined,
                              label: 'At center'.tr,
                              selected: con.sessionType == 0,
                              onTap: () => con.setSessionType(0),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _TypeCard(
                              icon: Icons.home_outlined,
                              label: 'Home visit'.tr,
                              selected: con.sessionType == 1,
                              onTap: () => con.setSessionType(1),
                            ),
                          ),
                        ],
                      ),
                      if (con.sessionType == 1) ...[
                        const SizedBox(height: 18),
                        _Label('HOME ADDRESS'.tr),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: TextField(
                            controller: con.homeAddressCtrl,
                            decoration: InputDecoration(
                              hintText: 'Where should the therapist visit?'.tr,
                              hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                              border: InputBorder.none,
                              isCollapsed: true,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      _Label('DATE'.tr),
                      const SizedBox(height: 10),
                      if (con.loadingDates && con.scheduleDates.isEmpty)
                        SnShimmer(
                          child: SizedBox(
                            height: 64,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: 5,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 10),
                              itemBuilder: (_, _) => const SnBone(
                                  width: 76, height: 64, radius: 12),
                            ),
                          ),
                        )
                      else
                        FadeInUp(
                          from: 18,
                          duration: const Duration(milliseconds: 350),
                          child: SizedBox(
                          height: 64,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: con.scheduleDates.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemBuilder: (_, i) {
                              final d = con.scheduleDates[i];
                              final sel = con.dateIndex == i;
                              return GestureDetector(
                                onTap: () => con.selectDate(i),
                                child: Container(
                                  width: 76,
                                  decoration: BoxDecoration(
                                    color: sel ? _brown : AppColors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: sel
                                            ? _brown
                                            : const Color(0xFFE2E8F0)),
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Text(d.label,
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: sel
                                                  ? Colors.white
                                                  : const Color(0xFF64748B))),
                                      const SizedBox(height: 2),
                                      Text(d.dayShort,
                                          style: TextStyle(
                                              fontSize: 13,
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
                      const SizedBox(height: 18),
                      _Label('TIME'.tr),
                      const SizedBox(height: 12),
                      if (con.loadingSlots && con.slots.isEmpty)
                        const SnGridSkeleton(
                          count: 6,
                          crossAxisCount: 3,
                          padding: EdgeInsets.zero,
                          childAspectRatio: 2.4,
                        )
                      else if (con.slots.isEmpty)
                        Text('No slots for this date.'.tr,
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFF94A3B8)))
                      else
                        FadeInUp(
                          from: 18,
                          duration: const Duration(milliseconds: 350),
                          child: GridView.count(
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 2.4,
                          children: con.slots.map((s) {
                            final sel = con.selectedSlotAt == s.scheduledAt;
                            final disabled = !s.available;
                            return GestureDetector(
                              onTap: disabled
                                  ? null
                                  : () => con.selectSlot(s.scheduledAt),
                              child: Opacity(
                                opacity: disabled ? 0.45 : 1,
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: sel
                                        ? _brown
                                        : (disabled
                                            ? const Color(0xFFF1F5F9)
                                            : AppColors.white),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: sel
                                            ? _brown
                                            : const Color(0xFFE2E8F0)),
                                  ),
                                  child: Text(s.time,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          decoration: disabled
                                              ? TextDecoration.lineThrough
                                              : null,
                                          color: sel
                                              ? Colors.white
                                              : const Color(0xFF0F172A))),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        ),
                      const SizedBox(height: 18),
                      _Label('NOTES (OPTIONAL)'.tr),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: TextField(
                          controller: con.notesCtrl,
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: 'Describe your concern (optional)…'.tr,
                            hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                            border: InputBorder.none,
                            isCollapsed: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _Label('PAYMENT'.tr),
                      const SizedBox(height: 10),
                      if (con.loadingPayments && con.paymentMethods.isEmpty)
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
                        children: con.paymentMethods.map((m) {
                          final sel = con.selectedPaymentKey == m.key;
                          final disabled = !m.enabled;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: GestureDetector(
                              onTap: disabled
                                  ? null
                                  : () => con.selectPayment(m.key),
                              child: Opacity(
                                opacity: disabled ? 0.5 : 1,
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: sel
                                            ? _brown
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
                                              ? _brown
                                              : const Color(0xFFCBD5E1)),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(m.label,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF0F172A))),
                                      ),
                                      if (disabled)
                                        Text('Soon'.tr,
                                            style: const TextStyle(
                                                fontSize: 11,
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
                    ],
                  ),
                ),
                _BottomBar(
                  left: 'When'.tr,
                  price:
                      '${con.selectedDateLabel} · ${con.selectedTime}',
                  loading: con.booking,
                  onTap: con.confirmBooking,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.current});
  final int current;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Row(
        children: [
          _node(0, 'Mode'.tr),
          _line(current >= 1),
          _node(1, 'Slot'.tr),
          _line(current >= 2),
          _node(2, 'Confirm'.tr),
        ],
      ),
    );
  }

  Widget _node(int index, String label) {
    final done = current > index;
    final active = current == index;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (done || active) ? _brown : const Color(0xFFE2E8F0),
          ),
          alignment: Alignment.center,
          child: done
              ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
              : Text('${index + 1}',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: active ? Colors.white : const Color(0xFF94A3B8))),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: (done || active)
                    ? const Color(0xFF0F172A)
                    : const Color(0xFF94A3B8))),
      ],
    );
  }

  Widget _line(bool active) => Expanded(
        child: Container(
          height: 2,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          color: active ? _brown : const Color(0xFFE2E8F0),
        ),
      );
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

class _TypeCard extends StatelessWidget {
  const _TypeCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: selected ? _tile : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selected ? _brown : const Color(0xFFE2E8F0),
              width: selected ? 1.6 : 1.2),
        ),
        child: Column(
          children: [
            Icon(icon,
                size: 24,
                color: selected ? _brown : const Color(0xFF64748B)),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? const Color(0xFF0F172A)
                        : const Color(0xFF334155))),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar(
      {required this.left,
      required this.price,
      required this.onTap,
      this.loading = false});
  final String left;
  final String price;
  final VoidCallback onTap;
  final bool loading;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(left,
                  style: const TextStyle(
                      fontSize: 11.5, color: Color(0xFF94A3B8))),
              Text(price,
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
                onPressed: loading ? null : onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brown,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.4, color: Colors.white),
                      )
                    : Text('Confirm booking'.tr,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
