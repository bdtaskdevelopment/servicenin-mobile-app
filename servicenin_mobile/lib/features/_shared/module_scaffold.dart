// lib/features/_shared/module_scaffold.dart
// Lightweight module landing used by routes whose full multi-screen UI is built
// from the matching HTML prototype. The data repository for each is already wired
// (see lib/app/repositories.dart) — drop the prototype screens in and call it.
import 'package:flutter/material.dart';
import '../../app/modules.dart';

class ModuleScaffold extends StatelessWidget {
  const ModuleScaffold(this.moduleId, {super.key});
  final String moduleId;
  @override
  Widget build(BuildContext context) {
    final m = kModules.firstWhere((x) => x.id == moduleId);
    return Scaffold(
      appBar: AppBar(title: Text(m.label)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 72, height: 72, decoration: BoxDecoration(color: m.accent.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                child: Icon(m.icon, color: m.accent, size: 36)),
            const SizedBox(height: 18),
            Text(m.label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Text('Repository wired to the ${m.label} API. Build the screens from the matching HTML prototype (${m.id} module) — data layer is ready in lib/app/repositories.dart.',
                textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF5B6471), height: 1.5)),
          ]),
        ),
      ),
    );
  }
}
