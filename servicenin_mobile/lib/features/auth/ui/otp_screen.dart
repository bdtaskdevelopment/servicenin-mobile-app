// lib/features/auth/ui/otp_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/providers.dart';
import '../../../core/theme/app_theme.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, required this.phone});
  final String phone;
  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _c = TextEditingController();
  bool _busy = false;
  String? _err;

  Future<void> _verify() async {
    setState(() { _busy = true; _err = null; });
    try {
      await ref.read(authControllerProvider.notifier).verifyOtp(phone: widget.phone, otp: _c.text.trim());
      // Router redirect handles navigation to /dashboard on authenticated state.
    } catch (e) {
      setState(() => _err = 'Invalid or expired code. Try again.');
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
          Text('OTP লিখুন', style: AppTheme.bn(const TextStyle(fontSize: 24, fontWeight: FontWeight.w700))),
          const SizedBox(height: 8),
          Text('${widget.phone} নম্বরে একটি 6-সংখ্যার কোড পাঠানো হয়েছে।',
              style: AppTheme.bn(const TextStyle(fontSize: 14, color: AppColors.ink500))),
          const SizedBox(height: 32),
          TextField(
            controller: _c, keyboardType: TextInputType.number, maxLength: 6,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: 12),
            decoration: const InputDecoration(counterText: '', hintText: '••••••', border: OutlineInputBorder()),
            onChanged: (_) => setState(() {}),
          ),
          if (_err != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_err!, style: const TextStyle(color: AppColors.danger))),
          const Spacer(),
          FilledButton(
            onPressed: _c.text.trim().length == 6 && !_busy ? _verify : null,
            child: _busy ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text('যাচাই করুন', style: AppTheme.bn(const TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: Colors.white))),
          ),
        ]),
      ),
    );
  }
}
