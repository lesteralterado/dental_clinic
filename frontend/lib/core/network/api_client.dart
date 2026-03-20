import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';

/// API Client using Dio with JWT authentication support
class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  bool _isRefreshing = false;

  ApiClient({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout:
            const Duration(milliseconds: ApiConstants.connectTimeout),
        receiveTimeout:
            const Duration(milliseconds: ApiConstants.receiveTimeout),
        headers: {
          ApiConstants.contentType: ApiConstants.applicationJson,
        },
      ),
    );

    _setupInterceptors();
  }

  Dio get dio => _dio;

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add Supabase API key header for all requests
          options.headers[ApiConstants.apikey] = ApiConstants.supabaseKey;

          // Add authorization header if token exists
          final token =
              await _secureStorage.read(key: AppConstants.accessToken);
          if (token != null && token.isNotEmpty) {
            options.headers[ApiConstants.authorization] =
                '${ApiConstants.bearer} $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Handle 401 errors - try to refresh token
          if (error.response?.statusCode == 401 && !_isRefreshing) {
            _isRefreshing = true;
            try {
              final refreshed = await _refreshToken();
              if (refreshed) {
                // Retry the request
                final opts = error.requestOptions;
                final token =
                    await _secureStorage.read(key: AppConstants.accessToken);
                opts.headers[ApiConstants.authorization] =
                    '${ApiConstants.bearer} $token';
                final response = await _dio.fetch(opts);
                _isRefreshing = false;
                return handler.resolve(response);
              }
            } catch (e) {
              _isRefreshing = false;
              // Clear tokens on refresh failure
              await _secureStorage.delete(key: AppConstants.accessToken);
              await _secureStorage.delete(key: AppConstants.refreshToken);
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken =
          await _secureStorage.read(key: AppConstants.refreshToken);
      if (refreshToken == null) return false;

      final response = await _dio.post(
        ApiConstants.refresh,
        data: {refreshToken: refreshToken},
        options: Options(headers: {}), // Don't send old token
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['accessToken'];
        await _secureStorage.write(
          key: AppConstants.accessToken,
          value: newAccessToken,
        );
        return true;
      }
    } catch (e) {
      // Refresh failed
    }
    return false;
  }

  /// Save access token
  Future<void> setAccessToken(String token) async {
    await _secureStorage.write(key: AppConstants.accessToken, value: token);
  }

  /// Save refresh token
  Future<void> setRefreshToken(String token) async {
    await _secureStorage.write(key: AppConstants.refreshToken, value: token);
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: AppConstants.accessToken);
  }

  /// Clear all tokens (logout)
  Future<void> clearTokens() async {
    await _secureStorage.delete(key: AppConstants.accessToken);
    await _secureStorage.delete(key: AppConstants.refreshToken);
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _secureStorage.read(key: AppConstants.accessToken);
    return token != null && token.isNotEmpty;
  }

  // GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get<T>(path,
        queryParameters: queryParameters, options: options);
  }

  // POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post<T>(path,
        data: data, queryParameters: queryParameters, options: options);
  }

  // PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put<T>(path,
        data: data, queryParameters: queryParameters, options: options);
  }

  // DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete<T>(path,
        data: data, queryParameters: queryParameters, options: options);
  }
}
