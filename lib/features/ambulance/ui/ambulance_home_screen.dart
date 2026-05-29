// lib/features/ambulance/ui/ambulance_home_screen.dart
// Worked example: a module screen wired to its repository (types + availability).
// Use this as the pattern for the other modules' screens (built from the prototypes).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/repositories.dart';
import '../../../core/theme/app_theme.dart';
import '../data/ambulance_api.dart';

final _typesProvider = FutureProvider.autoDispose<List<AmbType>>((ref) => ref.watch(ambulanceRepo).types());

class AmbulanceHomeScreen extends ConsumerWidget {
  const AmbulanceHomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final types = ref.watch(_typesProvider);
    return Scaffold(
      backgroundColor: AppColors.surfaceDim,
      appBar: AppBar(title: const Text('Ambulance')),
      body: types.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _Error(onRetry: () => ref.invalidate(_typesProvider)),
        data: (list) => ListView(padding: const EdgeInsets.all(16), children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFB91C1C)])),
            child: Row(children: [
              const Icon(Icons.local_hospital, color: Colors.white, size: 36),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('EMERGENCY · 999', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w800)),
                Text('Call Ambulance Now', style: AppTheme.bn(const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800))),
              ])),
            ]),
          ),
          const SizedBox(height: 20),
          const Text('Choose ambulance type', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...list.map((t) => Card(
                elevation: 0, margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: Color(0xFFE7E8EC))),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: AppColors.navy.withOpacity(0.1), child: const Icon(Icons.local_hospital, color: AppColors.navy)),
                  title: Text(t.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(t.description),
                  trailing: Text('৳${t.baseFare}', style: const TextStyle(fontWeight: FontWeight.w800)),
                ),
              )),
        ]),
      ),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Could not load ambulance types.'),
          const SizedBox(height: 8),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ]),
      );
}
