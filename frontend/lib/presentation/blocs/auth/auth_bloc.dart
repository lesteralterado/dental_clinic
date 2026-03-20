import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/mock_data_repository.dart';

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

  AuthBloc({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(),
        super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final token = await _storage.read(key: AppConstants.accessToken);
      if (token != null) {
        emit(Unauthenticated());
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
      // Use hardcoded authentication from MockDataRepository
      final mockRepo = MockDataRepository();
      final authData = mockRepo.authenticate(event.email, event.password);

      if (authData == null) {
        emit(const AuthError('Invalid email or password'));
        return;
      }

      // Create user from auth data
      final user = UserModel(
        id: authData['id'] as String,
        email: authData['email'] as String,
        name: authData['name'] as String,
        role: UserRole.fromString(authData['role'] as String),
        isActive: authData['isActive'] as bool,
        createdAt: DateTime.parse(authData['createdAt'] as String),
        updatedAt: DateTime.parse(authData['updatedAt'] as String),
      );

      // Save mock tokens
      await _storage.write(
        key: AppConstants.accessToken,
        value: authData['accessToken'] as String,
      );
      await _storage.write(
        key: AppConstants.refreshToken,
        value: authData['refreshToken'] as String,
      );
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _storage.delete(key: AppConstants.accessToken);
    await _storage.delete(key: AppConstants.refreshToken);
    emit(Unauthenticated());
  }
}
