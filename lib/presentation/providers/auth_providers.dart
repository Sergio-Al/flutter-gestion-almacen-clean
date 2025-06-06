import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_almacen_stock/domain/usecases/auth/check_auth_status_usecase.dart';
import 'package:gestion_almacen_stock/domain/usecases/auth/get_current_user_usecase.dart';
import 'package:gestion_almacen_stock/domain/usecases/auth/login_usecase.dart';
import 'package:gestion_almacen_stock/domain/usecases/auth/logout_usecase.dart';
import 'package:gestion_almacen_stock/domain/usecases/auth/update_user_usecase.dart';
import 'package:gestion_almacen_stock/domain/usecases/auth/change_password_usecase.dart';
import '../../core/providers/usecase_providers.dart';
import '../../domain/entities/user.dart';

// Estado de autenticación
class AuthState {
  final bool isLoading;
  final User? user;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    bool? isLoading,
    User? user,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

// Notifier para manejar el estado de autenticación
class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final CheckAuthStatusUseCase _checkAuthStatusUseCase;
  final UpdateUserUseCase _updateUserUseCase;
  final ChangePasswordUseCase _changePasswordUseCase;

  AuthNotifier(
    this._loginUseCase,
    this._logoutUseCase,
    this._getCurrentUserUseCase,
    this._checkAuthStatusUseCase,
    this._updateUserUseCase,
    this._changePasswordUseCase,
  ) : super(const AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final isAuthenticated = await _checkAuthStatusUseCase();
      if (isAuthenticated) {
        final user = await _getCurrentUserUseCase();
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: user,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          user: null,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isAuthenticated: false,
        user: null,
      );
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await _loginUseCase(email: email, password: password);
      state = state.copyWith(
        isLoading: false,
        user: user,
        isAuthenticated: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isAuthenticated: false,
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      await _logoutUseCase();
      state = const AuthState(isAuthenticated: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> updateUser({
    required String name,
    required String email,
  }) async {
    if (state.user == null) {
      state = state.copyWith(error: 'No hay usuario autenticado');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedUser = await _updateUserUseCase(
        id: state.user!.id,
        name: name,
        email: email,
      );
      
      state = state.copyWith(
        isLoading: false,
        user: updatedUser,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _changePasswordUseCase(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

// Provider para el notifier de autenticación
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final loginUseCase = ref.watch(loginUseCaseProvider);
  final logoutUseCase = ref.watch(logoutUseCaseProvider);
  final getCurrentUserUseCase = ref.watch(getCurrentUserUseCaseProvider);
  final checkAuthStatusUseCase = ref.watch(checkAuthStatusUseCaseProvider);
  final updateUserUseCase = ref.watch(updateUserUseCaseProvider);
  final changePasswordUseCase = ref.watch(changePasswordUseCaseProvider);
  
  return AuthNotifier(
    loginUseCase,
    logoutUseCase,
    getCurrentUserUseCase,
    checkAuthStatusUseCase,
    updateUserUseCase,
    changePasswordUseCase,
  );
});

// Provider para obtener solo el usuario actual
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

// Provider para verificar si está autenticado
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});
