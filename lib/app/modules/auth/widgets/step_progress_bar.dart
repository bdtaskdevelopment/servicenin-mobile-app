import 'package:flutter/material.dart';

import '../../../core/values/app_colors.dart';

/// Segmented progress indicator shown at the top of the registration steps.
/// Filled (orange) up to and including [currentStep] (0-based).
class StepProgressBar extends StatelessWidget {
  const StepProgressBar({
    super.key,
    required this.currentStep,
    this.totalSteps = 3,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (i) {
        final active = i <= currentStep;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i == totalSteps - 1 ? 0 : 6),
            height: 5,
            decoration: BoxDecoration(
              color: active ? AppColors.brandOrange : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}
