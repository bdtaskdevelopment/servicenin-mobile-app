// lib/features/account/ui/account_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/providers.dart';
import '../../../core/theme/app_theme.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final initials = (user?.fullName ?? 'U').trim().isEmpty
        ? 'U'
        : (user!.fullName.trim().split(RegExp(r'\s+')).map((w) => w[0]).take(2).join());
    return Scaffold(
      backgroundColor: AppColors.surfaceDim,
      appBar: AppBar(title: const Text('Account')),
      body: ListView(children: [
        Container(
          color: AppColors.navy,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Row(children: [
            CircleAvatar(radius: 32, backgroundColor: Colors.white24, child: Text(initials.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22))),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(user?.fullName ?? '', style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800)),
              Text(user?.phone ?? '', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Wrap(spacing: 6, children: [
                if (user?.nidVerified ?? false) _chip('NID verified', AppColors.success),
                if ((user?.bloodGroup ?? '').isNotEmpty) _chip('Blood ${user!.bloodGroup}', Colors.white24),
              ]),
            ])),
          ]),
        ),
        const SizedBox(height: 12),
        _tile(context, Icons.person_outline, 'Edit profile', 'Name, gender, blood group, address', () => context.push('/account/edit')),
        _tile(context, Icons.history, 'My activity', 'Bookings & requests across services', null),
        _tile(context, Icons.language, 'Language & settings', 'বাংলা / English · notifications', null),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.all(16),
          child: OutlinedButton(
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, minimumSize: const Size.fromHeight(52)),
            child: const Text('Log out', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    );
  }

  Widget _chip(String t, Color c) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(999)),
        child: Text(t, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
      );

  Widget _tile(BuildContext c, IconData i, String t, String s, VoidCallback? onTap) => Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.ink100)),
        child: ListTile(
          leading: CircleAvatar(backgroundColor: AppColors.navy.withOpacity(0.1), child: Icon(i, color: AppColors.navy, size: 20)),
          title: Text(t, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          subtitle: Text(s, style: const TextStyle(fontSize: 11)),
          trailing: const Icon(Icons.chevron_right, color: AppColors.ink400),
          onTap: onTap,
        ),
      );
}
