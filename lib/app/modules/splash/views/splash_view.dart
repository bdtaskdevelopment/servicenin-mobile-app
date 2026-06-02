import 'package:animate_do/animate_do.dart';
import 'package:servicenin/app/core/values/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/splash_controller.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppColors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return GetBuilder<SplashController>(
      builder: (splashCon) {
        return Scaffold(
          backgroundColor: AppColors.white,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.white,
                  AppColors.white,
                  Color(0xFFFFE8D8), // soft brand-orange tint
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // ── Centered logo + title block ───────────────
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // App logo — fades in & slides from the left
                          FadeInLeft(
                            duration: const Duration(milliseconds: 800),
                            child: Container(
                              width: 132,
                              height: 132,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(32),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.brandOrange
                                        .withValues(alpha: 0.18),
                                    blurRadius: 32,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/image/service_logo.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 26),
                          // Name + tagline — fade in & slide from the right
                          FadeInRight(
                            duration: const Duration(milliseconds: 800),
                            delay: const Duration(milliseconds: 250),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  'ServiceNin',
                                  style: TextStyle(
                                    color: Color(0xFF0F172A),
                                    fontSize: 30,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'আপনার শহর, আপনার সেবা',
                                  style: TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // ── Bottom indicator + version ────────────────
                  FadeInUp(
                    duration: const Duration(milliseconds: 900),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'v1.0.0',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
