import 'package:flutter/material.dart';

import '../../../core/values/app_colors.dart';

/// A tappable, read-only field shown as a rounded box with a small label, a
/// value (or placeholder), an optional leading icon and a trailing chevron.
///
/// Used for the date-of-birth picker and the division/district/thana/area
/// selectors on the registration screens.
class SelectField extends StatelessWidget {
  const SelectField({
    super.key,
    required this.label,
    required this.onTap,
    this.value,
    this.placeholder,
    this.leadingIcon,
    this.required = false,
    this.selected = false,
    this.centerText = false,
  });

  final String label;
  final VoidCallback onTap;
  final String? value;
  final String? placeholder;
  final IconData? leadingIcon;
  final bool required;
  final bool selected;
  final bool centerText;

  bool get _hasValue => value != null && value!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: (selected || _hasValue)
                ? AppColors.brandOrange
                : const Color(0xFFE2E8F0),
            width: (selected || _hasValue) ? 1.6 : 1.2,
          ),
        ),
        child: Row(
          children: [
            if (leadingIcon != null) ...[
              Icon(leadingIcon, size: 22, color: const Color(0xFF94A3B8)),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: centerText
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  RichText(
                    textAlign: centerText ? TextAlign.center : TextAlign.start,
                    text: TextSpan(
                      text: label,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                      children: required
                          ? const [
                              TextSpan(
                                text: ' *',
                                style: TextStyle(color: Color(0xFFE53E3E)),
                              ),
                            ]
                          : const [],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _hasValue ? value! : (placeholder ?? ''),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _hasValue
                          ? const Color(0xFF0F172A)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_right_rounded,
              color: Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }
}
