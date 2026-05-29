// lib/core/config/env.dart
//
// Build-time configuration. Override per environment with --dart-define:
//   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
//
// Localhost reachability (your API runs on localhost:8080):
//   • Android emulator   -> http://10.0.2.2:8080
//   • iOS simulator      -> http://localhost:8080
//   • Physical device    -> http://<your-LAN-IP>:8080  (same Wi-Fi)
//   • Staging / prod      -> https://api.servicenin... (set via --dart-define)
class Env {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  static const String apiPrefix = '/api/v1';

  /// Full REST base, e.g. http://10.0.2.2:8080/api/v1
  static String get apiRoot => '$apiBaseUrl$apiPrefix';

  /// Enforce HTTPS in release builds (allow http only for local dev).
  static const bool isProd = bool.fromEnvironment('dart.vm.product');

  /// Network timeouts.
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
}
