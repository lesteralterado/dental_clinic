import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class CheckAuthStatus extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  const LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class LogoutRequested extends AuthEvent {}

class UpdateUserProfile extends AuthEvent {
  final String userId;
  final String name;
  const UpdateUserProfile({required this.userId, required this.name});

  @override
  List<Object?> get props => [userId, name];
}

class ChangePassword extends AuthEvent {
  final String currentPassword;
  final String newPassword;
  const ChangePassword({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

// States
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserModel user;
  const Authenticated(this.user);
  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FlutterSecureStorage _storage;
  final AuthRepository _authRepository;

  AuthBloc({
    required AuthRepository authRepository,
    FlutterSecureStorage? storage,
  })  : _authRepository = authRepository,
        _storage = storage ?? const FlutterSecureStorage(),
        super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<UpdateUserProfile>(_onUpdateUserProfile);
    on<ChangePassword>(_onChangePassword);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final isAuthenticated = await _authRepository.isAuthenticated();
      if (isAuthenticated) {
        // Try to get current user from API
        final user = await _authRepository.getCurrentUser();
        if (user != null) {
          emit(Authenticated(user));
        } else {
          // Token exists but user not found - clear tokens
          await _storage.delete(key: AppConstants.accessToken);
          await _storage.delete(key: AppConstants.refreshToken);
          emit(Unauthenticated());
        }
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await _authRepository.login(event.email, event.password);

      if (result.isSuccess && result.user != null) {
        emit(Authenticated(result.user!));
      } else {
        emit(AuthError(result.errorMessage ?? 'Invalid email or password'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
    emit(Unauthenticated());
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await _authRepository.updateUser(
        userId: event.userId,
        name: event.name,
      );

      if (result.isSuccess && result.user != null) {
        emit(Authenticated(result.user!));
      } else {
        emit(AuthError(result.errorMessage ?? 'Failed to update profile'));
        // Restore the original user state
        final currentState = state;
        if (currentState is Authenticated) {
          emit(Authenticated(currentState.user));
        }
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      final currentState = state;
      if (currentState is Authenticated) {
        emit(Authenticated(currentState.user));
      }
    }
  }

  Future<void> _onChangePassword(
    ChangePassword event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await _authRepository.changePassword(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      );

      if (result.isSuccess) {
        // Keep the current user state but emit success
        final currentState = state;
        if (currentState is Authenticated) {
          emit(Authenticated(currentState.user));
        } else {
          emit(Unauthenticated());
        }
      } else {
        emit(AuthError(result.errorMessage ?? 'Failed to change password'));
        final currentState = state;
        if (currentState is Authenticated) {
          emit(Authenticated(currentState.user));
        }
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      final currentState = state;
      if (currentState is Authenticated) {
        emit(Authenticated(currentState.user));
      }
    }
  }
}
