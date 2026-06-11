import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/account_controller.dart';
import '../widgets/profile_avatar.dart';

const _navy = Color(0xFF1E2A4A);
const _iconTile = Color(0xFFEEF0FB);
const _iconColor = Color(0xFF334155);

class ProfileView extends GetView<AccountController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F6),
      body: GetBuilder<AccountController>(
        builder: (con) => Column(
        children: [
          // Navy header
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_navy, Color(0xFF2A3A60)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 16, 22),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          splashRadius: 22,
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              size: 20, color: Colors.white),
                        ),
                        Text('Profile'.tr,
                            style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: con.pickAndUploadPhoto,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          ProfileAvatar(
                            photoUrl: con.photoUrl,
                            initial: con.initial,
                            size: 84,
                            radius: 24,
                          ),
                          if (con.uploadingPhoto)
                            const Positioned.fill(
                              child: Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.5, color: Colors.white),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(con.fullName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: (con.loading && con.profile == null)
                ? const _ProfileRowsSkeleton()
                : FadeInUp(
              from: 18,
              duration: const Duration(milliseconds: 350),
              child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 6)),
                    ],
                  ),
                  child: Column(
                    children: [
                      _Row(
                        icon: Icons.call_outlined,
                        label: 'PHONE (LOGIN)'.tr,
                        value: con.maskedPhone,
                        trailing: const _VerifiedPill(),
                      ),
                      const _Divider(),
                      _Row(
                        icon: Icons.chat_bubble_outline_rounded,
                        label: 'EMAIL'.tr,
                        value: con.email,
                      ),
                      const _Divider(),
                      _Row(
                        icon: Icons.person_outline_rounded,
                        label: 'GENDER'.tr,
                        value: con.gender,
                      ),
                      const _Divider(),
                      _Row(
                        icon: Icons.water_drop_outlined,
                        label: 'BLOOD GROUP'.tr,
                        value: con.bloodGroup,
                      ),
                      const _Divider(),
                      _Row(
                        icon: Icons.location_on_outlined,
                        label: 'ADDRESS'.tr,
                        value: con.address,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ),
          ),
          // Edit profile button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: con.openEditProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _navy,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Edit profile'.tr,
                    style:
                        const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class _ProfileRowsSkeleton extends StatelessWidget {
  const _ProfileRowsSkeleton();
  @override
  Widget build(BuildContext context) {
    return SnShimmer(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE8ECF1)),
            ),
            child: Column(
              children: List.generate(
                5,
                (_) => const Padding(
                  padding: EdgeInsets.all(14),
                  child: Row(
                    children: [
                      SnBone(width: 42, height: 42, radius: 12),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SnBone(width: 90, height: 10),
                            SizedBox(height: 8),
                            SnBone(width: 150, height: 13),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });
  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
                color: _iconTile, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: _iconColor, size: 21),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF94A3B8),
                        letterSpacing: 0.6)),
                const SizedBox(height: 3),
                Text(value,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A))),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}

class _VerifiedPill extends StatelessWidget {
  const _VerifiedPill();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: const Color(0xFFDCFCE7),
          borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.circle, size: 7, color: Color(0xFF16A34A)),
          const SizedBox(width: 5),
          Text('Verified'.tr,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF15803D))),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 14),
        child: Divider(height: 1, color: Color(0xFFF1F5F9)),
      );
}
