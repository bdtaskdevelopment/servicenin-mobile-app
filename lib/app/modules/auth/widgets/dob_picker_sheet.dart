import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../global_widget/primary_button.dart';

/// Bottom sheet with day / month / year wheels (Bangla months) for selecting a
/// date of birth. Resolves to the chosen [DateTime] (or null if dismissed).
class DobPickerSheet extends StatefulWidget {
  const DobPickerSheet({super.key, this.initial});

  final DateTime? initial;

  static const List<String> bnMonths = [
    'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল', 'মে', 'জুন',
    'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর',
  ];

  static Future<DateTime?> show({DateTime? initial}) {
    return Get.bottomSheet<DateTime>(
      DobPickerSheet(initial: initial),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<DobPickerSheet> createState() => _DobPickerSheetState();
}

class _DobPickerSheetState extends State<DobPickerSheet> {
  // Year range: 1950 .. current-ish. We can't call DateTime.now() concerns in
  // app runtime are fine, but keep a fixed sensible upper bound.
  static const int _minYear = 1950;
  static const int _maxYear = 2025;

  late int _day;
  late int _monthIndex; // 0-based
  late int _year;

  late final FixedExtentScrollController _dayCtrl;
  late final FixedExtentScrollController _monthCtrl;
  late final FixedExtentScrollController _yearCtrl;

  List<int> get _years =>
      List.generate(_maxYear - _minYear + 1, (i) => _maxYear - i);

  @override
  void initState() {
    super.initState();
    final init = widget.initial ?? DateTime(2000, 5, 15);
    _day = init.day;
    _monthIndex = init.month - 1;
    _year = init.year.clamp(_minYear, _maxYear);

    _dayCtrl = FixedExtentScrollController(initialItem: _day - 1);
    _monthCtrl = FixedExtentScrollController(initialItem: _monthIndex);
    _yearCtrl = FixedExtentScrollController(initialItem: _maxYear - _year);
  }

  @override
  void dispose() {
    _dayCtrl.dispose();
    _monthCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  int get _daysInMonth => DateTime(_year, _monthIndex + 2, 0).day;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Select date of birth'.tr,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                _wheel(
                  controller: _dayCtrl,
                  count: _daysInMonth,
                  builder: (i) => '${i + 1}',
                  onChanged: (i) => setState(() => _day = i + 1),
                ),
                _wheel(
                  controller: _monthCtrl,
                  count: 12,
                  builder: (i) => DobPickerSheet.bnMonths[i],
                  onChanged: (i) => setState(() {
                    _monthIndex = i;
                    if (_day > _daysInMonth) _day = _daysInMonth;
                  }),
                ),
                _wheel(
                  controller: _yearCtrl,
                  count: _years.length,
                  builder: (i) => '${_years[i]}',
                  onChanged: (i) => setState(() => _year = _years[i]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Confirm'.tr,
            onPressed: () {
              final safeDay = _day.clamp(1, _daysInMonth);
              Get.back(result: DateTime(_year, _monthIndex + 1, safeDay));
            },
          ),
        ],
      ),
    );
  }

  Widget _wheel({
    required FixedExtentScrollController controller,
    required int count,
    required String Function(int) builder,
    required ValueChanged<int> onChanged,
  }) {
    return Expanded(
      child: CupertinoPicker(
        scrollController: controller,
        itemExtent: 40,
        diameterRatio: 1.2,
        selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(
          background: Color(0x14F15A24),
        ),
        onSelectedItemChanged: onChanged,
        children: List.generate(
          count,
          (i) => Center(
            child: Text(
              builder(i),
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
