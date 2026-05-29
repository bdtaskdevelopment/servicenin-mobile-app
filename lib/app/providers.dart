// lib/app/providers.dart
//
// Riverpod wiring: ApiClient -> AuthRepository -> AuthController.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/data/auth_models.dart';

/// Auth session state.
enum AuthStatus { unknown, unauthenticated, authenticated }

class AuthState {
  final AuthStatus status;
  final UserProfile? user;
  const AuthState(this.status, [this.user]);
}

final apiClientProvider = Provider<ApiClient>((ref) {
  // onLogout flips auth state -> router redirects to login.
  return ApiClient(onLogout: () => ref.read(authControllerProvider.notifier).forceLogout());
});

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(apiClientProvider).dio),
);

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) => AuthController(ref.watch(authRepositoryProvider)));

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repo) : super(const AuthState(AuthStatus.unknown)) {
    _bootstrap();
  }
  final AuthRepository _repo;

  Future<void> _bootstrap() async {
    if (await _repo.hasSession) {
      try {
        final user = await _repo.me();
        state = AuthState(AuthStatus.authenticated, user);
      } catch (_) {
        await _repo.logout();
        state = const AuthState(AuthStatus.unauthenticated);
      }
    } else {
      state = const AuthState(AuthStatus.unauthenticated);
    }
  }

  Future<void> verifyOtp({required String phone, required String otp}) async {
    await _repo.verifyOtp(phone: phone, otp: otp);
    final user = await _repo.me();
    state = AuthState(AuthStatus.authenticated, user);
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState(AuthStatus.unauthenticated);
  }

  void forceLogout() {
    _repo.logout();
    state = const AuthState(AuthStatus.unauthenticated);
  }
}
