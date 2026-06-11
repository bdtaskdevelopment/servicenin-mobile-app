import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../../../routes/app_pages.dart';
import '../controllers/account_controller.dart';
import '../widgets/profile_avatar.dart';

const _navy = Color(0xFF1E2A4A);
const _iconTile = Color(0xFFEEF0FB);
const _iconColor = Color(0xFF334155);

class AccountView extends GetView<AccountController> {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F6),
      body: GetBuilder<AccountController>(
        builder: (con) {
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              _ProfileHeader(con: con),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _MenuItem(
                      icon: Icons.person_outline_rounded,
                      title: 'View profile'.tr,
                      subtitle: 'Name, gender, blood group, address'.tr,
                      onTap: con.openProfile,
                    ),
                    const SizedBox(height: 14),
                    _MenuItem(
                      icon: Icons.access_time_rounded,
                      title: 'My activity'.tr,
                      subtitle: 'Bookings & requests across all services'.tr,
                      onTap: con.openActivity,
                    ),
                    const SizedBox(height: 14),
                    _MenuItem(
                      icon: Icons.notifications_none_rounded,
                      title: 'Language & settings'.tr,
                      subtitle: 'বাংলা / English · notifications',
                      onTap: con.openSettings,
                    ),
                    const SizedBox(height: 14),
                    _MenuItem(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'Help & support'.tr,
                      subtitle: 'FAQ · contact us'.tr,
                      onTap: () => Get.toNamed(Routes.INFORMATION),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: InkWell(
                  onTap: con.logout,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Text(
                      'Log out'.tr,
                      style: const TextStyle(
                        color: Color(0xFFDC2626),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'ServiceNin v3.0 · Bdtask Limited',
                  style: TextStyle(fontSize: 12, color: Color(0xFFB6C0CC)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}

// ── Navy profile header ─────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.con});
  final AccountController con;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          padding: const EdgeInsets.fromLTRB(20, 18, 16, 20),
          child: Column(
            children: [
              Row(
                children: [
                  ProfileAvatar(
                    photoUrl: con.photoUrl,
                    initial: con.initial,
                    size: 56,
                    radius: 16,
                    fontSize: 22,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: (con.loading && con.profile == null)
                        ? SnShimmer(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                SnBone(width: 150, height: 18, radius: 6),
                                SizedBox(height: 8),
                                SnBone(width: 110, height: 12, radius: 6),
                                SizedBox(height: 12),
                                SnBone(width: 70, height: 22, radius: 20),
                              ],
                            ),
                          )
                        : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          con.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          con.maskedPhone,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _BloodPill(group: con.bloodGroup),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(Icons.verified_user_outlined,
                        size: 18, color: Colors.white.withValues(alpha: 0.9)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'One ServiceNin ID powers all 12 services — no separate logins.'.tr,
                        style: TextStyle(
                            fontSize: 12.5,
                            height: 1.4,
                            color: Colors.white.withValues(alpha: 0.9)),
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

class _BloodPill extends StatelessWidget {
  const _BloodPill({required this.group});
  final String group;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text('${'Blood'.tr} $group',
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white)),
    );
  }
}

// ── Menu item ───────────────────────────────────────────────────────
class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _iconTile,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: _iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                        fontSize: 12.5, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_right_rounded,
                color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}
