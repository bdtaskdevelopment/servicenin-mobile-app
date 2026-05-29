// lib/app/router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers.dart';
import '../features/auth/ui/splash_screen.dart';
import '../features/auth/ui/phone_screen.dart';
import '../features/auth/ui/otp_screen.dart';
import '../features/dashboard/ui/dashboard_screen.dart';
import '../features/account/ui/account_screen.dart';
import '../features/account/ui/edit_profile_screen.dart';
import '../features/ambulance/ui/ambulance_home_screen.dart';
import '../features/_shared/module_scaffold.dart';

GoRouter buildRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final s = ref.read(authControllerProvider).status;
      final loc = state.matchedLocation;
      if (s == AuthStatus.unknown) return loc == '/splash' ? null : '/splash';
      final loggingIn = loc == '/phone' || loc.startsWith('/otp');
      if (s == AuthStatus.unauthenticated) return loggingIn ? null : '/phone';
      if (s == AuthStatus.authenticated && (loggingIn || loc == '/splash')) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/phone', builder: (_, __) => const PhoneScreen()),
      GoRoute(path: '/otp', builder: (_, st) => OtpScreen(phone: st.uri.queryParameters['phone'] ?? '')),
      GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
      GoRoute(path: '/account', builder: (_, __) => const AccountScreen()),
      GoRoute(path: '/account/edit', builder: (_, __) => const EditProfileScreen()),
      // Module routes — Ambulance is the worked example; the rest use the
      // repository-wired scaffold (build screens from the HTML prototypes).
      GoRoute(path: '/m/ambulance', builder: (_, __) => const AmbulanceHomeScreen()),
      GoRoute(path: '/m/blood', builder: (_, __) => const ModuleScaffold('blood')),
      GoRoute(path: '/m/healthcare', builder: (_, __) => const ModuleScaffold('healthcare')),
      GoRoute(path: '/m/services', builder: (_, __) => const ModuleScaffold('services')),
      GoRoute(path: '/m/physio', builder: (_, __) => const ModuleScaffold('physio')),
      GoRoute(path: '/m/matchmaking', builder: (_, __) => const ModuleScaffold('matchmaking')),
      GoRoute(path: '/m/jobs', builder: (_, __) => const ModuleScaffold('jobs')),
      GoRoute(path: '/m/education', builder: (_, __) => const ModuleScaffold('education')),
      GoRoute(path: '/m/nagarik', builder: (_, __) => const ModuleScaffold('nagarik')),
      GoRoute(path: '/m/info', builder: (_, __) => const ModuleScaffold('info')),
      GoRoute(path: '/m/funeral', builder: (_, __) => const ModuleScaffold('funeral')),
    ],
  );
}
