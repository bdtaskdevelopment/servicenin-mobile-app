import 'package:flutter/material.dart';

import '../../../core/values/app_colors.dart';

/// Row of selectable gender pills: পুরুষ / মহিলা / অন্যান্য.
class GenderSelector extends StatelessWidget {
  const GenderSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(options.length, (i) {
        final option = options[i];
        final isSelected = option == selected;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == options.length - 1 ? 0 : 10),
            child: GestureDetector(
              onTap: () => onSelected(option),
              child: Container(
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.brandOrange.withValues(alpha: 0.12)
                      : AppColors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.brandOrange
                        : const Color(0xFFE2E8F0),
                    width: isSelected ? 1.6 : 1.2,
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? AppColors.brandOrange
                        : const Color(0xFF475569),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
