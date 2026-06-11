import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/account_controller.dart';

const _red = Color(0xFFDC2626);

class DeleteAccountView extends GetView<AccountController> {
  const DeleteAccountView({super.key});

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
                    Text('Delete account'.tr,
                        style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A))),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  children: [
                    Center(
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(20)),
                        child: const Icon(Icons.delete_outline_rounded,
                            color: _red, size: 34),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text('Delete your ServiceNin ID?'.tr,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                          'Deleting is permanent. You\'ll lose access to every service tied to this account.'.tr,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 13.5,
                              height: 1.45,
                              color: Color(0xFF64748B))),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        children: [
                          _LossRow('Your profile, NID link & blood group'.tr),
                          const _LossDivider(),
                          _LossRow('All bookings & activity across 12 modules'.tr),
                          const _LossDivider(),
                          _LossRow('Saved family members & addresses'.tr),
                          const _LossDivider(),
                          _LossRow('This action cannot be undone'.tr),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text('TYPE DELETE TO CONFIRM'.tr,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF94A3B8),
                            letterSpacing: 0.6)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(14)),
                      child: TextField(
                        controller: con.deleteInput,
                        onChanged: con.onDeleteChanged,
                        textCapitalization: TextCapitalization.characters,
                        style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            color: Color(0xFF0F172A)),
                        decoration: const InputDecoration(
                          hintText: 'DELETE',
                          hintStyle: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                              color: Color(0xFFB8C0CC)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Bottom actions
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppColors.white,
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text('Cancel'.tr,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF334155))),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          onPressed: con.canDelete ? con.deleteAccount : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _red,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(0xFFF1A8A8),
                            disabledForegroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text('Delete account'.tr,
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w800)),
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

class _LossRow extends StatelessWidget {
  const _LossRow(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          const Icon(Icons.close_rounded, size: 18, color: _red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155))),
          ),
        ],
      ),
    );
  }
}

class _LossDivider extends StatelessWidget {
  const _LossDivider();
  @override
  Widget build(BuildContext context) => const Divider(
      height: 1, color: Color(0xFFF1F5F9));
}
