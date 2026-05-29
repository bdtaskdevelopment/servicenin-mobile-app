// lib/features/dashboard/ui/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/providers.dart';
import '../../../app/modules.dart';
import '../../../core/theme/app_theme.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final services = kModules.where((m) => m.id != 'account').toList();
    return Scaffold(
      backgroundColor: AppColors.surfaceDim,
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.orange, borderRadius: BorderRadius.circular(8)),
              alignment: Alignment.center, child: const Text('SN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
          const SizedBox(width: 10),
          const Text('ServiceNin', style: TextStyle(fontWeight: FontWeight.w800)),
        ]),
        actions: [IconButton(onPressed: () => context.push('/account'), icon: const Icon(Icons.person_outline))],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text('স্বাগতম, ${user?.fullName ?? ''}', style: AppTheme.bn(const TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
        const SizedBox(height: 4),
        const Text('আপনার শহর, আপনার সেবা', style: TextStyle(color: AppColors.ink500, fontSize: 12)),
        const SizedBox(height: 18),
        const Text('All Services', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 4, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.82,
          children: services.map((m) => _Tile(m)).toList(),
        ),
      ]),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.m);
  final ModuleDef m;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => context.push(m.route),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE7E8EC))),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 42, height: 42, decoration: BoxDecoration(color: m.accent.withOpacity(0.12), borderRadius: BorderRadius.circular(13)),
              child: Icon(m.icon, color: m.accent, size: 22)),
          const SizedBox(height: 8),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(m.labelBn, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: AppTheme.bn(const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700)))),
        ]),
      ),
    );
  }
}
