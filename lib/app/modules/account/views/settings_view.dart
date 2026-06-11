import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/languages/language_controller.dart';
import '../../../core/values/app_colors.dart';
import '../controllers/account_controller.dart';

const _navy = Color(0xFF1E2A4A);
const _tileSel = Color(0xFFE3E7F5);
// const _green = Color(0xFF16A34A); // used by the commented-out _ToggleCard

class SettingsView extends GetView<AccountController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F6),
      body: SafeArea(
        child: GetBuilder<AccountController>(
          builder: (con) => Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      splashRadius: 22,
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 20, color: Color(0xFF1A1A1A)),
                    ),
                    Text('Language & settings'.tr,
                        style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A))),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    _Label('LANGUAGE'.tr),
                    const SizedBox(height: 10),
                    GetBuilder<LanguageController>(
                      builder: (lang) => Row(
                        children: [
                          Expanded(
                            child: _LangCard(
                              title: 'বাংলা',
                              subtitle: 'Bangla',
                              selected: lang.index == 0,
                              onTap: () => lang.setByIndex(0),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _LangCard(
                              title: 'English',
                              subtitle: 'English',
                              selected: lang.index == 1,
                              onTap: () => lang.setByIndex(1),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // ── Notifications section hidden for now ──────────────
                    /*
                    const SizedBox(height: 18),
                    const _Label('NOTIFICATIONS'),
                    const SizedBox(height: 10),
                    _ToggleCard(
                      title: 'Push notifications',
                      subtitle: 'Bookings, status updates, alerts',
                      value: con.pushNotifications,
                      onChanged: con.togglePush,
                    ),
                    const SizedBox(height: 12),
                    _ToggleCard(
                      title: 'SMS alerts',
                      subtitle: 'OTP & critical updates',
                      value: con.smsAlerts,
                      onChanged: con.toggleSms,
                    ),
                    */
                    const SizedBox(height: 18),
                    _Label('ABOUT'.tr),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        children: [
                          _AboutRow(
                            label: 'App version'.tr,
                            trailing: const Text('3.0.0',
                                style: TextStyle(
                                    fontSize: 13.5,
                                    color: Color(0xFF94A3B8))),
                          ),
                          const _AboutDivider(),
                          _AboutRow(
                            label: 'Terms of service'.tr,
                            onTap: con.openTerms,
                            trailing: const Icon(
                                Icons.chevron_right_rounded,
                                color: Color(0xFF94A3B8)),
                          ),
                          const _AboutDivider(),
                          _AboutRow(
                            label: 'Privacy policy'.tr,
                            onTap: con.openPrivacy,
                            trailing: const Icon(
                                Icons.chevron_right_rounded,
                                color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('ACCOUNT'.tr,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFDC2626),
                            letterSpacing: 0.6)),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: con.openDeleteAccount,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16)),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                  color: const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.delete_outline_rounded,
                                  color: Color(0xFFDC2626), size: 21),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Delete account'.tr,
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFFDC2626))),
                                  const SizedBox(height: 2),
                                  Text('Permanently remove your ServiceNin ID'.tr,
                                      style: const TextStyle(
                                          fontSize: 12.5,
                                          color: Color(0xFF94A3B8))),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded,
                                color: Color(0xFFDC2626)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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

class _LangCard extends StatelessWidget {
  const _LangCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: selected ? _tileSel : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: selected ? _navy : const Color(0xFFE2E8F0),
              width: selected ? 1.6 : 1.2),
        ),
        child: Column(
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A))),
            const SizedBox(height: 2),
            Text(subtitle,
                style:
                    const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
            if (selected) ...[
              const SizedBox(height: 6),
              const Icon(Icons.check_rounded, size: 18, color: _navy),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Unused while the notifications section above is commented out ──
/*
class _ToggleCard extends StatelessWidget {
  const _ToggleCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      decoration: BoxDecoration(
          color: AppColors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12.5, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: _green,
          ),
        ],
      ),
    );
  }
}
*/

class _AboutRow extends StatelessWidget {
  const _AboutRow({required this.label, required this.trailing, this.onTap});
  final String label;
  final Widget trailing;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A))),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _AboutDivider extends StatelessWidget {
  const _AboutDivider();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Divider(height: 1, color: Color(0xFFF1F5F9)),
      );
}
