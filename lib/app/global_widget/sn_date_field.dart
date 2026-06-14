import 'package:flutter/material.dart';

import '../core/values/app_colors.dart';

/// A labeled field that opens a date (and optionally time) picker instead of a
/// raw text keyboard, writing the chosen value into [controller] as
/// `YYYY-MM-DD` (or `YYYY-MM-DD HH:MM` when [withTime] is true).
///
/// Drop-in replacement for date text inputs across the app.
class SnDateField extends StatefulWidget {
  const SnDateField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.withTime = false,
    this.firstDate,
    this.lastDate,
    this.accent = const Color(0xFF332F2C),
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool withTime;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final Color accent;
  final VoidCallback? onChanged;

  @override
  State<SnDateField> createState() => _SnDateFieldState();
}

class _SnDateFieldState extends State<SnDateField> {
  static String _two(int n) => n.toString().padLeft(2, '0');

  DateTime? _parse(String s) {
    if (s.trim().isEmpty) return null;
    return DateTime.tryParse(s.trim().replaceFirst(' ', 'T'));
  }

  String _format(DateTime dt) {
    final date =
        '${dt.year.toString().padLeft(4, '0')}-${_two(dt.month)}-${_two(dt.day)}';
    return widget.withTime ? '$date ${_two(dt.hour)}:${_two(dt.minute)}' : date;
  }

  Future<void> _pick() async {
    final now = DateTime.now();
    final existing = _parse(widget.controller.text);
    final first = widget.firstDate ?? DateTime(1900);
    final last = widget.lastDate ?? DateTime(now.year + 5, 12, 31);
    var initial = existing ?? now;
    if (initial.isBefore(first)) initial = first;
    if (initial.isAfter(last)) initial = last;

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
    );
    if (date == null) return;

    TimeOfDay? time;
    if (widget.withTime && mounted) {
      time = await showTimePicker(
        context: context,
        initialTime:
            existing != null ? TimeOfDay.fromDateTime(existing) : TimeOfDay.now(),
      );
    }

    final dt = DateTime(
      date.year,
      date.month,
      date.day,
      time?.hour ?? 0,
      time?.minute ?? 0,
    );
    widget.controller.text = _format(dt);
    widget.onChanged?.call();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.controller.text;
    final hint = widget.hint ?? (widget.withTime ? 'YYYY-MM-DD HH:MM' : 'YYYY-MM-DD');
    return GestureDetector(
      onTap: _pick,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEDEFF2))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.label,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF94A3B8),
                    letterSpacing: 0.6)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    value.isEmpty ? hint : value,
                    style: TextStyle(
                        fontSize: 15.5,
                        fontWeight:
                            value.isEmpty ? FontWeight.w500 : FontWeight.w700,
                        color: value.isEmpty
                            ? const Color(0xFFB0AEB8)
                            : const Color(0xFF0F172A)),
                  ),
                ),
                Icon(widget.withTime ? Icons.event_rounded : Icons.calendar_today_outlined,
                    size: 18, color: widget.accent),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
