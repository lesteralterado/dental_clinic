import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/user_model.dart';
import '../models/notification_settings.dart';
import 'mock_data_repository.dart';

/// Authentication repository - handles login, logout, and registration
/// Uses mock credentials for predefined users, falls back to Supabase for others
class AuthRepository {
  final ApiClient _apiClient;
  final MockDataRepository _mockDataRepository;

  AuthRepository(
      {required ApiClient apiClient, MockDataRepository? mockDataRepository})
      : _apiClient = apiClient,
        _mockDataRepository = mockDataRepository ?? MockDataRepository();

  /// Login with email and password
  /// First checks mock credentials, then falls back to Supabase Auth
  Future<AuthResult> login(String email, String password) async {
    // First, check against mock credentials
    final mockUser = _mockDataRepository.authenticate(email, password);
    if (mockUser != null) {
      final user = UserModel(
        id: mockUser['id'] as String,
        email: mockUser['email'] as String,
        name: mockUser['name'] as String,
        role: UserRole.fromString(mockUser['role'] as String),
        isActive: mockUser['isActive'] as bool,
        createdAt: DateTime.parse(mockUser['createdAt'] as String),
        updatedAt: DateTime.parse(mockUser['updatedAt'] as String),
      );

      // Set mock tokens
      await _apiClient.setAccessToken(mockUser['accessToken'] as String);
      await _apiClient.setRefreshToken(mockUser['refreshToken'] as String);

      return AuthResult.success(user);
    }

    // Fall back to Supabase Auth for non-mock users
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

  /// Update user profile (name)
  Future<AuthResult> updateUser({required String userId, String? name}) async {
    try {
      // Check if using mock mode
      final token = await _apiClient.getAccessToken();
      if (token != null && _mockDataRepository.isMockToken(token)) {
        // Update mock user - return success with updated user
        final success = _mockDataRepository.updateUserName(userId, name ?? '');
        if (success) {
          final mockUser = _mockDataRepository.getUserById(userId);
          if (mockUser != null) {
            final updatedUser = UserModel(
              id: mockUser['id'] as String,
              email: mockUser['email'] as String,
              name: mockUser['name'] as String,
              role: UserRole.fromString(mockUser['role'] as String),
              isActive: mockUser['isActive'] as bool,
              createdAt: DateTime.parse(mockUser['createdAt'] as String),
              updatedAt: DateTime.now(),
            );
            return AuthResult.success(updatedUser);
          }
        }
        return AuthResult.failure('Failed to update user');
      }

      // Real backend update via Supabase
      final response = await _apiClient.patch(
        '${ApiConstants.users}?id=eq.$userId',
        data: name != null ? {'name': name} : {},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Fetch updated user
        final userResponse = await _apiClient.get(
          '${ApiConstants.users}?id=eq.$userId',
        );

        if (userResponse.statusCode == 200 &&
            userResponse.data != null &&
            (userResponse.data as List).isNotEmpty) {
          final userData = (userResponse.data as List).first;
          final updatedUser = UserModel.fromJson(userData);
          return AuthResult.success(updatedUser);
        }
        return AuthResult.failure('Failed to fetch updated user');
      }
      return AuthResult.failure('Failed to update user profile');
    } on DioException catch (e) {
      final message =
          e.response?.data?['msg'] ?? 'Failed to update user profile';
      return AuthResult.failure(message);
    } catch (e) {
      return AuthResult.failure('An error occurred: $e');
    }
  }

  /// Change password
  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // Check if using mock mode
      final token = await _apiClient.getAccessToken();
      if (token != null && _mockDataRepository.isMockToken(token)) {
        // Mock mode - simulate success
        return AuthResult.success(UserModel(
          id: 'mock-user',
          email: 'mock@example.com',
          name: 'Mock User',
          role: UserRole.doctor,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      }

      // Real backend update via Supabase Auth
      final response = await _apiClient.put(
        ApiConstants.userProfile,
        data: {'password': newPassword},
      );

      if (response.statusCode == 200) {
        return AuthResult.success(UserModel(
          id: 'user',
          email: 'user@example.com',
          name: 'User',
          role: UserRole.doctor,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      }
      return AuthResult.failure('Failed to change password');
    } on DioException catch (e) {
      final message = e.response?.data?['msg'] ??
          e.response?.data?['error_description'] ??
          'Failed to change password';
      return AuthResult.failure(message);
    } catch (e) {
      return AuthResult.failure('An error occurred: $e');
    }
  }

  /// Get notification settings
  Future<NotificationSettings> getNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool('notification_enabled') ?? true;
      final sound = prefs.getBool('notification_sound') ?? true;
      final vibration = prefs.getBool('notification_vibration') ?? true;
      return NotificationSettings(
        enabled: enabled,
        sound: sound,
        vibration: vibration,
      );
    } catch (e) {
      return const NotificationSettings();
    }
  }

  /// Save notification settings
  Future<void> saveNotificationSettings(NotificationSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_enabled', settings.enabled);
    await prefs.setBool('notification_sound', settings.sound);
    await prefs.setBool('notification_vibration', settings.vibration);
  }

  /// Sync data with backend (placeholder for real sync functionality)
  Future<bool> syncData() async {
    try {
      // Check if using mock mode
      final token = await _apiClient.getAccessToken();
      if (token != null && _mockDataRepository.isMockToken(token)) {
        // Simulate sync delay
        await Future.delayed(const Duration(seconds: 2));
        return true;
      }

      // Real sync - fetch latest data
      // This would typically sync patients, appointments, etc.
      final response = await _apiClient.get(ApiConstants.patients);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
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
