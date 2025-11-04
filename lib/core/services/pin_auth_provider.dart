import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pin_auth_service.dart';

/// ==============================
/// 🔐 PIN Authentication Provider
/// ==============================

/// Provider for PinAuthService
final pinAuthServiceProvider = Provider<PinAuthService>((ref) {
  throw UnimplementedError('PinAuthService must be initialized in main.dart');
});

/// Provider to check if PIN is set
final isPinSetProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(pinAuthServiceProvider);
  return await service.isPinSet();
});

/// Provider for authentication state
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>(
  (ref) => AuthStateNotifier(ref.watch(pinAuthServiceProvider)),
);

/// Authentication state
enum AuthState {
  unauthenticated,
  authenticated,
  locked,
}

/// Authentication state notifier
class AuthStateNotifier extends StateNotifier<AuthState> {
  final PinAuthService _pinAuthService;

  AuthStateNotifier(this._pinAuthService) : super(AuthState.unauthenticated);

  /// Authenticate with PIN
  Future<bool> authenticate(String pin) async {
    final isValid = await _pinAuthService.verifyPin(pin);
    if (isValid) {
      state = AuthState.authenticated;
      return true;
    } else {
      final isLockedOut = await _pinAuthService.getRemainingAttempts() <= 0;
      if (isLockedOut) {
        state = AuthState.locked;
      }
      return false;
    }
  }

  /// Lock the app
  void lock() {
    state = AuthState.unauthenticated;
  }

  /// Unlock the app
  void unlock() {
    state = AuthState.authenticated;
  }

  /// Check if authenticated
  bool get isAuthenticated => state == AuthState.authenticated;
}
