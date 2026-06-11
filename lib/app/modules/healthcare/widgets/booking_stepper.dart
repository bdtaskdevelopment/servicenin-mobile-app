import 'package:flutter/material.dart';
import 'package:get/get.dart';

const _green = Color(0xFF0F7A52);

/// Slot → Patient → Confirm step indicator used across the booking flow.
class BookingStepper extends StatelessWidget {
  const BookingStepper({super.key, required this.current});

  /// 0 = Slot, 1 = Patient, 2 = Confirm.
  final int current;

  static const _labels = ['Slot', 'Patient', 'Confirm'];

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
                    color: (done || active) ? _green : const Color(0xFFE2E8F0),
                    shape: BoxShape.circle,
                  ),
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
                            ? _green
                            : const Color(0xFF94A3B8))),
                if (i != _labels.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      color: done ? _green : const Color(0xFFE2E8F0),
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
