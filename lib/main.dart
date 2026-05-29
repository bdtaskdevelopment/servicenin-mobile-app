// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/providers.dart';
import 'app/router.dart';
import 'core/theme/app_theme.dart';

void main() => runApp(const ProviderScope(child: ServiceNinApp()));

class ServiceNinApp extends ConsumerWidget {
  const ServiceNinApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Rebuild router when auth state changes so redirects re-evaluate.
    ref.watch(authControllerProvider);
    final router = buildRouter(ref);
    return MaterialApp.router(
      title: 'ServiceNin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: router,
    );
  }
}
