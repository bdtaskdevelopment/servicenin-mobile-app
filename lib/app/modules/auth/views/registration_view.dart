import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../global_widget/primary_button.dart';
import '../controllers/registration_controller.dart';
import '../widgets/step_progress_bar.dart';
import 'steps/step_about.dart';
import 'steps/step_location.dart';
import 'steps/step_security.dart';

class RegistrationView extends GetView<RegistrationController> {
  const RegistrationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: GetBuilder<RegistrationController>(
          builder: (con) {
            final isLast = con.currentStep == RegistrationController.totalSteps - 1;
            return Column(
              children: [
                // ── Top bar: back + progress + step count ──────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
                  child: Row(
                    children: [
                      IconButton(
                        splashRadius: 22,
                        onPressed: con.back,
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Color(0xFF1A1A1A),
                          size: 20,
                        ),
                      ),
                      Expanded(
                        child: StepProgressBar(currentStep: con.currentStep),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${con.currentStep + 1}/${RegistrationController.totalSteps}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                // ── Steps ──────────────────────────────────────────
                Expanded(
                  child: PageView(
                    controller: con.pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: const [
                      StepAbout(),
                      StepLocation(),
                      StepSecurity(),
                    ],
                  ),
                ),
                // ── Bottom action ──────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: PrimaryButton(
                    label: isLast ? 'অ্যাকাউন্ট তৈরি করুন' : 'পরবর্তী',
                    enabled: con.isCurrentStepValid,
                    onPressed: con.next,
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
