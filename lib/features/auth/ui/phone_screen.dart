// lib/features/auth/ui/phone_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/providers.dart';
import '../../../core/theme/app_theme.dart';

class PhoneScreen extends ConsumerStatefulWidget {
  const PhoneScreen({super.key});
  @override
  ConsumerState<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends ConsumerState<PhoneScreen> {
  final _c = TextEditingController();
  bool _busy = false;
  String? _err;

  bool get _valid => _c.text.trim().length == 10;

  Future<void> _submit() async {
    setState(() { _busy = true; _err = null; });
    final phone = '+880${_c.text.trim()}';
    try {
      await ref.read(authRepositoryProvider).requestOtp(phone);
      if (mounted) context.go('/otp?phone=${Uri.encodeComponent(phone)}');
    } catch (e) {
      setState(() => _err = 'Could not send OTP. Check your connection.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('আপনার ফোন নম্বর দিন', style: AppTheme.bn(const TextStyle(fontSize: 24, fontWeight: FontWeight.w700))),
          const SizedBox(height: 8),
          Text('আমরা একটি OTP পাঠাব যাচাইয়ের জন্য।', style: AppTheme.bn(const TextStyle(fontSize: 14, color: AppColors.ink500))),
          const SizedBox(height: 36),
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              decoration: BoxDecoration(border: Border.all(color: AppColors.ink200), borderRadius: BorderRadius.circular(12)),
              child: const Text('🇧🇩 +880', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _c, keyboardType: TextInputType.phone, maxLength: 10,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(counterText: '', hintText: '1XXXXXXXXX', border: OutlineInputBorder()),
              ),
            ),
          ]),
          if (_err != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_err!, style: const TextStyle(color: AppColors.danger))),
          const Spacer(),
          FilledButton(
            onPressed: _valid && !_busy ? _submit : null,
            child: _busy ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text('Registration করুন', style: AppTheme.bn(const TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: Colors.white))),
          ),
        ]),
      ),
    );
  }
}
