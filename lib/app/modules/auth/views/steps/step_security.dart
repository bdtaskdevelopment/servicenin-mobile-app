import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/registration_controller.dart';
import '../../widgets/boxed_code_input.dart';
import '../../widgets/toggle_tile.dart';

class StepSecurity extends StatelessWidget {
  const StepSecurity({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RegistrationController>(
      builder: (con) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Secure your account'.tr,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Set a 4-digit PIN. You\'ll use it for your wallet and sensitive actions.'.tr,
                style: const TextStyle(
                    fontSize: 14, color: Color(0xFF64748B), height: 1.5),
              ),
              const SizedBox(height: 24),
              _Label('Set PIN'.tr),
              const SizedBox(height: 10),
              BoxedCodeInput(
                length: 4,
                obscure: true,
                boxSize: 62,
                onChanged: con.setPin,
              ),
              const SizedBox(height: 22),
              _Label('Confirm PIN'.tr),
              const SizedBox(height: 10),
              BoxedCodeInput(
                length: 4,
                obscure: true,
                boxSize: 62,
                onChanged: con.setConfirmPin,
              ),
              const SizedBox(height: 26),
              ToggleTile(
                icon: Icons.fingerprint_rounded,
                title: 'Biometric login'.tr,
                subtitle: 'Fingerprint or face unlock'.tr,
                value: con.biometricEnabled,
                onChanged: con.toggleBiometric,
              ),
              const SizedBox(height: 12),
              ToggleTile(
                icon: Icons.notifications_none_rounded,
                title: 'Notification alerts'.tr,
                subtitle: 'Alerts for blood and other services'.tr,
                value: con.notificationEnabled,
                onChanged: con.toggleNotification,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF334155),
      ),
    );
  }
}
