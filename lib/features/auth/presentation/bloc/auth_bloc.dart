import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/check_auth_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../data/models/update_profile_params.dart';

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
  }) : _loginUseCase = loginUseCase,
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
    on<AuthUpdateProfileStarted>(_onUpdateProfileStarted);
  }

  /// Handle login event
  Future<void> _onLoginStarted(
    AuthLoginStarted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final params = LoginParams(email: event.email, password: event.password);

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

    await result.fold((failure) async => emit(const AuthUnauthenticated()), (
      isLoggedIn,
    ) async {
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
    });
  }

  /// Handle reset event
  void _onResetRequested(AuthResetRequested event, Emitter<AuthState> emit) {
    emit(const AuthInitial());
  }

  // --- Update User Profile ---
  Future<void> _onUpdateProfileStarted(
    AuthUpdateProfileStarted event,
    Emitter<AuthState> emit,
  ) async {
    // 1. Lấy thông tin user hiện tại (nếu đang đăng nhập)
    final currentUser = (state is AuthAuthenticated)
        ? (state as AuthAuthenticated).user
        : (state is AuthSuccess ? (state as AuthSuccess).user : null);

    if (currentUser == null) {
      emit(const AuthFailure(message: "User not found"));
      return;
    }

    // 2. Emit trạng thái Loading
    emit(const AuthLoading());

    try {
      // 3. GIẢ LẬP GỌI API (Vì bạn chưa có API thật cho update)
      // Sau này bạn sẽ thay đoạn này bằng: await _updateProfileUseCase(event.params);
      await Future.delayed(const Duration(seconds: 2));

      // 4. Tạo user mới với thông tin đã cập nhật
      // Lưu ý: Logic này chỉ cập nhật ở Client để hiển thị ngay.
      // Thực tế server sẽ trả về user mới nhất.
      final updatedUser = currentUser.copyWith(
        fullName: event.params.fullName?.isNotEmpty == true
            ? event.params.fullName
            : currentUser.fullName,
        phone: event.params.phone?.isNotEmpty == true
            ? event.params.phone
            : currentUser.phone,
        address: event.params.address?.isNotEmpty == true
            ? event.params.address
            : currentUser.address,
        // avatarUrl: ... xử lý logic ảnh nếu server trả về link ảnh mới
      );

      // 5. Báo thành công và cập nhật lại State
      emit(
        AuthSuccess(user: updatedUser),
      ); // Để UI hiển thị SnackBar thành công

      // Quan trọng: Phải emit lại AuthAuthenticated để app giữ trạng thái đăng nhập
      emit(AuthAuthenticated(user: updatedUser));
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
      // Nếu lỗi, quay lại trạng thái đăng nhập cũ để không bị văng ra ngoài
      emit(AuthAuthenticated(user: currentUser));
    }
  }

  // ----------------------------------------
}
