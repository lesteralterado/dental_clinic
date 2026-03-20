import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/user_model.dart';

/// Authentication repository - handles login, logout, and registration using Supabase
class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Login with email and password using Supabase Auth
  Future<AuthResult> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
        options: Options(headers: {
          ApiConstants.apikey: ApiConstants.supabaseKey,
        }),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Supabase returns access_token and refresh_token
        final accessToken = data['access_token'] as String?;
        final refreshToken = data['refresh_token'] as String?;

        if (accessToken != null) {
          await _apiClient.setAccessToken(accessToken);
          await _apiClient.setRefreshToken(refreshToken ?? accessToken);

          // Get user data - create from email since Supabase doesn't return full user object
          final user = UserModel(
            id: data['user']?['id'] ?? 'supabase-user',
            email: email,
            name: data['user']?['user_metadata']?['name'] ??
                email.split('@').first,
            role: UserRole.fromString(
                data['user']?['user_metadata']?['role'] ?? 'receptionist'),
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          return AuthResult.success(user);
        }
        return AuthResult.failure('Login failed - no token received');
      } else {
        return AuthResult.failure('Login failed');
      }
    } on DioException catch (e) {
      final message = e.response?.data['error_description'] ??
          e.response?.data['msg'] ??
          'Login failed';
      return AuthResult.failure(message);
    } catch (e) {
      return AuthResult.failure('An error occurred: $e');
    }
  }

  /// Register a new user using Supabase Auth
  Future<AuthResult> register({
    required String email,
    required String password,
    required String name,
    String role = 'receptionist',
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.register,
        data: {
          'email': email,
          'password': password,
          'data': {
            'name': name,
            'role': role,
          },
        },
        options: Options(headers: {
          ApiConstants.apikey: ApiConstants.supabaseKey,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Auto-login after registration
        return login(email, password);
      } else {
        return AuthResult.failure('Registration failed');
      }
    } on DioException catch (e) {
      final message =
          e.response?.data['error_description'] ?? 'Registration failed';
      return AuthResult.failure(message);
    } catch (e) {
      return AuthResult.failure('An error occurred: $e');
    }
  }

  /// Get current user profile from Supabase
  Future<UserModel?> getCurrentUser() async {
    try {
      final token = await _apiClient.getAccessToken();
      if (token != null) {
        // In a real app, you'd decode the JWT or fetch from /auth/v1/user
        // For now, we'll return a placeholder
        return UserModel(
          id: 'supabase-user',
          email: 'user@example.com',
          name: 'User',
          role: UserRole.receptionist,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Logout - clear tokens
  Future<void> logout() async {
    try {
      final token = await _apiClient.getAccessToken();
      if (token != null) {
        await _apiClient.post(
          ApiConstants.logout,
          options: Options(headers: {
            ApiConstants.apikey: ApiConstants.supabaseKey,
            ApiConstants.authorization: '${ApiConstants.bearer} $token',
          }),
        );
      }
    } catch (e) {
      // Ignore logout errors
    }
    await _apiClient.clearTokens();
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await _apiClient.isAuthenticated();
  }
}

/// Result class for authentication operations
class AuthResult {
  final bool isSuccess;
  final UserModel? user;
  final String? errorMessage;

  AuthResult._({
    required this.isSuccess,
    this.user,
    this.errorMessage,
  });

  factory AuthResult.success(UserModel user) {
    return AuthResult._(isSuccess: true, user: user);
  }

  factory AuthResult.failure(String message) {
    return AuthResult._(isSuccess: false, errorMessage: message);
  }
}
