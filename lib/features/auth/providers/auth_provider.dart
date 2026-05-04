import 'package:flutter_riverpod/flutter_riverpod.dart';

// Auth state
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final String? userId;
  final String? displayName;
  final String? email;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.userId,
    this.displayName,
    this.email,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? userId,
    String? displayName,
    String? email,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      error: error ?? this.error,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState(status: AuthStatus.unauthenticated));

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    await Future.delayed(const Duration(milliseconds: 1200));
    // Mock auth — replace with Firebase Auth
    if (email.isNotEmpty && password.length >= 6) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        userId: 'mock_user_001',
        displayName: email.split('@').first,
        email: email,
      );
    } else {
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'Invalid email or password.',
      );
    }
  }

  Future<void> signUp(String name, String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (email.isNotEmpty && password.length >= 6 && name.isNotEmpty) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        userId: 'mock_user_001',
        displayName: name,
        email: email,
      );
    } else {
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'Please fill all fields correctly.',
      );
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading);
    await Future.delayed(const Duration(milliseconds: 1000));
    state = state.copyWith(
      status: AuthStatus.authenticated,
      userId: 'google_user_001',
      displayName: 'Google User',
      email: 'user@gmail.com',
    );
  }

  Future<void> loginAsGuest() async {
    state = state.copyWith(status: AuthStatus.loading);
    await Future.delayed(const Duration(milliseconds: 800));
    state = state.copyWith(
      status: AuthStatus.authenticated,
      userId: 'guest_user',
      displayName: 'Guest User',
      email: 'guest@noor.app',
    );
  }

  void logout() {
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void clearError() {
    state = state.copyWith(status: AuthStatus.unauthenticated, error: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
