import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/account_controller.dart';
import '../widgets/profile_avatar.dart';

const _navy = Color(0xFF1E2A4A);
const _tileSel = Color(0xFFE3E7F5);

class EditProfileView extends GetView<AccountController> {
  const EditProfileView({super.key});

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
                padding: const EdgeInsets.fromLTRB(8, 6, 16, 4),
                child: Row(
                  children: [
                    IconButton(
                      splashRadius: 22,
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 20, color: Color(0xFF1A1A1A)),
                    ),
                    Text('Edit profile'.tr,
                        style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A))),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  children: [
                    // Avatar with camera badge
                    Center(
                      child: GestureDetector(
                        onTap: con.pickAndUploadPhoto,
                        child: Stack(
                          children: [
                            ProfileAvatar(
                              photoUrl: con.photoUrl,
                              initial: con.initial,
                              size: 84,
                              radius: 24,
                              background: const Color(0xFFE3E7F5),
                              foreground: _navy,
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                    color: _navy,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: const Color(0xFFF1F3F6),
                                        width: 2.5)),
                                child: con.uploadingPhoto
                                    ? const Padding(
                                        padding: EdgeInsets.all(6),
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white),
                                      )
                                    : const Icon(Icons.photo_camera_outlined,
                                        color: Colors.white, size: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Phone (login) verified card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(14)),
                      child: Row(
                        children: [
                          const Icon(Icons.call_outlined,
                              size: 20, color: Color(0xFF334155)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('PHONE (LOGIN)'.tr,
                                    style: const TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF94A3B8),
                                        letterSpacing: 0.6)),
                                const SizedBox(height: 2),
                                Text(con.maskedPhone,
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A))),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(20)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.circle,
                                    size: 7, color: Color(0xFF16A34A)),
                                const SizedBox(width: 5),
                                Text('Verified'.tr,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF15803D))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _InputCard(label: 'FULL NAME'.tr, controller: con.nameCtrl),
                    const SizedBox(height: 14),
                    _InputCard(
                        label: 'EMAIL'.tr,
                        controller: con.emailCtrl,
                        keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 16),
                    _Label('GENDER'.tr),
                    const SizedBox(height: 10),
                    Row(
                      children: List.generate(con.genders.length, (i) {
                        final g = con.genders[i];
                        final sel = con.gender == g;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                                right: i == con.genders.length - 1 ? 0 : 10),
                            child: GestureDetector(
                              onTap: () => con.setGender(g),
                              child: Container(
                                height: 50,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: sel ? _tileSel : AppColors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: sel
                                          ? _navy
                                          : const Color(0xFFE2E8F0),
                                      width: sel ? 1.6 : 1.2),
                                ),
                                child: Text(g,
                                    style: TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w700,
                                        color: sel
                                            ? _navy
                                            : const Color(0xFF334155))),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    _Label('BLOOD GROUP'.tr),
                    const SizedBox(height: 10),
                    GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.7,
                      children: con.bloodGroups.map((b) {
                        final sel = con.bloodGroup == b;
                        return GestureDetector(
                          onTap: () => con.setBloodGroup(b),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: sel ? _navy : AppColors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: sel
                                      ? _navy
                                      : const Color(0xFFE2E8F0),
                                  width: sel ? 1.6 : 1.2),
                            ),
                            child: Text(b,
                                style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                    color: sel
                                        ? Colors.white
                                        : const Color(0xFF0F172A))),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    _Label('ADDRESS'.tr),
                    const SizedBox(height: 10),
                    _InputCard(
                        label: null,
                        controller: con.addressCtrl,
                        maxLines: 2),
                  ],
                ),
              ),
              // Save
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: con.saving ? null : con.saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _navy,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: _navy.withValues(alpha: 0.6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: con.saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: Colors.white),
                          )
                        : Text('Save changes'.tr,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w800)),
                  ),
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

class _InputCard extends StatelessWidget {
  const _InputCard({
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.keyboardType,
  });
  final String? label;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType? keyboardType;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      decoration: BoxDecoration(
          color: AppColors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Text(label!,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF94A3B8),
                    letterSpacing: 0.6)),
          ],
          TextField(
            maxLines: maxLines,
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A)),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }
}
