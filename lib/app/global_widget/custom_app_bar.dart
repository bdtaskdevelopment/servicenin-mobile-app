import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/values/app_colors.dart';

/// Lightweight app bar used across the auth flow: a white bar with a single
/// back chevron on the left and an optional centered/left title.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.title,
    this.showBack = true,
    this.onBack,
    this.centerTitle = false,
    this.actions,
    this.backgroundColor = AppColors.white,
  });

  final String? title;
  final bool showBack;
  final VoidCallback? onBack;
  final bool centerTitle;
  final List<Widget>? actions;
  final Color backgroundColor;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      surfaceTintColor: backgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: centerTitle,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      leading: showBack
          ? IconButton(
              splashRadius: 22,
              onPressed: onBack ?? () => Get.back(),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF1A1A1A),
                size: 20,
              ),
            )
          : null,
      title: title == null
          ? null
          : Text(
              title!,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
      actions: actions,
    );
  }
}
