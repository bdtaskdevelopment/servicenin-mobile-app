import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../global_widget/primary_button.dart';
import '../controllers/registration_controller.dart';
// ── Multi-step design (About · Location · PIN) — commented out for now,
//    registration now collects only name · phone · email. ──────────────
// import '../widgets/step_progress_bar.dart';
// import 'steps/step_about.dart';
// import 'steps/step_location.dart';
// import 'steps/step_security.dart';

class RegistrationView extends GetView<RegistrationController> {
  const RegistrationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: GetBuilder<RegistrationController>(
          builder: (con) {
            return Column(
              children: [
                // ── Top bar ────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
                  child: Row(
                    children: [
                      IconButton(
                        splashRadius: 22,
                        onPressed: () => Get.back(),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Color(0xFF1A1A1A),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                    children: [
                      Text(
                        'Create your account'.tr,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Create an account with your details.'.tr,
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 28),
                      _Field(
                        label: 'Name'.tr,
                        hint: 'Your full name'.tr,
                        controller: con.nameController,
                        onChanged: con.onInfoChanged,
                        keyboard: TextInputType.name,
                      ),
                      const SizedBox(height: 18),
                      _Field(
                        label: 'Phone number'.tr,
                        hint: '+8801XXXXXXXXX',
                        controller: con.phoneController,
                        onChanged: con.onInfoChanged,
                        keyboard: TextInputType.phone,
                        formatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _Field(
                        label: 'Email'.tr,
                        hint: 'you@example.com',
                        controller: con.emailController,
                        onChanged: con.onInfoChanged,
                        keyboard: TextInputType.emailAddress,
                      ),
                    ],
                  ),
                ),
                // ── Bottom action ──────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: PrimaryButton(
                    label: 'Create your account'.tr,
                    enabled: con.isInfoValid,
                    onPressed: con.register,
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

// ── Single labeled input ────────────────────────────────────────────
class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.hint,
    required this.controller,
    required this.onChanged,
    this.keyboard,
    this.formatters,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboard;
  final List<TextInputFormatter>? formatters;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.brandOrange,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            keyboardType: keyboard,
            inputFormatters: formatters,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFFB6C0CC),
                fontWeight: FontWeight.w500,
              ),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
