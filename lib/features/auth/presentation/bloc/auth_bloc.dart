import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/check_auth_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Authentication BLoC - handles authentication state management
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final CheckAuthUseCase _checkAuthUseCase;
  final AuthRepository _authRepository;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required CheckAuthUseCase checkAuthUseCase,
    required AuthRepository authRepository,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _logoutUseCase = logoutUseCase,
        _checkAuthUseCase = checkAuthUseCase,
        _authRepository = authRepository,
        super(const AuthInitial()) {
    on<AuthLoginStarted>(_onLoginStarted);
    on<AuthRegisterStarted>(_onRegisterStarted);
    on<AuthLogoutStarted>(_onLogoutStarted);
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthResetRequested>(_onResetRequested);
  }

  /// Handle login event
  Future<void> _onLoginStarted(
    AuthLoginStarted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final params = LoginParams(
      email: event.email,
      password: event.password,
    );

    final result = await _loginUseCase(params);

    result.fold(
      (failure) => emit(AuthFailure(message: failure.message)),
      (user) => emit(AuthSuccess(user: user)),
    );
  }

  /// Handle register event
  Future<void> _onRegisterStarted(
    AuthRegisterStarted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _registerUseCase(event.registerParams);

    result.fold(
      (failure) => emit(AuthFailure(message: failure.message)),
      (user) => emit(AuthSuccess(user: user)),
    );
  }

  /// Handle logout event
  Future<void> _onLogoutStarted(
    AuthLogoutStarted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _logoutUseCase(const NoParams());

    result.fold(
      (failure) => emit(AuthFailure(message: failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  /// Handle check authentication status event
  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _checkAuthUseCase(const NoParams());

    await result.fold(
      (failure) async => emit(const AuthUnauthenticated()),
      (isLoggedIn) async {
        if (isLoggedIn) {
          // Try to get user profile
          final profileResult = await _authRepository.getProfile();
          profileResult.fold(
            (failure) => emit(const AuthUnauthenticated()),
            (user) => emit(AuthAuthenticated(user: user)),
          );
        } else {
          emit(const AuthUnauthenticated());
        }
      },
    );
  }

  /// Handle reset event
  void _onResetRequested(
    AuthResetRequested event,
    Emitter<AuthState> emit,
  ) {
    emit(const AuthInitial());
  }
}

