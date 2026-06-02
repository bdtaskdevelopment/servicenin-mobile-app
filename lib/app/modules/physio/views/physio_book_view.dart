import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
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
                          const Text('Book a session',
                              style: TextStyle(
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
                      const _Label('SESSION TYPE'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _TypeCard(
                              icon: Icons.meeting_room_outlined,
                              label: 'At center',
                              selected: con.sessionType == 0,
                              onTap: () => con.setSessionType(0),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _TypeCard(
                              icon: Icons.home_outlined,
                              label: 'Home visit',
                              selected: con.sessionType == 1,
                              onTap: () => con.setSessionType(1),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const _Label('DATE'),
                      const SizedBox(height: 10),
                      Row(
                        children: List.generate(con.dates.length, (i) {
                          final d = con.dates[i];
                          final sel = con.dateIndex == i;
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  right: i == con.dates.length - 1 ? 0 : 10),
                              child: GestureDetector(
                                onTap: () => con.setDate(i),
                                child: Container(
                                  height: 64,
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
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 18),
                      const _Label('TIME'),
                      const SizedBox(height: 12),
                      GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 2.4,
                        children: List.generate(con.times.length, (i) {
                          final sel = con.timeIndex == i;
                          return GestureDetector(
                            onTap: () => con.setTime(i),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: sel ? _brown : AppColors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: sel
                                        ? _brown
                                        : const Color(0xFFE2E8F0)),
                              ),
                              child: Text(con.times[i],
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: sel
                                          ? Colors.white
                                          : const Color(0xFF0F172A))),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                _BottomBar(
                  left: '${con.selectedDateLabel} · ${con.selectedTime}',
                  price: t?.fee ?? '',
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
          _node(0, 'Mode'),
          _line(current >= 1),
          _node(1, 'Slot'),
          _line(current >= 2),
          _node(2, 'Confirm'),
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
      {required this.left, required this.price, required this.onTap});
  final String left;
  final String price;
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
                  backgroundColor: _brown,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Confirm booking',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
