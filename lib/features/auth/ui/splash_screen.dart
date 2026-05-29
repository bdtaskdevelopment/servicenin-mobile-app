// lib/features/auth/ui/splash_screen.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [AppColors.orange, AppColors.orangeDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 96, height: 96,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              alignment: Alignment.center,
              child: const Text('SN', style: TextStyle(color: AppColors.orangeDark, fontSize: 38, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 24),
            const Text('ServiceNin', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('আপনার শহর, আপনার সেবা', style: AppTheme.bn(const TextStyle(color: Colors.white, fontSize: 14))),
            const SizedBox(height: 28),
            const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
          ]),
        ),
      ),
    );
  }
}
