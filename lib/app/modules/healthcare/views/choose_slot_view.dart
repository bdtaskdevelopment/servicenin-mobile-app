import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/booking_controller.dart';
import '../widgets/booking_stepper.dart';

const _green = Color(0xFF0F7A52);
const _tile = Color(0xFFD9F7E6);

class ChooseSlotView extends GetView<BookingController> {
  const ChooseSlotView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: GetBuilder<BookingController>(
          builder: (con) {
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
                          const Text('Choose a slot',
                              style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A))),
                          Text(con.doctorName,
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF94A3B8))),
                        ],
                      ),
                    ],
                  ),
                ),
                const BookingStepper(current: 0),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                    children: [
                      const _Label('CHAMBER / VENUE'),
                      const SizedBox(height: 10),
                      ...List.generate(con.venues.length, (i) {
                        final v = con.venues[i];
                        final sel = con.selectedVenue == i;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GestureDetector(
                            onTap: () => con.selectVenue(i),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: sel
                                        ? _green
                                        : const Color(0xFFE2E8F0),
                                    width: sel ? 1.6 : 1.2),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                        color: _tile,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: const Icon(
                                        Icons.location_on_outlined,
                                        color: _green,
                                        size: 19),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(v.venueName,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF0F172A))),
                                        const SizedBox(height: 2),
                                        Text(v.scheduleLabel,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF94A3B8))),
                                      ],
                                    ),
                                  ),
                                  _Radio(selected: sel),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                      const _Label('DATE'),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 64,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: con.dates.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 10),
                          itemBuilder: (_, i) {
                            final sel = con.selectedDate == i;
                            final d = con.dates[i];
                            return GestureDetector(
                              onTap: () => con.selectDate(i),
                              child: Container(
                                width: 74,
                                decoration: BoxDecoration(
                                  color: sel ? _green : AppColors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: sel
                                          ? _green
                                          : const Color(0xFFE2E8F0)),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(d.$1,
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: sel
                                                ? Colors.white
                                                : const Color(0xFF64748B))),
                                    const SizedBox(height: 2),
                                    Text(d.$2,
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
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          _Label('TIME'),
                          Text('Serial assigned at booking',
                              style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: _green)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      GridView.count(
                        crossAxisCount: 4,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.9,
                        children: con.times.map((t) {
                          final time = t.$1;
                          final available = t.$2;
                          final sel = con.selectedTime == time && available;
                          return GestureDetector(
                            onTap: available ? () => con.selectTime(time) : null,
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: available
                                    ? AppColors.white
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: sel
                                        ? _green
                                        : const Color(0xFFE2E8F0),
                                    width: sel ? 1.6 : 1.2),
                              ),
                              child: Text(time,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      decoration: available
                                          ? null
                                          : TextDecoration.lineThrough,
                                      color: !available
                                          ? const Color(0xFFCBD5E1)
                                          : sel
                                              ? _green
                                              : const Color(0xFF0F172A))),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                          'Serial, not a fixed time — arrive 15 min early.',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFFE07A1F))),
                    ],
                  ),
                ),
                _BottomBar(
                  left: con.slotSummary,
                  price: con.doctorFee,
                  label: 'Continue →',
                  onTap: con.slotContinue,
                ),
              ],
            );
          },
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

class _Radio extends StatelessWidget {
  const _Radio({required this.selected});
  final bool selected;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? _green : Colors.transparent,
        border: Border.all(
            color: selected ? _green : const Color(0xFFCBD5E1), width: 2),
      ),
      child: selected
          ? const Icon(Icons.circle, size: 8, color: Colors.white)
          : null,
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar(
      {required this.left,
      required this.price,
      required this.label,
      required this.onTap});
  final String left;
  final String price;
  final String label;
  final VoidCallback onTap;
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
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(label,
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
